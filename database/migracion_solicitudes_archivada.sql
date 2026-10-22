-- Solicitudes archivadas: pasan a Histórico sin cambiar su estado.
-- Histórico = estado IN ('Completada','Rechazada','Desistimiento') OR archivada = 1.

ALTER TABLE solicitudes_credito
    ADD COLUMN archivada TINYINT(1) NOT NULL DEFAULT 0,
    ADD COLUMN fecha_archivado DATETIME NULL,
    ADD INDEX idx_solicitudes_archivada (archivada);

-- Archivo inicial: solicitudes activas creadas antes del 1 de septiembre de 2026.
UPDATE solicitudes_credito
SET archivada = 1, fecha_archivado = NOW()
WHERE fecha_creacion < '2026-09-01 00:00:00'
  AND estado NOT IN ('Completada', 'Rechazada', 'Desistimiento')
  AND archivada = 0;
