#!/bin/bash
set -euo pipefail

BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="pki-backup-${DATE}.tar.gz"
LOG_FILE="$HOME/backup.log"

# Создаём директорию для бэкапов
mkdir -p "$BACKUP_DIR"

# Логирование
echo "[$(date)] Starting PKI backup..." >> "$LOG_FILE"

# Архивация PKI
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$HOME" easy-rsa/pki 2>> "$LOG_FILE"

# Проверка создания архива
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "[$(date)] Backup created: $BACKUP_FILE ($(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1))" >> "$LOG_FILE"
else
    echo "[$(date)] ERROR: Backup failed!" >> "$LOG_FILE"
    exit 1
fi

# Оставляем только 7 последних бэкапов
ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm

echo "[$(date)] Cleanup completed. Current backups:" >> "$LOG_FILE"
ls -la "$BACKUP_DIR" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
