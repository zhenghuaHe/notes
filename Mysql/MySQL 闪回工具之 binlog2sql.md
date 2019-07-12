# MySQL 闪回工具之 binlog2sql

### 适用于：
* 数据回滚
* 主从切换后数据不一致的修复
* 从binlog生成标准SQL，带来的衍生功能

## 闪回原理简析
```
MySQL binlog 以event为单位，记录数据库的变更信息，这些信息能够帮助我们重现这之间的所有变化，也就是所谓的闪回。

binlog 有三种可选的格式：
1、statement：基于 SQL 语句的模式，binlog 数据量小，但是某些语句和函数在复制过程可能导致数据不一致甚至出错；
2、mixed：混合模式，根据语句来选用是 statement 还是 row 模式；
3、row：基于行的模式，记录的是行的完整变化。安全，但 binlog 会比其他两种模式大很多；

利用 binlog 做闪回，需要将 binlog 格式设置为 row，因为我们需要最详尽的信息来确定操作之后数据不会出错。
既然 binlog 以 event 形式记录了所有的变更信息，那么我们把需要回滚的 event，从后往前回滚回去即可。

回滚操作：
对于 delete 操作，我们从 binlog 提取出 delete 信息，反向生成 insert 回滚语句；
对于 insert 操作，反向生成 delete 回滚语句；
对于 update 操作，根据信息生成反向的 update 语句；
```

安装
==============

```
shell> git clone https://github.com/danfengcao/binlog2sql.git && cd binlog2sql
shell> pip install -r requirements.txt
```
git与pip的安装问题请自行搜索解决。

使用
=========

### MySQL server必须设置以下参数:

    [mysqld]
    server_id = 1
    log_bin = /var/log/mysql/mysql-bin.log
    max_binlog_size = 1G
    binlog_format = row
    binlog_row_image = full

### user需要的最小权限集合：

    select, super/replication client, replication slave

    建议授权
    GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO

**权限说明**

* select：需要读取server端information_schema.COLUMNS表，获取表结构的元信息，拼接成可视化的sql语句
* super/replication client：两个权限都可以，需要执行'SHOW MASTER STATUS', 获取server端的binlog列表
* replication slave：通过BINLOG_DUMP协议获取binlog内容的权限

### 选项

**mysql连接配置**

-h host; -P port; -u user; -p password

**解析模式**

--stop-never 持续解析binlog。可选。默认False，同步至执行命令时最新的binlog位置。

-K, --no-primary-key 对INSERT语句去除主键。可选。默认False

-B, --flashback 生成回滚SQL，可解析大文件，不受内存限制。可选。默认False。与stop-never或no-primary-key不能同时添加。

--back-interval -B模式下，每打印一千行回滚SQL，加一句SLEEP多少秒，如不想加SLEEP，请设为0。可选。默认1.0。

**解析范围控制**

--start-file 起始解析文件，只需文件名，无需全路径 。必须。

--start-position/--start-pos 起始解析位置。可选。默认为start-file的起始位置。

--stop-file/--end-file 终止解析文件。可选。默认为start-file同一个文件。若解析模式为stop-never，此选项失效。

--stop-position/--end-pos 终止解析位置。可选。默认为stop-file的最末位置；若解析模式为stop-never，此选项失效。

--start-datetime 起始解析时间，格式'%Y-%m-%d %H:%M:%S'。可选。默认不过滤。

--stop-datetime 终止解析时间，格式'%Y-%m-%d %H:%M:%S'。可选。默认不过滤。

**对象过滤**

-d, --databases 只解析目标db的sql，多个库用空格隔开，如-d db1 db2。可选。默认为空。

-t, --tables 只解析目标table的sql，多张表用空格隔开，如-t tbl1 tbl2。可选。默认为空。

--only-dml 只解析dml，忽略ddl。可选。默认False。

--sql-type 只解析指定类型，支持INSERT, UPDATE, DELETE。多个类型用空格隔开，如--sql-type INSERT DELETE。可选。默认为增删改都解析。用了此参数但没填任何类型，则三者都不解析。


**解析出标准SQL**

```bash
shell> python binlog2sql.py -h127.0.0.1 -P3306 -uadmin -p'admin' -dtest -t test3 test4 --start-file='mysql-bin.000002'

输出：
INSERT INTO `test`.`test3`(`addtime`, `data`, `id`) VALUES ('2016-12-10 13:03:38', 'english', 4); #start 570 end 736
UPDATE `test`.`test3` SET `addtime`='2016-12-10 12:00:00', `data`='中文', `id`=3 WHERE `addtime`='2016-12-10 13:03:22' AND `data`='中文' AND `id`=3 LIMIT 1; #start 763 end 954
DELETE FROM `test`.`test3` WHERE `addtime`='2016-12-10 13:03:38' AND `data`='english' AND `id`=4 LIMIT 1; #start 981 end 1147
```

**解析出回滚SQL**

```bash

shell> python binlog2sql.py --flashback -h127.0.0.1 -P3306 -uadmin -p'admin' -dtest -ttest3 --start-file='mysql-bin.000002' --start-position=763 --stop-position=1147

输出：
INSERT INTO `test`.`test3`(`addtime`, `data`, `id`) VALUES ('2016-12-10 13:03:38', 'english', 4); #start 981 end 1147
UPDATE `test`.`test3` SET `addtime`='2016-12-10 13:03:22', `data`='中文', `id`=3 WHERE `addtime`='2016-12-10 12:00:00' AND `data`='中文' AND `id`=3 LIMIT 1; #start 763 end 954
```
