## 下载tar包
```
$ wget https://www.mongodb.com/dr/fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.1.tgz/download
```

## docker环境下运行
```
$ docker run  -h hostname -p  0.0.0.0:5222:22 -p 0.0.0.0:5002:8080 -it  -v /data/web/:/data/web/  --name ttd_arch_api_admin   mwteck/centos6:20180126b1

$ docker run  -h mongodb -p  0.0.0.0:5222:22 -p 0.0.0.0:5223:27017 -it  -v /data/db/:/data/db/  --name py_mongodb   centos:7
```
## tar包安装
```
$ cd /usr/local/
$ wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.1.tgz
$ tar -xzvf mongodb-linux-x86_64-4.0.1.tgz
$ mv mongodb-linux-x86_64-4.0.1 mongodb

$ export PATH=<mongodb-install-directory>/bin:$PATH
```
