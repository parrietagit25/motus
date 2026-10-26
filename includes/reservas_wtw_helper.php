<?php
/**
 * Pantalla WTW sobre reportes de reservas: solo lectura de reportes/líneas,
 * envío de propuestas por correo y estado de gestión por línea.
 */

const RESERVAS_WTW_ESTADOS = ['No enviado', 'Enviado', 'Aceptado', 'Rechazado'];
const RESERVAS_WTW_MAX_BYTES = 10 * 1024 * 1024;
const RESERVAS_WTW_EXTENSIONES = [
    'pdf' => ['application/pdf'],
    'doc' => ['application/msword', 'application/vnd.ms-office', 'application/octet-stream'],
    'docx' => ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/zip', 'application/octet-stream'],
    'xls' => ['application/vnd.ms-excel', 'application/vnd.ms-office', 'application/octet-stream'],
    'xlsx' => ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/zip', 'application/octet-stream'],
];

function reservas_wtw_puede_acceder(array $roles): bool
{
    return in_array('ROLE_WTW', $roles, true) || in_array('ROLE_ADMIN', $roles, true);
}

function reservas_wtw_csrf_token(): string
{
    if (empty($_SESSION['csrf_reservas_wtw'])) {
        $_SESSION['csrf_reservas_wtw'] = bin2hex(random_bytes(32));
    }
    return (string) $_SESSION['csrf_reservas_wtw'];
}

function reservas_wtw_csrf_valido(?string $token): bool
{
    $esperado = (string) ($_SESSION['csrf_reservas_wtw'] ?? '');
    return $esperado !== '' && is_string($token) && hash_equals($esperado, $token);
}

