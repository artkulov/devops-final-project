#!/bin/bash
set -euo pipefail

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

log "Начало настройки PKI сервера..."

# Проверка запуска от root
if [ "$EUID" -eq 0 ]; then
    error "Скрипт не должен запускаться от root. Используйте обычного пользователя с sudo."
fi

# Проверка наличия sudo
if ! command -v sudo &> /dev/null; then
    error "sudo не установлен. Установите sudo: apt install sudo"
fi

# Установка easy-rsa
log "Установка Easy-RSA..."
if ! dpkg -s easy-rsa >/dev/null 2>&1; then
    sudo apt update
    sudo apt install easy-rsa -y
else
    log "Easy-RSA уже установлен"
fi

# Создание рабочей директории PKI (если не существует)
if [ ! -d "$HOME/easy-rsa" ]; then
    log "Создание директории PKI..."
    make-cadir "$HOME/easy-rsa"
else
    warn "Директория PKI уже существует, пропускаем создание"
fi

cd "$HOME/easy-rsa"

# Создание файла vars (если не существует)
if [ ! -f "vars" ]; then
    log "Создание файла vars..."
    cat > vars << 'VARS_EOF'
set_var EASYRSA_REQ_COUNTRY    "RU"
set_var EASYRSA_REQ_PROVINCE   "Moscow"
set_var EASYRSA_REQ_CITY       "Krasnodar"
set_var EASYRSA_REQ_ORG        "MyCompany"
set_var EASYRSA_REQ_EMAIL      "admin@mycompany.local"
set_var EASYRSA_REQ_OU         "IT"
set_var EASYRSA_ALGO           ec
set_var EASYRSA_CURVE          secp384r1
set_var EASYRSA_CA_EXPIRE      3650
set_var EASYRSA_CERT_EXPIRE    825
VARS_EOF
else
    warn "Файл vars уже существует, пропускаем создание"
fi

# Инициализация PKI (если не существует)
if [ ! -d "pki" ]; then
    log "Инициализация PKI..."
    ./easyrsa init-pki
else
    warn "PKI уже инициализирована"
fi

# Создание корневого сертификата (если не существует)
if [ ! -f "pki/ca.crt" ]; then
    log "Создание корневого сертификата..."
    ./easyrsa --batch build-ca nopass
else
    warn "Корневой сертификат уже существует"
fi

log "=============================================="
log "Настройка PKI завершена успешно!"
log "Корневой сертификат: $HOME/easy-rsa/pki/ca.crt"
log "Приватный ключ CA: $HOME/easy-rsa/pki/private/ca.key"
log "=============================================="
