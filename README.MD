## 简介

桂电已于2019年5月14日启用新版无感知认证系统，此脚本适用于该认证系统。

## 依赖

1. busybox
2. wget 或 curl

## 用法

1. 将脚本上传至路由器/树莓派的`/root`路径下

2. 检查依赖，可以尝试运行 `/root/dial.sh login` 来做自动的依赖检测，**如果未安装 curl/wget 的话请先安装其中任意一种，否则脚本将无法工作**

2. 用编辑器打开脚本，将`$username`, `$password` , `$isp`三个变量的值设置好，其中：

   - `$username` 为你登录系统时的用户名，通常为学号，**不是**宽带账户
   - `$password` 为你登陆系统时的密码，**不是**宽带密码
   - `$isp` 是选择运营商用的，可以选择：0: 校园网   1: 中国电信   2:中国联通   3: 中国移动

3. 通过这个命令给脚本设置可执行权限

```
chmod +x dial.sh
chmod +x dial_watchdog.sh
```

4. 通过 `crontab -e` 编辑crontab，并且在里面加入一行
```
* * * * * /root/watchdog.sh >> /tmp/dial_watchdog.log 2>&1
```
以此来每分钟自动检测网络并且执行断网重连。

5. 编辑 `/etc/rc.local` 来添加开机自启动
```
/root/watchdog.sh >> /tmp/dial_watchdog.log 2>&1
```

## 小提示
你也可以用 `/root/dial.sh login` 来手动拨号，或者用 `/root/dial.sh logout` 来手动断开连接，以及使用 `/root/dial.sh status` 来检查拨号状态，返回的内容中若 result 为 1 则已登录，否则需要登录。

## 友情链接
[Python版本的脚本](https://github.com/AndPuQing/GUET-WIFI_AutoLogin)
