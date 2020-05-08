# kvm关闭vpn功能、修改网络模式

* kvm的vnc服务关闭
1. 关闭虚拟机
```
$ virsh shutdown kvm-name
```

2. 强制关闭（如果你上一步关闭比较慢的话可采用）
```
$ virsh destroy kvm-name
```
3. 删除关于vnc的配置信息
```
$ virsh edit kvm-name
----
<graphics type=‘vnc‘ port=‘-1‘ autoport=‘yes‘ listen=‘0.0.0.0‘>
<listen type=‘address‘ address=‘0.0.0.0‘/>
</graphics>
----
```
4. 启动验证
```
$ virsh start kvm-name
$ ps -ef|grep kvm-name  #确认自己进程的PID
$ ss -ntlp|grep 59*     #vnc开启的端口为59xx，对比是否有自己的进程PID，没有即为关闭成功。
```




* KVM修改虚机网卡模式：由NAT模式改为Bridge模式
1. 关闭虚拟机
```
$ virsh destroy kvm-name
```
２. 修改配置文件
```
$ virsh edit kvm-name
----
<interface type=‘default‘> 改为<interface type=‘bridge‘>
<mac address=‘52:54:00:50:58:7e‘/>
<source network=‘default‘/> 改为<source bridge=‘br0‘/>
<model type=‘virtio‘/>
<address type=‘pci‘ domain=‘0x0000‘ bus=‘0x00‘ slot=‘0x03‘ function=‘0x0‘/>
</interface>
```
修改为下面内容
```
<interface type=‘bridge‘>
<mac address=‘52:54:00:50:58:7e‘/>
<source bridge=‘br0‘/>
<model type=‘virtio‘/>
<address type=‘pci‘ domain=‘0x0000‘ bus=‘0x00‘ slot=‘0x03‘ function=‘0x0‘/>
</interface>
----
```
３. 重新启动
```
$ virsh start kvm-name
```
