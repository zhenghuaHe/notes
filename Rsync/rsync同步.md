


# rsync同步

* raync是一个非常好用的数据同步小工具，轻巧便捷，最好的好处是使用过程中支持断点续传，如果是很大的文件不至于浪费很多时间。且同步的文件可以根据类型，分别用参数命令备份，不至于误删除后不能恢复。

## １.1 linux操作系统的使用
* 首先两边都得安装rsync服务，一个服务端一个客户端，稍微配置就能使用
```
$ yum -y install rsync
```

### 1.1.1 server端配置
```
$ vim /etc/rsyncd.conf
# /etc/rsyncd: configuration file for rsync daemon mode
# See rsyncd.conf man page for more options.
# configuration example:

uid = tom
gid = tom
address = 172.16.2.66
port = 873
use chroot = yes
read only = yes

max connections = 4
pid file = /var/run/rsyncd.pid
# exclude = lost+found/
# transfer logging = yes
# timeout = 900
# ignore nonreadable = yes
# dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
#pid file = /run/rsyncd.pid

motd file = /etc/rsyncd.motd
log file = /var/log/rsync.log
timeout = 300
hosts allow=172.16.1.0/255.255.255.0 172.16.2.0/255.255.255.0 172.16.3.0/255.255.255.0

[mwteck]
path = /root/mwteck
ignore errors
exclude = git/
comment = 100W file

[test]
path = /root/test
list=yes
ignore errors
exclude = paichu/
comment = this is rsyncd.server test
```

### 1.1.2 client端配置
```
#test目录为例
/usr/bin/rsync -abvczP  --password-file=/etc/ps  --delete  --backup-dir=/root/172.16.2.66.com/change/test/`date +'%Y-%m-%d-%H-%M-%S'` --log-file=/root/172.16.2.66.com/log/`date +'%Y-%m-%d'`  tom@172.16.2.66::test /root/172.16.2.66.com/source/test

if [ $? -eq 0 ];then
   /bin/echo ">>>>>>>>>>>>>>>>>>>>test dir  rsyn success<<<<<<<<<<<<<<<<"

else
   /bin/echo "test dir rsyn failed"
fi


#守护进程方式：mon目录
/usr/bin/rsync -abvzcP --delete --password-file=/etc/ps  --backup-dir=/root/172.16.2.66.com/change/mon/`date +'%Y-%m-%d-%H-%M-%S'` --log-file=/root/172.16.2.66.com/log/`date +'%Y-%m-%d'` mm@172.16.2.66::mon  /root/172.16.2.66.com/source/mon

if [ $? -eq 0 ];then
   /bin/echo ">>>>>>>>>>>>>>>>>>>>>>>>>daemon_mon rsyn success<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

else
   /bin/echo ">>>>>>>>>>>>>>>>>>>>>>>>>daemon_mon rsyn failed<<<<<<<<<<<<<<<<<<<<<<<<<"
fi
```
* 上面的配置中是需要的密码验证的，实际应用中根据自己的需要写配置，可以对ip段/用户密码等做限制，也可以弄个ssh的密钥免密码登陆。



## １.2 wimdows操作系统
* 下载软件：<http://www.cr173.com/soft/110806.html>     （基本就是下一步-下一步的安装）


### 1.2.1 server端配置（默认位置：C:\Program Files\ICW\rsyncd.conf）
```
use chroot = false
#strict modes = false
strict modes = true
hosts allow = 172.16.1.0/24 172.16.2.0/24 172.16.3.0/24
max connections = 10
lock file = rsyncd.lock
gid = 0
uid = 0
log file = /cygdrive/d/work/rsyncd.log


# Module definitions
# Remember cygwin naming conventions : c:\work becomes /cygwin/c/work
#
[win7]
path = /cygdrive/d/work/webapps
read only = true
#auth users = mwteck
#secrets file = /cygdrive/d/work/rsync.ps
list = yes
transfer logging = yes
comment = test win7 rsyncd.server
```
* 注意：配置防火墙开发873端口的出站和入栈，不要轻易关闭防火墙


### 1.2.2 client端配置
在自己下载的cwrsync文件夹下面：
自建rsync.bat
```
@echo off

echo.
echo 开始同步数据，请稍等...
echo.

cd D:\cwrsync_5.4.1_x86\cwRsync_5.4.1_x86_Free_client
rsync -abzrvP  --progress  --log-file=/cygdrive/h/wk/error.log --delete --backup-dir=/cygdrive/h/wk/change/ 172.16.1.210::win7 /cygdrive/h/wk/source/webapps/

echo.
echo 数据同步完成
echo.
```

***
注意：
因为windows操作系统之所以可以linux命令时因为虚拟层的转化，但是在虚拟层的转化过程中，因为两者的权限机制不一样，会产生一些东西：比如windows使用cwrsync的过程中，会给备份的文件
自动加一些everyone none的用户权限，然而这个多余的全是应该是被摒弃的。

方法：
1. 在cwrsync的服务端做设置，让虚拟层不多做处理，即保持原先的权限不变。
在Windows平台，以客户端形式使用rsync时，同步过来的文件权限是混乱的。仅仅需要继承上级目录权限，作以下设置：
修改server端配置文件：（win7默认路径：C:\Program Files\ICW\etc）
```
etc/fstab
none /cygdrive cygdrive binary,noacl,posix=0,user 0 0
```
然后，重新执行rsync命令。

