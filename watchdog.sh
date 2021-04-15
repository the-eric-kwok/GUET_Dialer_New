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

check_status() {
        status=$(./dial.sh status | grep -o '"result":\d' | grep -o '\d')
        echo $status
}

networktest() {
        ping -c 2 10.0.1.5 > /dev/null 2>&1
        [ $? -ne 0 ] && return 255  # Check your wire connection
        status=$(check_status)
        if [ $status -eq 1 ]; then
                ping -c 2 39.156.69.79
                [ $? -eq 0 ] && return 0 || return 1
        fi
        return 254
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
        else
                msga=$(echo $ret | grep -o '"msga":".*"' | cut -d ':' -f 2 | grep -o '[^"]*')
                echo "$(logtime) Logged in failed, error msg: ${msga}"
        fi
fi
