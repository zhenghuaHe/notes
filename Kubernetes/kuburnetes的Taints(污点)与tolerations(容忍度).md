# kuburnetes的Taints(污点)与tolerations(容忍度)

* Taints（污点）与tolerations（容忍度）一起工作确保Pod不会被调度到不合适的节点上。单个节点可以应用多个taint（污点），node不接受无法容忍taint（污点）的pod调度。Toleration（容忍度）是pod的属性，允许（非强制）pod调度到taints（污点）相匹配的node上去.



* 创建删除污点范例
```
# 通过kubectl taint为node添加taint，如：
$ kubectl taint nodes node1 key=value:NoSchedule
#为node1删除刚才添加的taints，如下：
kubectl taint nodes node1 key:NoSchedule-

# 为node1增加一条taint(污点)，污点影响NoSchedule。意味着没有pod调度到node1上，除非pod匹配了容忍度。  
```

* 创建容忍度范例
```
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"
tolerations:
- key: "key"
  operator: "Exists"
  effect: "NoSchedule"
```

* Toleration（容忍度）与taint（污点）匹配的条件是key相同、effect相同，并且：
   1. Operator的值是Exists（无需指定values的值）
   2. Operator是Equal，并且values的值相等
   3. 如果不指定，operator默认是Equal。

```
可以为单个node指定多条taint（污点），也可以为单个pod指定多条toleration（容忍度）。系统采用过滤的方式处理这种情况：首先从node的所有taint（污点）开始，然后将与pod中的toleration（容忍度）相匹配的taint（污点）删除，余下的taint（污点）对部署进来的pod产生影响。特别地：

如果余下的taint（污点）中至少有一条的effect是NoSchedule，kubernetes将不会高度这个pod到的node上。

如果余下的taint（污点）中没有effect为NoSchedule的taint（污点），但至少有一条effect为PreferNoSchedule，则系统尝试着不将pod部署在node上（也就是有可能还是会部署到这个node上）。

如果余下的taint（污点）中至少有一条的effect是NoExecute，那么不旦新的pod不会被调度到这个node上，而且已经运行在这个node上的pod还会被驱逐出去。
```

* 基于taint的驱逐
先前提到的effect为NoExecute的taint，它对已经运行在node上的pod的影响如下：
   * 如果pod没有toleration这个taint的话，pod立即被驱逐。
   * 如果toleration了这个taint，并且没有指定tolerationSeconds的值，则一直不会驱逐
   * 如果toleration了这个taint，但是指定tolerationSeconds限定了容忍的时间，则到期后驱逐
此外，Kubernetes用taint代表node出了问题（1.13beta版）。换句话说，当Node某些条件为True时，节点控制器自动为Node节点添加污点，而在状态为Ready的Node上，之前设置过的普通的驱逐逻辑将会被禁用。内置以下污点：

   * node.kubernetes.io/not-ready：节点尚未就绪。这对应于NodeCondition Ready为“ False”。
   * node.kubernetes.io/unreachable：Node controlloer无法访问节点。这对应于NodeCondition Ready为“ Unknown”。
   * node.kubernetes.io/memory-pressure：节点有内存压力。
   * node.kubernetes.io/disk-pressure：节点有磁盘压力。
   * node.kubernetes.io/network-unavailable：节点的网络不可用。
   * node.kubernetes.io/unschedulable：节点是不可调度的。
   * node.cloudprovider.kubernetes.io/uninitialized：当使用“外部”云提供程序启动kubelet时，会在节点上设置此污点以将其标记为不可用。在cloud-controller-manager的控制器初始化此节点后，kubelet将删除此污点。



* 编辑kubelet-conf.yml文件修改默认阈值来调整驱逐条件
   * --eviction-hard：驱逐阈值(例如memory.available<1Gi)，如果满足这些阈值，就会触发pod驱逐。(默认imagefs.available < 15%, memory.available < 100 mi, nodefs.available < 10%, nodefs.inodesFree < 5%)
   * --eviction-soft：驱逐阈值(例如memory.available<1.5Gi)，如果在相应的宽限期内达到该阈值，就会触发pod驱逐。
   * --eviction-minimum-reclaim：最小回收(例如imagef .available=2Gi)，描述kubelet在执行pod回收(如果该资源处于压力之下)时回收的最小资源量。
   * --eviction-pressure-transition-period：kubelet必须等待一段时间才能从驱逐压力状态过渡出来。(默认5m0)

```
- pods
eventBurst: 10
eventRecordQPS: 5
evictionHard:                    # 驱逐阈值
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s  # 等待释放时间
```
