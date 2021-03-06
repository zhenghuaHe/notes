

- 清除filter表中的INPUT链的规则
```
$ iptables -F INPUT
```
- 确认没有任何规则，默认是全部通过
```
$ iptables -nL INPUT
```
- 增加规则(-I 添加规则，首部插入　-A 追加规则，尾部追加)
```
命令语法：iptables -t 表名 -A 链名 匹配条件 -j 动作
命令语法：iptables -t 表名 -I 链名 匹配条件 -j 动作
命令语法：iptables -t 表名 -I 链名 规则序号 匹配条件 -j 动作
命令语法：iptables -t 表名 -P 链名 动作
```
- 拒绝来自某ip的链接
```
$ iptables -t filter -I INPUT -s 172.16.1.227 -j DROP
$ iptables -vnL INPUT
Chain INPUT (policy ACCEPT 6 packets, 436 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0

测试：通过ping和ssh链接都连不过去啦,会一直没响应！
```

- 规则匹配是从上到下逐个匹配，只要有一条生效了后面的就不会生效了。(INPUT后面加数字可以直接加到指定的位置。)
```
$ iptables -t filter -I INPUT 3 -s 172.16.1.227 -j ACCEPT
$ iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 35 packets, 2448 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        2   168 ACCEPT     all  --  *      *       172.16.1.227         0.0.0.0/0
2        5   372 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0
3        0     0 ACCEPT     all  --  *      *       172.16.1.227         0.0.0.0/0
```

- 匹配条件的更多用法：（-s 针对源地址操作　-d　针对目标地址操作）
１、更多目标地址
查看filter表的INPUT链:
```
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
  647 51532 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    1    84 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
    1    60 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
    2   156 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
```
- 抛弃多个ip地址：
```
$ iptables -t filter -I INPUT -s 172.16.1.226,172.16.1.227 -j DROP
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0
    0     0 DROP       all  --  *      *       172.16.1.226         0.0.0.0/0
  670 53152 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    1    84 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
    1    60 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
    2   156 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
```
- 抛弃某个网段
```
$ iptables -t filter -I INPUT -s 172.16.3.0/24 -j DROP
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       172.16.3.0/24        0.0.0.0/0
    0     0 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0
    0     0 DROP       all  --  *      *       172.16.1.226         0.0.0.0/0
 1113 94921 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    2   168 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
    4   240 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
    2   156 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
```

- 匹配条件取反(条件前面加个【!】都表示取反)
```
$ iptables -t filter -A INPUT ! -s 172.16.1.227 -j ACCEPT    (不是这个ip都能通过)
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
   19  1328 ACCEPT     all  --  *      *      !172.16.1.227         0.0.0.0/0
```

- 目标地址

1、 抛弃某个ip到某个ip的链接，针对于多网卡
```
$ iptables -t filter -I INPUT -s 172.16.1.226 -d 172.16.1.233 -j DROP　（不指定源地址，源地址则为0.0.0.0，不指定目标地址，则为0.0.0.0）
[root@localhost ~]# iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       172.16.1.226         172.16.1.233
```
２、匹配条件：协议类型（-p 选项指定报文的协议类型,不使用-p则表示全部协议）
```
$ iptables -t filter -I INPUT -s 172.16.1.226 -d 172.16.1.233 -p tcp -j DROP
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 10 packets, 688 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       tcp  --  *      *       172.16.1.226         172.16.1.233

则通过tcp协议的方式连不过去，比如ssh
centos6中支持的协议：tcp/udp/icmp/esp/ah/sctp/udplite
centos7中支持的协议：tcp/udp/udplite/icmp/icmpv6/esp/ah/sctp/mh
```
３、匹配条件：网卡接口(-i 指定【流入】网卡名称，可附加协议；-o 指定【流出】网卡名称，可附加协议)
```
$ iptables -t filter -I INPUT -i eth0 -p icmp -j DROP
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 7 packets, 488 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       icmp --  eth0   *       0.0.0.0/0            0.0.0.0/0
```

