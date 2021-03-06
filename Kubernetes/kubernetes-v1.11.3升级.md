# Kubernetes平滑升级
* 可以参考：k8s高可用集群平滑升级 v1.11.x 到v1.12.x
    > https://www.cnblogs.com/dukuan/p/10071204.html


`注解：此方式只适合kubeadm安装,我的版本为v1.11.3,升级到v1.12.X中间还隔着一个v1.11.７，所以得先升级到v1.11.７再继续升级`

* 查看现在高可用集群的信息
```
[root@master1 ~]# kubectl get node
----
NAME      STATUS     ROLES     AGE       VERSION
master1   Ready      master    10d       v1.11.3
master2   Ready      master    10d       v1.11.3
master3   Ready      master    10d       v1.11.3
node1     NotReady   <none>    10d       v1.11.3
node2     Ready      <none>    10d       v1.11.3
node3     Ready      <none>    10d       v1.11.3
----
```
- master节点的升级
- 主节点master1升级kubeadm到v1.11.7版本
```
[root@master1 ~]# yum upgrade -y kubeadm-1.11.7  --disableexcludes=kubernetes
----
Running transaction
  Updating   : kubeadm-1.11.7-0.x86_64                                                                                                                    1/2
  Cleanup    : kubeadm-1.11.3-0.x86_64                                                                                                                    2/2
  Verifying  : kubeadm-1.11.7-0.x86_64                                                                                                                    1/2
  Verifying  : kubeadm-1.11.3-0.x86_64                                                                                                                    2/2

Updated:
  kubeadm.x86_64 0:1.11.7-0

Complete!
----
```

- 主节点master1上运行，查看自己可以升级到哪些版本，有哪些东西需要升级
```
[root@master1 ~]# kubeadm upgrade plan
[preflight] Running pre-flight checks.
[upgrade] Making sure the cluster is healthy:
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[endpoint] WARNING: port specified in api.controlPlaneEndpoint overrides api.bindPort in the controlplane address
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: v1.11.3
[upgrade/versions] kubeadm version: v1.11.3
[upgrade/versions] Latest stable version: v1.13.3
[upgrade/versions] Latest version in the v1.11 series: v1.11.7
[upgrade/versions] WARNING: No recommended etcd for requested kubernetes version (v1.13.3)

External components that should be upgraded manually before you upgrade the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT   AVAILABLE
Etcd        3.2.22    3.2.18

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       AVAILABLE
Kubelet     6 x v1.11.3   v1.11.7

Upgrade to the latest version in the v1.11 series:

COMPONENT            CURRENT   AVAILABLE
API Server           v1.11.3   v1.11.7
Controller Manager   v1.11.3   v1.11.7
Scheduler            v1.11.3   v1.11.7
Kube Proxy           v1.11.3   v1.11.7
CoreDNS              1.1.3     1.1.3

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.11.7

Note: Before you can perform this upgrade, you have to update kubeadm to v1.11.7.

_____________________________________________________________________

External components that should be upgraded manually before you upgrade the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT   AVAILABLE
Etcd        3.2.22    N/A

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       AVAILABLE
Kubelet     6 x v1.11.3   v1.13.3

Upgrade to the latest stable version:

COMPONENT            CURRENT   AVAILABLE
API Server           v1.11.3   v1.13.3
Controller Manager   v1.11.3   v1.13.3
Scheduler            v1.11.3   v1.13.3
Kube Proxy           v1.11.3   v1.13.3
CoreDNS              1.1.3     1.1.3

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.13.3

Note: Before you can perform this upgrade, you have to update kubeadm to v1.13.3.

_____________________________________________________________________



[root@master1 ~]# kubeadm upgrade apply v1.11.7
----
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.11.7". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
----

[root@master1 ~]# kubectl get node
NAME      STATUS     ROLES     AGE       VERSION
master1   Ready      master    11d       v1.11.3
master2   Ready      master    11d       v1.11.3
master3   Ready      master    11d       v1.11.3
node1     Ready      <none>    10d       v1.11.3
node2     Ready      <none>    10d       v1.11.3
node3     Ready      <none>    10d       v1.11.3

#标记master1为不可用，然后升级。master节点一定要加--ignore-daemonsets　不然没会报错
[root@master1 ~]# kubectl drain master1 --ignore-daemonsets
node/master1 cordoned
WARNING: Ignoring DaemonSet-managed pods: kube-flannel-ds-jpwvq, kube-proxy-pfh2j
You have new mail in /var/spool/mail/root



[root@master1 ~]# yum upgrade  kubelet-1.11.7 kubectl-1.11.7

systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet

#再把master1标记为可用
[root@master1 ~]# kubectl uncordon master1
node/master1 uncordoned

[root@master1 ~]# kubectl get nodes
NAME      STATUS                        ROLES     AGE       VERSION
master1   Ready                         master    11d       v1.11.7
master2   Ready                         master    11d       v1.11.3
master3   Ready                         master    11d       v1.11.3
node1     Ready                         <none>    11d       v1.11.3
node2     Ready                         <none>    11d       v1.11.3
node3     Ready                         <none>    11d       v1.11.3
```


- 升级master2,因为前面做了系统的升级，那现在直接标记为不可用，升级kubectl/kubelet就行,
```
[root@master1 ~]# yum upgrade -y kubeadm-1.11.7  --disableexcludes=kubernetes

#标记为不可用
[root@master2 ~]# kubectl drain master2 --ignore-daemonsets
node/master2 cordoned
WARNING: Ignoring DaemonSet-managed pods: kube-flannel-ds-ll9t5, kube-proxy-khzbv
pod/coredns-777d78ff6f-9c8cb evicted
pod/coredns-777d78ff6f-xsc9r evicted

[root@master2 ~]# yum upgrade  kubelet-1.11.7 kubectl-1.11.7

systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet

#标记为可用
kubectl uncordon master2

[root@master2 ~]# kubectl get node
NAME      STATUS     ROLES     AGE       VERSION
master1   Ready      master    11d       v1.11.7
master2   Ready      master    11d       v1.11.7
master3   Ready      master    11d       v1.11.3
node1     Ready      <none>    11d       v1.11.3
node2     Ready      <none>    11d       v1.11.3
node3     Ready      <none>    11d       v1.11.3
```
    > 其他master节点照master2执行命令就行。

```
yum upgrade -y kubeadm-1.12.0  --disableexcludes=kubernetes
kubectl drain master2 --ignore-daemonsets
yum upgrade  kubelet-1.12.0 kubectl-1.12.0
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
kubectl uncordon master1
kubectl get node
```








- node节点的升级
```
 yum upgrade -y kubeadm-1.11.7
 kubectl drain node1 --ignore-daemonsets
 yum upgrade  kubelet-1.11.7 kubectl-1.11.7

 systemctl daemon-reload
 systemctl restart kubelet
 systemctl status kubelet

 kubectl uncordon node1

[root@node1 ~]# kubectl get node
NAME      STATUS    ROLES     AGE       VERSION
master1   Ready     master    11d       v1.11.7
master2   Ready     master    11d       v1.11.7
master3   Ready     master    11d       v1.11.7
node1     Ready     <none>    11d       v1.11.7
node2     Ready     <none>    11d       v1.11.7
node3     Ready     <none>    11d       v1.11.3
```
