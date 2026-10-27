/**
 * Seguimiento admin banco — asignadas / respuestas / seleccionadas.
 */
(function () {
    var chartAsignadas = null;
    var chartSeleccionadas = null;
    var chartDecisiones = null;
    var chartEfectividad = null;
    var dt = null;
    var dtEf = null;

    function qs() {
        var d = document.getElementById('segBancoDesde');
        var h = document.getElementById('segBancoHasta');
        var p = new URLSearchParams();
        p.set('desde', d && d.value ? d.value : '');
        p.set('hasta', h && h.value ? h.value : '');
        p.set('_ts', String(Date.now()));
        return p.toString();
    }

    function escapeHtml(t) {
        if (t == null) return '';
        var el = document.createElement('div');
        el.textContent = String(t);
        return el.innerHTML;
    }

    function fmtMoney(v) {
        if (v == null || v === '') return '—';
        var n = parseFloat(v);
        if (!isFinite(n)) return '—';
        return '$' + n.toLocaleString('es-PA', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function fmtPct(v) {
        if (v == null || v === '') return '—';
        var n = parseFloat(v);
        if (!isFinite(n)) return '—';
        return n.toLocaleString('es-PA', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '%';
    }

    function destroyCharts() {
        if (chartAsignadas) {
            chartAsignadas.destroy();
            chartAsignadas = null;
        }
        if (chartSeleccionadas) {
            chartSeleccionadas.destroy();
            chartSeleccionadas = null;
        }
        if (chartDecisiones) {
            chartDecisiones.destroy();
            chartDecisiones = null;
        }
        if (chartEfectividad) {
            chartEfectividad.destroy();
            chartEfectividad = null;
        }
    }

    function num(v, dec) {
        if (v == null || v === '') return '—';
        var n = parseFloat(v);
        if (!isFinite(n)) return '—';
        return n.toLocaleString('es-PA', { minimumFractionDigits: dec || 0, maximumFractionDigits: dec || 0 });
    }

    function pctTxt(v) {
        return v == null || v === '' ? '—' : num(v, 1) + '%';
    }

    function horasTxt(v) {
        if (v == null || v === '') return '—';
        var h = parseFloat(v);
        if (!isFinite(h)) return '—';
        return h < 48 ? num(h, 1) + ' h' : num(h / 24, 1) + ' d';
    }

    function filaEfectividad(e, pos) {
        return '<td>' + (pos ? pos : '') + '</td>'
            + '<td>' + escapeHtml(e.ejecutivo || '—') + '</td>'
            + '<td class="text-center">' + num(e.asignadas) + '</td>'
            + '<td class="text-center">' + num(e.respondidas) + '</td>'
            + '<td class="text-center" data-order="' + (e.pct_respuesta == null ? -1 : e.pct_respuesta) + '">' + pctTxt(e.pct_respuesta) + '</td>'
            + '<td class="text-center' + (e.pendientes_24h > 0 ? ' text-danger fw-semibold' : '') + '">' + num(e.pendientes_24h) + '</td>'
            + '<td class="text-center">' + num(e.aprobado) + '</td>'
            + '<td class="text-center">' + num(e.preaprobado) + '</td>'
            + '<td class="text-center">' + num(e.aprobado_condicional) + '</td>'
            + '<td class="text-center">' + num(e.rechazado) + '</td>'
            + '<td class="text-center" data-order="' + (e.pct_positivas == null ? -1 : e.pct_positivas) + '">' + pctTxt(e.pct_positivas) + '</td>'
            + '<td class="text-center">' + num(e.seleccionadas) + '</td>'
            + '<td class="text-center" data-order="' + (e.pct_conversion == null ? -1 : e.pct_conversion) + '">' + pctTxt(e.pct_conversion) + '</td>'
            + '<td class="text-center">' + num(e.cierres) + '</td>'
            + '<td class="text-center" data-order="' + (e.horas_promedio == null ? 999999 : e.horas_promedio) + '">' + horasTxt(e.horas_promedio) + '</td>'
            + '<td class="text-center" data-order="' + (e.horas_mediana == null ? 999999 : e.horas_mediana) + '">' + horasTxt(e.horas_mediana) + '</td>'
            + '<td class="text-center">' + (e.tasa_promedio == null ? '—' : num(e.tasa_promedio, 2) + '%') + '</td>'
            + '<td class="text-end">' + fmtMoney(e.monto_promedio) + '</td>'
            + '<td class="text-center">' + (e.plazo_promedio == null ? '—' : num(e.plazo_promedio) + ' m') + '</td>'
            + '<td class="text-center">' + num(e.reevaluaciones) + '</td>';
    }

    function tarjetaDestacado(icono, color, titulo, d, valorTxt) {
        var cuerpo = d
            ? '<div class="fw-semibold">' + escapeHtml(d.ejecutivo) + '</div><div class="small text-muted">' + valorTxt(d.valor) + '</div>'
            : '<div class="small text-muted">Sin datos suficientes</div>';
        return '<div class="col-6 col-lg-3"><div class="border rounded p-2 h-100">'
            + '<div class="small text-muted"><i class="fas ' + icono + ' ' + color + ' me-1"></i>' + titulo + '</div>' + cuerpo
            + '</div></div>';
    }

    function renderEfectividad(ef) {
        var tbody = document.querySelector('#tablaSegBancoEfectividad tbody');
        var tfoot = document.querySelector('#tablaSegBancoEfectividad tfoot');
        var box = document.getElementById('segBancoDestacados');
        if (!tbody) return;
        if (dtEf) {
            dtEf.destroy();
            dtEf = null;
        }
        var lista = (ef && ef.ejecutivos) || [];
        var t = (ef && ef.totales) || {};

        document.querySelectorAll('[data-ef-kpi]').forEach(function (el) {
            var k = el.getAttribute('data-ef-kpi');
            var v = t[k];
            el.textContent = k.indexOf('pct_') === 0 ? pctTxt(v) : (k.indexOf('horas') === 0 ? horasTxt(v) : num(v));
        });

        if (box) {
            var d = (ef && ef.destacados) || {};
            var min = d.minimo_respondidas || 5;
            box.innerHTML = tarjetaDestacado('fa-trophy', 'text-warning', 'Más aprobaciones + preaprobaciones', d.mas_aprobaciones, function (v) { return num(v) + ' solicitudes'; })
                + tarjetaDestacado('fa-thumbs-up', 'text-success', 'Mayor % positivas (mín. ' + min + ' resp.)', d.mejor_pct_positivas, pctTxt)
                + tarjetaDestacado('fa-handshake', 'text-primary', 'Mayor % conversión (mín. ' + min + ' resp.)', d.mejor_conversion, pctTxt)
                + tarjetaDestacado('fa-bolt', 'text-info', 'Respuesta más rápida (mediana, mín. ' + min + ')', d.mas_rapido, horasTxt);
        }

        if (!lista.length) {
            tbody.innerHTML = '<tr><td colspan="20" class="text-center text-muted">Sin asignaciones en este rango</td></tr>';
            if (tfoot) tfoot.innerHTML = '';
            return;
        }
        tbody.innerHTML = lista.map(function (e, i) { return '<tr>' + filaEfectividad(e, i + 1) + '</tr>'; }).join('');
        if (tfoot) tfoot.innerHTML = '<tr>' + filaEfectividad(t, '') + '</tr>';

        if (window.jQuery && $.fn.DataTable) {
            dtEf = $('#tablaSegBancoEfectividad').DataTable({
                order: [[0, 'asc']],
                pageLength: 25,
                paging: lista.length > 25,
                language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json' },
                scrollX: true
            });
        }

        if (typeof Chart === 'undefined') return;
        var nombres = lista.map(function (e) { return e.ejecutivo; });
        var ctxD = document.getElementById('segBancoChartDecisiones');
        if (ctxD) {
            chartDecisiones = new Chart(ctxD, {
                type: 'bar',
                data: {
                    labels: nombres,
                    datasets: [
                        { label: 'Aprobado', data: lista.map(function (e) { return e.aprobado; }), backgroundColor: '#198754' },
                        { label: 'Preaprobado', data: lista.map(function (e) { return e.preaprobado; }), backgroundColor: '#20c997' },
                        { label: 'Condicional', data: lista.map(function (e) { return e.aprobado_condicional; }), backgroundColor: '#ffc107' },
                        { label: 'Rechazado', data: lista.map(function (e) { return e.rechazado; }), backgroundColor: '#dc3545' },
                        { label: 'Sin respuesta', data: lista.map(function (e) { return e.sin_respuesta; }), backgroundColor: '#adb5bd' }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true, ticks: { precision: 0 } } }
                }
            });
        }
        var ctxE = document.getElementById('segBancoChartEfectividad');
        if (ctxE) {
            chartEfectividad = new Chart(ctxE, {
                type: 'bar',
                data: {
                    labels: nombres,
                    datasets: [
                        { label: '% positivas', data: lista.map(function (e) { return e.pct_positivas || 0; }), backgroundColor: '#198754' },
                        { label: '% conversión', data: lista.map(function (e) { return e.pct_conversion || 0; }), backgroundColor: '#0d6efd' }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: { y: { beginAtZero: true, max: 100, ticks: { callback: function (v) { return v + '%'; } } } }
                }
            });
        }
    }

    function renderCompareBars(canvasId, pie, colors) {
        var ctx = document.getElementById(canvasId);
        if (!ctx || typeof Chart === 'undefined') return null;
        var data = pie || [];
        return new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(function (x) { return x.label; }),
                datasets: [{
                    label: 'Cantidad',
                    data: data.map(function (x) { return Number(x.total || 0); }),
                    backgroundColor: colors || ['#0d6efd', '#20c997']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
            }
        });
    }

    function renderDetalle(filas) {
        var tbody = document.querySelector('#tablaSegBancoDetalle tbody');
        if (!tbody) return;

        if (dt) {
            dt.destroy();
            dt = null;
        }

        if (!filas || !filas.length) {
            tbody.innerHTML = '<tr><td colspan="19" class="text-center text-muted">Sin solicitudes con estos filtros</td></tr>';
            return;
        }

        var html = '';
        filas.forEach(function (r) {
            var sid = parseInt(r.solicitud_id, 10) || 0;
            html += '<tr>'
                + '<td>#' + sid + '</td>'
                + '<td class="text-nowrap"><small>' + escapeHtml(r.fecha_asignacion || '—') + '</small></td>'
                + '<td>' + escapeHtml(r.nombre_cliente || '—') + '</td>'
                + '<td>' + escapeHtml(r.cedula || '—') + '</td>'
                + '<td>' + escapeHtml(r.solicitud_estado || '—') + '</td>'
                + '<td><small>' + escapeHtml(r.encargados || '—') + '</small></td>'
                + '<td class="text-center">' + escapeHtml(String(r.total_respuestas != null ? r.total_respuestas : 0)) + '</td>'
                + '<td>' + escapeHtml((r.ultima_decision || '').toString().toUpperCase().replace(/_/g, ' ') || '—') + '</td>'
                + '<td>' + (r.es_seleccionada ? '<span class="badge bg-success">Sí</span>' : '<span class="badge bg-secondary">No</span>') + '</td>'
                + '<td>' + escapeHtml((r.decision_seleccionada || '').toString().toUpperCase().replace(/_/g, ' ') || '—') + '</td>'
                + '<td>' + fmtPct(r.tasa_seleccionada) + '</td>'
                + '<td>' + fmtMoney(r.valor_financiar_seleccionada) + '</td>'
                + '<td>' + fmtMoney(r.abono_seleccionada) + '</td>'
                + '<td>' + (r.plazo_seleccionada != null && r.plazo_seleccionada !== '' ? escapeHtml(String(r.plazo_seleccionada)) + ' m' : '—') + '</td>'
                + '<td>' + fmtMoney(r.letra_seleccionada) + '</td>'
                + '<td><small>' + escapeHtml(r.promocion_seleccionada || '—') + '</small></td>'
                + '<td>' + fmtMoney(r.cuantia_seleccionada) + '</td>'
                + '<td><small>' + escapeHtml(r.vehiculo_label || '—') + '</small></td>'
                + '<td><a class="btn btn-sm btn-outline-primary" href="solicitudes.php?abrir_solicitud=' + sid + '" title="Abrir"><i class="fas fa-external-link-alt"></i></a></td>'
                + '</tr>';
        });
        tbody.innerHTML = html;

        if (window.jQuery && $.fn.DataTable) {
            dt = $('#tablaSegBancoDetalle').DataTable({
                order: [[1, 'desc']],
                pageLength: 25,
                language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json' },
                scrollX: true
            });
        }
    }

    function loadReporte(ev) {
        if (ev && typeof ev.preventDefault === 'function') {
            ev.preventDefault();
            ev.stopPropagation();
        }

        var query = qs();
        var btn = document.getElementById('btnSegBancoFiltrar');
        var nota = document.getElementById('segBancoNotaApi');
        var aplicados = document.getElementById('segBancoFiltrosAplicados');
        var ex = document.getElementById('segBancoExportXlsx');
        if (ex) ex.href = 'api/reportes_banco.php?action=exportar_excel_seguimiento&' + query;
        var exEf = document.getElementById('segBancoExportEfectividad');
        if (exEf) exEf.href = 'api/reportes_banco.php?action=exportar_excel_efectividad&' + query;
        if (nota) nota.textContent = '';
        if (aplicados) aplicados.textContent = 'Aplicando filtros…';
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Filtrando…';
        }

        fetch('api/reportes_banco.php?action=reporte_seguimiento&' + query)
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success) {
                    if (nota) nota.textContent = data.message || 'No se pudo cargar';
                    if (aplicados) aplicados.textContent = 'No se pudieron aplicar los filtros.';
                    destroyCharts();
                    renderDetalle([]);
                    renderEfectividad(null);
                    return;
                }

                var k = data.kpis || {};
                document.getElementById('segBancoKpiAsignadas').textContent = String(k.total_solicitudes != null ? k.total_solicitudes : 0);
                document.getElementById('segBancoKpiRespuestas').textContent = String(k.total_respuestas != null ? k.total_respuestas : 0);
                document.getElementById('segBancoKpiSeleccionadas').textContent = String(k.total_seleccionadas != null ? k.total_seleccionadas : 0);

                var f = data.filtros || {};
                if (aplicados) {
                    aplicados.textContent = 'Filtros aplicados: ' + (f.fecha_desde || '') + ' → ' + (f.fecha_hasta || '')
                        + ' · ' + String(k.total_solicitudes != null ? k.total_solicitudes : 0) + ' solicitudes';
                }
                if (nota && data.nota) nota.textContent = data.nota;

                destroyCharts();
                chartAsignadas = renderCompareBars('segBancoChartAsignadas', data.chart_asignadas_vs_enviadas, ['#0d6efd', '#20c997']);
                chartSeleccionadas = renderCompareBars('segBancoChartSeleccionadas', data.chart_enviadas_vs_seleccionadas, ['#20c997', '#198754']);
                renderDetalle(data.filas || []);
                renderEfectividad(data.efectividad);
            })
            .catch(function () {
                if (nota) nota.textContent = 'Error de red o servidor';
                if (aplicados) aplicados.textContent = 'Error al filtrar. Intente de nuevo.';
            })
            .finally(function () {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fas fa-filter me-1"></i>Filtrar';
                }
            });
    }

    var form = document.getElementById('segBancoFiltrosForm');
    if (form) form.addEventListener('submit', loadReporte);
    loadReporte();
})();
