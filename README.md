# DevOps Final Project: Infrastructure with VPN, PKI, and Monitoring

## Описание проекта

Инфраструктура для компании UI/UX Design, включающая:
- Удостоверяющий центр (PKI) на базе Easy-RSA
- VPN-сервер на базе OpenVPN
- Систему мониторинга на базе Prometheus + Alertmanager
- Систему резервного копирования

## Структура репозитория
├── scripts/ # Bash-скрипты автоматизации
│ ├── setup-pki.sh
│ ├── setup-monitoring.sh
│ ├── setup-node-exporter.sh
│ └── setup-openvpn-exporter.sh
├── packages/ # Deb-пакеты
│ ├── easy-rsa-config_1.0_all.deb
│ ├── prometheus-config_1.0_all.deb
│ └── alertmanager-config_1.0_all.deb
├── docs/ # Документация
│ ├── Этап_4_Резервное_копирование.docx
│ ├── backup-plan.md
│ └── disaster-recovery.md
└── README.md

text

## Серверы инфраструктуры

| Сервер | Внутренний IP | Публичный IP | Роль |
|--------|---------------|--------------|------|
| pki-server | 10.129.0.12 | 111.88.144.126 | Удостоверяющий центр |
| vpn-server | 10.129.0.11 | 111.88.146.58 | OpenVPN сервер |
| monitor-server | 10.129.0.8 | 111.88.146.40 | Prometheus + Alertmanager |

## Быстрое развёртывание

1. Клонировать репозиторий
2. Скопировать скрипты на соответствующие серверы
3. Запустить скрипты установки
4. Установить deb-пакеты с конфигурациями
