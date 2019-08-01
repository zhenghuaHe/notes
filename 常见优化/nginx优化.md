# nginx常见优化

## 基本优化
```
0. 隐藏nginx版本号信息。在配置文件中添加：server_tokens off
1. 修改nginx进程用户信息（worker进程）
2. 配置Nginx，禁止非法域名解析访问企业网站
3. 实现防盗链。1.利用reffer实现防盗链。2.根据cookie防盗链。3.通过加密变换访问路径实现防盗链。4.给图片信息加上水印
4. nginx 防爬虫优化。01.利用robots协议 02.修改nginx配置，user_agent 03开发的角度进行防止
```

## 性能优化

0. 优化worker进程数量信息。
```
vim nginx.conf
worker_processes 1;
PS:worker进程数量主要参照CPU核数信息
worker_processes 数量==CPU核数
worker_processes 数量==CPU核数*2
```
1. 优化worker进程连接数量能力
```
 vim nginx.conf
 worker_connections 1024;(2的倍数为妙)
 PS：系统最大打开文件数>=worker_connections*worker_processes
 [root@web01 nginx]# ulimit -a|grep open
 open files                      (-n) 65535
```
2. 优化nginx服务CPU亲和力
```
 服务器: CPU01(繁忙) CPU02 CPU03 CPU04  

 案例一: 有4个nginx进程  服务器有4颗CPU(进程数和颗数相同)
 wker_processes    4；
 worker_cpu_affinity 0001 0010 0100 1000;

 案例二: 有多个nginx进程 服务器有4颗CPU(进程数大于颗数信息)
 wker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000；
 worker_cpu_affinity 0001 0010 0100 1000 0001 0010 0100 1000；

 案例三:
 wker_processes    4；
 worker_cpu_affinity 0101 1010;
```
3. 开启高效文件传输模式
```
 sendfile    on;  特殊的数据传输功能：零拷贝
 tcp_nopush  on;  将数据积攒到一定量再发送
 tcp_nodelay off; 经数据信息进行快速传输

 数据包==1500字节==货车=1500件  1600字节 1500 100 == 1400  1500
    01. 先别着急发送, 确保数据包已经装满数据, 避免了网络拥塞
    	tcp_nopush on;
    02. 有时要抓紧发货, 确保数据尽快发送, 提高可数据传输效率
     	tcp_nodelay on;
    说明: 以上两个参数选择其一使用
```

4. 优化nginx服务超时信息
```
 1）keepalive_timeout  60;
 确保通讯双方在一定时间内没有传输数据了，断开连接
 2）client_header_timeout  15;
 发送方发出请求信息，但接受方迟迟不作出响应
 3) client_body_timeout  15;
 发送方放出主体信息，但接受方没有正常处理
 4） send_timeout  ;
 服务端等待客户端两次请求的间隔时间
```
5. 设置nginx服务允许用户最大上传数据大小
```
    client_max_body_size 2m;
    PS: 默认大小为1m
```
6. nginx与php之间fsstcgi优化信息
```
时间超时设定
 fastcgi_connect_timeout 240;
 fastcgi_send_timeout 240;
 fastcgi_read_timeout 240;
缓冲设置
http区块中设置
fastcgi_buffer_size 64k;
 fastcgi_buffers 4 64k;
 fastcgi_busy_buffers_size 128k;
 fastcgi_temp_file_write_size 128k;
 #fastcgi_temp_path /data/ngx_fcgi_tmp;
 fastcgi_cache_path /data/ngx_fcgi_cache levels=1:2 keys_zone=ngx_fcgi_cache:512m inactive=1d max_size=40g;
server区块中设置
  server {
      listen       80;
      server_name  blog.jinc.org;
      root   html/blog;
      index  index.php index.html index.htm;
      client_max_body_size 2m;
      location ~* .*\.(php|php5)?$ {
        root html/blog;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_cache ngx_fcgi_cache;
        fastcgi_cache_valid 200 302 1h;
        fastcgi_cache_valid 301 1d;
        fastcgi_cache_valid any 1m;
        fastcgi_cache_min_uses 1;
        fastcgi_cache_use_stale error timeout invalid_header http_500;
        fastcgi_cache_key http://$host$request_uri;
        include fastcgi.conf;
    }
  }

```
7. 压缩传输的数据信息
```
gzip on;
gzip_min_length             1k;
gzip_buffers                4 16k;
gzip_http_version           1.1;
gzip_comp_level             7;
gzip_types                  text/css text/xml application/javascripts;
gzip_vary                   on;
```

8. 让用户尽可能多的缓存网站数据信息。当网站架构负载压力过大的时候, 尽量将压力向前推
```
 location ~ .*\.（|jpg|jpeg|png|bmp|swf）$
    {
        expires      3650d；
    }
```
