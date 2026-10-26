<?php
/**
 * API de la pantalla WTW de reservas (ROLE_WTW / ROLE_ADMIN).
 * GET  ?action=lineas&reporte_id=N | ?action=detalle&linea_id=N
 * POST action=enviar_propuesta (multipart) | action=cambiar_estado   — requieren csrf_token
 */
session_start();
header('Content-Type: application/json; charset=utf-8');

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'No autorizado']);
    exit;
}

require_once __DIR__ . '/../includes/reservas_wtw_helper.php';

$roles = $_SESSION['user_roles'] ?? [];
if (!is_array($roles) || !reservas_wtw_puede_acceder($roles)) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Acceso denegado']);
    exit;
}

require_once __DIR__ . '/../config/database.php';
if (!isset($pdo) || !($pdo instanceof PDO)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Base de datos no disponible']);
    exit;
}

$usuarioId = (int) $_SESSION['user_id'];
$metodo = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$action = (string) ($metodo === 'POST' ? ($_POST['action'] ?? '') : ($_GET['action'] ?? ''));

try {
    if ($metodo === 'GET' && $action === 'lineas') {
        echo json_encode(['success' => true, 'data' => reservas_wtw_listar_lineas($pdo, (int) ($_GET['reporte_id'] ?? 0))]);
        exit;
    }
    if ($metodo === 'GET' && $action === 'detalle') {
        $det = reservas_wtw_detalle($pdo, (int) ($_GET['linea_id'] ?? 0));
        if ($det === null) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Registro no encontrado']);
            exit;
        }
        echo json_encode(['success' => true, 'data' => $det]);
        exit;
    }

    if ($metodo !== 'POST') {
        http_response_code(405);
        echo json_encode(['success' => false, 'message' => 'Método no permitido']);
        exit;
    }
    if (!reservas_wtw_csrf_valido($_POST['csrf_token'] ?? null)) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'La sesión expiró. Recargue la página.']);
        exit;
    }
    $lineaId = (int) ($_POST['linea_id'] ?? 0);
    $comentario = trim((string) ($_POST['comentario'] ?? ''));

    if ($action === 'enviar_propuesta') {
        $res = reservas_wtw_enviar_propuesta($pdo, $lineaId, (string) ($_POST['email'] ?? ''), $comentario, $_FILES['archivo'] ?? [], $usuarioId);
    } elseif ($action === 'cambiar_estado') {
        $res = reservas_wtw_cambiar_estado($pdo, $lineaId, (string) ($_POST['estado'] ?? ''), $usuarioId, $comentario);
        if ($res['success']) {
            $res['estado'] = (string) $_POST['estado'];
        }
    } else {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Acción no válida']);
        exit;
    }
    if (!$res['success']) {
        http_response_code(422);
    }
    echo json_encode($res);
} catch (Throwable $e) {
    error_log('api/reservas_wtw: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error interno']);
}
