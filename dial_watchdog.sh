#!/bin/sh

######################################################################
#  Use crontab to run this script every minute to monitor network.   #
#  Here is a crontab template.                                       #
#                                                                    #
#  * * * * * /root/dial_watchdog.sh >> /tmp/dial_watchdog.log 2>&1   #
#                                                                    #
######################################################################

LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
PATH="/root"

wget --spider --quiet --tries=1 --timeout=3 www.baidu.com
if [ "$?" != "0" ]; then
        echo '['$LOGTIME'] Trying to login...'
        $PATH/dial.sh login
fi
wget --spider --quiet --tries=1 --timeout=3 www.baidu.com
if [ "$?" != "0" ]; then
        echo '['$LOGTIME'] Still unconnected, trying to logout.'
        $PATH/dial.sh logout
        echo '['$LOGTIME'] And then re-login.'
        $PATH/dial.sh login
fi
wget --spider --quiet --tries=1 --timeout=3 www.baidu.com
if [ "$?" != "0" ]; then
        echo '['$LOGTIME'] Seems to be network problem, will wait 10 mins and try again.'
fi
