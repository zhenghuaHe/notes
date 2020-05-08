

# 安装node npm


## 方法一(建议)
    > 直接从yum的eprl源里面安装


## 方法二
* 下载网址
    > https://nodejs.org/dist/latest-v8.x/
```
$ cd /usr/local/
$ wget https://nodejs.org/dist/latest-v8.x/node-v8.16.0-linux-x64.tar.gz
$ tar -xzvf node-v8.16.0-linux-x64.tar.gz
$ mv node-v8.16.0-linux-x64 node
$ ln -s /usr/local/node/bin/npm /usr/sbin/
$ ln -s /usr/local/node/bin/node /usr/sbin/

#  查看版本
$ node -v
$ npm -v
```


## 方法三
```
$ cat /etc/yum.repos.d/nodesource-el6.repo
[nodesource]
name=Node.js Packages for Enterprise Linux 6 - $basearch
baseurl=https://rpm.nodesource.com/pub_9.x/el/6/$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL

[nodesource-source]
name=Node.js for Enterprise Linux 6 - $basearch - Source
baseurl=https://rpm.nodesource.com/pub_9.x/el/6/SRPMS
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL
gpgcheck=1
```
