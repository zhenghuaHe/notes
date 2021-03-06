# 参考范例

```
$ cat api-device.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: api-device
  namespace: t3
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: api-device
        track: stable
    spec:
      containers:
      - name: api-device
        image: mwteck/api/device:dev
        volumeMounts:
        - name: time
          mountPath: /etc/localtime
        - name: log
          mountPath: /var/log/tomcat
        - name: config
          mountPath: /etc/tomcat/server.xml
        - name: conf
          mountPath: /data/web/api-device/ROOT/WEB-INF/classes/config.properties
        ports:
          - containerPort: 8080
        livenessProbe:                      #心跳检测
          httpGet:　　　　　　　　　　　　　　　　　　
            path: /swagger-ui.html　　　　　　＃模拟访问，返回２００
            port: 8080
          initialDelaySeconds: 80　　　　　　　＃开机后８０Ｓ开始检测
          periodSeconds: 5
          timeoutSeconds: 1
          successThreshold: 1
          failureThreshold: 2
      nodeSelector:
        node: "node04"
      volumes:
      - name: time
        hostPath:
          path: /etc/localtime
      - name: log
        hostPath:
          path: /home/log/api-device
      - name: config
        hostPath:
          path: /home/config/api-device/server.xml
      - name: conf
        hostPath:
          path: /home/config/api-device/config.properties


# nodePort类型
$ cat api-device-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api-device
  namespace: t3
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30214
  selector:
    app: api-device
#　ClusterIP类型
$ cat api-device-service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: api-device
      namespace: dev
    spec:
      type: ClusterIP
      ports:
      - port: 8080
        targetPort: 8080
      selector:
        app: api-device
```
