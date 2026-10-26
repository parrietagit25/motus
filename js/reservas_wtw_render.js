/* Dibujo compartido del detalle de reservas WTW (reservas_wtw.php y reportes.php?submenu=wtw). */
window.ReservasWtwRender = (function () {
    'use strict';

    var BADGE = { 'No enviado': 'bg-secondary', 'Enviado': 'bg-primary', 'Aceptado': 'bg-success', 'Rechazado': 'bg-danger' };

    function esc(v) {
        return String(v === null || v === undefined ? '' : v)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

    function vacio(v) {
        return v === null || v === undefined || String(v).trim() === '';
    }

    function monto(v) {
        if (vacio(v) || isNaN(Number(v))) return vacio(v) ? '' : String(v);
        return '$' + Number(v).toLocaleString('es-PA', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function dinero(v) {
        return esc(monto(v));
    }

    function badgeEstado(estado) {
        return '<span class="badge ' + (BADGE[estado] || 'bg-secondary') + '">' + esc(estado) + '</span>';
    }

    function vehiculoTexto(l) {
        return [l.marca, l.modelo, l.anio].filter(function (x) { return !vacio(x); }).join(' ');
    }

    function tablaKV(obj) {
        var filas = Object.keys(obj).filter(function (k) { return !vacio(obj[k]); }).map(function (k) {
            return '<tr><th>' + esc(k) + '</th><td>' + esc(obj[k]) + '</td></tr>';
        });
        if (!filas.length) return '<p class="text-muted small mb-0">Sin datos.</p>';
        return '<table class="table table-sm table-bordered tabla-kv mb-0"><tbody>' + filas.join('') + '</tbody></table>';
    }

    function seccionSolicitud(s) {
        if (!s) {
            return '<div class="alert alert-light border small mb-0"><i class="fas fa-info-circle me-1"></i>Este registro no tiene coincidencia con una solicitud de crédito.</div>';
        }
        var html = tablaKV({
            'Solicitud': '#' + s.id,
            'Estado': s.estado,
            'Fecha de creación': s.fecha_creacion,
            'Última actualización': s.fecha_actualizacion,
            'Cliente': s.nombre_cliente,
            'Cédula': s.cedula,
            'Teléfono': s.telefono,
            'Correo': s.email,
            'Tipo de persona': s.tipo_persona,
            'Perfil financiero': s.perfil_financiero,
            'Gestor': s.gestor,
            'Ejecutivo de ventas': s.ejecutivo_ventas,
            'Sucursal del ejecutivo': s.ejecutivo_sucursal
        });
        if (s.vehiculos && s.vehiculos.length) {
            html += '<h6 class="mt-3">Vehículos de la solicitud</h6><div class="table-responsive"><table class="table table-sm table-bordered mb-0">'
                + '<thead class="table-light"><tr><th>Marca</th><th>Modelo</th><th>Año</th><th>Km</th><th>Precio</th><th>Abono</th><th>Unidad</th></tr></thead><tbody>'
                + s.vehiculos.map(function (v) {
                    return '<tr><td>' + esc(v.marca) + '</td><td>' + esc(v.modelo) + '</td><td>' + esc(v.anio) + '</td><td>' + esc(v.kilometraje)
                        + '</td><td>' + dinero(v.precio) + '</td><td>' + dinero(v.abono_monto) + '</td><td>' + esc(v.unidad) + '</td></tr>';
                }).join('') + '</tbody></table></div>';
        }
        if (s.propuesta_seleccionada) {
            var p = s.propuesta_seleccionada;
            html += '<h6 class="mt-3">Propuesta bancaria seleccionada</h6>' + tablaKV({
                'Banco': p.banco,
                'Decisión': p.decision,
                'Valor a financiar': monto(p.valor_financiar),
                'Plazo (meses)': p.plazo,
                'Letra': monto(p.letra),
                'Tasa': vacio(p.tasa_bancaria) ? '' : p.tasa_bancaria + '%',
                'Fecha de evaluación': p.fecha_evaluacion
            });
        }
        return html;
    }

    function seccionHistorial(hist) {
        if (!hist || !hist.length) return '<p class="text-muted small mb-0">Sin movimientos registrados.</p>';
        return '<div class="table-responsive"><table class="table table-sm table-striped mb-0"><thead class="table-light"><tr>'
            + '<th>Fecha</th><th>Acción</th><th>Estado</th><th>Detalle</th><th>Usuario</th></tr></thead><tbody>'
            + hist.map(function (h) {
                var accion = h.accion === 'envio_propuesta' ? 'Envío de propuesta' : 'Cambio de estado';
                var detalle = [];
                if (h.email_destino) detalle.push('A: ' + esc(h.email_destino));
                if (h.archivo_nombre) detalle.push('Archivo: ' + esc(h.archivo_nombre));
                if (h.comentario) detalle.push(esc(h.comentario));
                if (h.resultado === 'error') detalle.push('<span class="text-danger">' + esc(h.mensaje || 'Error') + '</span>');
                var estado = (h.estado_anterior && h.estado_anterior !== h.estado_nuevo ? esc(h.estado_anterior) + ' → ' : '') + esc(h.estado_nuevo);
                return '<tr><td class="text-nowrap">' + esc(h.created_at) + '</td><td>' + accion
                    + (h.resultado === 'error' ? ' <span class="badge bg-danger">fallido</span>' : '')
                    + '</td><td>' + estado + '</td><td class="small">' + detalle.join('<br>') + '</td><td>' + esc(h.usuario) + '</td></tr>';
            }).join('') + '</tbody></table></div>';
    }

    /** Lista de notas; con acciones=true agrega botones de editar/eliminar en las notas que el usuario puede modificar. */
    function seccionNotas(notas, acciones) {
        if (!notas || !notas.length) return '<p class="text-muted small mb-0">Sin notas registradas.</p>';
        return '<div class="list-group">' + notas.map(function (n) {
            var editado = n.editado_at ? ' · editada ' + esc(n.editado_at) + (n.editor && n.editor !== n.autor ? ' por ' + esc(n.editor) : '') : '';
            var botones = (acciones && n.puede_modificar)
                ? '<div class="btn-group btn-group-sm ms-2">'
                    + '<button type="button" class="btn btn-outline-secondary btn-wtw-nota-editar" data-nota-id="' + esc(n.id) + '" title="Editar"><i class="fas fa-pen"></i></button>'
                    + '<button type="button" class="btn btn-outline-danger btn-wtw-nota-eliminar" data-nota-id="' + esc(n.id) + '" title="Eliminar"><i class="fas fa-trash"></i></button>'
                    + '</div>'
                : '';
            return '<div class="list-group-item" data-nota-id="' + esc(n.id) + '">'
                + '<div class="d-flex justify-content-between align-items-start">'
                + '<div class="small text-muted"><strong>' + esc(n.autor) + '</strong> · ' + esc(n.created_at) + editado + '</div>' + botones
                + '</div>'
                + '<div class="mt-1" style="white-space:pre-wrap;">' + esc(n.nota) + '</div>'
                + '</div>';
        }).join('') + '</div>';
    }

    function detalle(d) {
        var excel = Object.assign({}, d.excel);
        ['Precio total', 'Abono', 'Importe', 'Saldo', 'Precio marcado'].forEach(function (k) {
            excel[k] = monto(excel[k]);
        });
        return '<div class="d-flex flex-wrap gap-3 align-items-center mb-3 small">'
            + '<span><strong>Reporte:</strong> #' + esc(d.linea.reporte_id) + ' ' + esc(d.linea.reporte_archivo) + '</span>'
            + '<span><strong>Fila:</strong> ' + esc(d.linea.fila_excel) + '</span>'
            + '<span><strong>Estado:</strong> ' + badgeEstado(d.linea.estado_wtw) + '</span>'
            + '</div>'
            + '<div class="row g-3">'
            + '<div class="col-lg-6"><h6><i class="fas fa-file-excel text-success me-1"></i>Datos del Excel</h6>' + tablaKV(excel) + '</div>'
            + '<div class="col-lg-6"><h6><i class="fas fa-link text-primary me-1"></i>Solicitud de crédito'
            + (d.solicitud ? ' <small class="text-muted">(coincidencia por ' + esc(d.linea.match_por) + ')</small>' : '') + '</h6>'
            + seccionSolicitud(d.solicitud) + '</div>'
            + '</div>'
            + '<h6 class="mt-4"><i class="fas fa-sticky-note me-1"></i>Notas</h6>' + seccionNotas(d.notas, false)
            + '<h6 class="mt-4"><i class="fas fa-history me-1"></i>Historial de gestión</h6>' + seccionHistorial(d.historial);
    }

    return {
        esc: esc, vacio: vacio, monto: monto, dinero: dinero, badgeEstado: badgeEstado,
        vehiculoTexto: vehiculoTexto, seccionNotas: seccionNotas, detalle: detalle
    };
})();
