#!/usr/bin/env bash
# Automated PostgreSQL Backup Script for FxBank
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/tmp/fxbank_backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATABASE_NAME="${POSTGRES_DB:-fxbank_production}"
BACKUP_FILE="${BACKUP_DIR}/${DATABASE_NAME}_${TIMESTAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"

echo "[$(date)] Starting backup of ${DATABASE_NAME}..."

# Execute pg_dump and compress on-the-fly
pg_dump "${DATABASE_URL:-postgresql://postgres:password@localhost:5432/${DATABASE_NAME}}" \
  --clean --if-exists --no-owner --no-privileges \
  | gzip -9 > "${BACKUP_FILE}"

FILESIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
echo "[$(date)] Backup completed: ${BACKUP_FILE} (${FILESIZE})"

# Retain last 7 days of local backups
find "${BACKUP_DIR}" -name "${DATABASE_NAME}_*.sql.gz" -mtime +7 -delete
echo "[$(date)] Cleaned old backups older than 7 days."
