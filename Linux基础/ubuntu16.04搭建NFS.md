
# ubuntu16.04服务器搭建nfs

- 安装nfs服务
```
$ sudo apt-get update
$ sudo apt-get install  nfs-kernel-server
```

- 配置nfs服务
```
$ sudo vi /etc/exports

/data/share  *(rw,sync,no_root_squash,no_subtree_check)
```

- 重启nfs服务
```
$ sudo /etc/init.d/rpcbind restart
$ sudo /etc/init.d/nfs-kernel-server restart
```

- 连接开发板验证
```
# Showmount –a显示出NFS服务器192.168.1.123的共享目录被客户端192.168.122挂载到/home中；
# Showmount –e显示出NFS服务器192.168.1.123上有两个共享目录：/tmp和/home/nfs-share
# Showmount –d显示出NFS服务器的共享目录被挂载到了/home这个挂载点上。

$ Showmount –e 172.16.1.200
Export list for 172.16.1.200:
/data/share *

```

- 客户端挂载
```
$ mkdir  /share
$ mount 172.16.1.200:/data/share /share
```
