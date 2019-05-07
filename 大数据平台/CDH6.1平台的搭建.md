
# CDH6.1平台的搭建过程简要记录

## 前期准备
```
$ vim /etc/hosts
172.16.1.120 node120
172.16.1.121 node121
172.16.1.122 node122

$ sudo systemctl disable firewalld
$ sudo systemctl stop firewalld

$ setenforce 0
$ sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

$ yum -y install ntp
$ sed -i 's/server 0.centos.pool.ntp.org iburst/#server 0.centos.pool.ntp.org iburst/g' #/etc/ntp.conf     
$ sed -i 's/server 1.centos.pool.ntp.org iburst/#server 1.centos.pool.ntp.org iburst/g' #/etc/ntp.conf
$ sed -i 's/server 2.centos.pool.ntp.org iburst/#server 2.centos.pool.ntp.org iburst/g' #/etc/ntp.conf
$ sed -i 's/server 3.centos.pool.ntp.org iburst/#server 3.centos.pool.ntp.org iburst/g' #/etc/ntp.conf
$ sed  -ie 's/#server 3.centos.pool.ntp.org iburst/#server 3.centos.pool.ntp.org iburst \nserver 10.17.87.8/g' /etc/ntp.conf
$ systemctl restart ntpd && systemctl enable ntpd && ntpq -p  && hwclock -r

$ ssh-keygen -t rsa  #一直回车
$ ssh-copy-id node121
$ ssh-copy-id node122
```
## 中期安装相关的软件

```
# 提前下载好离线包
cdh6.1.0 离线包：
CDH-6.1.0-1.cdh6.1.0.p0.770702-el7.parcel
CDH-6.1.0-1.cdh6.1.0.p0.770702-el7.parcel.sha256
manifest.json

* 下载： <https://archive.cloudera.com/cdh6/6.1.0/parcels/>

cdh6 的CM 包:
cloudera-manager-agent-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-daemons-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-server-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-server-db-2-6.1.0-769885.el7.x86_64.rpm
oracle-j2sdk1.8-1.8.0+update141-1.x86_64.rpm
allkeys.asc

* 下载地址：<https://archive.cloudera.com/cm6/6.1.0/redhat7/yum/RPMS/x86_64/>

$ ls /root/cm6
allkeys.asc
CDH-6.1.0-1.cdh6.1.0.p0.770702-el7.parcel
CDH-6.1.0-1.cdh6.1.0.p0.770702-el7.parcel.sha256
cloudera-manager-agent-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-agent.rpm
cloudera-manager-daemons-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-daemons.rpm
cloudera-manager-server-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-server-db-2-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-server.rpm
manifest.json

$ yum -y install httpd createrepo
$ vim /etc/httpd/conf/httpd.conf
AddType application/x-gzip .gz .tgz .parcel
$ systemctl start httpd
$ cd /root/cm6 && createrepo .
$ mv cm6 /var/www/html/
$ ls /var/www/html/cm6/
allkeys.asc
CDH-6.1.0-1.cdh6.1.0.p0.770702-el7.parcel
CDH-6.1.0-1.cdh6.1.0.p0.770702-el7.parcel.sha256
cloudera-manager-agent-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-agent.rpm
cloudera-manager-daemons-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-daemons.rpm
cloudera-manager-server-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-server-db-2-6.1.0-769885.el7.x86_64.rpm
cloudera-manager-server.rpm
manifest.json
repodata



$ yum install java-1.8.0-openjdk-devel
$ yum install cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server



# 数据库5.6安装
$ wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
$ rpm -ivh mysql-community-release-el7-5.noarch.rpm
$ yum install mysql-server
$ systemctl start mysqld
$ systemctl enable mysqld
$ mysql_secure_installation ＃回车-Y-设置密码-再次设置密码-Y-N-Y-Y



# 安装MySQL JDBC Driver
$ wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz
$ tar zxvf mysql-connector-java-5.1.46.tar.gz
$ mkdir -p /usr/share/java/
$ cd mysql-connector-java-5.1.46
$ cp mysql-connector-java-5.1.46-bin.jar /usr/share/java/mysql-connector-java.jar



# 给mysql数据库创建需要用到的库
$ mysql -uroot -p
$ CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON scm.* TO 'scm'@'%' IDENTIFIED BY 'scm@123';
$ CREATE DATABASE amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON amon.* TO 'amon'@'%' IDENTIFIED BY ' amon@123';
$ CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON rman.* TO 'rman'@'%' IDENTIFIED BY 'rman@123';
$ CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON hue.* TO 'hue'@'%' IDENTIFIED BY 'hue@123';
$ CREATE DATABASE metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON metastore.* TO 'metastore'@'%' IDENTIFIED BY 'metastore@123';
$ CREATE DATABASE sentry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON sentry.* TO 'sentry'@'%' IDENTIFIED BY 'sentry@123';
$ CREATE DATABASE nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON nav.* TO 'nav'@'%' IDENTIFIED BY 'nav@123';
$ CREATE DATABASE navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON navms.* TO 'navms'@'%' IDENTIFIED BY 'navms@123';
$ CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON oozie.* TO 'oozie'@'%' IDENTIFIED BY 'oozie@123';
$ CREATE DATABASE hive DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
$ GRANT ALL ON hive.* TO 'hive'@'%' IDENTIFIED BY 'hive@123';
$ flush privileges;

# 建立CM的数据库：
$ /opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm


$ systemctl start cloudera-scm-server
```

## CDH6.1.0的初始化
* http://<server_IP>:7180
* 用户名：admin
* 密码：admin


在master:7180端口里面的选择存储库处，选择第三个远程设置自己的本地地址，如：http://172.16.1.120/cdh6.1/




# FQA总结
1. Swapping
sudo sysctl vm.swappiness=1
echo "vm.swappiness = 1" >>  /etc/sysctl.conf

2. Clock Offset 。测试主机时钟与其 NTP 服务器之间的偏差。

3.

4.
