-- Notas por línea de reporte de reservas (pantalla reservas_wtw.php). Las notas eliminadas
-- se conservan con eliminado_at para auditoría. includes/reservas_wtw_helper.php también
-- crea esta tabla si no existe.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `reservas_wtw_notas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `linea_id` int NOT NULL,
  `nota` text NOT NULL,
  `usuario_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `editado_por` int DEFAULT NULL,
  `editado_at` timestamp NULL DEFAULT NULL,
  `eliminado_por` int DEFAULT NULL,
  `eliminado_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_wtw_notas_linea` (`linea_id`,`eliminado_at`),
  KEY `idx_wtw_notas_usuario` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
