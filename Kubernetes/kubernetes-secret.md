# Kubernetes-Secret

- Secret有四种TYPE（类型）
   - Opaque ：base64编码格式的Secret，用来存储密码、密钥、信息、证书等，类型标识符为generic；
   - kubernetes.io/dockerconfigjson ：用来存储私有docker registry的认证信息，类型标识为docker-registry。
   - kubernetes.io/tls：用于为SSL通信模式存储证书和私钥文件，命令式创建类型标识为tls。
   - kubernetes.io/service-account-token：用来访问Kubernetes API，由Kubernetes自动创建，并且会自动挂载到Pod的/var/run/secrets/kubernetes.io/serviceaccount目录中；



### Secret 与 ConfigMap 对比

- 相同点：
   - key/value 的形式
   - 属于某个特定的namespace
   - 可以导出到环境变量
   - 可以通过目录/文件形式挂载
   - 通过volume挂载的配置信息均可热更新

- 不同点：
   - Secret可以被ServerAccount关联
   - Secret可以存储docker register的鉴权信息，用在ImagePullSecret 参数中，用于拉取私有仓库的镜像
   - Secret支持Base64加密
   - Secret分为 kubernetes.io/service-account-token、kubernetes.io/dockerconfigjson、Opaque 、kubernetes.io/tls 四种类型，而Configmap不区分类型
