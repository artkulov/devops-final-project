# DevOps Final Project: Infrastructure with VPN, PKI, and Monitoring

## Описание проекта

Инфраструктура для компании UI/UX Design, включающая:
- Удостоверяющий центр (PKI) на базе Easy-RSA
- VPN-сервер на базе OpenVPN
- Систему мониторинга на базе Prometheus + Alertmanager
- Систему резервного копирования

## Структура репозитория
<pre>
devops-final-project/
├── <b>scripts/</b>
│   ├── setup-pki.sh                 # Установка PKI (Этап 1)
│   ├── setup-vpn.sh                 # Установка OpenVPN (Этап 2)
│   ├── setup-monitoring.sh          # Установка Prometheus (Этап 3)
│   ├── setup-node-exporter.sh       # Установка Node Exporter
│   ├── setup-openvpn-exporter.sh    # Установка OpenVPN Exporter
│   ├── backup-pki.sh                # Бэкап PKI (Этап 4)
│   └── restore-pki.sh               # Восстановление PKI (Этап 4)
├── <b>packages/</b>
│   ├── easy-rsa-config_1.0_all.deb
│   ├── prometheus-config_1.0_all.deb
│   ├── alertmanager-config_1.0_all.deb
│   └── vpn-server-config_1.0_all.deb
├── <b>docs/</b>
│   └── Резервное_копирование.docx
└── README.md
</pre>

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
