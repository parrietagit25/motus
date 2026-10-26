-- Gestión de propuestas WTW sobre las líneas de reportes de reservas (pantalla reservas_wtw.php).
-- No modifica reportes_reservas ni reportes_reservas_lineas. includes/reservas_wtw_helper.php
-- también crea estas tablas si no existen.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `reservas_wtw_gestion` (
  `linea_id` int NOT NULL,
  `estado` enum('No enviado','Enviado','Aceptado','Rechazado') NOT NULL DEFAULT 'No enviado',
  `actualizado_por` int DEFAULT NULL,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`linea_id`),
  KEY `idx_wtw_gestion_estado` (`estado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `reservas_wtw_historial` (
  `id` int NOT NULL AUTO_INCREMENT,
  `linea_id` int NOT NULL,
  `accion` enum('envio_propuesta','cambio_estado') NOT NULL,
  `estado_anterior` varchar(20) DEFAULT NULL,
  `estado_nuevo` varchar(20) DEFAULT NULL,
  `email_destino` varchar(255) DEFAULT NULL,
  `archivo_nombre` varchar(255) DEFAULT NULL,
  `archivo_ruta` varchar(500) DEFAULT NULL,
  `archivo_bytes` int unsigned DEFAULT NULL,
  `comentario` text,
  `resultado` enum('ok','error') NOT NULL DEFAULT 'ok',
  `mensaje` varchar(500) DEFAULT NULL,
  `usuario_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_wtw_hist_linea` (`linea_id`),
  KEY `idx_wtw_hist_fecha` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
