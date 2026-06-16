#!/bin/sh

# ============================================
# НАСТРОЙКА ИНТЕРФЕЙСА AWG10
# ============================================

INTERFACE_NAME="awg10"
CONFIG_NAME="amneziawg_awg10"
PROTO="amneziawg"
ZONE_NAME="awg"

# Получаем параметры из существующей конфигурации
PrivateKey=$(uci get network.${INTERFACE_NAME}.private_key 2>/dev/null)
Address=$(uci get network.${INTERFACE_NAME}.addresses 2>/dev/null | cut -d' ' -f1)
MTU=$(uci get network.${INTERFACE_NAME}.mtu 2>/dev/null)
Jc=$(uci get network.${INTERFACE_NAME}.awg_jc 2>/dev/null)
Jmin=$(uci get network.${INTERFACE_NAME}.awg_jmin 2>/dev/null)
Jmax=$(uci get network.${INTERFACE_NAME}.awg_jmax 2>/dev/null)
S1=$(uci get network.${INTERFACE_NAME}.awg_s1 2>/dev/null)
S2=$(uci get network.${INTERFACE_NAME}.awg_s2 2>/dev/null)
H1=$(uci get network.${INTERFACE_NAME}.awg_h1 2>/dev/null)
H2=$(uci get network.${INTERFACE_NAME}.awg_h2 2>/dev/null)
H3=$(uci get network.${INTERFACE_NAME}.awg_h3 2>/dev/null)
H4=$(uci get network.${INTERFACE_NAME}.awg_h4 2>/dev/null)
I1=$(uci get network.${INTERFACE_NAME}.awg_i1 2>/dev/null)

# Получаем параметры пира
PUBLIC_KEY=$(uci get network.@${CONFIG_NAME}[0].public_key 2>/dev/null)
ENDPOINT_HOST=$(uci get network.@${CONFIG_NAME}[0].endpoint_host 2>/dev/null)
ENDPOINT_PORT=$(uci get network.@${CONFIG_NAME}[0].endpoint_port 2>/dev/null)

if [ -z "$PrivateKey" ] || [ -z "$Address" ] || [ -z "$PUBLIC_KEY" ]; then
    echo "Ошибка: Не найдена конфигурация интерфейса $INTERFACE_NAME"
    echo "Пожалуйста, сначала настройте интерфейс вручную или через скрипт установки"
    exit 1
fi

echo "Настройка интерфейса $INTERFACE_NAME..."

# Настройка интерфейса
uci set network.${INTERFACE_NAME}=interface
uci set network.${INTERFACE_NAME}.proto=$PROTO

if ! uci show network | grep -q ${CONFIG_NAME}; then
    uci add network ${CONFIG_NAME}
fi

uci set network.${INTERFACE_NAME}.private_key="$PrivateKey"
uci del network.${INTERFACE_NAME}.addresses
uci add_list network.${INTERFACE_NAME}.addresses="$Address"
uci set network.${INTERFACE_NAME}.mtu="${MTU:-1280}"
uci set network.${INTERFACE_NAME}.awg_jc="${Jc:-120}"
uci set network.${INTERFACE_NAME}.awg_jmin="${Jmin:-23}"
uci set network.${INTERFACE_NAME}.awg_jmax="${Jmax:-911}"
uci set network.${INTERFACE_NAME}.awg_s1="${S1:-0}"
uci set network.${INTERFACE_NAME}.awg_s2="${S2:-0}"
uci set network.${INTERFACE_NAME}.awg_h1="${H1:-1}"
uci set network.${INTERFACE_NAME}.awg_h2="${H2:-2}"
uci set network.${INTERFACE_NAME}.awg_h3="${H3:-3}"
uci set network.${INTERFACE_NAME}.awg_h4="${H4:-4}"
uci set network.${INTERFACE_NAME}.awg_i1="$I1"
uci set network.${INTERFACE_NAME}.nohostroute='1'

# Настройка пира
if [ -n "$PUBLIC_KEY" ]; then
    uci set network.@${CONFIG_NAME}[0].description="${INTERFACE_NAME}_peer"
    uci set network.@${CONFIG_NAME}[0].public_key="$PUBLIC_KEY"
    uci set network.@${CONFIG_NAME}[0].endpoint_host="$ENDPOINT_HOST"
    uci set network.@${CONFIG_NAME}[0].endpoint_port="$ENDPOINT_PORT"
    uci set network.@${CONFIG_NAME}[0].persistent_keepalive='25'
    uci set network.@${CONFIG_NAME}[0].allowed_ips='0.0.0.0/0'
    uci set network.@${CONFIG_NAME}[0].route_allowed_ips='0'
fi

uci commit network

# Настройка firewall зоны
if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
    uci add firewall zone
    uci set firewall.@zone[-1].name="$ZONE_NAME"
    uci set firewall.@zone[-1].network="$INTERFACE_NAME"
    uci set firewall.@zone[-1].forward='REJECT'
    uci set firewall.@zone[-1].output='ACCEPT'
    uci set firewall.@zone[-1].input='REJECT'
    uci set firewall.@zone[-1].masq='1'
    uci set firewall.@zone[-1].mtu_fix='1'
    uci set firewall.@zone[-1].family='ipv4'
    uci commit firewall
fi

# Настройка форвардинга
if ! uci show firewall | grep -q "@forwarding.*name='${ZONE_NAME}'"; then
    uci add firewall forwarding
    uci set firewall.@forwarding[-1]=forwarding
    uci set firewall.@forwarding[-1].name="${ZONE_NAME}"
    uci set firewall.@forwarding[-1].dest="${ZONE_NAME}"
    uci set firewall.@forwarding[-1].src='lan'
    uci set firewall.@forwarding[-1].family='ipv4'
    uci commit firewall
fi

# Добавляем интерфейс в зону если его там нет
ZONES=$(uci show firewall | grep "zone$" | cut -d'=' -f1)
for zone in $ZONES; do
    CURR_ZONE_NAME=$(uci get $zone.name)
    if [ "$CURR_ZONE_NAME" = "$ZONE_NAME" ]; then
        if ! uci get $zone.network | grep -q "$INTERFACE_NAME"; then
            uci add_list $zone.network="$INTERFACE_NAME"
            uci commit firewall
        fi
    fi
done

echo "Перезапуск firewall и network..."
service firewall restart

echo "Отключение интерфейса $INTERFACE_NAME..."
ifdown $INTERFACE_NAME

echo "Включение интерфейса $INTERFACE_NAME..."
ifup $INTERFACE_NAME

echo "Ожидание поднятия интерфейса..."
sleep 5

# Проверка работы интерфейса
if ping -c 1 -I $INTERFACE_NAME 8.8.8.8 >/dev/null 2>&1; then
    echo "✓ Интерфейс $INTERFACE_NAME успешно настроен и работает"
else
    echo "✗ Интерфейс $INTERFACE_NAME не отвечает"
    echo "Проверьте конфигурацию и параметры подключения"
fi

echo "Настройка завершена"
