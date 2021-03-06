# Kubernetes常用命令
* yum安装
```
# 1.10.3的源
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-kubernetes-110-release/x86_64/os/
gpgcheck=0

# 1.11.1源
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
```




# kubeadm:


* kubectl:
    > kubectl [command] [name] [flags]

* 查看集群有多少个Node
    > kubectl get node

* 查看某个node的详细信息
    > kubectl describe node node02

* 查看pod信息，看不到有命名空间的pod
    > kubectl get pods

* 查看所有命名空间的pods
    > kubectl get pods --all-namespaces

* 查看pod的详细信息
    > kubectl describe pod mysql-j2nqc

* 查看集群的service的信息
    > kubectl get service

* 查看集群的rc信息
    > kubectl get rc

* 通过修改rc的数量控制pod的动态缩放
    > kubectl scale rc mysql  --replicas=2

* 查看集群的deployment信息
    > kubectl get deployment

* 通过修改rc的数量控制deployment的动态缩放
    > kubectl scale deployment nginx  --replicas=2

* 查看describe的详细信息
    > kubectl describe deployment nginx

* 查看endpoints信息
    > kubectl get endpoints

* 获取命名空间
    > kubectl get namespaces

* 查看集群信息
    > kubectl cluster-info


* 重载配置文件
     > kubectl replace -f rc-nginx.yaml
* 查看详细信息
     > kubectl describe po mysql



* 进入某个 Pod 容器里边的命令行
    > kubectl exec -it $app bash

* 查看某个 Pod 的日志
    > kubectl logs app


* 进入t3命名空间的deployment 下面
    > kubectl exec -n t3 -it t3-rabbitmq-646c7ddff8-njs6m   /bin/bash

* kubernetes labels的创建以及使用
```
1.创建label

kubectl label nodes <node-name> <label-key>=<label-value>

kubectl label nodes node05 node=node05



2.查看labels

kubectl get nodes -Lsystem/build-node

kubectl get nodes --show-labels

kubectl get nodes --show-labels
```

* 设置为不可调度、恢复调度
    > kubectl drain mwteck201 --ignore-daemonsets
    > kubectl uncordon mwteck201
