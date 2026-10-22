#!/usr/bin/env bash
set -euo pipefail

# Backup automático de MySQL (contenedor motus_db)
# - Credenciales desde ENV_FILE (MYSQL_DATABASE, MYSQL_ROOT_PASSWORD); nunca en el crontab.
# - Genera dump .sql.gz + checksum .sha256 solo si el dump terminó completo.
# - Si falla, no toca los respaldos anteriores ni ejecuta la limpieza por retención.

ENV_FILE="${ENV_FILE:-/root/baes/.env}"
DB_CONTAINER="${DB_CONTAINER:-motus_db}"
BACKUP_DIR="${BACKUP_DIR:-/root/backups/motus_db}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DATE_TAG="$(date +%F_%H%M%S)"

env_val() {
  grep -E "^$1=" "${ENV_FILE}" 2>/dev/null | head -1 | cut -d= -f2- \
    | sed -e 's/\r$//' -e 's/^["'\'']//' -e 's/["'\'']$//'
}

DB_NAME="${DB_NAME:-$(env_val MYSQL_DATABASE)}"
DB_USER="${DB_USER:-root}"
if [[ -z "${DB_PASS:-}" ]]; then
  if [[ "${DB_USER}" == "root" ]]; then
    DB_PASS="$(env_val MYSQL_ROOT_PASSWORD)"
  else
    DB_PASS="$(env_val MYSQL_PASSWORD)"
  fi
fi

mkdir -p "${BACKUP_DIR}/logs"
chmod 700 "${BACKUP_DIR}"

OUT_SQL_GZ="${BACKUP_DIR}/${DB_NAME}_${DATE_TAG}.sql.gz"
TMP_SQL_GZ="${OUT_SQL_GZ}.partial"
OUT_SHA="${OUT_SQL_GZ}.sha256"
LOG_FILE="${BACKUP_DIR}/logs/backup_${DATE_TAG}.log"

fallar() {
  echo "[ERROR] $(date -Is) $1"
  rm -f "${TMP_SQL_GZ}"
  exit 1
}

{
  echo "[INFO] $(date -Is) Iniciando backup de ${DB_NAME}..."
  echo "[INFO] Contenedor: ${DB_CONTAINER}"
  echo "[INFO] Destino: ${OUT_SQL_GZ}"

  [[ -n "${DB_NAME}" ]] || fallar "MYSQL_DATABASE vacío (revise ${ENV_FILE})."
  [[ -n "${DB_PASS}" ]] || fallar "Contraseña vacía (revise ${ENV_FILE})."

  # Dump consistente para InnoDB; la contraseña va por variable de entorno, no por argumento.
  if ! docker exec -e MYSQL_PWD="${DB_PASS}" "${DB_CONTAINER}" mysqldump \
      -u"${DB_USER}" \
      --single-transaction \
      --routines \
      --triggers \
      --events \
      --no-tablespaces \
      --set-gtid-purged=OFF \
      --default-character-set=utf8mb4 \
      "${DB_NAME}" | gzip -6 > "${TMP_SQL_GZ}"; then
    fallar "mysqldump terminó con error."
  fi

  gzip -t "${TMP_SQL_GZ}" || fallar "El archivo comprimido no es válido."
  if ! zcat "${TMP_SQL_GZ}" | tail -n 1 | grep -q '^-- Dump completed'; then
    fallar "El dump no terminó completo."
  fi

  mv "${TMP_SQL_GZ}" "${OUT_SQL_GZ}"
  chmod 600 "${OUT_SQL_GZ}"
  sha256sum "${OUT_SQL_GZ}" > "${OUT_SHA}"
  echo "[INFO] Tamaño: $(du -h "${OUT_SQL_GZ}" | cut -f1)"
  echo "[INFO] SHA256 generado: ${OUT_SHA}"

  # Limpieza por retención (solo tras un backup válido)
  find "${BACKUP_DIR}" -maxdepth 1 -type f -name "${DB_NAME}_*.sql.gz" -mtime +"${RETENTION_DAYS}" -print -delete || true
  find "${BACKUP_DIR}" -maxdepth 1 -type f -name "${DB_NAME}_*.sql.gz.sha256" -mtime +"${RETENTION_DAYS}" -print -delete || true
  find "${BACKUP_DIR}/logs" -maxdepth 1 -type f -name "backup_*.log" -mtime +"${RETENTION_DAYS}" -print -delete || true

  echo "[INFO] Últimos backups:"
  ls -1t "${BACKUP_DIR}/${DB_NAME}_"*.sql.gz 2>/dev/null | head -n 5 || true

  echo "[OK] $(date -Is) Backup completado."
} 2>&1 | tee -a "${LOG_FILE}"