function reservas_wtw_asegurar_tablas(PDO $pdo): void
{
    static $listo = false;
    if ($listo) {
        return;
    }
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS reservas_wtw_gestion (
            linea_id int NOT NULL,
            estado enum('No enviado','Enviado','Aceptado','Rechazado') NOT NULL DEFAULT 'No enviado',
            actualizado_por int DEFAULT NULL,
            fecha_actualizacion timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (linea_id),
            KEY idx_wtw_gestion_estado (estado)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS reservas_wtw_historial (
            id int NOT NULL AUTO_INCREMENT,
            linea_id int NOT NULL,
            accion enum('envio_propuesta','cambio_estado') NOT NULL,
            estado_anterior varchar(20) DEFAULT NULL,
            estado_nuevo varchar(20) DEFAULT NULL,
            email_destino varchar(255) DEFAULT NULL,
            archivo_nombre varchar(255) DEFAULT NULL,
            archivo_ruta varchar(500) DEFAULT NULL,
            archivo_bytes int unsigned DEFAULT NULL,
            comentario text,
            resultado enum('ok','error') NOT NULL DEFAULT 'ok',
            mensaje varchar(500) DEFAULT NULL,
            usuario_id int NOT NULL,
            created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY idx_wtw_hist_linea (linea_id),
            KEY idx_wtw_hist_fecha (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    $listo = true;
}

/** @return list<array<string, mixed>> */
function reservas_wtw_listar_reportes(PDO $pdo): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $stmt = $pdo->query("
        SELECT r.id, r.nombre_original, r.fecha_subida,
               (SELECT COUNT(*) FROM reportes_reservas_lineas l WHERE l.reporte_id = r.id) AS lineas,
               (SELECT COUNT(*) FROM reportes_reservas_lineas l WHERE l.reporte_id = r.id AND l.solicitud_id IS NOT NULL) AS con_solicitud,
               (SELECT COUNT(*) FROM reportes_reservas_lineas l
                  INNER JOIN reservas_wtw_gestion g ON g.linea_id = l.id
                 WHERE l.reporte_id = r.id AND g.estado <> 'No enviado') AS gestionadas
        FROM reportes_reservas r
        ORDER BY r.fecha_subida DESC
    ");
    return $stmt ? ($stmt->fetchAll(PDO::FETCH_ASSOC) ?: []) : [];
}

/** @return list<array<string, mixed>> */
function reservas_wtw_listar_lineas(PDO $pdo, int $reporteId): array
{
    if ($reporteId <= 0) {
        return [];
    }
    reservas_wtw_asegurar_tablas($pdo);
    $stmt = $pdo->prepare("
        SELECT l.id, l.fila_excel, l.mov_id, l.fecha_emision, l.nombre_sucursal, l.nombre_cliente, l.cedula,
               l.marca, l.modelo, l.anio, l.precio_total, l.solicitud_id, l.match_por,
               COALESCE(g.estado, 'No enviado') AS estado_wtw, g.fecha_actualizacion AS estado_wtw_fecha
        FROM reportes_reservas_lineas l
        LEFT JOIN reservas_wtw_gestion g ON g.linea_id = l.id
        WHERE l.reporte_id = ?
        ORDER BY l.fila_excel ASC
    ");
    $stmt->execute([$reporteId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
}

function reservas_wtw_estado_linea(PDO $pdo, int $lineaId): ?string
{
    $st = $pdo->prepare("
        SELECT COALESCE(g.estado, 'No enviado')
        FROM reportes_reservas_lineas l
        LEFT JOIN reservas_wtw_gestion g ON g.linea_id = l.id
        WHERE l.id = ?
    ");
    $st->execute([$lineaId]);
    $v = $st->fetchColumn();
    return $v === false ? null : (string) $v;
}

/**
 * Detalle completo de la línea: datos del Excel, coincidencia, solicitud (si hay match) e historial.
 *
 * @return array<string, mixed>|null
 */
function reservas_wtw_detalle(PDO $pdo, int $lineaId): ?array
{
    reservas_wtw_asegurar_tablas($pdo);
    $st = $pdo->prepare("
        SELECT l.*, r.nombre_original AS reporte_archivo, COALESCE(g.estado, 'No enviado') AS estado_wtw
        FROM reportes_reservas_lineas l
        LEFT JOIN reportes_reservas r ON r.id = l.reporte_id
        LEFT JOIN reservas_wtw_gestion g ON g.linea_id = l.id
        WHERE l.id = ?
    ");
    $st->execute([$lineaId]);
    $l = $st->fetch(PDO::FETCH_ASSOC);
    if (!$l) {
        return null;
    }

    $excel = [
        'Mov' => $l['mov'], 'Mov ID' => $l['mov_id'], 'Fecha de emisión' => $l['fecha_emision'],
        'Días de reserva' => $l['dias_reserva'], 'Sucursal' => $l['nombre_sucursal'], 'Vendedor' => $l['nombre_vendedor'],
        'Código de cliente' => $l['cliente_codigo'], 'Cliente' => $l['nombre_cliente'], 'Cédula' => $l['cedula'],
        'Correo' => $l['correo_cliente'], 'Marca' => $l['marca'], 'Modelo' => $l['modelo'], 'Año' => $l['anio'],
        'Kilometraje' => $l['kilometraje'], 'Precio total' => $l['precio_total'], 'Abono' => $l['abono_monto'],
        'Abono %' => $l['abono_porcentaje'], 'Unidad' => $l['unidad'], 'Chasis' => $l['chasis'], 'Placas' => $l['placas'],
    ];
    $extra = json_decode((string) ($l['datos_excel_json'] ?? ''), true);
    if (is_array($extra)) {
        foreach ($extra as $k => $v) {
            if (is_scalar($v) || $v === null) {
                $excel[ucfirst(str_replace('_', ' ', (string) $k))] = $v;
            }
        }
    }

    $out = [
        'linea' => [
            'id' => (int) $l['id'],
            'reporte_id' => (int) $l['reporte_id'],
            'reporte_archivo' => $l['reporte_archivo'],
            'fila_excel' => (int) $l['fila_excel'],
            'estado_wtw' => $l['estado_wtw'],
            'match_por' => $l['match_por'],
            'estado_proceso' => $l['estado'],
            'mensaje_proceso' => $l['mensaje'],
            'correo_cliente' => $l['correo_cliente'],
        ],
        'excel' => $excel,
        'solicitud' => null,
        'historial' => [],
    ];

    $sid = (int) ($l['solicitud_id'] ?? 0);
    if ($sid > 0) {
        $s = $pdo->prepare("
            SELECT s.id, s.estado, s.fecha_creacion, s.fecha_actualizacion, s.nombre_cliente, s.cedula,
                   s.telefono, s.email, s.perfil_financiero, s.tipo_persona,
                   CONCAT_WS(' ', u.nombre, u.apellido) AS gestor,
                   ev.nombre AS ejecutivo_ventas, ev.sucursal AS ejecutivo_sucursal,
                   s.evaluacion_seleccionada
            FROM solicitudes_credito s
            LEFT JOIN usuarios u ON u.id = s.gestor_id
            LEFT JOIN ejecutivos_ventas ev ON ev.id = s.ejecutivo_ventas_id
            WHERE s.id = ?
        ");
        $s->execute([$sid]);
        $sol = $s->fetch(PDO::FETCH_ASSOC);
        if ($sol) {
            $v = $pdo->prepare('SELECT marca, modelo, anio, kilometraje, precio, abono_monto, unidad, apartado FROM vehiculos_solicitud WHERE solicitud_id = ? ORDER BY orden, id');
            $v->execute([$sid]);
            $sol['vehiculos'] = $v->fetchAll(PDO::FETCH_ASSOC) ?: [];
            $sol['propuesta_seleccionada'] = null;
            if (!empty($sol['evaluacion_seleccionada'])) {
                $e = $pdo->prepare("
                    SELECT b.nombre AS banco, e.decision, e.valor_financiar, e.plazo, e.letra, e.tasa_bancaria, e.fecha_evaluacion
                    FROM evaluaciones_banco e
                    LEFT JOIN usuarios_banco_solicitudes ubs ON ubs.id = e.usuario_banco_id
                    LEFT JOIN usuarios ub ON ub.id = ubs.usuario_banco_id
                    LEFT JOIN bancos b ON b.id = ub.banco_id
                    WHERE e.id = ?
                ");
                $e->execute([(int) $sol['evaluacion_seleccionada']]);
                $sol['propuesta_seleccionada'] = $e->fetch(PDO::FETCH_ASSOC) ?: null;
            }
            unset($sol['evaluacion_seleccionada']);
            $out['solicitud'] = $sol;
        }
    }

    $h = $pdo->prepare("
        SELECT h.created_at, h.accion, h.estado_anterior, h.estado_nuevo, h.email_destino, h.archivo_nombre,
               h.comentario, h.resultado, h.mensaje, CONCAT_WS(' ', u.nombre, u.apellido) AS usuario
        FROM reservas_wtw_historial h
        LEFT JOIN usuarios u ON u.id = h.usuario_id
        WHERE h.linea_id = ?
        ORDER BY h.id DESC
        LIMIT 50
    ");
    $h->execute([$lineaId]);
    $out['historial'] = $h->fetchAll(PDO::FETCH_ASSOC) ?: [];
    return $out;
}

function reservas_wtw_guardar_estado(PDO $pdo, int $lineaId, string $estado, int $usuarioId): void
{
    $st = $pdo->prepare("
        INSERT INTO reservas_wtw_gestion (linea_id, estado, actualizado_por) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE estado = VALUES(estado), actualizado_por = VALUES(actualizado_por)
    ");
    $st->execute([$lineaId, $estado, $usuarioId]);
}

/** @param array<string, mixed> $datos */
function reservas_wtw_registrar_historial(PDO $pdo, array $datos): void
{
    $st = $pdo->prepare("
        INSERT INTO reservas_wtw_historial
            (linea_id, accion, estado_anterior, estado_nuevo, email_destino, archivo_nombre, archivo_ruta,
             archivo_bytes, comentario, resultado, mensaje, usuario_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $st->execute([
        (int) $datos['linea_id'], (string) $datos['accion'], $datos['estado_anterior'] ?? null, $datos['estado_nuevo'] ?? null,
        $datos['email_destino'] ?? null, $datos['archivo_nombre'] ?? null, $datos['archivo_ruta'] ?? null,
        $datos['archivo_bytes'] ?? null, $datos['comentario'] ?? null, $datos['resultado'] ?? 'ok',
        isset($datos['mensaje']) ? mb_substr((string) $datos['mensaje'], 0, 500) : null, (int) $datos['usuario_id'],
    ]);
}

/** @return array{success: bool, message: string} */
function reservas_wtw_cambiar_estado(PDO $pdo, int $lineaId, string $estado, int $usuarioId, string $comentario = ''): array
{
    reservas_wtw_asegurar_tablas($pdo);
    if (!in_array($estado, RESERVAS_WTW_ESTADOS, true)) {
        return ['success' => false, 'message' => 'Estado no válido'];
    }
    $anterior = reservas_wtw_estado_linea($pdo, $lineaId);
    if ($anterior === null) {
        return ['success' => false, 'message' => 'Registro no encontrado'];
    }
    $pdo->beginTransaction();
    try {
        reservas_wtw_guardar_estado($pdo, $lineaId, $estado, $usuarioId);
        reservas_wtw_registrar_historial($pdo, [
            'linea_id' => $lineaId, 'accion' => 'cambio_estado', 'estado_anterior' => $anterior,
            'estado_nuevo' => $estado, 'comentario' => $comentario !== '' ? mb_substr($comentario, 0, 2000) : null,
            'usuario_id' => $usuarioId,
        ]);
        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        error_log('reservas_wtw_cambiar_estado: ' . $e->getMessage());
        return ['success' => false, 'message' => 'No se pudo guardar el estado'];
    }
    return ['success' => true, 'message' => 'Estado actualizado a «' . $estado . '»'];
}

/**
 * Valida y guarda el adjunto de la propuesta en adjuntos/reservas_wtw/.
 *
 * @param array<string, mixed> $file Entrada de $_FILES
 * @return array{success: bool, message: string, ruta_abs?: string, ruta_rel?: string, nombre?: string, bytes?: int}
 */
function reservas_wtw_guardar_adjunto(array $file): array
{
    $err = (int) ($file['error'] ?? UPLOAD_ERR_NO_FILE);
    if ($err !== UPLOAD_ERR_OK) {
        return ['success' => false, 'message' => $err === UPLOAD_ERR_NO_FILE ? 'Adjunte el documento de la propuesta' : 'No se pudo recibir el archivo (código ' . $err . ')'];
    }
    $size = (int) ($file['size'] ?? 0);
    if ($size <= 0 || $size > RESERVAS_WTW_MAX_BYTES) {
        return ['success' => false, 'message' => 'El archivo debe pesar menos de 10 MB'];
    }
    $nombre = (string) ($file['name'] ?? 'propuesta');
    $ext = strtolower((string) pathinfo($nombre, PATHINFO_EXTENSION));
    if (!isset(RESERVAS_WTW_EXTENSIONES[$ext])) {
        return ['success' => false, 'message' => 'Formato no permitido. Use PDF, Word (.doc/.docx) o Excel (.xls/.xlsx)'];
    }
    $tmp = (string) ($file['tmp_name'] ?? '');
    $mime = '';
    if (function_exists('finfo_open')) {
        $fi = finfo_open(FILEINFO_MIME_TYPE);
        $mime = $fi ? (string) finfo_file($fi, $tmp) : '';
        if ($fi) {
            finfo_close($fi);
        }
    }
    if ($mime !== '' && !in_array($mime, RESERVAS_WTW_EXTENSIONES[$ext], true)) {
        return ['success' => false, 'message' => 'El contenido del archivo no corresponde a su extensión'];
    }
    $dir = dirname(__DIR__) . '/adjuntos/reservas_wtw';
    if (!is_dir($dir) && !@mkdir($dir, 0755, true) && !is_dir($dir)) {
        return ['success' => false, 'message' => 'No se pudo preparar la carpeta de adjuntos'];
    }
    if (!is_file($dir . '/.htaccess')) {
        @file_put_contents($dir . '/.htaccess', "Require all denied\n");
    }
    $guardado = bin2hex(random_bytes(16)) . '.' . $ext;
    $abs = $dir . '/' . $guardado;
    if (!move_uploaded_file($tmp, $abs)) {
        return ['success' => false, 'message' => 'No se pudo guardar el archivo'];
    }
    $limpio = preg_replace('/[^\p{L}\p{N}._ -]+/u', '_', basename($nombre)) ?: ('propuesta.' . $ext);
    return [
        'success' => true, 'message' => 'ok', 'ruta_abs' => $abs,
        'ruta_rel' => 'adjuntos/reservas_wtw/' . $guardado, 'nombre' => mb_substr($limpio, 0, 200), 'bytes' => $size,
    ];
}

/**
 * Envía la propuesta por correo con el adjunto y marca la línea como «Enviado».
 *
 * @param array<string, mixed> $file
 * @return array{success: bool, message: string, estado?: string}
 */
function reservas_wtw_enviar_propuesta(PDO $pdo, int $lineaId, string $email, string $comentario, array $file, int $usuarioId): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $email = trim($email);
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return ['success' => false, 'message' => 'Correo de destino no válido'];
    }
    $st = $pdo->prepare('SELECT id, mov_id, nombre_cliente, marca, modelo, anio FROM reportes_reservas_lineas WHERE id = ?');
    $st->execute([$lineaId]);
    $l = $st->fetch(PDO::FETCH_ASSOC);
    if (!$l) {
        return ['success' => false, 'message' => 'Registro no encontrado'];
    }
    $anterior = reservas_wtw_estado_linea($pdo, $lineaId) ?? 'No enviado';

    $adj = reservas_wtw_guardar_adjunto($file);
    if (!$adj['success']) {
        return ['success' => false, 'message' => $adj['message']];
    }

    $u = $pdo->prepare("SELECT email, CONCAT_WS(' ', nombre, apellido) AS nombre FROM usuarios WHERE id = ?");
    $u->execute([$usuarioId]);
    $remitente = $u->fetch(PDO::FETCH_ASSOC) ?: ['email' => '', 'nombre' => ''];

    $h = static function ($v): string {
        return htmlspecialchars((string) $v, ENT_QUOTES, 'UTF-8');
    };
    $vehiculo = trim(implode(' ', array_filter([(string) $l['marca'], (string) $l['modelo'], (string) $l['anio']])));
    $subject = 'Propuesta - Reserva ' . ($l['mov_id'] !== null && $l['mov_id'] !== '' ? $l['mov_id'] : '#' . $lineaId)
        . ($vehiculo !== '' ? ' - ' . $vehiculo : '');
    $content = '<h2>Propuesta</h2>'
        . '<p>Le compartimos la propuesta adjunta correspondiente a la siguiente reserva:</p>'
        . '<div class="info-box" style="background:#f8f9fa;border-left:4px solid #0d6efd;padding:12px;margin:10px 0;">'
        . '<p><strong>Reserva (Mov ID):</strong> ' . $h($l['mov_id'] ?? '-') . '</p>'
        . ($vehiculo !== '' ? '<p><strong>Vehículo:</strong> ' . $h($vehiculo) . '</p>' : '')
        . '</div>'
        . ($comentario !== '' ? '<p style="white-space:pre-wrap;">' . nl2br($h($comentario)) . '</p>' : '')
        . '<p>Saludos cordiales,<br><strong>' . $h($remitente['nombre'] ?? '') . '</strong></p>';
    $app_name = 'MOTUS - AutoMarket Seminuevos';
    ob_start();
    include __DIR__ . '/../templates/email/base.php';
    $html = ob_get_clean();

    try {
        require_once __DIR__ . '/EmailService.php';
        $mail = new EmailService();
        $replyTo = filter_var((string) ($remitente['email'] ?? ''), FILTER_VALIDATE_EMAIL) ? (string) $remitente['email'] : '';
        $res = $mail->enviarCorreo($email, $subject, $html, '', '', [['path' => $adj['ruta_abs'], 'filename' => $adj['nombre']]], [], [], $replyTo);
    } catch (Throwable $e) {
        error_log('reservas_wtw_enviar_propuesta: ' . $e->getMessage());
        $res = ['success' => false, 'message' => 'El servicio de correo no está disponible'];
    }

    $ok = !empty($res['success']);
    try {
        $pdo->beginTransaction();
        if ($ok) {
            reservas_wtw_guardar_estado($pdo, $lineaId, 'Enviado', $usuarioId);
        }
        reservas_wtw_registrar_historial($pdo, [
            'linea_id' => $lineaId, 'accion' => 'envio_propuesta', 'estado_anterior' => $anterior,
            'estado_nuevo' => $ok ? 'Enviado' : $anterior, 'email_destino' => $email,
            'archivo_nombre' => $adj['nombre'], 'archivo_ruta' => $ok ? $adj['ruta_rel'] : null, 'archivo_bytes' => $adj['bytes'],
            'comentario' => $comentario !== '' ? mb_substr($comentario, 0, 2000) : null,
            'resultado' => $ok ? 'ok' : 'error', 'mensaje' => (string) ($res['message'] ?? ''), 'usuario_id' => $usuarioId,
        ]);
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log('reservas_wtw historial envio: ' . $e->getMessage());
    }
    if (!$ok) {
        @unlink($adj['ruta_abs']);
        return ['success' => false, 'message' => 'No se pudo enviar el correo: ' . (string) ($res['message'] ?? 'error desconocido')];
    }
    return ['success' => true, 'message' => 'Propuesta enviada a ' . $email, 'estado' => 'Enviado'];
}
