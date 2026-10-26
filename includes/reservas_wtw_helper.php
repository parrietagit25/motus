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
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS reservas_wtw_notas (
            id int NOT NULL AUTO_INCREMENT,
            linea_id int NOT NULL,
            nota text NOT NULL,
            usuario_id int NOT NULL,
            created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            editado_por int DEFAULT NULL,
            editado_at timestamp NULL DEFAULT NULL,
            eliminado_por int DEFAULT NULL,
            eliminado_at timestamp NULL DEFAULT NULL,
            PRIMARY KEY (id),
            KEY idx_wtw_notas_linea (linea_id, eliminado_at),
            KEY idx_wtw_notas_usuario (usuario_id)
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
               COALESCE(g.estado, 'No enviado') AS estado_wtw, g.fecha_actualizacion AS estado_wtw_fecha,
               (SELECT COUNT(*) FROM reservas_wtw_notas n WHERE n.linea_id = l.id AND n.eliminado_at IS NULL) AS notas
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
    $out['notas'] = reservas_wtw_listar_notas($pdo, $lineaId);
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

/**
 * Notas activas de la línea. puede_modificar: autor de la nota o administrador.
 *
 * @return list<array<string, mixed>>
 */
function reservas_wtw_listar_notas(PDO $pdo, int $lineaId, int $usuarioId = 0, bool $esAdmin = false): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $st = $pdo->prepare("
        SELECT n.id, n.nota, n.usuario_id, n.created_at, n.editado_at,
               CONCAT_WS(' ', u.nombre, u.apellido) AS autor, CONCAT_WS(' ', e.nombre, e.apellido) AS editor
        FROM reservas_wtw_notas n
        LEFT JOIN usuarios u ON u.id = n.usuario_id
        LEFT JOIN usuarios e ON e.id = n.editado_por
        WHERE n.linea_id = ? AND n.eliminado_at IS NULL
        ORDER BY n.id DESC
    ");
    $st->execute([$lineaId]);
    $notas = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
    foreach ($notas as &$n) {
        $n['puede_modificar'] = $esAdmin || ($usuarioId > 0 && (int) $n['usuario_id'] === $usuarioId);
        unset($n['usuario_id']);
    }
    unset($n);
    return $notas;
}

function reservas_wtw_nota_limpia(string $nota): ?string
{
    $nota = trim(str_replace("\r\n", "\n", $nota));
    if ($nota === '' || mb_strlen($nota) > 2000) {
        return null;
    }
    return $nota;
}

/** @return array{success: bool, message: string} */
function reservas_wtw_crear_nota(PDO $pdo, int $lineaId, string $nota, int $usuarioId): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $texto = reservas_wtw_nota_limpia($nota);
    if ($texto === null) {
        return ['success' => false, 'message' => 'Escriba la nota (máximo 2000 caracteres)'];
    }
    if (reservas_wtw_estado_linea($pdo, $lineaId) === null) {
        return ['success' => false, 'message' => 'Registro no encontrado'];
    }
    $st = $pdo->prepare('INSERT INTO reservas_wtw_notas (linea_id, nota, usuario_id) VALUES (?, ?, ?)');
    $st->execute([$lineaId, $texto, $usuarioId]);
    return ['success' => true, 'message' => 'Nota agregada'];
}

/**
 * Valida que la nota exista, pertenezca a la línea, siga activa y que el usuario pueda modificarla.
 *
 * @return array{success: bool, message: string}
 */
function reservas_wtw_validar_nota(PDO $pdo, int $notaId, int $lineaId, int $usuarioId, bool $esAdmin): array
{
    $st = $pdo->prepare('SELECT linea_id, usuario_id FROM reservas_wtw_notas WHERE id = ? AND eliminado_at IS NULL');
    $st->execute([$notaId]);
    $n = $st->fetch(PDO::FETCH_ASSOC);
    if (!$n || (int) $n['linea_id'] !== $lineaId) {
        return ['success' => false, 'message' => 'Nota no encontrada'];
    }
    if (!$esAdmin && (int) $n['usuario_id'] !== $usuarioId) {
        return ['success' => false, 'message' => 'Solo el autor de la nota puede modificarla'];
    }
    return ['success' => true, 'message' => 'ok'];
}

