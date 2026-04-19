#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

if [ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null; then
    error "Требуются права sudo"
fi

MONITOR_IP="10.129.0.8"

# Установка зависимостей
log "Установка зависимостей..."
sudo apt update
sudo apt install golang-go git -y

# Клонирование и сборка экспортёра
if [ ! -f "/usr/local/bin/openvpn_exporter" ]; then
    log "Сборка OpenVPN Exporter..."
    cd /tmp
    rm -rf openvpn_exporter 2>/dev/null || true
    git clone https://github.com/kumina/openvpn_exporter.git
    cd openvpn_exporter
    go build -o openvpn_exporter .
    sudo mv openvpn_exporter /usr/local/bin/
    sudo chmod +x /usr/local/bin/openvpn_exporter
else
    log "OpenVPN Exporter уже установлен"
fi

# Создание systemd сервиса
log "Создание systemd сервиса..."
sudo tee /etc/systemd/system/openvpn-exporter.service > /dev/null << 'SERVICE_EOF'
[Unit]
Description=OpenVPN Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/openvpn_exporter \
  -openvpn.status_paths /var/log/openvpn/openvpn-status.log \
  -web.listen-address :9176
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Настройка файрвола
log "Настройка файрвола..."
sudo ufw allow from $MONITOR_IP to any port 9176 comment 'OpenVPN Exporter' 2>/dev/null || true

# Запуск сервиса
sudo systemctl daemon-reload
sudo systemctl enable openvpn-exporter
sudo systemctl restart openvpn-exporter

log "OpenVPN Exporter установлен и запущен."
