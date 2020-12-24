
# nfs

- centos7安装
```
$ yum -y install nfs-utils
```

- 修改配置
```
$ vim /etc/exports
/data3 *(rw,no_root_squash,no_subtree_check,async,insecure)
```

- 启动
```
$ systemctl start rpcbind
$ systemctl start nfs
$ systemctl enable rpcbind
$ systemctl enable nfs
```

- 查看是否挂好了nfs
```
$ showmount -e ip
```

- exportfs常用命令
```
常用选项
-a 全部挂载或者全部卸载
-r 重新挂载
-u 卸载某一个目录
-v 显示共享目录

$ exportfs -arv //不用重启nfs服务，配置文件就会生效
```