#!/usr/bin/env bash
set -euo pipefail

# Restore de respaldo .sql.gz hacia motus_baes
# Uso:
#   ./database/restore_mysql_motus.sh /root/backups/motus_db/motus_baes_2026-04-28_235900.sql.gz
#
# Nota: Este script REEMPLAZA la base destino.

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <archivo_backup.sql.gz> [nombre_base]"
  exit 1
fi

BACKUP_FILE="$1"
DB_NAME="${2:-motus_baes}"
DB_CONTAINER="${DB_CONTAINER:-motus_db}"
DB_USER="${DB_USER:-root}"
ENV_FILE="${ENV_FILE:-/root/baes/.env}"
env_val() {
  grep -E "^$1=" "${ENV_FILE}" 2>/dev/null | head -1 | cut -d= -f2- \
    | sed -e 's/\r$//' -e 's/^["'\'']//' -e 's/["'\'']$//'
}
DB_PASS="${DB_PASS:-$(env_val MYSQL_ROOT_PASSWORD)}"
if [[ -z "${DB_PASS}" ]]; then
  echo "[ERROR] Contraseña vacía: defina DB_PASS o MYSQL_ROOT_PASSWORD en ${ENV_FILE}"
  exit 1
fi

if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "[ERROR] No existe el archivo: ${BACKUP_FILE}"
  exit 1
fi

SHA_FILE="${BACKUP_FILE}.sha256"
if [[ -f "${SHA_FILE}" ]]; then
  echo "[INFO] Verificando checksum..."
  sha256sum -c "${SHA_FILE}"
fi

echo "[INFO] Creando backup previo de seguridad..."
PRE_TAG="$(date +%F_%H%M%S)"
mkdir -p /root/backups/motus_db
docker exec -i -e MYSQL_PWD="${DB_PASS}" "${DB_CONTAINER}" mysqldump -u"${DB_USER}" --single-transaction --routines --triggers "${DB_NAME}" > "/root/backups/motus_db/${DB_NAME}_pre_restore_${PRE_TAG}.sql" || true

echo "[INFO] Recreando base ${DB_NAME}..."
docker exec -i -e MYSQL_PWD="${DB_PASS}" "${DB_CONTAINER}" mysql -u"${DB_USER}" -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`; CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "[INFO] Restaurando ${BACKUP_FILE} ..."
gunzip -c "${BACKUP_FILE}" | docker exec -i -e MYSQL_PWD="${DB_PASS}" "${DB_CONTAINER}" mysql -u"${DB_USER}" "${DB_NAME}"

echo "[INFO] Verificación rápida..."
docker exec -i -e MYSQL_PWD="${DB_PASS}" "${DB_CONTAINER}" mysql -u"${DB_USER}" -e "USE \`${DB_NAME}\`; SHOW TABLES; SELECT COUNT(*) AS total_solicitudes FROM solicitudes_credito;" || true

echo "[OK] Restore completado."
