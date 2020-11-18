# Prometheus K8S中部署Alertmanager

```
设置告警和通知的主要步骤如下：
一、部署Alertmanager
二、配置Prometheus与Alertmanager通信
三、配置告警
　　1. prometheus指定rules目录
　　2. configmap存储告警规则
　　3. configmap挂载到容器rules目录
  
```

alertmanager-deployment.yaml 主要是加载对应的yaml文件，指明发送告警的方式和策略
```
apiVersion: v1
kind: ConfigMap
metadata:
  # 配置文件名称
  name: alertmanager-config
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: EnsureExists
data:
  alertmanager.yml: |
    global: 
      resolve_timeout: 5m
      # 告警自定义邮件
      smtp_smarthost: 'smtp.163.com:25'
      smtp_from: 'baojingtongzhi@163.com'
      smtp_auth_username: 'baojingtongzhi@163.com'
      smtp_auth_password: 'liang123'

    receivers:
    - name: default-receiver
      email_configs:
      - to: "zhenliang369@163.com"

    route:
      group_interval: 1m
      group_wait: 10s
      receiver: default-receiver
      repeat_interval: 1m

```


配置Prometheus与Alertmanager通信

```
cat prometheus.yml
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  scrape_timeout:      10s
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.

  external_labels:
    datacenter: 'qingcloud'
    monitor: 'infrastructure'
    replica: A

# 和alert交互
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['10.43.44.16:9093']

# 定义触发规则
rule_files:
  - "/data/app/prometheus/rule/process.yml"

# 获取哪些metrics
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['127.0.0.1:9090']

  - job_name: 'consul'
    metrics_path: /v1/agent/metrics
    scheme: http
    params:
      format: ['prometheus']
    static_configs:
    - targets: ['10.43.44.16:8500','10.43.44.18:8500','10.43.44.19:8500']


```
