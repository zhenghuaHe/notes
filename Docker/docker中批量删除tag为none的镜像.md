

* 在容器没使用的情况下，可以直接执行命令删除，否则先删除容器，再删除镜像
```
$ docker images|grep none|awk '{print $3}'|xargs docker rmi
```
