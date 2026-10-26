(function () {
    'use strict';

    var API = 'api/reservas_wtw.php';
    var BADGE = { 'No enviado': 'bg-secondary', 'Enviado': 'bg-primary', 'Aceptado': 'bg-success', 'Rechazado': 'bg-danger' };
    var lineasCache = {};
    var tablaLineas = null;

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

    function alerta(tipo, msg) {
        var el = document.getElementById('wtwAlerta');
        el.className = 'alert alert-' + tipo;
        el.textContent = msg;
        window.scrollTo({ top: 0, behavior: 'smooth' });
        clearTimeout(alerta._t);
        alerta._t = setTimeout(function () { el.className = 'alert d-none'; }, 6000);
    }

    function pedir(url, opciones) {
        return fetch(url, Object.assign({ credentials: 'same-origin' }, opciones || {}))
            .then(function (r) {
                return r.json().catch(function () { return { success: false, message: 'Respuesta inválida del servidor (' + r.status + ')' }; });
            });
    }

    function vehiculoTexto(l) {
        return [l.marca, l.modelo, l.anio].filter(function (x) { return !vacio(x); }).join(' ');
    }

    function filaHtml(l) {
        var sol = l.solicitud_id
            ? '<span class="badge bg-success">#' + esc(l.solicitud_id) + '</span> <small class="text-muted">' + esc(l.match_por) + '</small>'
            : '<span class="text-muted small">Sin coincidencia</span>';
        return '<tr data-linea-id="' + esc(l.id) + '">'
            + '<td>' + esc(l.fila_excel) + '</td>'
            + '<td>' + esc(l.mov_id) + '</td>'
            + '<td>' + esc(l.nombre_cliente) + '</td>'
            + '<td>' + esc(l.cedula) + '</td>'
            + '<td>' + esc(vehiculoTexto(l)) + '</td>'
            + '<td class="text-end" data-order="' + esc(l.precio_total || 0) + '">' + dinero(l.precio_total) + '</td>'
            + '<td>' + sol + '</td>'
            + '<td class="celda-estado" data-order="' + esc(l.estado_wtw) + '">' + badgeEstado(l.estado_wtw) + '</td>'
            + '<td class="text-nowrap">'
            + '<button type="button" class="btn btn-sm btn-outline-info me-1 btn-wtw-detalle" title="Detalles"><i class="fas fa-eye"></i></button>'
            + '<button type="button" class="btn btn-sm btn-outline-primary me-1 btn-wtw-enviar" title="Enviar propuesta"><i class="fas fa-paper-plane"></i></button>'
            + '<button type="button" class="btn btn-sm btn-outline-secondary btn-wtw-estado" title="Cambiar estado"><i class="fas fa-exchange-alt"></i></button>'
            + '</td></tr>';
    }

    function cargarLineas(reporteId, nombre) {
        var card = document.getElementById('cardWtwLineas');
        document.getElementById('wtwTituloLineas').textContent = 'Detalle del reporte #' + reporteId + (nombre ? ' — ' + nombre : '');
        card.classList.remove('d-none');
        if (tablaLineas) {
            tablaLineas.destroy();
            tablaLineas = null;
        }
        var tbody = document.querySelector('#tablaWtwLineas tbody');
        tbody.innerHTML = '<tr><td colspan="9" class="text-muted">Cargando…</td></tr>';

        pedir(API + '?action=lineas&reporte_id=' + encodeURIComponent(reporteId)).then(function (res) {
            if (!res.success) {
                tbody.innerHTML = '';
                alerta('danger', res.message || 'No se pudieron cargar los registros');
                return;
            }
            lineasCache = {};
            (res.data || []).forEach(function (l) { lineasCache[l.id] = l; });
            tbody.innerHTML = (res.data || []).map(filaHtml).join('');
            tablaLineas = $('#tablaWtwLineas').DataTable({
                pageLength: 25,
                order: [[0, 'asc']],
                columnDefs: [{ orderable: false, targets: 8 }],
                language: { url: 'https://cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json' }
            });
            card.scrollIntoView({ behavior: 'smooth' });
        });
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

    function abrirDetalle(lineaId) {
        var cuerpo = document.getElementById('wtwDetalleCuerpo');
        cuerpo.innerHTML = '<span class="text-muted">Cargando…</span>';
        bootstrap.Modal.getOrCreateInstance(document.getElementById('modalWtwDetalle')).show();
        pedir(API + '?action=detalle&linea_id=' + encodeURIComponent(lineaId)).then(function (res) {
            if (!res.success) {
                cuerpo.innerHTML = '<div class="alert alert-danger mb-0">' + esc(res.message || 'Error') + '</div>';
                return;
            }
            var d = res.data;
            var excel = Object.assign({}, d.excel);
            ['Precio total', 'Abono', 'Importe', 'Saldo', 'Precio marcado'].forEach(function (k) {
                excel[k] = monto(excel[k]);
            });
            cuerpo.innerHTML =
                '<div class="d-flex flex-wrap gap-3 align-items-center mb-3 small">'
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
                + '<h6 class="mt-4"><i class="fas fa-history me-1"></i>Historial de gestión</h6>' + seccionHistorial(d.historial);
        });
    }

    function resumenLinea(l) {
        return 'Reserva ' + (l.mov_id || '#' + l.id) + ' — ' + (l.nombre_cliente || '') + (vehiculoTexto(l) ? ' — ' + vehiculoTexto(l) : '');
    }

    function abrirEnviar(lineaId) {
        var l = lineasCache[lineaId] || { id: lineaId };
        var form = document.getElementById('formWtwEnviar');
        form.reset();
        document.getElementById('wtwEnviarLinea').value = lineaId;
        document.getElementById('wtwEnviarResumen').textContent = resumenLinea(l);
        document.getElementById('wtwEnviarError').classList.add('d-none');
        bootstrap.Modal.getOrCreateInstance(document.getElementById('modalWtwEnviar')).show();
    }

    function abrirEstado(lineaId) {
        var l = lineasCache[lineaId] || { id: lineaId, estado_wtw: 'No enviado' };
        var form = document.getElementById('formWtwEstado');
        form.reset();
        document.getElementById('wtwEstadoLinea').value = lineaId;
        document.getElementById('wtwEstadoValor').value = l.estado_wtw || 'No enviado';
        document.getElementById('wtwEstadoResumen').textContent = resumenLinea(l);
        document.getElementById('wtwEstadoError').classList.add('d-none');
        bootstrap.Modal.getOrCreateInstance(document.getElementById('modalWtwEstado')).show();
    }

    function actualizarEstadoFila(lineaId, estado) {
        if (lineasCache[lineaId]) lineasCache[lineaId].estado_wtw = estado;
        var celda = document.querySelector('#tablaWtwLineas tr[data-linea-id="' + lineaId + '"] .celda-estado');
        if (!celda) return;
        celda.innerHTML = badgeEstado(estado);
        celda.setAttribute('data-order', estado);
        if (tablaLineas) tablaLineas.cell(celda).invalidate('dom').draw(false);
    }

    function enviarFormulario(form, btn, errEl, validar, alTerminar) {
        errEl.classList.add('d-none');
        var problema = validar();
        if (problema) {
            errEl.textContent = problema;
            errEl.classList.remove('d-none');
            return;
        }
        var original = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Procesando…';
        pedir(API, { method: 'POST', body: new FormData(form) }).then(function (res) {
            if (!res.success) {
                errEl.textContent = res.message || 'No se pudo completar la acción';
                errEl.classList.remove('d-none');
                return;
            }
            alTerminar(res);
        }).catch(function () {
            errEl.textContent = 'Error de conexión';
            errEl.classList.remove('d-none');
        }).finally(function () {
            btn.disabled = false;
            btn.innerHTML = original;
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        $('#tablaWtwReportes').DataTable({
            pageLength: 10,
            order: [[0, 'desc']],
            columnDefs: [{ orderable: false, targets: 6 }],
            language: { url: 'https://cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json' }
        });

        $(document).on('click', '.btn-wtw-ver-reporte', function () {
            cargarLineas(this.getAttribute('data-reporte-id'), this.getAttribute('data-reporte-nombre'));
        });
        $(document).on('click', '.btn-wtw-detalle', function () {
            abrirDetalle($(this).closest('tr').data('linea-id'));
        });
        $(document).on('click', '.btn-wtw-enviar', function () {
            abrirEnviar($(this).closest('tr').data('linea-id'));
        });
        $(document).on('click', '.btn-wtw-estado', function () {
            abrirEstado($(this).closest('tr').data('linea-id'));
        });
        document.getElementById('btnCerrarLineas').addEventListener('click', function () {
            document.getElementById('cardWtwLineas').classList.add('d-none');
        });

        var formEnviar = document.getElementById('formWtwEnviar');
        formEnviar.addEventListener('submit', function (ev) {
            ev.preventDefault();
            enviarFormulario(formEnviar, document.getElementById('btnWtwEnviar'), document.getElementById('wtwEnviarError'), function () {
                var archivo = document.getElementById('wtwEnviarArchivo').files[0];
                if (!archivo) return 'Adjunte el documento de la propuesta.';
                if (!/\.(pdf|docx?|xlsx?)$/i.test(archivo.name)) return 'Formato no permitido. Use PDF, Word o Excel.';
                if (archivo.size > 10 * 1024 * 1024) return 'El archivo debe pesar menos de 10 MB.';
                var email = document.getElementById('wtwEnviarEmail');
                if (!email.value.trim() || !email.checkValidity()) return 'Ingrese un correo de destino válido.';
                return '';
            }, function (res) {
                actualizarEstadoFila(document.getElementById('wtwEnviarLinea').value, res.estado || 'Enviado');
                bootstrap.Modal.getOrCreateInstance(document.getElementById('modalWtwEnviar')).hide();
                alerta('success', res.message || 'Propuesta enviada');
            });
        });

        var formEstado = document.getElementById('formWtwEstado');
        formEstado.addEventListener('submit', function (ev) {
            ev.preventDefault();
            enviarFormulario(formEstado, document.getElementById('btnWtwEstado'), document.getElementById('wtwEstadoError'), function () {
                return document.getElementById('wtwEstadoValor').value ? '' : 'Seleccione un estado.';
            }, function (res) {
                actualizarEstadoFila(document.getElementById('wtwEstadoLinea').value, res.estado);
                bootstrap.Modal.getOrCreateInstance(document.getElementById('modalWtwEstado')).hide();
                alerta('success', res.message || 'Estado actualizado');
            });
        });
    });
})();
