# kvm虚拟机
    > 推荐参考：https://blog.csdn.net/github_27924183/article/details/76914322?locationNum=5&fps=1


- 创建kvm虚拟机：

- 直接在能上外网的物理机采用桥接网络模式
```
# 语法
$ virt-install --virt-type=[类型] --name=[虚拟机名字] --vcpus=[cpu等信息] --memory=[内存] --location=[iso存放地址] --disk path=[虚拟机文件存放地址]/svn.qcow2,size=200,format=qcow2 --network bridge=br_wan --graphics none --extra-args='console=ttyS0' --force

$ virt-install --virt-type=[类型] --name=[虚拟机名字] --vcpus=[cpu等信息] --memory=[内存] --location=[iso存放地址] --disk path=[虚拟机文件存放地址]/svn.qcow2,size=200,format=qcow2 --network bridge=br_wan --graphics none --extra-args='console=ttyS0' --force

# 范例
$ virt-install --virt-type=kvm --name=svn --vcpus=4 --memory=2048 --location=/data/libvirt/iso/CentOS-7-x86_64-DVD-1611.iso --disk path=/data1/libvirt/qcow2/svn.qcow2,size=200,format=qcow2 --network bridge=br_wan --graphics vnc --extra-args='console=ttyS0' --force

$ virt-install --virt-type=kvm --name=vm192168122143 --vcpus=8 --memory=8096 --location=/data/libvirt/iso/CentOS-7-x86_64-DVD-1611.iso --disk path=/data/libvirt/qcow2/vm192168122143.qcow2,size=200,format=qcow2 --network bridge=br_wan --graphics none --extra-args='co
nsole=ttyS0' --force
```

* 直接在能上外网的物理机采用net的网络模式
```
$ virt-install --virt-type=kvm --name=tpl_centos7 --vcpus=8 --memory=8096 --location=/data1/libvirt/iso/CentOS-7-x86_64-Minimal-1708.iso \
--disk path=/data1/libvirt/qcow2/tpl_centos7.qcow2,size=200,format=qcow2 --network network=default --graphics none --extra-args='console=ttyS0' --force
```

- 新建一个磁盘
```
$ qemu-img create -f qcow2 kvm-clone.qcow2 2G
```

- 克隆
```
$ virt-clone -o 被克隆的虚拟机 -n 新的虚拟机名 -f 新磁盘保存路径`
$ virt-clone --connect=qemu:///system -o 172016001231 -n 172016001232 -f /data1/libvirt/qcow2/172016001232.qcow2      #不需要提前创建磁盘文件


virt-clone 参数介绍
Options（一些基本的选项）：
--version：查看版本
-h，--help：查看帮助信息
--connect=URI：连接到虚拟机管理程序 libvirt 的URI

General Option（一般选项）：
-o ORIGINAL_GUEST, --original=ORIGINAL_GUEST：原来的虚拟机名称
-n NEW_NAME, --name=NEW_NAME：新的虚拟机名称
--auto-clone：从原来的虚拟机配置自动生成克隆名称和存储路径。
-u NEW_UUID, --uuid=NEW_UUID：克隆虚拟机的新的UUID，默认值是一个随机生成的UUID

Storage Configuration（存储配置）：
-f NEW_DISKFILE, --file=NEW_DISKFILE：指定新的虚拟机磁盘文件
--force-copy=TARGET：强制复制设备
--nonsparse：不使用稀疏文件复制磁盘映像

Networking Configuration:（网络配置）
-m NEW_MAC, --mac=NEW_MAC：设置一个新的mac地址，默认是一个随机的mac
```



* 自动重启
```
$ virsh autostart kvm-name    #设置随宿主机开机自启动

检查在/etc/libvirt/qemu/autostart/下会生成一个（虚拟机名.xml）文件
virsh autostart --disable kvm-name  #取消随宿主机开机自启动
```


- 链接虚拟机：
```
   1. 通过控制窗口登录虚拟机
   $ virsh console kvm-name
   ２. 通过ssh去链接
   $ ssh root@xx.xx.xx.xx
```

- 查看虚拟机信息：
```
１、列出所有的虚拟机
$ virsh list --all


２、显示虚拟机信息
$ virsh dominfo kvm-name