4、源端口、目标端口
【--dport　目标端口，前提是要指定-p　协议，-m 协议模块（可省略，不写默认为协议对应的模块）】
【--sport 源端口】
【多端口匹配:--dport 22:25 表示22－25端口段;--dport :22 表示0-22端口;--dport 80:  表示80-65535端口;-m multiport 可以分散指定多个端口】
```
$ iptables -t filter -I INPUT -p tcp --dport 22 -s 172.16.1.226 -j REJECT  (拒绝来自172.16.1.226的22端口访问)
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 15 packets, 1140 bytes)
 pkts bytes target     prot opt in     out     source               destination
    1    60 REJECT     tcp  --  *      *       172.16.1.226         0.0.0.0/0            tcp dpt:22 reject-with icmp-port-unreachable

$ iptables -t filter -I INPUT -s 172.16.1.226 -p tcp --sport 22 -j ACCEPT 　（允许源地址的22端口链接，当下面两条规则同时存在，不能ssh）
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 10 packets, 688 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     tcp  --  *      *       172.16.1.226         0.0.0.0/0            tcp spt:22
    4   240 REJECT     tcp  --  *      *       172.16.1.226         0.0.0.0/0            tcp dpt:22 reject-with icmp-port-unreachable

$ iptables -t filter -I INPUT -s 172.16.1.226 -p tcp -m multiport --dport 22,25,80 -j ACCEPT
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 6 packets, 436 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     tcp  --  *      *       172.16.1.226         0.0.0.0/0            multiport dports 22,25,80
```



- 拓展模块

１、iprange拓展模块
[--src-range:源地址连续ip]
[--dst-range:目标地址连续IP]
```
$ iptables -t filter -I INPUT -m iprange --src-range 172.16.1.226-172.16.1.240 -j DROP
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 9 packets, 636 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            source IP range 172.16.1.226-172.16.1.240
```

２、string拓展模块
[-m string :表示使用这个模块；--algo bm:表示使用bm算法去匹配；--string "qq"：表示要匹配的字符串]
```
$ iptables -t filter -I INPUT -m string --algo bm --string "qq" -j REJECT
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 7 packets, 488 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            STRING match  "qq" ALGO name bm TO 65535 reject-with icmp-port-unreachable
    7   420 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            source IP range 172.16.1.226-172.16.1.240
```

３、time拓展模块
【-m　time：表示使用time模块，--timestart:指定起始时间，--timestop:指定结束时间】
```
$ iptables -t filter -I INPUT -p tcp --dport 80 -m time --timestart 09:00:00 --timestop 18:00:00 -j REJECT
$ iptables -t filter -vnL INPUT
Chain INPUT (policy ACCEPT 7 packets, 488 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 TIME from 09:00:00 to 18:00:00 UTC reject-with icmp-port-unreachable

[关于星期设置]
$ iptables -t filter -I OUTPUT -p tcp --dport 80 -m time --weekdays 6,7 -j REJECT
$ iptables -t filter -vnL OUTPUT
Chain OUTPUT (policy ACCEPT 44 packets, 4888 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 TIME on Sat,Sun UTC reject-with icmp-port-unreachable

[关于每月多少号的设置]
$ iptables -t filter -I OUTPUT -p tcp --dport 80 -m time --monthdays 22,23 -j REJECT
$ iptables -t filter -vnL OUTPUT
Chain OUTPUT (policy ACCEPT 4 packets, 608 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 TIME on 22nd,23rd UTC reject-with icmp-port-unreachable

[关于日期的多少号到多少号]
$ iptables -t filter -I OUTPUT -p tcp --dport 80 -m time --datestart 2019-01-15 --datestop 2019-01-20 -j REJECT
$ iptables -t filter -vnL OUTPUT
Chain OUTPUT (policy ACCEPT 4 packets, 640 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 TIME starting from 2019-01-15 00:00:00 until date 2019-01-20 00:00:00 UTC reject-with icmp-port-unreachable
```

