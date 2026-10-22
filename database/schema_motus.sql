
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `Automarket_Invs_web`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Automarket_Invs_web` (
  `Year` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Transmission` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Color` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Make` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Km` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LicensePlate` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Model` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Chasis` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Unit` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Engine` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Fuel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Price` decimal(14,2) DEFAULT NULL,
  `PriceTax` decimal(14,2) DEFAULT NULL,
  `Doors` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CarType` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CC` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LocationCode` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LocationName` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Interior` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Headline` text COLLATE utf8mb4_unicode_ci,
  `Description` text COLLATE utf8mb4_unicode_ci,
  `Photo` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Marked` tinyint(1) DEFAULT '0',
  `Promo` tinyint(1) DEFAULT '0',
  `PromoPrice` decimal(14,2) DEFAULT NULL,
  `PromoPriceTax` decimal(14,2) DEFAULT NULL,
  `LoadDate` datetime DEFAULT NULL,
  `Prefijo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `VIN` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `trg_updatefechaWeb` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `update_stat` int DEFAULT NULL,
  `stat_master` int DEFAULT NULL,
  `Internacional` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `tipo_compra` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `prioridad` int DEFAULT '0',
  `foto_impel` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `date_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`VIN`),
  KEY `idx_status` (`Status`),
  KEY `idx_make_model` (`Make`,`Model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Automarket_Invs_web_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Automarket_Invs_web_temp` (
  `Year` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Transmission` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Color` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Make` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Km` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LicensePlate` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Model` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Chasis` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Unit` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Engine` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Fuel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Price` decimal(14,2) DEFAULT NULL,
  `PriceTax` decimal(14,2) DEFAULT NULL,
  `Doors` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CarType` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CC` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LocationCode` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LocationName` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Interior` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Headline` text COLLATE utf8mb4_unicode_ci,
  `Description` text COLLATE utf8mb4_unicode_ci,
  `Photo` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Marked` tinyint(1) DEFAULT '0',
  `Promo` tinyint(1) DEFAULT '0',
  `PromoPrice` decimal(14,2) DEFAULT NULL,
  `PromoPriceTax` decimal(14,2) DEFAULT NULL,
  `LoadDate` datetime DEFAULT NULL,
  `Prefijo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `VIN` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `trg_updatefechaWeb` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `update_stat` int DEFAULT NULL,
  `stat_master` int DEFAULT NULL,
  `Internacional` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `tipo_compra` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `prioridad` int DEFAULT '0',
  `foto_impel` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `FechaActualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`VIN`),
  KEY `idx_stat_master` (`stat_master`),
  KEY `idx_update_stat` (`update_stat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `adjuntos_financiamiento_registros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `adjuntos_financiamiento_registros` (
  `id` int NOT NULL AUTO_INCREMENT,
  `financiamiento_registro_id` int NOT NULL,
  `nombre_archivo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruta_archivo` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_archivo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tamano_archivo` int DEFAULT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `fecha_subida` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fin_reg` (`financiamiento_registro_id`),
  KEY `idx_fecha_subida` (`fecha_subida`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `adjuntos_solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `adjuntos_solicitud` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `nombre_archivo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_original` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruta_archivo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_archivo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tamaño_archivo` int NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `texto_extraido` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Texto extraÃ­do por OCR o pdftotext',
  `fecha_subida` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_solicitud` (`solicitud_id`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_fecha` (`fecha_subida`),
  CONSTRAINT `adjuntos_solicitud_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `adjuntos_solicitud_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `bancos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bancos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `direccion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitio_web` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contacto_principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono_contacto` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_contacto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`),
  KEY `idx_nombre` (`nombre`),
  KEY `idx_codigo` (`codigo`),
  KEY `idx_activo` (`activo`),
  KEY `idx_fecha_creacion` (`fecha_creacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `citas_firma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `citas_firma` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `nombre_evento` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Nombre del evento',
  `fecha_cita` date NOT NULL,
  `hora_cita` time DEFAULT NULL,
  `comentarios` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `asistio` enum('pendiente','asistio','no_asistio') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pendiente',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_solicitud` (`solicitud_id`),
  KEY `idx_fecha_cita` (`fecha_cita`),
  CONSTRAINT `citas_firma_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `configuracion_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracion_sistema` (
  `clave` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `valor` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `documentos_solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documentos_solicitud` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `nombre_archivo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruta_archivo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_documento` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tamaño_archivo` int DEFAULT NULL,
  `fecha_subida` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_solicitud` (`solicitud_id`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_fecha` (`fecha_subida`),
  CONSTRAINT `documentos_solicitud_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `documentos_solicitud_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ejecutivos_ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ejecutivos_ventas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sucursal` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_activo` (`activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `email_corredor_envios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_corredor_envios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `email_corredor` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comentario_interno` text COLLATE utf8mb4_unicode_ci,
  `comentario_correo` text COLLATE utf8mb4_unicode_ci,
  `nombre_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_archivo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruta_archivo` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_archivo` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tamano_archivo` int DEFAULT '0',
  `estado` enum('enviado','fallido') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'enviado',
  `mensaje` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_envio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_corredor_solicitud` (`solicitud_id`),
  KEY `idx_corredor_fecha` (`fecha_envio`),
  KEY `fk_corredor_usuario` (`usuario_id`),
  CONSTRAINT `fk_corredor_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_corredor_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `email_resumen_banco_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_resumen_banco_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `usuario_banco_id` int DEFAULT NULL,
  `destinatario_email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_envio` enum('individual','todos') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'individual',
  `estado` enum('enviado','fallido') COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider_message_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mensaje` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_envio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email_resumen_solicitud` (`solicitud_id`),
  KEY `idx_email_resumen_estado` (`estado`),
  KEY `idx_email_resumen_fecha` (`fecha_envio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `encuesta_formulario_publico_vendedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encuesta_formulario_publico_vendedor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int DEFAULT NULL COMMENT 'Usuario de sesión que envía',
  `nombre_completo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cargo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `puntuacion_1` tinyint unsigned NOT NULL COMMENT 'Facilidad compartir enlace con el cliente (1-5)',
  `puntuacion_2` tinyint unsigned NOT NULL COMMENT 'Claridad instrucciones al cliente (1-5)',
  `puntuacion_3` tinyint unsigned NOT NULL COMMENT 'Rapidez del cliente al completar el formulario (1-5)',
  `puntuacion_4` tinyint unsigned NOT NULL COMMENT 'Acompañamiento/resolución de dudas en el proceso (1-5)',
  `puntuacion_5` tinyint unsigned NOT NULL COMMENT 'Satisfacción general con el formulario público (1-5)',
  `recomendaciones` text COLLATE utf8mb4_unicode_ci,
  `creado_en` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_creado` (`creado_en`),
  KEY `idx_usuario` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `encuesta_proceso_gestor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encuesta_proceso_gestor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int DEFAULT NULL COMMENT 'Usuario de sesión que envía',
  `nombre_completo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cargo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `puntuacion_1` tinyint unsigned NOT NULL COMMENT 'Agilidad al crear o gestionar solicitudes (1-5)',
  `puntuacion_2` tinyint unsigned NOT NULL COMMENT 'Claridad de la información en pantalla (1-5)',
  `puntuacion_3` tinyint unsigned NOT NULL COMMENT 'Comunicación vendedor/banco/equipos (1-5)',
  `puntuacion_4` tinyint unsigned NOT NULL COMMENT 'Utilidad de reportes o herramientas del rol (1-5)',
  `puntuacion_5` tinyint unsigned NOT NULL COMMENT 'Satisfacción general con la gestión en el sistema (1-5)',
  `recomendaciones` text COLLATE utf8mb4_unicode_ci,
  `creado_en` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_creado` (`creado_en`),
  KEY `idx_usuario` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `estadisticas_importacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estadisticas_importacion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha_importacion` date NOT NULL,
  `total_importados` int DEFAULT '0',
  `total_errores` int DEFAULT '0',
  `archivo_original` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario_id` int DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fecha` (`fecha_importacion`),
  KEY `idx_usuario` (`usuario_id`),
  CONSTRAINT `estadisticas_importacion_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `evaluaciones_banco`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evaluaciones_banco` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `vehiculo_id` int DEFAULT NULL,
  `usuario_banco_id` int NOT NULL,
  `decision` enum('preaprobado','aprobado','aprobado_condicional','rechazado') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon` text COLLATE utf8mb4_unicode_ci COMMENT 'Raz??n de la decisi??n del banco',
  `valor_financiar` decimal(15,2) DEFAULT NULL,
  `abono` decimal(15,2) DEFAULT NULL,
  `plazo` int DEFAULT NULL,
  `letra` decimal(15,2) DEFAULT NULL,
  `letra_quincenal` decimal(15,2) DEFAULT NULL COMMENT 'Letra / cuota quincenal',
  `promocion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cuantia` decimal(15,2) DEFAULT NULL COMMENT 'CuantÃ­a de la promociÃ³n seleccionada',
  `tasa_bancaria` decimal(6,2) NOT NULL DEFAULT '0.00' COMMENT 'Tasa nominal anual (%)',
  `comentarios` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `comentario_reevaluacion_solicitada` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Motivo al solicitar reevaluación (gestor/admin)',
  `fecha_solicitud_reevaluacion` datetime DEFAULT NULL,
  `fecha_evaluacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_solicitud` (`solicitud_id`),
  KEY `idx_usuario_banco` (`usuario_banco_id`),
  KEY `idx_decision` (`decision`),
  KEY `idx_fecha` (`fecha_evaluacion`),
  KEY `idx_vehiculo` (`vehiculo_id`),
  CONSTRAINT `evaluaciones_banco_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `evaluaciones_banco_ibfk_2` FOREIGN KEY (`usuario_banco_id`) REFERENCES `usuarios_banco_solicitudes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `evaluaciones_banco_ibfk_3` FOREIGN KEY (`vehiculo_id`) REFERENCES `vehiculos_solicitud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `feria_vendedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feria_vendedores` (
  `feria_id` int NOT NULL,
  `ejecutivo_ventas_id` int NOT NULL,
  `fecha_asignacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feria_id`,`ejecutivo_ventas_id`),
  KEY `idx_fv_ejecutivo` (`ejecutivo_ventas_id`),
  CONSTRAINT `fk_fv_ejecutivo` FOREIGN KEY (`ejecutivo_ventas_id`) REFERENCES `ejecutivos_ventas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_fv_feria` FOREIGN KEY (`feria_id`) REFERENCES `ferias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ferias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ferias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `lugar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ferias_activo` (`activo`),
  KEY `idx_ferias_fechas` (`fecha_inicio`,`fecha_fin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `financiamiento_adjuntos_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financiamiento_adjuntos_token` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `financiamiento_registro_id` int NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Token aleatorio (hex)',
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_usuario_id` int NOT NULL,
  `revoked_at` datetime DEFAULT NULL COMMENT 'Invalidado al generar un enlace nuevo',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fin_adj_token` (`token`),
  KEY `idx_fin_adj_reg_expira` (`financiamiento_registro_id`,`expires_at`),
  KEY `idx_fin_adj_revoked` (`revoked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `financiamiento_refirma_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financiamiento_refirma_token` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `financiamiento_registro_id` int NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Token aleatorio (hex)',
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_usuario_id` int NOT NULL,
  `used_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_token` (`token`),
  KEY `idx_registro_expira` (`financiamiento_registro_id`,`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `financiamiento_registro_auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financiamiento_registro_auditoria` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `financiamiento_registro_id` int NOT NULL,
  `usuario_id` int NOT NULL COMMENT 'Usuario admin que aplicó el cambio',
  `fecha_modificacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cambios_json` longtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'JSON: campo -> {old, new}',
  PRIMARY KEY (`id`),
  KEY `idx_fin_registro` (`financiamiento_registro_id`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_fecha` (`fecha_modificacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `financiamiento_registros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financiamiento_registros` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `token_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_vendedor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Correo decodificado del enlace (vendedor)',
  `id_vendedor` int DEFAULT NULL COMMENT 'ID en ejecutivos_ventas si el email estaba registrado',
  `cliente_nombre` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cliente_estado_civil` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cliente_sexo` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cliente_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cliente_nacimiento` date DEFAULT NULL,
  `cliente_edad` int DEFAULT NULL,
  `cliente_nacionalidad` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cliente_dependientes` int DEFAULT NULL,
  `cliente_correo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cliente_peso` decimal(6,2) DEFAULT NULL,
  `cliente_estatura` decimal(5,2) DEFAULT NULL,
  `vivienda` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vivienda_monto` decimal(12,2) DEFAULT NULL,
  `prov_dist_corr` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tel_residencia` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `barriada_calle_casa` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `calle` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `celular_cliente` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `edificio_apto` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo_residencial` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `empresa_nombre` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `empresa_ocupacion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `empresa_anios` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `empresa_telefono` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `empresa_salario` decimal(14,2) DEFAULT NULL,
  `empresa_direccion` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `otros_ingresos` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ocupacion_otros` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trabajo_anterior` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tiene_conyuge` tinyint(1) NOT NULL DEFAULT '0',
  `con_nombre` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_estado_civil` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_sexo` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_nacimiento` date DEFAULT NULL,
  `con_edad` int DEFAULT NULL,
  `con_nacionalidad` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_dependientes` int DEFAULT NULL,
  `con_correo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_empresa` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_ocupacion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_anios` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_tel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_salario` decimal(14,2) DEFAULT NULL,
  `con_direccion` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_otros_ingresos` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_trabajo_anterior` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp1_nombre` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp1_cel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp1_dir_res` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp1_dir_lab` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp2_nombre` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp2_cel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp2_dir_res` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refp2_dir_lab` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff1_nombre` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff1_cel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff1_dir_res` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff1_dir_lab` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff2_nombre` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff2_cel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff2_dir_res` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reff2_dir_lab` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marca_auto` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modelo_auto` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `anio_auto` int DEFAULT NULL,
  `kms_cod_auto` int DEFAULT NULL,
  `precio_venta` decimal(14,2) DEFAULT NULL,
  `abono` decimal(14,2) DEFAULT NULL,
  `sucursal` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombre_gestor` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comentarios_gestor` text COLLATE utf8mb4_unicode_ci,
  `firma` longtext COLLATE utf8mb4_unicode_ci,
  `firmantes_adicionales` text COLLATE utf8mb4_unicode_ci,
  `telemetria_session_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sesion del navegador del formulario publico',
  `telemetria_started_at` datetime DEFAULT NULL COMMENT 'Inicio del formulario en cliente',
  `telemetria_submitted_at` datetime DEFAULT NULL COMMENT 'Envio del formulario en cliente',
  `telemetria_duracion_segundos` int DEFAULT NULL COMMENT 'Duracion total del llenado',
  `telemetria_paso_tiempos_json` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Duracion por paso del wizard (ms)',
  `telemetria_eventos_json` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Eventos del wizard (navegacion, errores, envio)',
  `telemetria_dispositivo_json` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Datos de dispositivo/navegador del cliente',
  `telemetria_geo_country` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Pais por geolocalizacion IP (persistido)',
  `telemetria_geo_city` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Ciudad por geolocalizacion IP (persistido)',
  `solicitud_credito_id` int DEFAULT NULL COMMENT 'Solicitud Motus creada desde este envÃ­o (adjuntos)',
  PRIMARY KEY (`id`),
  KEY `idx_fecha` (`fecha_creacion`),
  KEY `idx_cliente_id` (`cliente_id`),
  KEY `idx_cliente_correo` (`cliente_correo`),
  KEY `idx_fin_reg_solicitud_credito` (`solicitud_credito_id`),
  KEY `idx_id_vendedor` (`id_vendedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `financiamiento_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financiamiento_usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `historial_solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historial_solicitud` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `tipo_accion` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'creacion, cambio_estado, documento_agregado, asignacion_banco, actualizacion_datos, evaluacion_banco',
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado_anterior` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_nuevo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_solicitud` (`solicitud_id`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_fecha` (`fecha_creacion`),
  KEY `idx_tipo` (`tipo_accion`),
  CONSTRAINT `historial_solicitud_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `historial_solicitud_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `link_financiamiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `link_financiamiento` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email_destino` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Correo del vendedor/gestor que recibe el PDF',
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` int DEFAULT NULL COMMENT 'Quien generÃ³ el link (vendedor/gestor/admin)',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_token` (`token`),
  KEY `idx_email` (`email_destino`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `link_financiamiento_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mensajes_solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mensajes_solicitud` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `mensaje` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `tipo` enum('general','banco','gestor') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'general',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `idx_mensajes_solicitud` (`solicitud_id`),
  KEY `idx_mensajes_fecha` (`fecha_creacion`),
  CONSTRAINT `mensajes_solicitud_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mensajes_solicitud_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `notas_solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notas_solicitud` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `vehiculo_id` int DEFAULT NULL,
  `usuario_id` int NOT NULL,
  `usuario_banco_id` int DEFAULT NULL,
  `tipo_nota` enum('Comentario','Actualización','Documento','Respuesta Banco','Respuesta Cliente') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `titulo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contenido` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_solicitud` (`solicitud_id`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_fecha` (`fecha_creacion`),
  KEY `idx_usuario_banco` (`usuario_banco_id`),
  KEY `idx_vehiculo` (`vehiculo_id`),
  CONSTRAINT `fk_nota_usuario_banco` FOREIGN KEY (`usuario_banco_id`) REFERENCES `usuarios_banco_solicitudes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_nota_vehiculo` FOREIGN KEY (`vehiculo_id`) REFERENCES `vehiculos_solicitud` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notas_solicitud_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notas_solicitud_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ocr_pruebas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ocr_pruebas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_guardado` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruta_relativa` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `size_bytes` bigint unsigned NOT NULL DEFAULT '0',
  `texto_extraido` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Texto extraÃ­do por OCR o pdftotext',
  `creado_en` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ocr_pruebas_creado_en` (`creado_en`),
  KEY `idx_ocr_pruebas_mime` (`mime_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `token_hash` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'SHA-256 del token enviado por correo',
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `used_at` datetime DEFAULT NULL,
  `ip_solicitud` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_token_hash` (`token_hash`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `reportes_reservas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reportes_reservas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre_original` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruta_archivo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tamano_bytes` bigint unsigned DEFAULT NULL,
  `mime_type` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario_id` int NOT NULL,
  `estado` enum('pendiente','procesando','completado','error') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `filas_total` int unsigned NOT NULL DEFAULT '0',
  `filas_aplicadas` int unsigned NOT NULL DEFAULT '0',
  `filas_sin_coincidencia` int unsigned NOT NULL DEFAULT '0',
  `fecha_procesado` timestamp NULL DEFAULT NULL,
  `fecha_subida` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reportes_reservas_fecha` (`fecha_subida`),
  KEY `idx_reportes_reservas_usuario` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `reportes_reservas_lineas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reportes_reservas_lineas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reporte_id` int NOT NULL,
  `fila_excel` int NOT NULL,
  `mov` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mov_id` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mov_id_norm` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_emision` date DEFAULT NULL,
  `dias_reserva` int DEFAULT NULL,
  `nombre_sucursal` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombre_vendedor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cliente_codigo` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombre_cliente` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cedula` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cedula_norm` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo_cliente` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo_norm` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marca` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modelo` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `anio` int DEFAULT NULL,
  `kilometraje` int DEFAULT NULL,
  `precio_total` decimal(15,2) DEFAULT NULL,
  `abono_monto` decimal(15,2) DEFAULT NULL,
  `abono_porcentaje` decimal(5,2) DEFAULT NULL,
  `unidad` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `chasis` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `placas` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `datos_excel_json` json DEFAULT NULL,
  `solicitud_id` int DEFAULT NULL,
  `vehiculo_id` int DEFAULT NULL,
  `match_por` enum('cedula','email','nombre','ninguno') COLLATE utf8mb4_unicode_ci DEFAULT 'ninguno',
  `estado` enum('pendiente','aplicado','sin_coincidencia','error') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `mensaje` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_rr_lineas_mov_id_norm` (`mov_id_norm`),
  KEY `idx_rr_lineas_reporte` (`reporte_id`),
  KEY `idx_rr_lineas_solicitud` (`solicitud_id`),
  KEY `idx_rr_lineas_cedula_norm` (`cedula_norm`),
  KEY `idx_rr_lineas_correo_norm` (`correo_norm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `activo` tinyint(1) DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `seguridad_rate_limit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seguridad_rate_limit` (
  `bucket` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `clave` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `intentos` int NOT NULL DEFAULT '0',
  `ventana_inicio` datetime NOT NULL,
  `bloqueado_hasta` datetime DEFAULT NULL,
  PRIMARY KEY (`bucket`,`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solicitudes_credito`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitudes_credito` (
  `id` int NOT NULL AUTO_INCREMENT,
  `gestor_id` int NOT NULL,
  `banco_id` int DEFAULT NULL,
  `ejecutivo_ventas_id` int DEFAULT NULL,
  `evaluacion_seleccionada` int DEFAULT NULL,
  `evaluacion_en_reevaluacion` int DEFAULT NULL,
  `fecha_aprobacion_propuesta` timestamp NULL DEFAULT NULL,
  `comentario_seleccion_propuesta` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `criterio_seleccion_propuesta` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Motivo de aceptación de la propuesta (select obligatorio)',
  `vendedor_id` int DEFAULT NULL,
  `tipo_persona` enum('Natural','Juridica') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_cliente` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cedula` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `edad` int DEFAULT NULL,
  `genero` enum('Masculino','Femenino','Otro') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono_principal` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_pipedrive` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_cliente_pipedrive` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_deal_pipedrive` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `forma_pago_pipedrive` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `provincia` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `distrito` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corregimiento` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `barriada` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `casa_edif` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_casa_apto` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `casado` tinyint(1) DEFAULT '0',
  `hijos` int DEFAULT '0',
  `perfil_financiero` enum('Asalariado','Jubilado','Independiente') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ingreso` decimal(15,2) DEFAULT NULL,
  `tiempo_laborar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profesion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ocupacion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombre_empresa_negocio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estabilidad_laboral` date DEFAULT NULL,
  `fecha_constitucion` date DEFAULT NULL,
  `continuidad_laboral` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marca_auto` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modelo_auto` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `año_auto` int DEFAULT NULL,
  `kilometraje` int DEFAULT NULL,
  `precio_especial` decimal(15,2) DEFAULT NULL,
  `abono_porcentaje` decimal(5,2) DEFAULT NULL,
  `abono_monto` decimal(15,2) DEFAULT NULL,
  `comentarios_gestor` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `score_apc` decimal(10,2) DEFAULT NULL COMMENT 'Score APC del cliente (pestaÃ±a AnÃ¡lisis)',
  `ejecutivo_banco` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `respuesta_banco` enum('Pendiente','Aprobado','Pre Aprobado','Aprobado Condicional','Rechazado') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  `letra` decimal(15,2) DEFAULT NULL,
  `plazo` int DEFAULT NULL,
  `abono_banco` decimal(15,2) DEFAULT NULL,
  `promocion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comentarios_ejecutivo_banco` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `respuesta_cliente` enum('Pendiente','Acepta','Rechaza') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  `motivo_respuesta` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_envio_proforma` date DEFAULT NULL,
  `fecha_firma_cliente` date DEFAULT NULL,
  `fecha_poliza` date DEFAULT NULL,
  `fecha_carta_promesa` date DEFAULT NULL,
  `comentarios_fi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `estado` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Nueva',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `financiamiento_registro_id` int DEFAULT NULL COMMENT 'ID en financiamiento_registros',
  `ao_auto` int DEFAULT NULL,
  `archivada` tinyint(1) NOT NULL DEFAULT '0',
  `fecha_archivado` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_gestor` (`gestor_id`),
  KEY `idx_estado` (`estado`),
  KEY `idx_respuesta_banco` (`respuesta_banco`),
  KEY `idx_fecha_creacion` (`fecha_creacion`),
  KEY `idx_email` (`email`),
  KEY `idx_cedula` (`cedula`),
  KEY `idx_banco` (`banco_id`),
  KEY `idx_vendedor` (`vendedor_id`),
  KEY `idx_evaluacion_seleccionada` (`evaluacion_seleccionada`),
  KEY `idx_evaluacion_reevaluacion` (`evaluacion_en_reevaluacion`),
  KEY `idx_fecha_aprobacion_propuesta` (`fecha_aprobacion_propuesta`),
  KEY `idx_ejecutivo_ventas_id` (`ejecutivo_ventas_id`),
  KEY `idx_solicitudes_archivada` (`archivada`),
  CONSTRAINT `fk_solicitudes_banco` FOREIGN KEY (`banco_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_solicitudes_vendedor` FOREIGN KEY (`vendedor_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `solicitudes_credito_ibfk_1` FOREIGN KEY (`gestor_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `solicitudes_credito_ibfk_2` FOREIGN KEY (`evaluacion_seleccionada`) REFERENCES `evaluaciones_banco` (`id`) ON DELETE SET NULL,
  CONSTRAINT `solicitudes_credito_ibfk_3` FOREIGN KEY (`evaluacion_en_reevaluacion`) REFERENCES `evaluaciones_banco` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `usuario_actividad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_actividad` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int DEFAULT NULL,
  `session_key` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `evento` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'login, logout, page_view, click, action, heartbeat, visibility, login_failed',
  `pagina` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `seccion` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `detalle` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ua_usuario_fecha` (`usuario_id`,`created_at`),
  KEY `idx_ua_evento_fecha` (`evento`,`created_at`),
  KEY `idx_ua_created` (`created_at`),
  KEY `idx_ua_session` (`session_key`),
  KEY `idx_ua_ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `usuario_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `rol_id` int NOT NULL,
  `fecha_asignacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_usuario_rol` (`usuario_id`,`rol_id`),
  KEY `rol_id` (`rol_id`),
  CONSTRAINT `usuario_roles_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `usuario_roles_ibfk_2` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pais` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cargo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `banco_id` int DEFAULT NULL,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_cobrador` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_vendedor` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `primer_acceso` tinyint(1) DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_banco` (`banco_id`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`banco_id`) REFERENCES `bancos` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `usuarios_banco_solicitudes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios_banco_solicitudes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `usuario_banco_id` int NOT NULL,
  `estado` enum('activo','inactivo') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'activo',
  `fecha_asignacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_desactivacion` timestamp NULL DEFAULT NULL,
  `creado_por` int NOT NULL,
  `correos_enviados` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_asignacion` (`solicitud_id`,`usuario_banco_id`),
  KEY `creado_por` (`creado_por`),
  KEY `idx_usuarios_banco_solicitud` (`solicitud_id`),
  KEY `idx_usuarios_banco_usuario` (`usuario_banco_id`),
  KEY `idx_usuarios_banco_estado` (`estado`),
  CONSTRAINT `usuarios_banco_solicitudes_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `usuarios_banco_solicitudes_ibfk_2` FOREIGN KEY (`usuario_banco_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `usuarios_banco_solicitudes_ibfk_3` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `vehiculos_solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehiculos_solicitud` (
  `id` int NOT NULL AUTO_INCREMENT,
  `solicitud_id` int NOT NULL,
  `marca` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modelo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `anio` int DEFAULT NULL,
  `kilometraje` int DEFAULT NULL,
  `precio` decimal(15,2) DEFAULT NULL,
  `abono_porcentaje` decimal(5,2) DEFAULT NULL,
  `abono_monto` decimal(15,2) DEFAULT NULL,
  `unidad` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `orden` int DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `apartado` tinyint(1) NOT NULL DEFAULT '0',
  `apartado_en` timestamp NULL DEFAULT NULL,
  `mov_id_reserva` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_solicitud` (`solicitud_id`),
  KEY `idx_orden` (`orden`),
  CONSTRAINT `vehiculos_solicitud_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_credito` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
