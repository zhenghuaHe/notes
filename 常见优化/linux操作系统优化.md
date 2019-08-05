# linux操作系统的常见优化

0. 关闭daemons。有些运行在服务器中的daemons (后台服务)，并不是完全必要的。关闭这些daemons可释放更多的内存、减少启动时间并减少CPU处理的进程数。
1. 关闭不要的显示。
2. 改变内核参数。内核参数可以改变，在命令行下执行sysctl 命令。
3. 处理器子系统调优。处理器对于应用和数据库服务器来讲是最重要的硬件子系统之一。然而在这些系统中，CPU经常是性能的瓶颈。
4. 内存子系统的调优。内存子系统的调优不是很容易，需要不停地监测来保证内存的改变不会对服务器的其他子系统造成负面影响。
5. 网络子系统的调优。操作系统安装完毕，就要对网络子系统进行调优。
6. 针对TCP和UDP的调优，主要是解决对连接数量非常大的服务器



## 1. 关闭不要的显示。
1. 去除系统及内核版本登录前的屏幕显示
```
# cat /etc/redhat-release
CentOS Linux release 7.4.1708 (Core)
# cat /etc/issue
\S
Kernel \r on an \m

```

## 2. 改变内核参数
1. 禁止ping
```
# 开启禁止ping
echo "net.ipv4.icmp_echo_ignore_all=1"  1>> /etc/sysctl.conf
sysctl -p
# 关闭禁止ping
首先要删除 /etc/sysctl.conf 里面net.ipv4.icmp_echo_ignore_all = 1
之后执行如下命令
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
# 后续就可以通过更改 cat  /proc/sys/net/ipv4/icmp_echo_ignore_all文件
关闭 1 开启 0

```
## 5. 网络子系统的调优
```
内容较多，建议参考官网！

```
## 6. 针对TCP和UDP的调优
```
内容较多，建议参考官网！

```
