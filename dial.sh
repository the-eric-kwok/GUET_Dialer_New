#!/bin/sh
# Config area
username=			# 你的学号
password=			# 你的密码
isp=1   			# 0: 校园网 Campus Network   1: 中国电信 China Telecom   2:中国联通 China Unicom   3: 中国移动 China Mobile

login() {
  wget "http://10.32.254.11/drcom/login?callback=dr1557825447911&DDDDD=${username}&upass=${password}&0MKKey=123456&R1=0&R3=${isp}&R6=0&para=00&v6ip=&_=15578245696520" -q -O -
}

logout() {
  wget -q -O - "http://10.32.254.11:801/eportal/?c=Portal&a=logout&callback=dr1557832876175&login_method=0&user_account=drcom&user_password=123&ac_logout=1&register_mode=1&wlan_user_ip=${ip_addr}&wlan_user_ipv6=&wlan_vlan_id=1&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=3.3&_=1557832872091"
}

get_ip() {
  ip_addr=$(ifconfig eth1 | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}')
}

help() {
  echo 'new_dial.sh <login/logout>'
}

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