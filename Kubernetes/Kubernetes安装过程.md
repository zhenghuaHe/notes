# kubernetes高可用安装

* 准备工作
```
systemctl stop firewalld
systemctl disable firewalld

swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab

setenforce  0
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

modprobe br_netfilter
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf
echo `ls /proc/sys/net/bridge`


cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```
* 安装基础包
```
$ yum install -y epel-release
$ yum install -y yum-utils device-mapper-persistent-data lvm2 net-tools conntrack-tools wget vim  ntpdate libseccomp libtool-ltdl
```


* 其他配置
```
$ systemctl enable ntpdate.service
echo '*/30 * * * * /usr/sbin/ntpdate time7.aliyun.com >/dev/null 2>&1' > /tmp/crontab2.tmp
crontab /tmp/crontab2.tmp
$ systemctl start ntpdate.service


echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nproc 65536"  >> /etc/security/limits.conf
echo "* hard nproc 65536"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf
```

* 安装etcd
```
$ yum install etcd　-y
[root@node01 ~]# grep -v "^#" /etc/etcd/etcd.conf
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_NAME="master_etcd"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://172.16.1.218:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://172.16.1.218:2379"
ETCD_INITIAL_CLUSTER="master_etcd=http://172.16.1.218:2380"
```

* 安装docker
```
$ yum install https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm  -y
$ yum install https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm  -y

$ systemctl start docker
```

* 安装kube包
```
$ yum install -y kubeadm-1.10.5 kubectl-1.10.5 kubelet-1.10.5

```




























脚本安装：
需要作为node节点或者master节点，分别执行不同的脚本

node节点加入master集群的可以直接复制master下面的/etc/kubernetes到node节点下

ＦＱＡ：如果加入集群的节点加入了集群，但是状态没对，请查看对应的docker镜像在node节点创建了没有。