/** @return array{success: bool, message: string} */
function reservas_wtw_editar_nota(PDO $pdo, int $notaId, int $lineaId, string $nota, int $usuarioId, bool $esAdmin): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $texto = reservas_wtw_nota_limpia($nota);
    if ($texto === null) {
        return ['success' => false, 'message' => 'Escriba la nota (máximo 2000 caracteres)'];
    }
    $v = reservas_wtw_validar_nota($pdo, $notaId, $lineaId, $usuarioId, $esAdmin);
    if (!$v['success']) {
        return $v;
    }
    $st = $pdo->prepare('UPDATE reservas_wtw_notas SET nota = ?, editado_por = ?, editado_at = NOW() WHERE id = ? AND eliminado_at IS NULL');
    $st->execute([$texto, $usuarioId, $notaId]);
    return ['success' => true, 'message' => 'Nota actualizada'];
}

/** @return array{success: bool, message: string} */
function reservas_wtw_eliminar_nota(PDO $pdo, int $notaId, int $lineaId, int $usuarioId, bool $esAdmin): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $v = reservas_wtw_validar_nota($pdo, $notaId, $lineaId, $usuarioId, $esAdmin);
    if (!$v['success']) {
        return $v;
    }
    $st = $pdo->prepare('UPDATE reservas_wtw_notas SET eliminado_por = ?, eliminado_at = NOW() WHERE id = ? AND eliminado_at IS NULL');
    $st->execute([$usuarioId, $notaId]);
    return ['success' => true, 'message' => 'Nota eliminada'];
}

/**
 * Actividad registrada desde la pantalla WTW: cambios de estado y envíos exitosos, y notas activas.
 */
function reservas_wtw_sql_actividad(): string
{
    return "
        SELECT linea_id, usuario_id, created_at AS fecha FROM reservas_wtw_historial WHERE resultado = 'ok'
        UNION ALL
        SELECT linea_id, usuario_id, created_at FROM reservas_wtw_notas WHERE eliminado_at IS NULL
        UNION ALL
        SELECT linea_id, editado_por, editado_at FROM reservas_wtw_notas WHERE eliminado_at IS NULL AND editado_at IS NOT NULL
    ";
}

/**
 * @param array<string, mixed> $q Parámetros GET
 * @return array{desde: string, hasta: string, estado: string, usuario_id: int, texto: string}
 */
function reservas_wtw_reporte_filtros(array $q): array
{
    $fecha = static function ($v): string {
        $v = trim((string) $v);
        $d = DateTime::createFromFormat('Y-m-d', $v);
        return ($d && $d->format('Y-m-d') === $v) ? $v : '';
    };
    $estado = (string) ($q['estado'] ?? '');
    return [
        'desde' => $fecha($q['desde'] ?? ''),
        'hasta' => $fecha($q['hasta'] ?? ''),
        'estado' => in_array($estado, RESERVAS_WTW_ESTADOS, true) ? $estado : '',
        'usuario_id' => max(0, (int) ($q['usuario_id'] ?? 0)),
        'texto' => mb_substr(trim((string) ($q['texto'] ?? '')), 0, 100),
    ];
}

/**
 * Registros atendidos (con al menos una acción o nota) desde la pantalla WTW.
 *
 * @param array{desde: string, hasta: string, estado: string, usuario_id: int, texto: string} $f
 * @return list<array<string, mixed>>
 */
