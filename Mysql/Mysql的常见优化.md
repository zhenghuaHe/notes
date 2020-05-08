# mysql5.7常见优化


* 常见优化
0. 各种优化参数
1. 数据库引擎(innodb/myisam)
2. 合理的索引
3. 分区分表
4. 查询缓存
5. 读写分离
6. sql优化


## 0. 各种优化参数的一些大概方向
```
0、允许cpu使用数
1、内存数据存入磁盘，开机加载
2、超时时间
3、最大连接数相关、内存使用相关等.默认是50，TCP/IP的连接数量，一个连接占用256KB内存，最大是64MB，256 * 300 =75MB内存
4、查询缓存。query_cache_type=0，query_cache_size=0
5、处理io的上限，允许用多少内存来处理，一般为物理内存的60%-70%
6、数据的一致性。不管有没有提交，每秒钟都写到binlog日志里
```

* 附一份个人总结的配置文件详解
```
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
innodb_buffer_pool_size = 8094M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0                          # 支持符号链接，可以管理不同数据目录的数据
lower_case_table_names=1                  # 不区分大小写，修改需重启MySQL
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

server_id=101
character-set-server=utf8mb4              # 设置默认编码
default-storage-engine=InnoDB             # 设置默认引擎
skip-name-resolve                         # 解决本地连接慢的问题

back_log=100                              # back_log值指出在MySQL暂时停止回答新请求之前的短时间内多少个请求可以被存在堆栈中。也就是说，如果MySql的连接数达到max_connections时，新来的请求将会被存在堆栈中，以等待某一连接释放资源，该堆栈的数量即back_log，如果等待连接的数量超过back_log，将不被授予连接资源。back_log值不能超过TCP/IP连接的侦听队列的大小。若超过则无效，查看当前系统的TCP/IP连接的侦听队列的大小命令：cat /proc/sys/net/ipv4/tcp_max_syn_backlog，目前系统为1024。
max_connections=2000                      # 最大连接数
max_allowed_packet=64M                    # 允许最大的语句64M
innodb_flush_log_at_trx_commit=1          # 每次事务的结束都会触发Log Thread 将log buffer 中的数据写入文件并通知文件系统同步文件，最安全但效率底
sync_binlog=1                             # 每次组提交进行FSYNC刷盘，同时dump线程会在sync阶段后进行binlog传输

log_bin=mysql-bin                         # 开启主从复制
binlog_format=row                         # 加快从库重放日志，跳过了MySQL优化器
slow_query_log=1                          # 开启慢查询功能
slow_query_log_file=/var/log/mysql_slow_query.log  # 慢日志路径
long_query_time=3                         # 超过多长时间写满日志
log_timestamps=SYSTEM                     # 日志时间
# thread level per one
join_buffer_size = 5M                     # 当我们的join是ALL,index,rang或者Index_merge的时候使用的buffer。 实际上这种join被称为FULL JOIN
wait_timeout=3600                         # 等待释放资源的时间

sort_buffer_size = 5M                     # connection第一次需要使用buffer一次性分配的内存，不是越高越好会拖累内存资源
read_buffer_size = 1M                     # 读入缓冲区的大小，将对表进行顺序扫描的请求将分配一个读入缓冲区，MySQL会为它分配一段内存缓冲区

query_cache_type=1                        # 开启高速缓存
query_cache_size=1024M                    # 缓存所有的结果
query_cache_limit=2M                      # 指定单个查询能够使用的缓冲区大小
key_buffer_size=256M                      # 所有线程所共有的MyISAM表索引缓存
```
