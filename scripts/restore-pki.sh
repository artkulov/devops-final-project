#!/bin/bash
set -euo pipefail

BACKUP_DIR="$HOME/backups"

if [ $# -ne 1 ]; then
    echo "Использование: $0 <файл_бэкапа>"
    echo "Доступные бэкапы:"
    ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "  Нет бэкапов"
    exit 1
fi

BACKUP_FILE="$1"

echo "Восстановление PKI из $BACKUP_FILE..."

# Бэкапим текущую PKI (если есть)
if [ -d "$HOME/easy-rsa/pki" ]; then
    mv "$HOME/easy-rsa/pki" "$HOME/easy-rsa/pki.bak.$(date +%Y%m%d-%H%M%S)"
    echo "Текущая PKI сохранена в pki.bak.*"
fi

# Восстанавливаем
tar -xzf "$BACKUP_FILE" -C "$HOME"

echo "PKI восстановлена!"
ls -la "$HOME/easy-rsa/pki/"
