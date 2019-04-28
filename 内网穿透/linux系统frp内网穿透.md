## 环境
* centos7 外网服务器
* centos7 内网服务器


## 步骤
1. 外网服务器步骤
```
$ mkdir /usr/local/frp
$ cd /usr/local/frp
$ wget https://github.com/fatedier/frp/releases/download/v0.13.0/frp_0.13.0_linux_amd64.tar.gz
$ tar -xzvf frp_0.13.0_linux_amd64.tar.gz
$ cp  frp_0.13.0_linux_amd64/* ./
$ rm -rf frp_0.13.0_linux_amd64*
$ vim frps.ini
[common]
bind_port = 8888
vhost_http_port = 9999
privilege_token = FzaNBryPd5h9BZPxBEpe
pool_count = 5
$ nohup /usr/local/frp/frps -c /usr/local/frp/frps.ini &
$ ss -ntl|grep 8888
LISTEN     0      128         :::8888                    :::*                  
$ ss -ntl|grep 9999
LISTEN     0      128         :::9999                    :::*
```
- 到这里我们的服务端就算做好啦～
---
#### 注释
* frpc、frpc.ini：客户端所关注的文件
* frps、frps.ini：服务端所关注的文件
---


2. 内网服务器步骤
```
$ mkdir /usr/local/frp
$ cd /usr/local/frp
$ wget https://github.com/fatedier/frp/releases/download/v0.13.0/frp_0.13.0_linux_amd64.tar.gz
$ tar -xzvf frp_0.13.0_linux_amd64.tar.gz
$ cp  frp_0.13.0_linux_amd64/* ./
$ rm -rf frp_0.13.0_linux_amd64*
$ vim frpc.ini
[common]
server_addr = 104.133.122.204
server_port = 8888
privilege_token = FzaNBryPd5h9BZPxBEpe
pool_count = 5

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 1008
$ nohup /usr/local/frp/frpc -c /usr/local/frp/frpc.ini &
```
- 到这里我们的客户端就算做好啦～

- 这下你可以用你的外网IP加上内网映射的端口去连接你的内网服务器啦～

`ssh -p1008 root@104.133.122.204`
