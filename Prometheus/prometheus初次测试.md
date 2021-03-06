## 1、直接创建docker容器
$ docker run -h Prometheus -d -p 9090:9090　-p 9100:9100　-it　--name Prometheus registry.cn-shanghai.aliyuncs.com/mwteck/base:centos6  /bin/bash

## ２、二进制安装：
```
$ yum install go
$ go version
go version go1.9.4 linux/amd64

$ wget https://github.com/prometheus/prometheus/releases/download/v2.3.0/prometheus-2.3.0.linux-amd64.tar.gz
$ tar zxvf prometheus-2.3.0.linux-amd64.tar.gz -C /usr/local/
$ mv prometheus-2.3.0.linux-amd64 prometheus
$ cd /usr/local/prometheus

$ vim prometheus.yml
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['0.0.0.0:9090']

  - job_name: os_linux
    static_configs:
      - targets: ['172.16.1.221:9100']
        labels:
          instance: os_centos


$ nohup ./prometheus --config.file=prometheus.yml &

```
* 验证方法：ip+9090



## 安装node_exporter:
* prometheus的一个小插件，主要收集机器数据：
```
$ wget https://github.com/prometheus/node_exporter/releases/download/v0.14.0/node_exporter-0.14.0.linux-amd64.tar.gz
$ tar xvf node_exporter-0.14.0.linux-amd64.tar.gz -C /usr/local/
$ nohup /usr/local/node_exporter-0.14.0.linux-amd64/node_exporter &
$ curl 127.0.0.1:9100/metrics   # 验证是否成功
```

## 安装grafana:
```
$ wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.0.1-1.x86_64.rpm
$ sudo yum localinstall grafana-5.0.1-1.x86_64.rpm
# 编辑配置文件/etc/grafana/grafana.ini，修改dashboards.json段落下两个参数的值：
[dashboards.json]
enabled = true
path = /var/lib/grafana/dashboards

# 安装仪表盘（Percona提供）:
$ git clone https://github.com/percona/grafana-dashboards.git
$ cp -r grafana-dashboards/dashboards /var/lib/grafana

# 运行以下命令为Grafana打个补丁，不然图表不能正常显示：
$ sed -i 's/expr=\(.\)\.replace(\(.\)\.expr,\(.\)\.scopedVars\(.*\)var \(.\)=\(.\)\.interval/expr=\1.replace(\2.expr,\3.scopedVars\4var \5=\1.replace(\6.interval, \3.scopedVars)/' /usr/share/grafana/public/app/plugins/datasource/prometheus/datasource.js
$ sed -i 's/,range_input/.replace(\/"{\/g,"\\"").replace(\/}"\/g,"\\""),range_input/; s/step_input:""/step_input:this.target.step/' /usr/share/grafana/public/app/plugins/datasource/prometheus/query_ctrl.js

#ps:这儿这个文件的格式可能不是js而是ts结尾的。

$ systemctl daemon-reload
$ systemctl start grafana-server
$ systemctl status grafana-server
```

* 浏览器访问：127.0.0.1:3000/login
* 默认登陆帐号/密码为admin/admin


报警：
```
$ vim /etc/grafana/grafana.ini

[smtp]
;enabled = false
;host = localhost:25
;user =
# If the password contains # or ; you have to wrap it with trippel quotes. Ex """#password;"""
;password =
;cert_file =
;key_file =
;skip_verify = false
;from_address = admin@grafana.localhost
;from_name = Grafana
# EHLO identity in SMTP dialog (defaults to instance_name)
;ehlo_identity = dashboard.example.com
enabled = true
host = smtp.exmail.qq.com:25
user = mwteck@mwteck.com
password = 12345678
skip_verift = true
from_address = mwteck@mwteck.com
from_name = Grafana

$ systemctl restart grafana-server
```
* grafana的操作页面：
* Alerting -->Notification channels --> 添加个收件箱就行



prometheus常用语法：
```
# 统计pro命名空间的pod数量
sum(kube_pod_container_status_running{namespace="pro"})

# 统计pro命名空间pod重启的次数(如果感兴趣还可以加上时间限制)
sum(kube_pod_container_status_restarts_total{namespace="pro"})

# 入口处nginx访问状态码为5xx的数量
sum(nginx_server_requests{code="5xx"})

#　入口处nginx访问状态码为4xx的数量
sum(nginx_server_requests{code="4xx",host="*"})

```
