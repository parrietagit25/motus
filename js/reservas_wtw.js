(function () {
    'use strict';

    var API = 'api/reservas_wtw.php';
    var R = window.ReservasWtwRender;
    var esc = R.esc;
    var lineasCache = {};
    var notasCache = [];
    var tablaLineas = null;

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

    function botonNotas(cantidad) {
        return '<i class="fas fa-sticky-note"></i>' + (cantidad > 0 ? ' <span class="badge bg-warning text-dark">' + esc(cantidad) + '</span>' : '');
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
            + '<td>' + esc(R.vehiculoTexto(l)) + '</td>'
            + '<td class="text-end" data-order="' + esc(l.precio_total || 0) + '">' + R.dinero(l.precio_total) + '</td>'
            + '<td>' + sol + '</td>'
            + '<td class="celda-estado" data-order="' + esc(l.estado_wtw) + '">' + R.badgeEstado(l.estado_wtw) + '</td>'
            + '<td class="text-nowrap">'
            + '<button type="button" class="btn btn-sm btn-outline-info me-1 btn-wtw-detalle" title="Detalles"><i class="fas fa-eye"></i></button>'
            + '<button type="button" class="btn btn-sm btn-outline-primary me-1 btn-wtw-enviar" title="Enviar propuesta"><i class="fas fa-paper-plane"></i></button>'
            + '<button type="button" class="btn btn-sm btn-outline-secondary me-1 btn-wtw-estado" title="Cambiar estado"><i class="fas fa-exchange-alt"></i></button>'
            + '<button type="button" class="btn btn-sm btn-outline-warning btn-wtw-notas" title="Notas" aria-label="Notas">' + botonNotas(Number(l.notas || 0)) + '</button>'
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

    function abrirDetalle(lineaId) {
        var cuerpo = document.getElementById('wtwDetalleCuerpo');
        cuerpo.innerHTML = '<span class="text-muted">Cargando…</span>';
        bootstrap.Modal.getOrCreateInstance(document.getElementById('modalWtwDetalle')).show();
        pedir(API + '?action=detalle&linea_id=' + encodeURIComponent(lineaId)).then(function (res) {
            cuerpo.innerHTML = res.success
                ? R.detalle(res.data)
                : '<div class="alert alert-danger mb-0">' + esc(res.message || 'Error') + '</div>';
        });
    }

    function resumenLinea(l) {
        return 'Reserva ' + (l.mov_id || '#' + l.id) + ' — ' + (l.nombre_cliente || '') + (R.vehiculoTexto(l) ? ' — ' + R.vehiculoTexto(l) : '');
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
        celda.innerHTML = R.badgeEstado(estado);
        celda.setAttribute('data-order', estado);
        if (tablaLineas) tablaLineas.cell(celda).invalidate('dom').draw(false);
    }

    function actualizarNotasFila(lineaId, cantidad) {
        if (lineasCache[lineaId]) lineasCache[lineaId].notas = cantidad;
        var btn = document.querySelector('#tablaWtwLineas tr[data-linea-id="' + lineaId + '"] .btn-wtw-notas');
        if (btn) btn.innerHTML = botonNotas(cantidad);
    }

    function mostrarError(errEl, msg) {
        errEl.textContent = msg;
        errEl.classList.remove('d-none');
    }

    function enviarFormulario(form, btn, errEl, validar, alTerminar) {
        errEl.classList.add('d-none');
        var problema = validar();
        if (problema) {
            mostrarError(errEl, problema);
            return;
        }
        var original = btn.innerHTML;
        function restaurar() {
            btn.disabled = false;
            btn.innerHTML = original;
        }
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Procesando…';
        pedir(API, { method: 'POST', body: new FormData(form) }).then(function (res) {
            restaurar();
            if (!res.success) {
                mostrarError(errEl, res.message || 'No se pudo completar la acción');
                return;
            }
            alTerminar(res);
        }).catch(function () {
            restaurar();
            mostrarError(errEl, 'Error de conexión');
        });
    }

    /* ---------- Notas: listar, agregar, editar y eliminar en una sola modal ---------- */

    function modoNuevaNota() {
        document.getElementById('wtwNotaAccion').value = 'nota_crear';
        document.getElementById('wtwNotaId').value = '';
        document.getElementById('wtwNotaTexto').value = '';
        document.getElementById('wtwNotaEtiqueta').textContent = 'Nueva nota';
        document.getElementById('btnWtwNotaGuardar').innerHTML = '<i class="fas fa-plus me-1"></i>Agregar nota';
        document.getElementById('btnWtwNotaCancelar').classList.add('d-none');
        document.getElementById('wtwNotaError').classList.add('d-none');
    }

    function pintarNotas(notas) {
        notasCache = notas || [];
        document.getElementById('wtwNotasLista').innerHTML = R.seccionNotas(notasCache, true);
        actualizarNotasFila(document.getElementById('wtwNotaLinea').value, notasCache.length);
    }

    function abrirNotas(lineaId) {
        var l = lineasCache[lineaId] || { id: lineaId };
        document.getElementById('wtwNotaLinea').value = lineaId;
        document.getElementById('wtwNotasResumen').textContent = resumenLinea(l);
        document.getElementById('wtwNotasLista').innerHTML = '<span class="text-muted">Cargando…</span>';
        modoNuevaNota();
        bootstrap.Modal.getOrCreateInstance(document.getElementById('modalWtwNotas')).show();
        pedir(API + '?action=notas&linea_id=' + encodeURIComponent(lineaId)).then(function (res) {
            if (!res.success) {
                document.getElementById('wtwNotasLista').innerHTML = '<div class="alert alert-danger mb-0">' + esc(res.message || 'Error') + '</div>';
                return;
            }
            pintarNotas(res.data);
        });
    }

    function editarNota(notaId) {
        var n = notasCache.filter(function (x) { return String(x.id) === String(notaId); })[0];
        if (!n) return;
        document.getElementById('wtwNotaAccion').value = 'nota_editar';
        document.getElementById('wtwNotaId').value = n.id;
        document.getElementById('wtwNotaTexto').value = n.nota;
        document.getElementById('wtwNotaEtiqueta').textContent = 'Editar nota de ' + (n.autor || '') + ' (' + n.created_at + ')';
        document.getElementById('btnWtwNotaGuardar').innerHTML = '<i class="fas fa-save me-1"></i>Guardar cambios';
        document.getElementById('btnWtwNotaCancelar').classList.remove('d-none');
        document.getElementById('wtwNotaError').classList.add('d-none');
        document.getElementById('wtwNotaTexto').focus();
    }

    function eliminarNota(notaId) {
        if (!window.confirm('¿Eliminar esta nota?')) return;
        var form = document.getElementById('formWtwNota');
        var fd = new FormData();
        fd.append('action', 'nota_eliminar');
        fd.append('csrf_token', form.querySelector('[name="csrf_token"]').value);
        fd.append('linea_id', document.getElementById('wtwNotaLinea').value);
        fd.append('nota_id', notaId);
        pedir(API, { method: 'POST', body: fd }).then(function (res) {
            if (!res.success) {
                mostrarError(document.getElementById('wtwNotaError'), res.message || 'No se pudo eliminar la nota');
                return;
            }
            if (String(document.getElementById('wtwNotaId').value) === String(notaId)) modoNuevaNota();
            pintarNotas(res.notas);
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
        $(document).on('click', '.btn-wtw-notas', function () {
            abrirNotas($(this).closest('tr').data('linea-id'));
        });
        $(document).on('click', '.btn-wtw-nota-editar', function () {
            editarNota(this.getAttribute('data-nota-id'));
        });
        $(document).on('click', '.btn-wtw-nota-eliminar', function () {
            eliminarNota(this.getAttribute('data-nota-id'));
        });
        document.getElementById('btnWtwNotaCancelar').addEventListener('click', modoNuevaNota);
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

        var formNota = document.getElementById('formWtwNota');
        formNota.addEventListener('submit', function (ev) {
            ev.preventDefault();
            enviarFormulario(formNota, document.getElementById('btnWtwNotaGuardar'), document.getElementById('wtwNotaError'), function () {
                var t = document.getElementById('wtwNotaTexto').value.trim();
                if (!t) return 'Escriba la nota.';
                if (t.length > 2000) return 'La nota no puede superar 2000 caracteres.';
                return '';
            }, function (res) {
                pintarNotas(res.notas);
                modoNuevaNota();
            });
        });
    });
})();
