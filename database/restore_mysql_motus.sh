#!/usr/bin/env bash
set -euo pipefail

# Restore de respaldo .sql.gz hacia motus_baes
# Uso:
#   ./database/restore_mysql_motus.sh /root/backups/motus_db/motus_baes_AAAA-MM-DD_HHMMSS.sql.gz
#
# Nota: Este script REEMPLAZA la base destino.
# Credencial: ENV_FILE (por defecto /root/.motus/mysql_root.env, 600, fuera del bind mount).
# La contrasena nunca va en argumentos: se escribe por stdin en un archivo de opciones
# temporal (600) dentro del contenedor y se elimina al terminar.

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <archivo_backup.sql.gz> [nombre_base]"
  exit 1
fi

BACKUP_FILE="$1"
DB_NAME="${2:-motus_baes}"
DB_CONTAINER="${DB_CONTAINER:-motus_db}"
DB_USER="${DB_USER:-root}"
if [[ -z "${ENV_FILE:-}" ]]; then
  if [[ -f /root/.motus/mysql_root.env ]]; then ENV_FILE=/root/.motus/mysql_root.env; else ENV_FILE=/root/baes/.env; fi
fi
env_val() {
  grep -E "^$1=" "${ENV_FILE}" 2>/dev/null | head -1 | cut -d= -f2- \
    | sed -e 's/\r$//' -e 's/^["'\'']//' -e 's/["'\'']$//'
}
DB_PASS="${DB_PASS:-$(env_val MYSQL_ROOT_PASSWORD)}"
if [[ -z "${DB_PASS}" ]]; then
  echo "[ERROR] Contraseña vacía: defina MYSQL_ROOT_PASSWORD en ${ENV_FILE}"
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

CNF=/tmp/.motus_restore_$$.cnf
limpiar_cnf() { docker exec "${DB_CONTAINER}" rm -f "${CNF}" >/dev/null 2>&1 || true; }
trap limpiar_cnf EXIT
printf '[client]\nuser=%s\npassword=%s\n' "${DB_USER}" "${DB_PASS}" \
  | docker exec -i "${DB_CONTAINER}" sh -c "umask 077; cat > ${CNF}"
unset DB_PASS
MYSQL=(docker exec -i "${DB_CONTAINER}" mysql --defaults-extra-file="${CNF}")
MYSQLDUMP=(docker exec -i "${DB_CONTAINER}" mysqldump --defaults-extra-file="${CNF}")

echo "[INFO] Creando backup previo de seguridad..."
PRE_TAG="$(date +%F_%H%M%S)"
mkdir -p /root/backups/motus_db
"${MYSQLDUMP[@]}" --single-transaction --routines --triggers --no-tablespaces "${DB_NAME}" > "/root/backups/motus_db/${DB_NAME}_pre_restore_${PRE_TAG}.sql" || true

echo "[INFO] Recreando base ${DB_NAME}..."
"${MYSQL[@]}" -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`; CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "[INFO] Restaurando ${BACKUP_FILE} ..."
gunzip -c "${BACKUP_FILE}" | "${MYSQL[@]}" "${DB_NAME}"

echo "[INFO] Verificación rápida..."
"${MYSQL[@]}" -e "USE \`${DB_NAME}\`; SHOW TABLES; SELECT COUNT(*) AS total_solicitudes FROM solicitudes_credito;" || true

echo "[OK] Restore completado."
