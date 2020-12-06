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

checkstatus() {
  [[ $have_wget = 1 ]]&& wget -q -O - "http://10.32.254.11/drcom/chkstatus?callback=dr1002&jsVersion=4.1&v=6500&lang=zh"; return
  [[ $have_curl = 1 ]]&& curl -d "callback=dr1002&jsVersion=4.1&v=6500&lang=zh" --url "http://10.32.254.11/drcom/chkstatus"
}

login() {
  [[ $have_wget = 1 ]]&& wget -q -O - "http://10.32.254.11/drcom/login?callback=dr1003&DDDDD=${username}&upass=${password}&0MKKey=123456&R1=0&R3=${isp}&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn&jsVersion=4.1&v=4186&lang=zh"; return
  [[ $have_curl = 1 ]]&& curl -d "callback=dr1003&DDDDD=${username}&upass=${password}&0MKKey=123456&R1=0&R3=${isp}&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn&jsVersion=4.1&v=4186&lang=zh" --url "http://10.32.254.11/drcom/login"
}

logout() {
  [[ $have_wget = 1 ]] && wget -q -O - "http://10.32.254.11/drcom/logout?callback=dr1005&jsVersion=4.1&v=5350&lang=zh"; return
  [[ $have_curl = 1 ]] && curl -d "callback=dr1005&jsVersion=4.1&v=5350&lang=zh" --url "http://10.32.254.11/drcom/logout"
}

get_ip() {
  ip_addr=$(ifconfig | grep -A 3 'eth' | grep -o -E -m 1 'inet addr:\d+\.\d+\.\d+\.\d+' | cut -d ':' -f 2)
}

help() {
  echo 'A simple script to play around with GUET network auth system.'
  echo 'GitHub page: https://github.com/the-eric-kwok/GUET_Dialer_New'
  echo ''
  echo 'Usage: dial.sh <option>'
  echo ''
  echo 'Options:'
  echo '  login:  login with provided info'
  echo '  logout: you got that'
  echo "  status: check your login status, if result=1 then you've logged in"
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

if [ "$1" = "status" ]; then
  checkstatus
elif [ "$1" = "login" ]; then
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