function reservas_wtw_reporte(PDO $pdo, array $f): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $act = reservas_wtw_sql_actividad();
    $where = [];
    $params = [];
    if ($f['desde'] !== '') {
        $where[] = 'a.ultima >= ?';
        $params[] = $f['desde'] . ' 00:00:00';
    }
    if ($f['hasta'] !== '') {
        $where[] = 'a.ultima < DATE_ADD(?, INTERVAL 1 DAY)';
        $params[] = $f['hasta'];
    }
    if ($f['estado'] !== '') {
        $where[] = "COALESCE(g.estado, 'No enviado') = ?";
        $params[] = $f['estado'];
    }
    if ($f['usuario_id'] > 0) {
        $where[] = 'EXISTS (SELECT 1 FROM act x WHERE x.linea_id = l.id AND x.usuario_id = ?)';
        $params[] = $f['usuario_id'];
    }
    if ($f['texto'] !== '') {
        $where[] = '(l.nombre_cliente LIKE ? OR l.cedula LIKE ? OR l.mov_id LIKE ?)';
        $like = '%' . addcslashes($f['texto'], '%_\\') . '%';
        array_push($params, $like, $like, $like);
    }
    $sql = "
        WITH act AS ($act),
        a AS (SELECT linea_id, MIN(fecha) AS primera, MAX(fecha) AS ultima FROM act GROUP BY linea_id),
        p AS (
            SELECT x.linea_id, GROUP_CONCAT(DISTINCT CONCAT_WS(' ', u.nombre, u.apellido) ORDER BY u.nombre SEPARATOR ', ') AS atendido_por
            FROM act x LEFT JOIN usuarios u ON u.id = x.usuario_id
            GROUP BY x.linea_id
        ),
        h AS (
            SELECT linea_id, SUM(accion = 'envio_propuesta') AS propuestas, SUM(accion = 'cambio_estado') AS cambios
            FROM reservas_wtw_historial WHERE resultado = 'ok' GROUP BY linea_id
        ),
        n AS (SELECT linea_id, COUNT(*) AS notas FROM reservas_wtw_notas WHERE eliminado_at IS NULL GROUP BY linea_id)
        SELECT l.id AS linea_id, l.reporte_id, r.nombre_original AS reporte_archivo, l.mov_id, l.fecha_emision,
               l.nombre_sucursal, l.nombre_cliente, l.cedula, l.marca, l.modelo, l.anio, l.precio_total, l.solicitud_id,
               COALESCE(g.estado, 'No enviado') AS estado_wtw, a.primera, a.ultima,
               COALESCE(h.propuestas, 0) AS propuestas_enviadas, COALESCE(h.cambios, 0) AS cambios_estado,
               (SELECT h2.email_destino FROM reservas_wtw_historial h2
                 WHERE h2.linea_id = l.id AND h2.accion = 'envio_propuesta' AND h2.resultado = 'ok'
                 ORDER BY h2.id DESC LIMIT 1) AS ultimo_correo,
               COALESCE(n.notas, 0) AS notas,
               (SELECT n2.nota FROM reservas_wtw_notas n2 WHERE n2.linea_id = l.id AND n2.eliminado_at IS NULL
                 ORDER BY n2.id DESC LIMIT 1) AS ultima_nota,
               p.atendido_por
        FROM a
        INNER JOIN reportes_reservas_lineas l ON l.id = a.linea_id
        LEFT JOIN reportes_reservas r ON r.id = l.reporte_id
        LEFT JOIN reservas_wtw_gestion g ON g.linea_id = l.id
        LEFT JOIN h ON h.linea_id = l.id
        LEFT JOIN n ON n.linea_id = l.id
        LEFT JOIN p ON p.linea_id = l.id
        " . ($where ? 'WHERE ' . implode(' AND ', $where) : '') . "
        ORDER BY a.ultima DESC
    ";
    $st = $pdo->prepare($sql);
    $st->execute($params);
    $rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
    foreach ($rows as &$r) {
        foreach (['linea_id', 'reporte_id', 'propuestas_enviadas', 'cambios_estado', 'notas'] as $k) {
            $r[$k] = (int) $r[$k];
        }
    }
    unset($r);
    return $rows;
}

/** @return list<array{id: int, nombre: string}> Usuarios con actividad en la pantalla WTW. */
function reservas_wtw_reporte_usuarios(PDO $pdo): array
{
    reservas_wtw_asegurar_tablas($pdo);
    $act = reservas_wtw_sql_actividad();
    $rows = $pdo->query("
        WITH act AS ($act)
        SELECT u.id, CONCAT_WS(' ', u.nombre, u.apellido) AS nombre
        FROM usuarios u
        WHERE u.id IN (SELECT usuario_id FROM act)
        ORDER BY u.nombre, u.apellido
    ")->fetchAll(PDO::FETCH_ASSOC) ?: [];
    return array_map(static fn ($r) => ['id' => (int) $r['id'], 'nombre' => (string) $r['nombre']], $rows);
}
