<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit();
}

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/includes/validar_acceso.php';
require_once __DIR__ . '/includes/reservas_wtw_helper.php';

$userRoles = $_SESSION['user_roles'] ?? [];
if (!reservas_wtw_puede_acceder($userRoles)) {
    header('Location: dashboard.php');
    exit();
}

$reportes = reservas_wtw_listar_reportes($pdo);
$csrf = reservas_wtw_csrf_token();

function h($s): string
{
    return htmlspecialchars((string) $s, ENT_QUOTES, 'UTF-8');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes de Reservas - MOTUS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <style>
        .sidebar { min-height: 100vh; background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%); }
        .sidebar .nav-link { color: #ecf0f1; padding: 12px 20px; border-radius: 8px; margin: 5px 10px; transition: all 0.3s ease; }
        .sidebar .nav-link:hover { background: rgba(255,255,255,0.1); color: #fff; transform: translateX(5px); }
        .sidebar .nav-link.active { background: #3498db; color: #fff; }
        .main-content { background: #f8f9fa; min-height: 100vh; }
        .card { border: none; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.08); }
        .tabla-kv th { width: 38%; background: #f8f9fa; font-weight: 600; }
        .tabla-kv td, .tabla-kv th { font-size: .875rem; }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <?php include __DIR__ . '/includes/sidebar.php'; ?>
        <div class="col-md-9 col-lg-10 main-content">
            <div class="container-fluid py-4">
                <div class="mb-4">
                    <h2 class="mb-1">Reportes de Reservas</h2>
                    <p class="text-muted mb-0">Consulte los reportes cargados, revise el detalle de cada reserva y gestione las propuestas.</p>
                </div>

                <div id="wtwAlerta" class="alert d-none" role="alert"></div>

                <div class="card">
                    <div class="card-header bg-white border-0 pt-3">
                        <h5 class="mb-0"><i class="fas fa-history me-2 text-secondary"></i>Reportes cargados</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table id="tablaWtwReportes" class="table table-striped table-hover w-100">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Archivo</th>
                                        <th>Registros</th>
                                        <th>Con solicitud</th>
                                        <th>Gestionados</th>
                                        <th>Fecha</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <?php foreach ($reportes as $r): ?>
                                    <tr>
                                        <td data-order="<?php echo (int) $r['id']; ?>"><?php echo (int) $r['id']; ?></td>
                                        <td><?php echo h($r['nombre_original'] ?? ''); ?></td>
                                        <td><?php echo (int) $r['lineas']; ?></td>
                                        <td><?php echo (int) $r['con_solicitud']; ?></td>
                                        <td><?php echo (int) $r['gestionadas']; ?></td>
                                        <td><?php echo h($r['fecha_subida'] ?? ''); ?></td>
                                        <td class="text-nowrap">
                                            <button type="button" class="btn btn-sm btn-outline-info btn-wtw-ver-reporte"
                                                    data-reporte-id="<?php echo (int) $r['id']; ?>"
                                                    data-reporte-nombre="<?php echo h($r['nombre_original'] ?? ''); ?>"
                                                    title="Ver detalle">
                                                <i class="fas fa-list"></i>
                                            </button>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="card mt-4 d-none" id="cardWtwLineas">
                    <div class="card-header bg-white border-0 pt-3 d-flex justify-content-between align-items-center">
                        <h5 class="mb-0" id="wtwTituloLineas">Detalle del reporte</h5>
                        <button type="button" class="btn-close" id="btnCerrarLineas" aria-label="Cerrar"></button>
                    </div>
                    <div class="card-body table-responsive">
                        <table id="tablaWtwLineas" class="table table-sm table-striped w-100">
                            <thead>
                                <tr>
                                    <th>Fila</th><th>Mov ID</th><th>Cliente</th><th>Cédula</th><th>Vehículo</th>
                                    <th>Total</th><th>Solicitud</th><th>Estado</th><th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal detalle -->
<div class="modal fade" id="modalWtwDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-file-alt me-2"></i>Detalle de la reserva</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body" id="wtwDetalleCuerpo"><span class="text-muted">Cargando…</span></div>
        </div>
    </div>
</div>

<!-- Modal enviar propuesta -->
<div class="modal fade" id="modalWtwEnviar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form class="modal-content" id="formWtwEnviar" enctype="multipart/form-data" novalidate>
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-paper-plane me-2"></i>Enviar propuesta</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="action" value="enviar_propuesta">
                <input type="hidden" name="csrf_token" value="<?php echo h($csrf); ?>">
                <input type="hidden" name="linea_id" id="wtwEnviarLinea">
                <p class="small text-muted mb-3" id="wtwEnviarResumen"></p>
                <div class="mb-3">
                    <label for="wtwEnviarArchivo" class="form-label">Documento de la propuesta *</label>
                    <input type="file" class="form-control" id="wtwEnviarArchivo" name="archivo" required
                           accept=".pdf,.doc,.docx,.xls,.xlsx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
                    <div class="form-text">PDF, Word o Excel. Máximo 10 MB.</div>
                </div>
                <div class="mb-3">
                    <label for="wtwEnviarEmail" class="form-label">Correo de destino *</label>
                    <input type="email" class="form-control" id="wtwEnviarEmail" name="email" required maxlength="255" placeholder="cliente@correo.com">
                </div>
                <div class="mb-0">
                    <label for="wtwEnviarComentario" class="form-label">Mensaje (opcional)</label>
                    <textarea class="form-control" id="wtwEnviarComentario" name="comentario" rows="3" maxlength="2000"></textarea>
                </div>
                <div class="alert alert-danger small mt-3 mb-0 d-none" id="wtwEnviarError"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnWtwEnviar"><i class="fas fa-paper-plane me-1"></i>Enviar</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal cambiar estado -->
<div class="modal fade" id="modalWtwEstado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form class="modal-content" id="formWtwEstado" novalidate>
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-exchange-alt me-2"></i>Cambiar estado</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="action" value="cambiar_estado">
                <input type="hidden" name="csrf_token" value="<?php echo h($csrf); ?>">
                <input type="hidden" name="linea_id" id="wtwEstadoLinea">
                <p class="small text-muted mb-3" id="wtwEstadoResumen"></p>
                <div class="mb-3">
                    <label for="wtwEstadoValor" class="form-label">Estado *</label>
                    <select class="form-select" id="wtwEstadoValor" name="estado" required>
                        <?php foreach (RESERVAS_WTW_ESTADOS as $e): ?>
                        <option value="<?php echo h($e); ?>"><?php echo h($e); ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="mb-0">
                    <label for="wtwEstadoComentario" class="form-label">Comentario (opcional)</label>
                    <textarea class="form-control" id="wtwEstadoComentario" name="comentario" rows="2" maxlength="2000"></textarea>
                </div>
                <div class="alert alert-danger small mt-3 mb-0 d-none" id="wtwEstadoError"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnWtwEstado"><i class="fas fa-save me-1"></i>Guardar</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal notas -->
<div class="modal fade" id="modalWtwNotas" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-sticky-note me-2"></i>Notas</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <p class="small text-muted mb-3" id="wtwNotasResumen"></p>
                <div id="wtwNotasLista" class="mb-3"></div>
                <form id="formWtwNota" class="border-top pt-3" novalidate>
                    <input type="hidden" name="action" id="wtwNotaAccion" value="nota_crear">
                    <input type="hidden" name="csrf_token" value="<?php echo h($csrf); ?>">
                    <input type="hidden" name="linea_id" id="wtwNotaLinea">
                    <input type="hidden" name="nota_id" id="wtwNotaId">
                    <label for="wtwNotaTexto" class="form-label" id="wtwNotaEtiqueta">Nueva nota</label>
                    <textarea class="form-control" id="wtwNotaTexto" name="nota" rows="3" maxlength="2000" required></textarea>
                    <div class="alert alert-danger small mt-2 mb-0 d-none" id="wtwNotaError"></div>
                    <div class="d-flex justify-content-end gap-2 mt-2">
                        <button type="button" class="btn btn-outline-secondary d-none" id="btnWtwNotaCancelar">Cancelar edición</button>
                        <button type="submit" class="btn btn-warning" id="btnWtwNotaGuardar"><i class="fas fa-plus me-1"></i>Agregar nota</button>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script src="js/reservas_wtw_render.js?v=<?php echo file_exists(__DIR__ . '/js/reservas_wtw_render.js') ? filemtime(__DIR__ . '/js/reservas_wtw_render.js') : time(); ?>"></script>
<script src="js/reservas_wtw.js?v=<?php echo file_exists(__DIR__ . '/js/reservas_wtw.js') ? filemtime(__DIR__ . '/js/reservas_wtw.js') : time(); ?>"></script>
</body>
</html>
