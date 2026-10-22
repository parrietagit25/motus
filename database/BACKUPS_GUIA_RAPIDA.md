# Backups automáticos (Motus)

> El script lee `MYSQL_DATABASE` y `MYSQL_ROOT_PASSWORD` de `/root/baes/.env`. No escriba contraseñas en comandos, documentación ni crontab.

## 1) Subir scripts al servidor

Después de `git push` en local:

```bash
cd /root/baes
git pull
chmod +x database/backup_mysql_motus.sh
chmod +x database/restore_mysql_motus.sh
```

## 2) Probar backup manual

Si aparece `Permission denied`, el script no es ejecutable (o use `bash` como en la segunda línea):

```bash
chmod +x /root/baes/database/backup_mysql_motus.sh /root/baes/database/restore_mysql_motus.sh
```

```bash
BACKUP_DIR=/root/backups/motus_db RETENTION_DAYS=14 \
/root/baes/database/backup_mysql_motus.sh
```

Alternativa sin `chmod` (siempre funciona):

```bash
BACKUP_DIR=/root/backups/motus_db RETENTION_DAYS=14 \
bash /root/baes/database/backup_mysql_motus.sh
```

Verifica:

```bash
ls -lh /root/backups/motus_db
ls -lh /root/backups/motus_db/logs | tail
```

## 3) Programar cron diario (03:30 AM)

```bash
crontab -e
```

Agregar línea:

```cron
30 3 * * * BACKUP_DIR=/root/backups/motus_db RETENTION_DAYS=14 /root/baes/database/backup_mysql_motus.sh >> /root/backups/motus_db/cron.log 2>&1
```

Ver cron instalado:

```bash
crontab -l
```

## 4) Restore (emergencia)

```bash
/root/baes/database/restore_mysql_motus.sh /root/backups/motus_db/motus_baes_YYYY-MM-DD_HHMMSS.sql.gz
```

## 5) Recomendado (semanal)

- Probar restore en una base temporal (`motus_baes_restore_test`) y validar `SHOW TABLES`.
- Confirmar que se crean archivos `.sql.gz` + `.sha256`.
- Confirmar que la retención borra respaldos viejos automáticamente.