３、显示虚拟机内存和cpu的使用情况
$ yum -y install virt-top
$ virt-top
```

- 启动关闭虚拟机：
```
1、启动虚拟机
$ virsh start kvm-name

２、关闭虚拟机（shutodwn）
$ virsh shutdown kvm-name

3、强制关闭虚拟机
$ virsh destroy kvm-name

4、删除
$ virsh undefine kvm-name

5、彻底删除
$ rm /data/libvirt/qcow2/kvm-name.qcow2  # 不建议删除硬盘

6、重载配置
$ virsh define /etc/libvirt/qemu/centos7.xml
```
- 快照与恢复
```
#test12:kvm-name snap1:快照名
#qemu-img snapshot -l /kvm/img/test12.qcow2 #查看磁盘快照
$ virsh snapshot-list test12 #查看快照
$ virsh snapshot-create test12 #生成快照
$ virsh snapshot-create-as test12 snap1 #自定义快照名
$ virsh snapshot-revert test12 snap1    #快照恢复虚拟
$ virsh snapshot-delete test12 snapname #删除指定快照

范例：
$ virsh snapshot-list 172016001218
 Name                 Creation Time             State
------------------------------------------------------------
 172016001218_01      2018-07-09 14:46:45 +0800 running

$ virsh snapshot-delete --domain 172016001218 --snapshotname 172016001218_01
Domain snapshot 172016001218_01 deleted


$ virsh snapshot-current test12

＃查看是否有快照
 $ virsh snapshot-list 172016001218

 ＃范例：
 [source,bash]
 ----
$ virsh list　　　　　　　＃查看全部虚拟机
 Id    Name                           State
----------------------------------------------------
 26    172016001220                   running
 27    172016001218                   running

$ virsh snapshot-list 172016001218　　　＃查看某个虚拟机的快照
 Name                 Creation Time             State
------------------------------------------------------------

$ virsh snapshot-create 172016001218　　＃创建快照
Domain snapshot 1530597851 created
$ virsh snapshot-list 172016001218　　　＃查看某虚拟机的快照
 Name                 Creation Time             State
------------------------------------------------------------
 1530597851           2018-07-03 14:04:11 +0800 running

$ virsh snapshot-create-as 172016001218 172016001218_bak　　＃给快照指定名字
Domain snapshot 172016001218_bak created
$ virsh snapshot-list 172016001218
 Name                 Creation Time             State
------------------------------------------------------------
 1530597851           2018-07-03 14:04:11 +0800 running
 172016001218_bak     2018-07-03 14:05:25 +0800 running

$ virsh snapshot-delete 172016001218 1530597851　　＃删除不要的快照
Domain snapshot 1530597851 deleted

$ virsh snapshot-list 172016001218　
 Name                 Creation Time             State
------------------------------------------------------------
 172016001218_bak     2018-07-03 14:05:25 +0800 running
```





* 改变虚拟机的参数
    > 通过命令行更改创建之后虚拟机的内存，cpu等信息
```
- 更改内存
1. 查看虚拟机当前内存
$ virsh dominfo kvm-name | grep memory
Max memory:     4194304 KiB
Used memory:    4194304 KiB

2、动态设置内存为512MB，内存减少
$ virsh setmem kvm-name 524288
# 注意单位必须是KB

3、查看内存变化
$ virsh dominfo kvm-name | grep memory
Max memory: 14194304 KiB
Used memory: 524288 kiB

4、内存增加
$ virsh shutdown kvm-name
$ virsh edit kvm-name  # 直接更改memory
$ virsh create /etc/libvirt/demu/kvm-name/xml
# 之后操作1,2,3步骤增加内存

- 更改CPU
需要修改配置文件，因此需要停止虚拟机

$ virsh shutdown kvm-name
$ virsh edit kvm-name
#  <vcpu>2</vcpu>  # 4 > 2
virsh create /etc/libvirt/qemu/kvm-name/xml
```




## FQA:
* 1、kvm虚拟机自动切换到paused状态是什么导致的？怎么解决?
```
一、人为的暂停状态直接恢复virsh resume kvm-name，或者关掉重启
二、因为硬件导致的请检测磁盘空间和内存。
```
