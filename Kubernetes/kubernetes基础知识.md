
# Kubernetes基础知识
    > Kubernetes将集群的机器划分为一个Master节点和一群工作节点（Node）。

* Master节点
```
　　　运行着管理相关的一组进程kube-apiserver、kube-controller-maneger和kube-scheduler.
　　　kube-apiserver：提供http接口服务，是所有资源的增删查改等操作的入口，也是集群控制的入口进程。
　　　kube-controller-maneger：资源对象的自动化控制中心，可以理解为资源对象的“大总管”。
　　　kube-scheduler：负责资源调度(Pod调度)的进程，相当于工程上的“调度室”。
　　　etcd:所有资源对象的数据全部是保存在etcd中的。
     实现了整个集群的资源管理、Pod调度、弹性伸缩、安全控制、系统监控和纠错等功能，并且是自动完成。
```

* Node节点
```
　　　为集群的工作节点，运行真正的程序。
　　　运行着kubelet、kube-proxy服务进程，负责Pod的创建、启动、监控、重启、销毁，以及实现软件模式的负载均衡。
     kubelet:负责Pod对应容器的创建、启停等任务，同时与Master节点密切协作，实现集群管理。
　　　最小运行单元是Pod。
     node节点上可以运行几百个pod。一个pod里运行着一个Pause容器和N个业务容器，业务容器共享Pause容器的网络栈和Volume挂载卷。
     因此他们之间的通信和数据交换更快更高效。
     一组密切相关的服务进程放入同一个Pod中。
     只有提供服务的一组Pod才会被“映射”成一个服务。
```
* 升级
```
     扩容升级：只需要为Service关联的Pod创建一个RC(之后的步骤系统根据文件自动调配)，一个RC的定义文件包括：
     １、目标Pod的定义
     ２、目标Pod需要运行的副本数量
     ３、要监控的Pod目标的标签
```

* pod类型
```
     pod有两种类型：普通pod和静态pod。
     前者存在于etcd存储中，会被master调度到某个具体的node上进行绑定；
     后者存放于某个具体的文件，且只在此node上运行。
```
* 标签
```
     label(标签)：
     　　　　label可以附加到各种资源对象上，一个资源对象可以定义任意数量的label，同一个label也可以被添加到任意数量的资源对象上。
     　　　　通过给指定的资源对象捆绑一个或多个不同的label来实现多维度的资源分管功能，便于灵活、方便的进行资源分配、调度、配置、部署等。
```

* 应用升级
```
应用升级通常会build一个新的docker镜像，并用新的镜像版本来代替旧版达到目的。
```

* 副本控制器类型（Pod叫副本）
1. ReplicationController （简称为RC）  # 早期产品，后被RS取代
2. ReplicaSet (简称为RS)     # 部署pod，后被更高级的Deployment取代
3. Deployment               # 部署pod，创建更新删除
4. StatefulSet              # 管理有状态的服务
5. DaemonSet                # 管理全局的，相当于在每个节点跑一份
6. Job,Cronjob              # 管理定时任务
