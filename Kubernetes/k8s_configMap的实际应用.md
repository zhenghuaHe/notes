# k8s_configMap的实际应用

## 创建configMap的方式
```
# 直接把整个配置文件的目录加载成configMap,-n 命名空间　dev-api-admin　configMap的名字　--from-file　后面是路径
$ kubectl create configmap -n dev dev-api-admin --from-file=./config/api-admin/
# 直接把具体某个文件加载成configMap
$ kubectl create configmap -n dev dev-api-admin --from-file=./config/api-admin/server.xml
```


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
