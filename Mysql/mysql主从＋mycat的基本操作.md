# docker搭建主从
* 创建操作
```
$ docker run  -h mysql_master -p  0.0.0.0:10022:22 -p 0.0.0.0:13306:3306 -it  -v /data/mysql:/data/mysql  --name mysql_master mwteck/centos6:20180126b1
$ docker run  -h mysql_slave -p  0.0.0.0:10023:22 -p 0.0.0.0:13307:3306 -it  -v /data/mysql:/data/mysql  --name mysql_slave mwteck/centos6:20180126b1

$ docker exec -it mysql_master bash
[root@localhost ~]# vim /etc/yum.repos.d/mysql.repo
[root@localhost ~]# cat /etc/yum.repos.d/mysql.repo
[mysql56]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/6/$basearch/
enabled=1
gpgcheck=0

$ yum -y install mysql-community-server
$ service mysqld start
$ mysql_secure_installation



$ [root@mysql_master ~]# cat /etc/my.cnf
[mysqld]
server-id = 1
log-bin=mysql-bin

$ service mysqld restart


$ mysql -uroot -p
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      120 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+

mysql> grant replication client,replication slave on *.* to 'test'@'%' identified by '123456';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)


$ docker exec -it mysql_slave bash
[root@mysql_slave ~]# cat /etc/my.cnf
[mysqld]
server-id = 2
service mysqld restart
mysql -uroot -p

mysql> change master to master_host='172.17.0.10',master_user='test',master_password='123456',master_log_file='mysql-bin.000002',master_log_pos=120;
Query OK, 0 rows affected, 2 warnings (0.26 sec)

mysql> start slave;
Query OK, 0 rows affected (0.02 sec)

mysql> show slave status\G
```


* FAQ:
```
1、数据同步失败，链接不过去。
Last_IO_Error: error connecting to master 'test@172.17.0.8:3306' - retry-time: 60  retries: 2
解决：检查容器IP是否发生变化，检查防火墙。
　　　停掉slave，执行reset slave,重新change链接一次就好。
```
