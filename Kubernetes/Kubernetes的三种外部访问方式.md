Kubernetes的三种外部访问方式：NodePort、LoadBalancer和Ingress

# 默认方式：ClusterIP
    > ClusterIP 服务是Kubernetes的默认服务。它给你一个集群内的服务，集群内的其它应用都可以访问该服务。集群外部无法访问它。

```
ClusterIP服务的YAML文件类似如下：

apiVersion: v1
kind: Service
metadata:   
  name: my-internal-service
selector:     
  app: my-app
spec:
  type: ClusterIP
  ports:   
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
```

### 何时使用这种方式？
```
有一些场景下，你得使用 Kubernetes 的 proxy 模式来访问你的服务：

由于某些原因，你需要调试你的服务，或者需要直接通过笔记本电脑去访问它们。
容许内部通信，展示内部仪表盘等。
这种方式要求我们运行 kubectl 作为一个未认证的用户，因此我们不能用这种方式把服务暴露到 internet 或者在生产环境使用。
```

# 1、NodePort
    > NodePort 服务是引导外部流量到你的服务的最原始方式。NodePort，正如这个名字所示，在所有节点（虚拟机）上开放一个特定端口，任何发送到该端口的流量都被转发到对应服务。

## ![nodePort](../Map/nodeport.png)
```
NodePort 服务的 YAML 文件类似如下：

apiVersion: v1
kind: Service
metadata:   
  name: my-nodeport-service
selector:     
  app: my-app
spec:
  type: NodePort
  ports:   
  - name: http
    port: 80
    targetPort: 80
    nodePort: 30036
    protocol: TCP

```

```
NodePort 服务主要有两点区别于普通的“ClusterIP”服务。
第一，它的类型是“NodePort”。有一个额外的端口，称为 nodePort，它指定节点上开放的端口值 。如果你不指定这个端口，系统将选择一个随机端口。大多数时候我们应该让Kubernetes来选择端口，用户自己来选择可用端口代价太大。
第二，直接外部访问

何时使用这种方式？

这种方法有许多缺点：
每个端口只能是一种服务
端口范围只能是 30000-32767
如果节点/VM 的 IP 地址发生变化，你需要能处理这种情况

基于以上原因，不建议在生产环境上用这种方式暴露服务。如果你运行的服务不要求一直可用，或者对成本比较敏感，你可以使用这种方法。这样的应用的最佳例子是 demo 应用，或者某些临时应用。
```

# LoadBalancer
    > LoadBalancer 服务是暴露服务到 internet 的标准方式。在 GKE 上，这种方式会启动一个 Network Load Balancer[2]，它将给你一个单独的 IP 地址，转发所有流量到你的服务。

## ![LoadBalancer](../Map/LoadBalancer.jpg)
```
何时使用这种方式？

如果你想要直接暴露服务，这就是默认方式。所有通往你指定的端口的流量都会被转发到对应的服务。它没有过滤条件，没有路由等。这意味着你几乎可以发送任何种类的流量到该服务，像 HTTP，TCP，UDP，Websocket，gRPC 或其它任意种类。

这个方式的最大缺点是每一个用 LoadBalancer 暴露的服务都会有它自己的 IP 地址，每个用到的 LoadBalancer 都需要付费，这将是非常昂贵的
```

# Ingress
    > 有别于以上所有例子，Ingress 事实上不是一种服务类型。相反，它处于多个服务的前端，扮演着“智能路由”或者集群入口的角色。
    > 你可以用 Ingress 来做许多不同的事情，各种不同类型的 Ingress 控制器也有不同的能力。
    > GKE 上的默认 ingress 控制器是启动一个 HTTP(S) Load Balancer[3]。它允许你基于路径或者子域名来路由流量到后端服务。例如，你可以将任何发往域名,foo.yourdomain.com 的流量转到 foo 服务，将路径 yourdomain.com/bar/path 的流量转到 bar 服务。

## ![ingress](../Map/ingress.jpg)
```
    GKE 上用 L7 HTTP Load Balancer[4]生成的 Ingress 对象的 YAML 文件类似如下：

    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: my-ingress
    spec:
      backend:
        serviceName: other
        servicePort: 8080
      rules:
      - host: foo.mydomain.com
        http:
          paths:
          - backend:
              serviceName: foo
              servicePort: 8080
      - host: mydomain.com
        http:
          paths:
          - path: /bar/*
            backend:
              serviceName: bar
              servicePort: 8080
```

```
何时使用这种方式？

Ingress 可能是暴露服务的最强大方式，但同时也是最复杂的。Ingress 控制器有各种类型，包括 Google Cloud Load Balancer， Nginx，Contour，Istio，等等。它还有各种插件，比如 cert-manager[5]，它可以为你的服务自动提供 SSL 证书。

如果你想要使用同一个 IP 暴露多个服务，这些服务都是使用相同的七层协议（典型如 HTTP），那么Ingress 就是最有用的。如果你使用本地的 GCP 集成，你只需要为一个负载均衡器付费，且由于 Ingress是“智能”的，你还可以获取各种开箱即用的特性（比如 SSL、认证、路由等等）。
```
