#!/bin/sh
set -euo pipefail
####################################
# Error Code:                      #
# 1: Missing wget and/or curl      #
# 2: username or password is empty #
####################################

VERSION="1.1.0"

################## Config Segment ###################
## Contents in this section will remain in self updating.
# Config area
username=""                   # 你的学号 Your CampusID
password=""                   # 你的密码 Your Password

# Uncomment below line to configure your network isp
isp=""              # 校园网 Campus Network
#isp="%40telecom"    # 中国电信 China Telecom
#isp="%40unicom"     # 中国联通 China Unicom
#isp="%40cmcc"       # 中国移动 China Mobile

# Self update
auto_update=1        # 1: yes   0: no
watchdog_update=1    # 1: yes   0: no
######################################################



################### Code Segment #####################
checkstatus() {
    if [[ $have_wget = 1 ]]; then
        wget --no-check-certificate -q -O - "http://10.0.1.5/drcom/chkstatus?callback=dr1002&jsVersion=4.1&v=6500&lang=zh"
    fi
    if [[ $have_curl = 1 ]]; then
        curl --insecure -d "callback=dr1002&jsVersion=4.1&v=6500&lang=zh" --url "http://10.0.1.5/drcom/chkstatus"
    fi
}

login() {
    if [[ $have_wget = 1 ]]; then
        wget --no-check-certificate -q -O - "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=${username}${isp}&upass=${password}&0MKKey=123456&R1=0&R2=&R3=0&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn&jsVersion=4.1&v=2223&lang=zh"
    fi
    if [[ $have_curl = 1 ]]; then
        curl --insecure "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=${username}${isp}&upass=${password}&0MKKey=123456&R1=0&R2=&R3=0&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn&jsVersion=4.1&v=2223&lang=zh"
    fi
}

logout() {
    if [[ $have_wget = 1 ]]; then
        wget --no-check-certificate -q -O - "http://10.0.1.5:801/eportal/portal/mac/unbind?callback=dr1003&user_account=$username$isp&wlan_user_mac=000000000000&wlan_user_ip=$(get_ip)&jsVersion=4.1&v=3685&lang=zh"
        wget --no-check-certificate -q -O - "http://10.0.1.5:801/eportal/portal/logout?callback=dr1004&login_method=0&user_account=drcom&user_password=123&ac_logout=1&register_mode=1&wlan_user_ip=$(get_ip)&wlan_user_ipv6=&wlan_vlan_id=1&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1&v=3340&lang=zh"
    fi
    if [[ $have_curl = 1 ]]; then
        curl --insecure "http://10.0.1.5:801/eportal/portal/mac/unbind?callback=dr1003&user_account=$username$isp&wlan_user_mac=000000000000&wlan_user_ip=$(get_ip)&jsVersion=4.1&v=3685&lang=zh"
        curl --insecure "http://10.0.1.5:801/eportal/portal/logout?callback=dr1004&login_method=0&user_account=drcom&user_password=123&ac_logout=1&register_mode=1&wlan_user_ip=$(get_ip)&wlan_user_ipv6=&wlan_vlan_id=1&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1&v=3340&lang=zh"
    fi
}

get_ip() {
    ifconfig | grep -E '^(eth|en)' -A 5 | grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' -o | head -1
}

help() {
    echo 'A simple script to play around with GUET network auth system.'
    echo 'GitHub page: https://github.com/the-eric-kwok/GUET_Dialer_New'
    echo ''
    echo -e '\033[1mMODIFY THE SCRIPT TO CONFIGURE BEFORE YOU USE IT!\033[0m'
    echo ''
    echo 'Usage: dial.sh <option>'
    echo ''
    echo 'Options:'
    echo '  login      login with provided info'
    echo '  logout     you got that'
    echo "  status     check your login status, if result=1 then you've logged in"
    echo '  version    print your script version'
    echo ''
}

print_version() {
    echo "Version: $VERSION"
}

update() {
    echo 'Checking for update...'
    remote_link='https://gitee.com/erickwok404/GUET_Dialer_New/raw/main/dial.sh'
    watchdog_link='https://gitee.com/erickwok404/GUET_Dialer_New/raw/main/watchdog.sh'
    [ $have_wget -eq 1 ] && [ $have_curl -eq 0 ] && remote_version=$(wget --no-check-certificate -q -O - $remote_link | grep "VERSION=")
    [ $have_curl -eq 1 ] && [ $have_wget -eq 0 ] && remote_version=$(curl --insecure -fsSL $remote_link | grep "VERSION=")
    [ $have_curl -eq 1 ] && [ $have_wget -eq 1 ] && remote_version=$(curl --insecure -fsSL $remote_link | grep "VERSION=")
    remote_version=$(echo $remote_version | grep -o '\d*\.\d*\.\d*')
    rD1=$(echo $remote_version | cut -d'.' -f1)
    rD2=$(echo $remote_version | cut -d'.' -f2)
    rD3=$(echo $remote_version | cut -d'.' -f3)
    lD1=$(echo $VERSION | cut -d'.' -f1)
    lD2=$(echo $VERSION | cut -d'.' -f2)
    lD3=$(echo $VERSION | cut -d'.' -f3)
    if [ $lD1 -ge $rD1 ] && [ $lD2 -ge $rD2 ] && [ $lD3 -ge $rD3 ]; then
        echo 'Already up-to-date.'
        return
    else
        if [ $auto_update -eq 0 ]; then
            echo "Auto update is disabled"
            return
        elif [ $have_wget -eq 1 ]; then
            echo 'Updating...'
            wget --no-check-certificate -q -O dial_new.sh $remote_link
            [ $watchdog_update -eq 1 ] && rm watchdog.sh && wget --no-check-certificate -q $watchdog_link
        elif [ $have_curl -eq 1 ]; then
            echo 'Updating...'
            curl --insecure -fsSL -o dial_new.sh $remote_link
            [ $watchdog_update -eq 1 ] && curl --insecure -fsSOL $watchdog_link
        fi
        sed -i "s/username=\"\"/username=\"$username\"/g" dial_new.sh
        sed -i "s/password=\"\"/password=\"$password\"/g" dial_new.sh
        sed -i "s/#isp=\"$isp\"/isp=\"$isp\"/g" dial_new.sh
        sed -i "s/auto_update=\d/auto_update=$auto_update/g" dial_new.sh
        sed -i "s/watchdog_update=\d/watchdog_update=$watchdog_update/g" dial_new.sh
        chmod +x dial_new.sh
        chmod +x watchdog.sh
        mv dial.sh dial_old.sh
        mv dial_new.sh dial.sh
        rm dial_old.sh
        echo 'Done!'
    fi
}

which wget > /dev/null && have_wget=1 || have_wget=0
which curl > /dev/null && have_curl=1 || have_curl=0

if [[ $have_curl = 0 ]] && [[ $have_wget = 0 ]]; then
    echo "Missing wget and/or curl, please install one of them with opkg."
    exit 1
fi

if [ -z $username ] || [ -z $password ]; then
    echo '$username or $password is empty, please modify script and fill them with your username and password.'
    exit 2
fi

if [ -z ${1+x} ]; then
    # If $1 is empty
    help
elif [ "$1" = "version" ]; then
    print_version
elif [ "$1" = "update" ]; then
    update
elif [ "$1" = "status" ]; then
    checkstatus
elif [ "$1" = "login" ]; then
    echo "Logging..."
    login
    echo "Done!"
    sh -c "sleep 30 && ./dial.sh update" &
elif [ "$1" = "logout" ]; then
    echo "Logging out..."
    logout
    echo "Done!"
else
    help
fi
exit 0
#####################################################
