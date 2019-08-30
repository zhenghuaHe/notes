# kubernetes ingress参考范例

![ingress](../Map/ingress.png)
```
组件说明
externalLB : 外部的4层负载均衡器
<Service> ingress-nginx : nodePort 类型的 service 为 <IngressController> ingress-nginx 的 pod 接入外部流量
<IngressController> ingress-nginx : ingress-nginx pod, 负责创建负载均衡
<Ingress> : Ingress 根据后端 Service 实时识别分类及 IP 把结果生成配置文件注入到 ingress-nginx pod 中
<Service> site1 : Service 对后端的pod 进行分类(只起分类作用)
```
* 部署Ingress Nginx
    > 使用Ingress功能步骤：(注意先后顺序，如果先执行了mandatory.yaml文件在执行service-nodeport.yaml文件使用kubectl logs -f 看ingress-controller的pod的日志会有很多报错信息)

   * 下载Ingress-controller相关的YAML文件，并给Ingress-controller创建独立的名称空间命名为ingress-nginx；
   * 创建Ingress-controller的service，以实现接入集群外部流量；
   * 部署Ingress-controller；
   * 部署后端的服务，如tomcat，并通过service进行暴露；
   * 部署Ingress，进行定义规则，使Ingress-controller和后端服务的Pod组进行关联。


```
https://github.com/kubernetes/ingress-nginx/blob/nginx-0.17.0/deploy/mandatory.yaml
把上面页面的yaml文件弄回本地执行，确保nginx-ingress-controller起来了。
$ kubectl get pods -n ingress-nginx |grep nginx-ingress-controller
nginx-ingress-controller-5784c99d57-vpgp7   1/1     Running            0          15m


然后根据自己的具体业务写,暴露端口方便访问
$ cat nginx-ingress-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
spec:      
  type: NodePort
  ports:
    - port: 80
      name: http
      nodePort: 30080
    - port: 443
      name: https
      nodePort: 30443
  selector:
    app: ingress-nginx


# 通过url转发到指定的项目
$ cat tomcat-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: tomcat-ingress
  namespace: dev
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/configuration-snippet: |　　
      rewrite /api-admin/(.*)  /$1  break;                 # 重新连接，去掉多于的/api-admin
spec:
  rules:
  - host: dev.lift360.cn
    http:
      paths:
      - path: /api-admin
        backend:
          serviceName: api-admin
          servicePort: 8080

```
