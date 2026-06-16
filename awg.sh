#!/bin/sh

# ============================================
# ФУНКЦИИ ЗАПРОСА WARP КОНФИГА
# ============================================
requestConfWARP1() {
    HASH='68747470733a2f2f73616e74612d61746d6f2e72752f776172702f776172702e706870'
    COMPILE=$(printf '%b' "$(printf '%s\n' "$HASH" | sed 's/../\\x&/g')")
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" "$COMPILE" \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' \
        -H "referer: $COMPILE" -H "Origin: $COMPILE"
}

requestConfWARP2() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://dulcet-fox-556b08.netlify.app/api/warp' \
        -H 'Content-Type: application/json' \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' \
        --data-raw '{"selectedServices":[],"siteMode":"all","deviceType":"computer","endpoint":"162.159.195.1:500"}'
}

requestConfWARP3() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://warp-config-generator-theta.vercel.app/api/warp' \
        -H 'Content-Type: application/json' \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' \
        --data-raw '{"selectedServices":[],"siteMode":"all","deviceType":"computer","endpoint":"162.159.195.1:500"}'
}

requestConfWARP4() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://generator-warp-config.vercel.app/warp4s?dns=1.1.1.1%2C%201.0.0.1%2C%202606%3A4700%3A4700%3A%3A1111%2C%202606%3A4700%3A4700%3A%3A1001&allowedIPs=0.0.0.0%2F0%2C%20%3A%3A%2F0' \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' \
        -H 'referer: https://generator-warp-config.vercel.app'
}

requestConfWARP5() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://valokda-amnezia.vercel.app/api/warp' \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

requestConfWARP6() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://warp-gen.vercel.app/generate-config' \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

requestConfWARP7() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warps' \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

requestConfWARP8() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp6s' \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

requestConfWARP9() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp4s' \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

requestConfWARP10() {
    curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://warp-generator.vercel.app/api/warp' \
        -H 'Content-Type: application/json' \
        -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' \
        --data-raw '{"selectedServices":[],"siteMode":"all","deviceType":"computer"}'
}

confWarpBuilder() {
    response_body=$1
    peer_pub=$(echo "$response_body" | jq -r '.result.config.peers[0].public_key')
    client_ipv4=$(echo "$response_body" | jq -r '.result.config.interface.addresses.v4')
    client_ipv6=$(echo "$response_body" | jq -r '.result.config.interface.addresses.v6')
    priv=$(echo "$response_body" | jq -r '.result.key')
    cat <<-EOM
[Interface]
PrivateKey = ${priv}
S1 = 0
S2 = 0
Jc = 120
Jmin = 23
Jmax = 911
H1 = 1
H2 = 2
H3 = 3
H4 = 4
MTU = 1280
Address = ${client_ipv4}, ${client_ipv6}
DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

[Peer]
PublicKey = ${peer_pub}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 162.159.192.1:500
EOM
}

check_request() {
    local response="$1"
    local choice="$2"
    response_code="${response: -3}"
    response_body="${response%???}"

    if [ "$response_code" -eq 200 ]; then
        case $choice in
            1) confWarpBuilder "$response_body" ;;
            2|3|10)
                content=$(echo "$response_body" | jq -r '.content')
                content=$(echo "$content" | jq -r '.configBase64')
                echo "$content" | base64 -d
                ;;
            4|5|7|8|9)
                content=$(echo "$response_body" | jq -r '.content')
                echo "$content" | base64 -d
                ;;
            6) echo "$response_body" | jq -r '.config' ;;
            *) echo "Error" ;;
        esac
    else
        echo "Error"
    fi
}

# ============================================
# ОСНОВНОЙ ЦИКЛ: ГЕНЕРАЦИЯ И ПРИМЕНЕНИЕ AWG WARP
# ============================================
INTERFACE_NAME="awg10"
CONFIG_NAME="amneziawg_awg10"
ZONE_NAME="awg"

countRepeatAWGGen=2
currIter=0
isExit=0

