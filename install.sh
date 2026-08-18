#!/bin/sh

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}===> Быстрая установка TG WS Proxy <===${NC}"

# 1. Только необходимые системные пакеты
opkg update
opkg install git git-http python3-light python3-cryptography coreutils-nohup ca-certificates

# 2. Клонирование без истории коммитов
cd /opt/
if [ -d "/opt/tg-ws-proxy" ]; then
    echo "Обновление..."
    cd tg-ws-proxy && git pull
else
    git clone --depth 1 https://github.com/Flowseal/tg-ws-proxy.git
    cd tg-ws-proxy
fi

# 3. Настройка IP
echo "Выберите IP адрес:"
echo "1) 0.0.0.0 (Доступен из сети)"
echo "2) 127.0.0.1 (Только локально)"
read -p "Ваш выбор [1-2, по умолчанию 1]: " choice

case $choice in
    2) LISTEN_IP="127.0.0.1" ;;
    *) LISTEN_IP="0.0.0.0" ;;
esac

# 4. Генерация секрета штатными средствами Linux
GEN_SECRET=$(hexdump -n 16 -e '4/4 "%08x"' /dev/urandom)

# 5. Автозапуск S99tgwsproxy
cat <<EOF > /opt/etc/init.d/S99tgwsproxy
#!/bin/sh

ENABLED=yes
WORKDIR="/opt/tg-ws-proxy"
PYTHON="/opt/bin/python3"
PROG="proxy.tg_ws_proxy"

PORT="1443"
SECRET="$GEN_SECRET"
ARGS="--host $LISTEN_IP --port \$PORT --secret \$SECRET"
LOG="/opt/var/log/tgwsproxy.log"

case "\$1" in
    start)
        if [ "\$ENABLED" = "yes" ]; then
            cd \$WORKDIR
            nohup \$PYTHON -m \$PROG \$ARGS > \$LOG 2>&1 &
            echo "TG WS Proxy запущен [$LISTEN_IP:\$PORT]"
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

echo -e "${GREEN}===> Готово! <===${NC}"
echo "Секрет: $GEN_SECRET"
echo "Ссылка: tg://proxy?server=192.168.1.1&port=1443&secret=dd$GEN_SECRET"