注意：
cygwin1.7以前的rsync，只能这样实现这个需求：（client端的脚本加上命令）
```
SET CYGWIN=nontsec
rsync ......
```

2. 安装windows使用linux命令的插件Cygwin Terminal，你会发现你client端的备份目录权限组是none,就是这个权限组让你的windows多出来everyone、none用户。(测试第一次成功了，第二次又没成功)
```
chgrp  Users  workspace
chown user:group  workspace
```

.FAQ（IP以10.10.10.10代替）：

错误一：
```
password file must not be other-accessible
continuing without password file
Password:
rsync客户端路径是否写错，权限设置不对，需要再次输入密码，客户端和服务端的密码文件都应该是600的权限才可以
```
错误二：
```
@ERROR: Unknown module ‘bak’
rsync error: error starting client-server protocol (code 5) at main.c(1522) [receiver= 3.0.3]
服务端server的配置中的[bak]名字和客户端client的10.10.10.10::bak不符
```
错误三：
```
rsync: failed to connect to 10.10.10.10: Connection timed out (110)
rsync error: error in socket IO (code 10) at clientserver.c(124) [receiver=3.0.6]
检查服务端server服务是否正常启动，检查端口防火墙，iptables打开873端口
如果服务端是windows server则在防火墙入站规则中增加873端口
如果服务端是Linux则先检查服务是否启动#ps aux | grep rsync
然后开启873端口#iptables -A INPUT -p tcp --dport 873 -j ACCEPT开启873端口
附：
安装rsync yum install rsync
启动服务/usr/bin/rsync --daemon
启动服务错误failed to create pid file /var/rsyncd.pid: File exists
看看提示服务错误的路径（这个路径不一定就是这个，看自己的报错路径）这里是/var/rsyncd.pid所以
rm -rf /var/rsyncd.pid；再重新启动Rsync服务
此时在看一下ps aux | grep rsync启动成功
```
错误四：
```
@ERROR: access denied to gmz88down from unknown (10.10.10.10)
rsync error: error starting client-server protocol (code 5) at main.c(1503) [receiver=3.0.6]
看看是不是服务端server hosts allow限制了IP，把这里的IP加入到服务端server的hosts allow白名单中，windows rsync不能写多个allow，可以在一个allow中加多个IP，例：hosts allow=10.10.10.10 20.20.20.20
```
错误五：
```
@ERROR: chdir failed
rsync error: error starting client-server protocol (code 5) at main.c(1503) [receiver=3.0.6]
服务端server的目录不存在或者没有权限（要同步的那个文件路径），安装windows rsync时候会创建一个SvcCWRSYNC用户，这个用户对要拷贝的目录没有权限，方法一，将这个用户给权限加入到目录中，方法二，修改这个用户隶属于的组，修改后要在管理中重启服务
```
错误六：
```
rsync error: error starting clie
nt-server protocol (code 5) at main.c(1524) [Receiver= 3.0.7 ]
/etc/rsyncd.conf配置文件内容有错误，检查下配置文件
```
错误七：
```
rsync: ch
own "" failed: Invalid argument (22)
权限无法复制，去掉同步权限的参数即可
```
错误八：
```
@ERROR: auth failed on module bak
rsync error: error starting client-server protocol (code 5) at main.c(1530) [receiver=3.0.6]
密码错误或服务器上是否有bak模块
```
错误九：
```
rsync: connection unexpectedly closed (5 bytes received so far) [sender]
rsync error: error in rsync protocol data stream (code 12) at io.c(600) [sender=3.0.6]
模块read only = no设置为no false
```
错误十：
```
@ERROR: invalid uid nobody
rsync error: error starting client-server protocol (code 5) at main.c(1503) [sender=3.0.6]
设置
uid =0
gid = 0
```
错误十一：
```
rsync: failed to connect to 10.10.10.10: No route to host (113)
rsync error: error in socket IO (code 10) at clientserver.c(124) [receiver=3.0.6]
防火墙原因
```
错误十二：
```
rsync: read error: Connection reset by peer (104)
rsync error: error in rsync protocol data stream (code 12) at io.c(759) [receiver=3.0.6]

/etc/rsyncd.conf配置文件不存在
```
错误十三：
```
rsync: Failed to exec ssh: No such file or directory (2)
rsync error: error in IPC code (code 14) at pipe.c(84) [receiver=3.0.6]
rsync: connection unexpectedly closed (0 bytes received so far) [receiver]
rsync error: error in IPC code (code 14) at io.c(600) [receiver=3.0.6]

需要在客户端安装yum install -y openssh-clients即可
```
错误十四：
```
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1518) [generator=3.0.9]

服务端没有写权限，修改rsyncd.conf中uid和gid
```


* 参考博客：
1. cygwin的一些细节操作：<http://oldratlee.com/post/2012-12-22/stunning-cygwin>
2. 学长M19-吴昊 ：<https://blog.whsir.com/post-category/linux/rsync> （windows server 2008服务器使用（软件包下载） +linux的守护进程使用）
