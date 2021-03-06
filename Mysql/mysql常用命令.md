
# mysql常用基础命令
- 远程登录＋账号赋权
    > grant all privileges on *.* to root@"%" identified by '123456';
    > flush privileges;

* mysql 查看锁表解锁
```
    > 查看那些表锁到了
    > show OPEN TABLES where In_use > 0;
    > 查看进程号
    > show processlist;
    > 删除进程
    > kill 1085850；
　

* 远程备份：
    > mysqldump -h172.16.1.200 -P2000 -uttd -p12345.  ttd >ttd_back.sql

* 指定表备份
    > mysqldump -u user -p db tab1 tab2 > db.sql
* 恢复
    > mysql -u user -p db < db.sql

* 备份本地整个数据库
    > mysqldump db1 >/backup/db1.20060725
* 压缩备份
    > mysqldump db1 | gzip >/backup/db1.20060725
* 分表备份
    > mysqldump db1 tab1 tab2 >/backup/db1_tab1_tab2.sql
* 直接远程备份
    > mysqladmin -h boa.snake.net create db1
    > mysqldump db1 | mysql -h boa.snake.net db1



- 链表查询

JOIN 按照功能大致分为如下三类：

INNER JOIN（内连接,或等值连接）：取得两个表中存在连接匹配关系的记录。　显示两个表共有的数据
LEFT JOIN（左连接）：取得左表（table1）完全记录，即是右表（table2）并无对应匹配记录。　查询两张表共有的数据，以左边的表为准，数据不足的地方显示NULL
RIGHT JOIN（右连接）：与 LEFT JOIN 相反，取得右表（table2）完全记录，即是左表（table1）并无匹配对应记录　　查询两张表共有的数据，以右边的表为准，数据不足的地方显示NULL

范例：
    > SELECT * FROM table01 as a INNER JOIN table02 AS b ON a.id=b.id;
    > SELECT * FROM table01 AS a LEFT JOIN table02 AS b ON a.id=b.id;
    > SELECT * FROM table02 AS a RIGHT JOIN table01 AS b ON a.id=b.id;
