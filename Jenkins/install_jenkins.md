# 简单安装使用jenkins
```
$ yum -y install java-1.8.0-openjdk-devel.x86_64
$ rpm -ivh https://pkg.jenkins.io/redhat-stable/jenkins-2.164.2-1.1.noarch.rpm
$ systemctl start jenkins
$ systemctl enable jenkins
```
* 数据都存在jenkins_home下面的，记得保存好,这个存放数据的目录可以自行定义



1. 源码管理－填写git地址报错
Failed to connect to repository : Error performing command: git ls-remote -h git@git.mwteck.com:yinyan/p5-dataV.git HEAD
    > 解决方法：安装git
