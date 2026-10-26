(function () {
    'use strict';

    var R = window.ReservasWtwRender;
    var esc = R.esc;
    var usuariosCargados = false;

    function filtrosQuery() {
        var p = new URLSearchParams();
        [['desde', 'filtroWtwDesde'], ['hasta', 'filtroWtwHasta'], ['estado', 'filtroWtwEstado'],
            ['usuario_id', 'filtroWtwUsuario'], ['texto', 'filtroWtwTexto']].forEach(function (par) {
            var v = (document.getElementById(par[1]).value || '').trim();
            if (v) p.set(par[0], v);
        });
        var qs = p.toString();
        return qs ? '&' + qs : '';
    }

    function pintarUsuarios(usuarios) {
        if (usuariosCargados) return;
        var sel = document.getElementById('filtroWtwUsuario');
        (usuarios || []).forEach(function (u) {
            var o = document.createElement('option');
            o.value = u.id;
            o.textContent = u.nombre;
            sel.appendChild(o);
        });
        usuariosCargados = true;
    }

    function pintarKpis(resumen) {
        document.querySelectorAll('#wtwKpis [data-kpi]').forEach(function (el) {
            var v = resumen ? resumen[el.getAttribute('data-kpi')] : null;
            el.textContent = (v === undefined || v === null) ? '0' : Number(v).toLocaleString('es-PA');
        });
    }

    function fila(r) {
        var sol = r.solicitud_id ? '<span class="badge bg-success">#' + esc(r.solicitud_id) + '</span>' : '<span class="text-muted small">—</span>';
        var notas = r.notas > 0
            ? '<span class="badge bg-warning text-dark">' + esc(r.notas) + '</span>'
                + (r.ultima_nota ? '<div class="small text-muted nota-corta" title="' + esc(r.ultima_nota) + '">' + esc(r.ultima_nota) + '</div>' : '')
            : '<span class="text-muted">0</span>';
        return '<tr>'
            + '<td class="text-nowrap">' + esc(r.ultima) + '</td>'
            + '<td>#' + esc(r.reporte_id) + ' <small class="text-muted">' + esc(r.reporte_archivo) + '</small></td>'
            + '<td>' + esc(r.mov_id) + '</td>'
            + '<td>' + esc(r.nombre_cliente) + '<div class="small text-muted">' + esc(r.cedula) + '</div></td>'
            + '<td>' + esc(R.vehiculoTexto(r)) + '</td>'
            + '<td class="text-center">' + sol + '</td>'
            + '<td class="text-center">' + R.badgeEstado(r.estado_wtw) + '</td>'
            + '<td class="text-center">' + esc(r.propuestas_enviadas) + '</td>'
            + '<td class="small">' + esc(r.ultimo_correo || '—') + '</td>'
            + '<td class="text-center">' + notas + '</td>'
            + '<td class="small">' + esc(r.atendido_por) + '</td>'
            + '<td class="text-center"><button type="button" class="btn btn-sm btn-outline-primary btn-rep-wtw-ver" data-linea-id="' + esc(r.linea_id) + '" title="Ver detalle"><i class="fas fa-eye"></i></button></td>'
            + '</tr>';
    }

    function cargar() {
        var qs = filtrosQuery();
        var ex = document.getElementById('btnExportReporteActual');
        if (ex) ex.href = 'api/reportes.php?action=exportar_excel_wtw' + qs;
        var tbody = document.querySelector('#tabla-wtw tbody');
        tbody.innerHTML = '<tr><td colspan="12" class="text-center text-muted">Cargando…</td></tr>';
        fetch('api/reportes.php?action=reporte_wtw' + qs, { credentials: 'same-origin' })
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (!res.success) {
                    tbody.innerHTML = '<tr><td colspan="12" class="text-center text-danger">' + esc(res.message || 'Error al cargar el reporte') + '</td></tr>';
                    pintarKpis(null);
                    return;
                }
                pintarUsuarios(res.usuarios);
                pintarKpis(res.resumen);
                var filas = res.data || [];
                document.getElementById('wtwConteo').textContent = '(' + filas.length + ')';
                tbody.innerHTML = filas.length
                    ? filas.map(fila).join('')
                    : '<tr><td colspan="12" class="text-center text-muted">No hay reservas atendidas con estos filtros.</td></tr>';
            })
            .catch(function () {
                tbody.innerHTML = '<tr><td colspan="12" class="text-center text-danger">Error de conexión</td></tr>';
            });
    }

    function verDetalle(lineaId) {
        var cuerpo = document.getElementById('repWtwDetalleCuerpo');
        cuerpo.innerHTML = '<span class="text-muted">Cargando…</span>';
        bootstrap.Modal.getOrCreateInstance(document.getElementById('modalRepWtwDetalle')).show();
        fetch('api/reportes.php?action=reporte_wtw_detalle&linea_id=' + encodeURIComponent(lineaId), { credentials: 'same-origin' })
            .then(function (r) { return r.json(); })
            .then(function (res) {
                cuerpo.innerHTML = res.success
                    ? R.detalle(res.data)
                    : '<div class="alert alert-danger mb-0">' + esc(res.message || 'Error') + '</div>';
            })
            .catch(function () {
                cuerpo.innerHTML = '<div class="alert alert-danger mb-0">Error de conexión</div>';
            });
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.getElementById('btnFiltrarWtw').addEventListener('click', cargar);
        document.getElementById('filtroWtwTexto').addEventListener('keydown', function (ev) {
            if (ev.key === 'Enter') {
                ev.preventDefault();
                cargar();
            }
        });
        document.getElementById('tabla-wtw').addEventListener('click', function (ev) {
            var btn = ev.target.closest('.btn-rep-wtw-ver');
            if (btn) verDetalle(btn.getAttribute('data-linea-id'));
        });
        cargar();
    });
})();
