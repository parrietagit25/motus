<?php
/**
 * Resumen de la solicitud (mismo contenido que el correo a bancos), en HTML para mostrar en pantalla.
 */
session_start();
header('Content-Type: application/json; charset=utf-8');

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'No autorizado']);
    exit;
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/banco_scope_helper.php';
require_once __DIR__ . '/../includes/sp_scope_helper.php';
require_once __DIR__ . '/../includes/email_helper.php';

$solicitudId = (int) ($_GET['solicitud_id'] ?? 0);
if ($solicitudId <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Solicitud no válida']);
    exit;
}

$roles = $_SESSION['user_roles'] ?? [];
if (!is_array($roles)) {
    $roles = [];
}

$esInterno = in_array('ROLE_ADMIN', $roles, true)
    || in_array('ROLE_GESTOR', $roles, true)
    || motus_es_vista_sp($roles);

if (!$esInterno) {
    if (!motus_es_vista_banco($roles) || !motus_solicitud_en_alcance_banco($pdo, $solicitudId, $roles)) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'Acceso denegado']);
        exit;
    }
}

try {
    $datos = obtenerDatosResumenSolicitudBanco($pdo, $solicitudId);
    if ($datos === null) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Solicitud no encontrada']);
        exit;
    }
    $html = construirSeccionesResumenSolicitudHtml(
        $datos['solicitud'],
        $datos['vehiculos'],
        $datos['evaluaciones'],
        $datos['adjuntos']
    );
    echo json_encode(['success' => true, 'html' => $html]);
} catch (Throwable $e) {
    error_log('resumen_solicitud: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'No se pudo cargar el resumen']);
}
