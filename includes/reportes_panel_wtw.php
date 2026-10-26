<?php
require_once __DIR__ . '/reservas_wtw_helper.php';
?>
<style>
    #modalRepWtwDetalle .tabla-kv th { width: 38%; background: #f8f9fa; font-weight: 600; }
    #modalRepWtwDetalle .tabla-kv td, #modalRepWtwDetalle .tabla-kv th { font-size: .875rem; }
    #tabla-wtw .nota-corta { max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
</style>
<div id="panel-wtw" class="report-panel">
    <div class="card mb-3">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-md-2">
                    <label class="form-label small mb-0" for="filtroWtwDesde">Última actividad desde</label>
                    <input type="date" id="filtroWtwDesde" class="form-control form-control-sm">
                </div>
                <div class="col-md-2">
                    <label class="form-label small mb-0" for="filtroWtwHasta">Hasta</label>
                    <input type="date" id="filtroWtwHasta" class="form-control form-control-sm">
                </div>
                <div class="col-md-2">
                    <label class="form-label small mb-0" for="filtroWtwEstado">Estado</label>
                    <select id="filtroWtwEstado" class="form-select form-select-sm">
                        <option value="">Todos los estados</option>
                        <?php foreach (RESERVAS_WTW_ESTADOS as $e): ?>
                        <option value="<?php echo htmlspecialchars($e, ENT_QUOTES, 'UTF-8'); ?>"><?php echo htmlspecialchars($e, ENT_QUOTES, 'UTF-8'); ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small mb-0" for="filtroWtwUsuario">Atendido por</label>
                    <select id="filtroWtwUsuario" class="form-select form-select-sm">
                        <option value="">Todos los usuarios</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small mb-0" for="filtroWtwTexto">Buscar</label>
                    <input type="text" id="filtroWtwTexto" class="form-control form-control-sm" placeholder="Cliente, cédula, Mov ID...">
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-primary btn-sm w-100" id="btnFiltrarWtw"><i class="fas fa-filter me-1"></i>Filtrar</button>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-3" id="wtwKpis">
        <?php
        $kpis = [
            'total' => ['Atendidas', 'fa-clipboard-check', 'primary'],
            'Enviado' => ['Enviado', 'fa-paper-plane', 'info'],
            'Aceptado' => ['Aceptado', 'fa-check-circle', 'success'],
            'Rechazado' => ['Rechazado', 'fa-times-circle', 'danger'],
            'No enviado' => ['No enviado', 'fa-pause-circle', 'secondary'],
            'propuestas' => ['Propuestas enviadas', 'fa-envelope', 'dark'],
        ];
        foreach ($kpis as $k => [$label, $icon, $color]): ?>
        <div class="col-6 col-md-4 col-xl-2">
            <div class="card h-100">
                <div class="card-body py-3">
                    <div class="small text-muted"><i class="fas <?php echo $icon; ?> text-<?php echo $color; ?> me-1"></i><?php echo htmlspecialchars($label, ENT_QUOTES, 'UTF-8'); ?></div>
                    <div class="fs-4 fw-bold" data-kpi="<?php echo htmlspecialchars($k, ENT_QUOTES, 'UTF-8'); ?>">–</div>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    </div>

    <div class="card">
        <div class="card-body">
            <h5 class="card-title mb-3">Reservas atendidas <small class="text-muted" id="wtwConteo"></small></h5>
            <div class="table-responsive">
                <table class="table table-bordered table-hover table-reportes" id="tabla-wtw">
                    <thead class="table-light">
                        <tr>
                            <th>Última actividad</th>
                            <th>Reporte</th>
                            <th>Mov ID</th>
                            <th>Cliente</th>
                            <th>Vehículo</th>
                            <th class="text-center">Solicitud</th>
                            <th class="text-center">Estado</th>
                            <th class="text-center">Propuestas</th>
                            <th>Último correo</th>
                            <th class="text-center">Notas</th>
                            <th>Atendido por</th>
                            <th class="text-center">Ver</th>
                        </tr>
                    </thead>
                    <tbody><tr><td colspan="12" class="text-center text-muted">Cargando…</td></tr></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalRepWtwDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header reportes">
                <h5 class="modal-title"><i class="fas fa-file-alt me-2"></i>Detalle de la reserva</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body" id="repWtwDetalleCuerpo"></div>
        </div>
    </div>
</div>
