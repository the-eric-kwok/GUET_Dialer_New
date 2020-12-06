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
        return $status
}

networktest() {
        ping -c 2 10.32.254.11 > /dev/null 2>&1
        [[ $? != 0 ]] && return -1  # Check your wire connection
        check_status
        return $?
}

networktest
result=$?
if [[ $result == 1 ]]; then
        echo "$(logtime) Network no problem"
        exit 0
fi
if [[ $result == -1 ]]; then
        echo "$(logtime) Network not connected! Please check your wire connection!"
        exit 1
fi
if [[ $result == 0 ]]; then
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
