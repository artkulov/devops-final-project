#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Проверка прав
if [ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null; then
    error "Требуются права sudo"
fi

# Установка Node Exporter
if ! dpkg -s prometheus-node-exporter >/dev/null 2>&1; then
    log "Установка Node Exporter..."
    sudo apt update
    sudo apt install prometheus-node-exporter -y
else
    log "Node Exporter уже установлен"
fi

# Настройка файрвола (доступ только с monitor-server)
MONITOR_IP="10.129.0.8"
log "Настройка файрвола для доступа с $MONITOR_IP..."
sudo ufw allow from $MONITOR_IP to any port 9100 comment 'Node Exporter for Monitor' 2>/dev/null || true

# Запуск сервиса
sudo systemctl enable prometheus-node-exporter
sudo systemctl restart prometheus-node-exporter

log "Node Exporter установлен и запущен."
