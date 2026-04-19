# TG WS Proxy for Keenetic (Entware)

Скрипт устанавливающий и запускающий [TG WS Proxy](https://github.com/Flowseal/tg-ws-proxy), оптимизированный для работы на роутерах Keenetic с установленной средой Entware.

Этот прокси позволяет обходить ограничения и ускорять Telegram, упаковывая MTProto трафик в WebSocket (TLS).

## Особенности версии для Keenetic
- **Оптимизация памяти**: Минимум зависимостей.
- **Автозапуск**: Интеграция в систему инициализации `/opt/etc/init.d/`.
- **Удаленная настройка**: Возможность выбора IP-адреса для прослушивания (локальный или внешний).

## Быстрая установка (Keenetic SSH)

Просто вставьте эту команду в терминал вашего роутера и следуйте инструкции:

```bash
curl -sL [https://raw.githubusercontent.com/MurKa2009/tg-ws-proxy-keenetic/main/install.sh](https://raw.githubusercontent.com/MurKa2009/tg-ws-proxy-keenetic/main/install.sh) | sh
