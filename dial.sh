#!/bin/sh
####################################
# Error Code:                      #
# 1: Missing wget and/or curl      #
# 2: username or password is empty #
####################################

# Config area
username=			# 你的学号
password=			# 你的密码
isp=    			# 0: 校园网 Campus Network   1: 中国电信 China Telecom   2:中国联通 China Unicom   3: 中国移动 China Mobile

login() {
  [[ $have_wget = 1 ]]&& wget "http://10.32.254.11/drcom/login?callback=dr1557825447911&DDDDD=${username}&upass=${password}&0MKKey=123456&R1=0&R3=${isp}&R6=0&para=00&v6ip=&_=15578245696520" -q -O -; return
  [[ $have_curl = 1 ]]&& curl -d "callback=dr1557825447911&DDDDD=${username}&upass=${password}&0MKKey=123456&R1=0&R3=${isp}&R6=0&para=00&v6ip=&_=15578245696520" --url "http://10.32.254.11/drcom/login"
}

logout() {
  [[ $have_wget = 1 ]]&& wget -q -O - "http://10.32.254.11:801/eportal/?c=Portal&a=logout&callback=dr1557832876175&login_method=0&user_account=drcom&user_password=123&ac_logout=1&register_mode=1&wlan_user_ip=${ip_addr}&wlan_user_ipv6=&wlan_vlan_id=1&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=3.3&_=1557832872091"; return
  [[ $have_curl = 1 ]]&& curl -d "c=Portal&a=logout&callback=dr1557832876175&login_method=0&user_account=drcom&user_password=123&ac_logout=1&register_mode=1&wlan_user_ip=${ip_addr}&wlan_user_ipv6=&wlan_vlan_id=1&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=3.3&_=1557832872091" --url "http://10.32.254.11:801/eportal/"
}

get_ip() {
  ip_addr=$(ifconfig eth1 | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}')
}

help() {
  echo 'Usage: dial.sh <login/logout>'
}

which wget > /dev/null
[[ $? = 0 ]]&& have_wget=1 || have_wget=0
which curl > /dev/null
[[ $? = 0 ]]&& have_curl=1 || have_curl=0

if [[ $have_curl = 0 ]] && [[ $have_wget = 0 ]]; then
  echo "Missing wget and/or curl, please install one of them with opkg."
  exit 1
fi

if [ -z $username ] || [ -z $password ] || [ -z $isp ]; then
  echo '$username or $password or $isp is empty, please modify script and fill them with your username and password.'
  exit 2
fi

if [ "$1" = "login" ]; then
  echo "Logging..."
  login
  echo "Done!"
elif [ "$1" = "logout" ]; then
  get_ip
  echo "IP:${ip_addr}"
  echo "Logging out..."
  logout
  echo "Done!"
else
  help
fi
exit 0
