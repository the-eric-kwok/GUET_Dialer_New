#!/bin/sh

######################################################################
#  Use crontab to run this script every minute.                      #
#  Here is a crontab template.                                       #
#                                                                    #
#  * * * * * /root/watchdog.sh >> /tmp/dial_watchdog.log 2>&1        #
#                                                                    #
######################################################################

logtime() {
    date "+%Y-%m-%d %H:%M:%S"
}

networktest() {
    ping -c 2 10.0.1.5 > /dev/null 2>&1
    [ $? -ne 0 ] && return 255  # Cannot ping to dial up server
    ping -c 2 114.114.114.114 > /dev/null 2>&1
    [ $? -ne 0 ] && return 1  # Cannot ping to 114 DNS server
    ping -c 2 baidu.com > /dev/null 2>&1
    [ $? -ne 0 ] && return 2  # Can connect to 114 DNS server but not baidu.com
    return 0  # Network OK
}

networktest
result=$?
if [ $result -eq 0 ]; then
    echo "$(logtime) Network no problem."
    exit 0
fi
if [ $result -eq 1 ]; then
    echo "$(logtime) Dialed up but not able to connect to Internet, blame the campus network."
    exit 1
fi
if [ $result -eq 2 ]; then
    echo "$(logtime) DNS configuration error."
    exit 2
fi
if [ $result -eq 255 ]; then
    echo "$(logtime) Network not connected! Please check your wire connection!"
    exit 255
fi
if [ $result -eq 254 ]; then
    echo "$(logtime) Trying to login..."
    ret=$(/root/dial.sh login)
    result=$(echo $ret | grep -o '"result":\d' | grep -o '\d')
    if [[ $result == 1 ]] ; then
        echo "$(logtime) Logged in successfully"
        return 0
    else
        msga=$(echo $ret | grep -o '"msga":".*"' | cut -d ':' -f 2 | grep -o '[^"]*')
        echo "$(logtime) Logged in failed, error msg: ${msga}"
        return 254
    fi
fi