while [ $currIter -lt $countRepeatAWGGen ] && [ "$isExit" = "0" ]; do
    currIter=$(( currIter + 1 ))
    printf "\033[32;1mCreate and Check AWG WARP... Attempt #$currIter...\033[0m\n"

    warp_config="Error"
    for i in 1 2 3 4 5 6 7 8 9 10; do
        printf "\033[32;1mRequest WARP config... Attempt #$i\033[0m\n"
        result=$(eval requestConfWARP$i)
        warpGen=$(check_request "$result" $i)
        if [ "$warpGen" != "Error" ] && [ -n "$warpGen" ]; then
            warp_config="$warpGen"
            break
        fi
    done

    if [ "$warp_config" = "Error" ] || [ -z "$warp_config" ]; then
        printf "\033[31;1mGenerate config AWG WARP failed... Try again later...\033[0m\n"
        isExit=2
    else
        # Парсим конфиг
        while IFS=' = ' read -r line; do
            if echo "$line" | grep -q "="; then
                key=$(echo "$line" | cut -d'=' -f1 | xargs)
                value=$(echo "$line" | cut -d'=' -f2- | xargs)
                eval "$key=\"$value\""
            fi
        done < <(echo "$warp_config")

        Address=$(echo "$Address" | cut -d',' -f1)
        DNS=$(echo "$DNS" | cut -d',' -f1)
        AllowedIPs=$(echo "$AllowedIPs" | cut -d',' -f1)
        EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
        EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)
    fi

    if [ "$isExit" = "2" ]; then
        isExit=0
    else
        printf "\033[32;1mCreate and configure tunnel AmneziaWG WARP...\033[0m\n"

        # Настройка интерфейса
        uci set network.${INTERFACE_NAME}=interface
        uci set network.${INTERFACE_NAME}.proto='amneziawg'
        if ! uci show network | grep -q ${CONFIG_NAME}; then
            uci add network ${CONFIG_NAME}
        fi
        uci set network.${INTERFACE_NAME}.private_key=$PrivateKey
        uci del network.${INTERFACE_NAME}.addresses
        uci add_list network.${INTERFACE_NAME}.addresses=$Address
        uci set network.${INTERFACE_NAME}.mtu=$MTU
        uci set network.${INTERFACE_NAME}.awg_jc=$Jc
        uci set network.${INTERFACE_NAME}.awg_jmin=$Jmin
        uci set network.${INTERFACE_NAME}.awg_jmax=$Jmax
        uci set network.${INTERFACE_NAME}.awg_s1=$S1
        uci set network.${INTERFACE_NAME}.awg_s2=$S2
        uci set network.${INTERFACE_NAME}.awg_h1=$H1
        uci set network.${INTERFACE_NAME}.awg_h2=$H2
        uci set network.${INTERFACE_NAME}.awg_h3=$H3
        uci set network.${INTERFACE_NAME}.awg_h4=$H4
        [ -z "$I1" ] && I1="<b 0xc10000000114367096bb0fb3f58f3a3fb8aaacd61d63a1c8a40e14f7374b8a62dccba6431716c3abf6f5afbcfb39bd008000047c32e268567c652e6f4db58bff759bc8c5aaca183b87cb4d22938fe7d8dca22a679a79e4d9ee62e4bbb3a380dd78d4e8e48f26b38a1d42d76b371a5a9a0444827a69d1ab5872a85749f65a4104e931740b4dc1e2dd77733fc7fac4f93011cd622f2bb47e85f71992e2d585f8dc765a7a12ddeb879746a267393ad023d267c4bd79f258703e27345155268bd3cc0506ebd72e2e3c6b5b0f005299cd94b67ddabe30389c4f9b5c2d512dcc298c14f14e9b7f931e1dc397926c31fbb7cebfc668349c218672501031ecce151d4cb03c4c660b6c6fe7754e75446cd7de09a8c81030c5f6fb377203f551864f3d83e27de7b86499736cbbb549b2f37f436db1cae0a4ea39930f0534aacdd1e3534bc87877e2afabe959ced261f228d6362e6fd277c88c312d966c8b9f67e4a92e757773db0b0862fb8108d1d8fa262a40a1b4171961f0704c8ba314da2482ac8ed9bd28d4b50f7432d89fd800c25a50c5e2f5c0710544fef5273401116aa0572366d8e49ad758fcb29e6a92912e644dbe227c247cb3417eabfab2db16796b2fba420de3b1dc94e8361f1f324a331ddaf1e626553138860757fd0bf687566108b77b70fb9f8f8962eca599c4a70ed373666961a8cb506b96756d9e28b94122b20f16b54f118c0e603ce0b831efea614ad836df6cf9affbdd09596412547496967da758cec9080295d853b0861670b71d9abde0d562b1a6de82782a5b0c14d297f27283a895abc889a5f6703f0e6eb95f67b2da45f150d0d8ab805612d570c2d5cb6997ac3a7756226c2f5c8982ffbd480c5004b0660a3c9468945efde90864019a2b519458724b55d766e16b0da25c0557c01f3c11ddeb024b62e303640e17fdd57dedb3aeb4a2c1b7c93059f9c1d7118d77caac1cd0f6556e46cbc991c1bb16970273dea833d01e5090d061a0c6d25af2415cd2878af97f6d0e7f1f936247b394ecb9bd484da6be936dee9b0b92dc90101a1b4295e97a9772f2263eb09431995aa173df4ca2abd687d87706f0f93eaa5e13cbe3b574fa3cfe94502ace25265778da6960d561381769c24e0cbd7aac73c16f95ae74ff7ec38124f7c722b9cb151d4b6841343f29be8f35145e1b27021056820fed77003df8554b4155716c8cf6049ef5e318481460a8ce3be7c7bfac695255be84dc491c19e9dedc449dd3471728cd2a3ee51324ccb3eef121e3e08f8e18f0006ea8957371d9f2f739f0b89e4db11e5c6430ada61572e589519fbad4498b460ce6e4407fc2d8f2dd4293a50a0cb8fcaaf35cd9a8cc097e3603fbfa08d9036f52b3e7fcce11b83ad28a4ac12dba0395a0cc871cefd1a2856fffb3f28d82ce35cf80579974778bab13d9b3578d8c75a2d196087a2cd439aff2bb33f2db24ac175fff4ed91d36a4cdbfaf3f83074f03894ea40f17034629890da3efdbb41141b38368ab532209b69f057ddc559c19bc8ae62bf3fd564c9a35d9a83d14a95834a92bae6d9a29ae5e8ece07910d16433e4c6230c9bd7d68b47de0de9843988af6dc88b5301820443bd4d0537778bf6b4c1dd067fcf14b81015f2a67c7f2a28f9cb7e0684d3cb4b1c24d9b343122a086611b489532f1c3a26779da1706c6759d96d8ab>"
        uci set network.${INTERFACE_NAME}.awg_i1="$I1"
        uci set network.${INTERFACE_NAME}.nohostroute='1'

        uci set network.@${CONFIG_NAME}[-1].description="${INTERFACE_NAME}_peer"
        uci set network.@${CONFIG_NAME}[-1].public_key=$PublicKey
        uci set network.@${CONFIG_NAME}[-1].endpoint_host=$EndpointIP
        uci set network.@${CONFIG_NAME}[-1].endpoint_port=$EndpointPort
        uci set network.@${CONFIG_NAME}[-1].persistent_keepalive='25'
        uci set network.@${CONFIG_NAME}[-1].allowed_ips='0.0.0.0/0'
        uci set network.@${CONFIG_NAME}[-1].route_allowed_ips='0'
        uci commit network

        # Firewall zone
        if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
            uci add firewall zone
            uci set firewall.@zone[-1].name=$ZONE_NAME
            uci set firewall.@zone[-1].network=$INTERFACE_NAME
            uci set firewall.@zone[-1].forward='REJECT'
            uci set firewall.@zone[-1].output='ACCEPT'
            uci set firewall.@zone[-1].input='REJECT'
            uci set firewall.@zone[-1].masq='1'
            uci set firewall.@zone[-1].mtu_fix='1'
            uci set firewall.@zone[-1].family='ipv4'
            uci commit firewall
        fi

        if ! uci show firewall | grep -q "@forwarding.*name='${ZONE_NAME}'"; then
            uci add firewall forwarding
            uci set firewall.@forwarding[-1]=forwarding
            uci set firewall.@forwarding[-1].name="${ZONE_NAME}"
            uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
            uci set firewall.@forwarding[-1].src='lan'
            uci set firewall.@forwarding[-1].family='ipv4'
            uci commit firewall
        fi

        # Добавляем интерфейс в зону
        for zone in $(uci show firewall | grep "zone$" | cut -d'=' -f1); do
            CURR_ZONE_NAME=$(uci get $zone.name)
            if [ "$CURR_ZONE_NAME" = "$ZONE_NAME" ]; then
                if ! uci get $zone.network | grep -q "$INTERFACE_NAME"; then
                    uci add_list $zone.network="$INTERFACE_NAME"
                    uci commit firewall
                fi
            fi
        done

        service firewall restart

        # Перебор эндпоинтов WARP
        I=0
        WARP_ENDPOINT_HOSTS="engage.cloudflareclient.com 162.159.192.1 162.159.192.2 162.159.192.4 162.159.195.1 162.159.195.4 188.114.96.1 188.114.96.23 188.114.96.50 188.114.96.81"
        WARP_ENDPOINT_PORTS="500"
        for element in $WARP_ENDPOINT_HOSTS; do
            EndpointIP="$element"
            for element2 in $WARP_ENDPOINT_PORTS; do
                I=$(( I + 1 ))
                EndpointPort="$element2"
                uci set network.@${CONFIG_NAME}[-1].endpoint_host=$EndpointIP
                uci set network.@${CONFIG_NAME}[-1].endpoint_port=$EndpointPort
                uci commit network
                ifdown $INTERFACE_NAME
                ifup $INTERFACE_NAME
                printf "\033[33;1mIter #$I: Check Endpoint WARP $element:$element2. Wait up AWG WARP 10 second...\033[0m\n"
                sleep 10
                if ping -c 1 -I $INTERFACE_NAME 8.8.8.8 >/dev/null 2>&1; then
                    printf "\033[32;1m	Endpoint WARP $element:$element2 work...\033[0m\n"
                    isExit=1
                    break
                else
                    printf "\033[31;1m	Endpoint WARP $element:$element2 not work...\033[0m\n"
                    isExit=0
                fi
            done
            [ "$isExit" = "1" ] && break
        done
    fi
done

if [ "$isExit" = "1" ]; then
    printf "\033[32;1mAWG WARP well work...\033[0m\n"
else
    printf "\033[31;1mAWG WARP not work...\033[0m\n"
fi
