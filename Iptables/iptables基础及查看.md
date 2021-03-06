


# 五链四表：

## 五链：prerouting/input/output/forward/postrouting
```
链名：   prerouting    input      output       forward      postrouting

存在于：   raw           filter     raw          mangle       mangle
哪些表：   mangle        mangle     filter       filter       nat
          nat            nat       mangle
                                  net
```

## 四表：filter/nat/mangle/raw
```
filter: 负责过滤功能
nat:　网络地址转换功能
mangle:　拆解报文、做出修改，重新封装
raw:　关闭nat表上的连接追踪机制
```

# 处理动作:
```
accept:允许数据包通过
drop：直接丢弃数据包，不给任何回应
reject:拒绝数据包通过
snat：源地址转换，解决内网用户同一个公网上网问题
masquerede:snat的一种特殊形态，适用于动态、临时会变的ip
dnat：目标地址转换
redirect:做本机端口映射
log：在/var/log/message中记录日志，然后将数据包传递给下一条规则
```

### 查看某个表的规则(不加-t默认是查看filter表)
$ iptables -t nat -L
```
- 详细显示
$ iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
  182 17881 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
    5   382 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
    1    60 INPUT_direct  all  --  *      *       0.0.0.0/0            0.0.0.0/0
    1    60 INPUT_ZONES_SOURCE  all  --  *      *       0.0.0.0/0            0.0.0.0/0
    1    60 INPUT_ZONES  all  --  *      *       0.0.0.0/0            0.0.0.0/0
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate INVALID
    0     0 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
```
```
policy:当前链的默认规则，上图默认为accept。即默认所有通过，规则只需要加不允许谁通过就行。
pkts:对应规则匹配到的报文个数
bytes：对应规则匹配到的报文包的大小总和
target:规则对应的动作，即规则匹配成功后需要采取的动作
prot:规则对应的协议，是否只针对某些协议
in:数据包通过哪个网卡流入
out:数据包通过哪个网卡流出
source:规则对应的源头地址，可以是ip和网段
destination:规则对应的目标地址，可以是ip和网段
```

- 带有编号的显示
```
$ iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1     1120 95662 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
2        5   382 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
3        4   258 INPUT_direct  all  --  *      *       0.0.0.0/0            0.0.0.0/0
4        4   258 INPUT_ZONES_SOURCE  all  --  *      *       0.0.0.0/0            0.0.0.0/0
5        4   258 INPUT_ZONES  all  --  *      *       0.0.0.0/0            0.0.0.0/0
6        0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate INVALID
7        1    78 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
```

- 查看filter表的INPUT链
$ iptables -t filter -vnL INPUT --line-number