４、connlimit拓展模块
[--connlimit-above：默认所有ip.限制每个ip地址最多占用server端的链接数量，不指定ip则针对每个ip]
```
$ iptables -I INPUT -p tcp --dport 22 -m connlimit --connlimit-above 3 -j REJECT
$ iptables -vnL INPUT
Chain INPUT (policy ACCEPT 94 packets, 7740 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22 #conn src/32 > 3 reject-with icmp-port-unreachable
#表示每个ip最多通过ssh链接22端口３次

[--connlimit-mask :限制某类网段，即255.255.255.0]
$ iptables -I INPUT -p tcp --dport 22 -m connlimit --connlimit-above 3 --connlimit-mask 24 -j REJECT
$ iptables -vnL INPUT
Chain INPUT (policy ACCEPT 11 packets, 784 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22 #conn src/24 > 3 reject-with icmp-port-unreachable
```

５、limit拓展模块
[限制报文到达速率，限制单位时间流入包的数量]
```
$ iptables -t filter -I INPUT -p icmp -m limit --limit 10/minute -j ACCEPT
$ iptables -vnL INPUT
Chain INPUT (policy ACCEPT 27 packets, 1936 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            limit: avg 10/min burst 5
#每分钟最多放行10个包,默认是放行，所以不会有变化
再加个限制就好啦
$ iptables -t filter -I INPUT -p icmp -j REJECT
```






















- 删除规则
１、根据规则的编号删除
２、根据具体匹配条件和动作删除
命令语法：iptables -t 表名 -D 链名 规则序号
命令语法：iptables -t 表名 -D 链名 匹配条件 -j 动作


$ iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 35 packets, 2448 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        2   168 ACCEPT     all  --  *      *       172.16.1.227         0.0.0.0/0
2        5   372 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0
3        0     0 ACCEPT     all  --  *      *       172.16.1.227         0.0.0.0/0

- 根据规则编号删除
$ iptables -t filter -D INPUT 3
$ iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 7 packets, 488 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        2   168 ACCEPT     all  --  *      *       172.16.1.227         0.0.0.0/0
2        5   372 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0

- 根据具体匹配条件和动作删除
$ iptables -t filter -D INPUT -s 172.16.1.227 -j ACCEPT  (iptables -t 表名　-D 链名　-s 源地址匹配条件　-j 对应的动作)
$ iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 7 packets, 488 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        5   372 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0



- 修改规则
１、根据指定的编号修改（慎用，规则较多容易错改）
２、建议先删除再增加的方式
命令语法：iptables -t 表名 -R 链名 规则序号 规则原本的匹配条件 -j 动作
命令语法：iptables -t 表名 -P 链名 动作


$ iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 7 packets, 488 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        5   372 DROP       all  --  *      *       172.16.1.227         0.0.0.0/0

- 根据指定编号修改
[root@localhost ~]# iptables -t filter -R INPUT 1  -s 172.16.1.227 -j REJECT　　（-R 修改指定的链,-s 指定源地址，不指定的话会被修改成0.0.0.0/0）
[root@localhost ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 9 packets, 636 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        0     0 REJECT     all  --  *      *       172.16.1.227         0.0.0.0/0            reject-with icmp-port-unreachable

修改为拒绝之后，再去链接会直接返回被拒绝

- 修改表上链的默认策略：
$ iptables -t filter -P FORWARD DROP  (-P 指定要修改的链，修改为DROP)
$ iptables -vnL FORWARD --line-number
Chain FORWARD (policy DROP 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
2        0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0



- 保存规则

centos6中：　service iptables save  规则默认保存在：/etc/sysconfig/iptables

centos7中：　iptables-save >> /etc/sysconfig/iptables (保存规则并追加到文件)
            iptables-restore << /etc/sysconfig/iptables (重载文件中的规则，未保存的将丢失或被覆盖）
#配置好yum源以后安装iptables-service
# yum install -y iptables-services
#停止firewalld
# systemctl stop firewalld
#禁止firewalld自动启动
# systemctl disable firewalld
#启动iptables
# systemctl start iptables
#将iptables设置为开机自动启动，以后即可通过iptables-service控制iptables服务
# systemctl enable iptables


















$ iptables -t filter -D INPUT -s 172.16.1.227 -j DROP
