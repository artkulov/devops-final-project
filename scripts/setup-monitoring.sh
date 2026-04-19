#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

log "Начало установки системы мониторинга..."

# Проверка запуска от root
if [ "$EUID" -eq 0 ]; then
    error "Скрипт не должен запускаться от root. Используйте обычного пользователя с sudo."
fi

# Установка Prometheus и Node Exporter
log "Установка Prometheus и Node Exporter..."
if ! dpkg -s prometheus >/dev/null 2>&1; then
    sudo apt update
    sudo apt install prometheus prometheus-node-exporter -y
else
    warn "Prometheus уже установлен"
fi

# Установка Alertmanager
log "Установка Alertmanager..."
if ! dpkg -s prometheus-alertmanager >/dev/null 2>&1; then
    sudo apt install prometheus-alertmanager -y
else
    warn "Alertmanager уже установлен"
fi

# Настройка файрвола
log "Настройка файрвола..."
sudo ufw allow 22 comment 'SSH' 2>/dev/null || true
sudo ufw allow 9090 comment 'Prometheus Web UI' 2>/dev/null || true
sudo ufw allow 9093 comment 'Alertmanager' 2>/dev/null || true

# Включение и запуск сервисов
log "Запуск сервисов..."
sudo systemctl enable prometheus prometheus-node-exporter prometheus-alertmanager
sudo systemctl restart prometheus prometheus-node-exporter prometheus-alertmanager

log "=============================================="
log "Установка мониторинга завершена!"
log "Prometheus: http://$(hostname -I | awk '{print $1}'):9090"
log "Alertmanager: http://$(hostname -I | awk '{print $1}'):9093"
log "=============================================="
