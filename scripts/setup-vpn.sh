#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

log "Начало настройки VPN-сервера..."

# Проверка запуска от root
if [ "$EUID" -eq 0 ]; then
    error "Скрипт не должен запускаться от root"
fi

# Установка пакетов
log "Установка OpenVPN и Easy-RSA..."
sudo apt update
sudo apt install openvpn easy-rsa ufw iptables-persistent -y

# Настройка файрвола
log "Настройка файрвола..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default allow routed
sudo ufw allow 22 comment 'SSH'
sudo ufw allow 1194/udp comment 'OpenVPN'
sudo ufw allow 443/tcp comment 'OpenVPN HTTPS'
sudo ufw --force enable

# Создание директорий
log "Создание директорий..."
sudo mkdir -p /etc/openvpn/server

if [ ! -d "$HOME/easy-rsa-client" ]; then
    make-cadir ~/easy-rsa-client
fi

# Инициализация Easy-RSA
cd ~/easy-rsa-client
if [ ! -d "pki" ]; then
    ./easyrsa init-pki
fi

# Генерация ключа сервера (если нет)
if [ ! -f "pki/private/vpn-server.key" ]; then
    log "Генерация ключа VPN-сервера..."
    ./easyrsa --batch gen-req vpn-server nopass
fi

# Генерация DH и TLS ключей
log "Генерация DH ключа..."
./easyrsa gen-dh
sudo cp pki/dh.pem /etc/openvpn/server/

if [ ! -f "/etc/openvpn/server/ta.key" ]; then
    log "Генерация TLS ключа..."
    sudo openvpn --genkey secret /etc/openvpn/server/ta.key
fi

# Настройка IP forwarding
log "Настройка IP forwarding..."
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p

# Настройка NAT
log "Настройка NAT..."
INTERFACE=$(ip route | grep default | awk '{print $5}')
sudo iptables -t nat -C POSTROUTING -s 10.8.0.0/24 -o "$INTERFACE" -j MASQUERADE 2>/dev/null || \
    sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$INTERFACE" -j MASQUERADE

# Сохраняем правила iptables
sudo apt install iptables-persistent -y
echo "y" | sudo netfilter-persistent save

log "=============================================="
log "Базовая настройка VPN-сервера завершена!"
log "Не забудьте получить сертификаты с PKI-сервера"
log "=============================================="
