# k8s_configMap的实际应用

## 创建configMap的方式
```
# 直接把整个配置文件的目录加载成configMap,-n 命名空间　dev-api-admin　configMap的名字　--from-file　后面是路径
$ kubectl create configmap -n dev dev-api-admin --from-file=./config/api-admin/
# 直接把具体某个文件加载成configMap
$ kubectl create configmap -n dev dev-api-admin --from-file=./config/api-admin/server.xml
```
- 容器应用对 ConfigMap 的使用有以下两种方法。
   - 1、通过环境变量获取 ConfigMap 中的内容。(不支持动态更新)
   - 2、通过 Volume 挂载的方式将 ConfigMap 中的内容关在为容器内部的文件或目录。(支持动态更新)

## tomcat项目读取configMap配置
```
$ vim api-admin.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: api-admin
  namespace: dev
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: api-admin
        track: stable
    spec:
      containers:
      - name: api-admin
        image: mwteck/api/admin:dev
        volumeMounts:
        - name: dev-api-admin-volume
          mountPath: /etc/tomcat/server.xml
          subPath: server.xml
          readOnly: true
        - name: dev-api-admin-volume
          mountPath: /data/web/api-admin/ROOT/WEB-INF/classes/config.properties
          subPath: config.properties
          readOnly: true
        ports:
          - containerPort: 8080
      volumes:
      - name: dev-api-admin-volume
        configMap:
          name: dev-api-admin

```
* 这里是直接把所有配置文件通过目录的形式加载到名字为dev-api-admin的configMap里，读取配置文件时，直接通过subPath读取整个挂在的目录下的具体的配置文件。


- 使用 ConfigMap 的限制条件
    - ConfigMap必须在Pod之前创建。
    - ConfigMap受Namespace限制，只有处于同Namespace的Pod可以引用它。
    - ConfigMap中的配额管理还未能实现。
    - kubelet只支持可以被API Server管理的Pod使用ConfigMap。kubelet 在本Node上通过–manifest-url或–config自动创建的静态Pod将无法引用ConfigMap。
    - 在 Pod对ConfigMap进行挂载（VolumeMount）操作时，容器内部只能挂载为 ”目录“，无法挂在为文件。在挂载到容器内部后，目录中将包含 ConfigMap定义的每个item，如果该目录下原来还有其他文件，则容器内的该目录将会被挂载的 ConfigMap 覆盖。如果应用程序需要保留原来的其他文件，则需要进行额外的处理。可以将 ConfigMap 挂载到容器内部的临时目录，在通过启动脚本将配置文件复制或者链接到（cp 或者 link、ln 命令）应用所用的实际配置目录下。
