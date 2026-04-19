#!/bin/sh

# Цветной вывод
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}===> Начинаем установку TG WS Proxy для Keenetic <===${NC}"

# 1. Установка системных зависимостей
echo "Установка пакетов Entware..."
opkg update
opkg install git git-http python3-light python3-pip python3-cryptography python3-multidict coreutils-nohup

# 2. Клонирование репозитория
cd /opt/
if [ -d "/opt/tg-ws-proxy" ]; then
    echo "Папка проекта уже существует, обновляем..."
    cd tg-ws-proxy && git pull
else
    git clone https://github.com/Flowseal/tg-ws-proxy.git
    cd tg-ws-proxy
fi

# 3. Установка Python зависимостей
echo "Установка aiohttp..."
pip3 install --no-cache-dir aiohttp

# 4. Интерактивная настройка IP
echo -e "${GREEN}--- Настройка сети ---${NC}"
echo "Выберите IP адрес, на котором будет работать прокси:"
echo "1) 0.0.0.0 (Доступен отовсюду: из дома и из интернета)"
echo "2) 127.0.0.1 (Только для самого роутера)"
echo "3) Ввести свой IP вручную"
read -p "Ваш выбор [1-3]: " choice

case $choice in
    1) LISTEN_IP="0.0.0.0" ;;
    2) LISTEN_IP="127.0.0.1" ;;
    3) read -p "Введите IP: " LISTEN_IP ;;
    *) LISTEN_IP="0.0.0.0" ;;
esac

# 5. Генерация секрета
GEN_SECRET=$(python3 -c 'import secrets; print(secrets.token_hex(16))')

# 6. Создание скрипта автозапуска
echo "Создание скрипта автозапуска в /opt/etc/init.d/..."

cat <<EOF > /opt/etc/init.d/S99tgwsproxy
#!/bin/sh

ENABLED=yes
WORKDIR="/opt/tg-ws-proxy"
PYTHON="/opt/bin/python3"
PROG="proxy.tg_ws_proxy"

# Настройки
PORT="1443"
SECRET="$GEN_SECRET"
ARGS="--host $LISTEN_IP --port \$PORT --secret \$SECRET"
LOG="/opt/var/log/tgwsproxy.log"

case "\$1" in
    start)
        if [ "\$ENABLED" = "yes" ]; then
            cd \$WORKDIR
            /opt/bin/nohup \$PYTHON -m \$PROG \$ARGS > \$LOG 2>&1 &
            echo "TG WS Proxy запущен на \$LISTEN_IP:\$PORT"
        fi
        ;;
    stop)
        pkill -f "\$PROG"
        echo "TG WS Proxy остановлен"
        ;;
    restart)
        \$0 stop
        sleep 2
        \$0 start
        ;;
esac
EOF

chmod +x /opt/etc/init.d/S99tgwsproxy
/opt/etc/init.d/S99tgwsproxy start

echo -e "${GREEN}===> Установка завершена! <===${NC}"
echo "Ваш секрет: $GEN_SECRET"
echo "Ссылка для Telegram (локальная): tg://proxy?server=192.168.1.1&port=1443&secret=dd$GEN_SECRET"
