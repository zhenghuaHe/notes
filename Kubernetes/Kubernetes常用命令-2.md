# Kubernetes常用命令

* 状态查询
```
# 查看集群信息
$ kubectl cluster-info
$ systemctl status kube-apiserver
$ systemctl status kubelet
$ systemctl status kube-proxy
$ systemctl status kube-scheduler
$ systemctl status kube-controller-manager
$ systemctl status docker
```

* node相关
```
# 查看namespaces
$ kubectl get namespaces
$ kubectl get ns

# 为节点增加lable
$ kubectl label nodes 10.126.72.31 points=test

# 查看节点和lable
$ kubectl get nodes --show-labels

# 查看状态
$ kubectl get componentstatuses
$ kubectl get cs

# Node的隔离与恢复
## 隔离
$ kubectl cordon k8s-node1

## 恢复
$ kubectl uncordon k8s-node1
```

* 查询
```
# 查看所有nodes节点
$ kubectl get nodes

# 查看一个node
$ kubectl describe nodes node1

# 通过yaml文件查询
$ kubectl get -f xxx-yaml/

# endpoints端
$ kubectl get endpoints

#### 查看pods ####

# 查看指定空间`kube-system`的pods
$ kubectl get po -n kube-system

# 查看所有空间的
$ kubectl get pods -o wide --all-namespaces

# 其他的写法
$ kubectl get pod -o wide --namespace=kube-system

# 获取svc
$ kubectl get svc --all-namespaces

# 其他写法
$ kubectl get services --all-namespaces

# 通过lable查询
$ kubectl get pods -l app=nginx -o yaml|grep podIP

# 当我们发现一个pod迟迟无法创建时，可以使用describe来查看详细信息。
$ kubectl describe pod xxx
```

* 删除pod
```
# 删除所有pods
$ kubectl delete pods --all

# 删除所有包含某个lable的pod和serivce
$ kubectl delete pods,services -l name=<lable-name>

# 删除ui server,然后重建
$ kubectl delete deployments kubernetes-dashboard --namespace=kube-system
$ kubectl delete services kubernetes-dashboard --namespace=kube-system

# 强制删除部署
$ kubectl delete deployment kafka-1

# 删除rc
$ kubectl delete rs --all && kubectl delete rc --all

## 强制删除Terminating状态的pod
$ kubectl delete deployment kafka-1 --grace-period=0 --force
```
* 滚动
```
# 升级
$ kubectl apply -f xxx.yaml --record

# 回滚
$ kubectl rollout undo deployment javademo

#指定回滚版本
$ kubectl rollout undo deployment/nginx-ye --to-revision=4 -n kube-system

# 查看滚动升级记录
$ kubectl rollout history deployment {名称}
```

* 查看日志
```
# 查看指定镜像的日志
$ kubectl logs -f kube-dns-699984412-vz1q6 -n kube-system

$ kubectl logs --tail=10 nginx  

#指定其中一个查看日志
$ kubectl logs kube-dns-699984412-n5zkz -c kubedns --namespace=kube-system
$ kubectl logs kube-dns-699984412-vz1q6 -c dnsmasq --namespace=kube-system
$ kubectl logs kube-dns-699984412-mqb14 -c sidecar --namespace=kube-system

# 看日志
$ journalctl -f
```
* 扩展
```
# 扩展副本
$ kubectl scale rc xxxx --replicas=3
$ kubectl scale rc mysql --replicas=1
$ kubectl scale --replicas=3 -f foo.yaml
```
* 执行
```
# 启动
$ nohup kubectl proxy --address='10.1.70.247' --port=8001 --accept-hosts='^*$' >/dev/null 2>&1 &

# 进入镜像
$ kubectl exec kube-dns-699984412-vz1q6 -n kube-system -c kubedns ifconfig
$ kubectl exec kube-dns-699984412-vz1q6 -n kube-system -c kubedns ifconfig /bin/bash

# 执行镜像内命令
$ kubectl exec kube-dns-4140740281-pfjhr -c etcd --namespace=kube-system etcdctl get /skydns/local/cluster/default/redis-master
```

* 其他
```
# 创建和删除
$ kubectl create -f dashboard-controller.yaml
$ kubectl delete -f dashboard-dashboard.yaml

# 查看指定pods的环境变量
$ kubectl exec xxx env

# 判断dns是否通
$ kubectl exec busybox -- nslookup kube-dns.kube-system

# kube-proxy状态
$ systemctl status kube-proxy -l

# token的
$ kubectl get serviceaccount/kube-dns --namespace=kube-system -o yaml|grep token
```
