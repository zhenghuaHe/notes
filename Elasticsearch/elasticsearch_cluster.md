- 节点1
```
cluster.name: qing-idc
node.name: es-1
node.master: true
node.data: true

node.attr.zone: "shanghai"
node.max_local_storage_nodes: 1

path.data: /data/elasticsearch/data
path.logs: /var/log/elasticsearch

bootstrap.memory_lock: true

http.host: 0.0.0.0
http.port: 9200
http.max_content_length: 100mb
http.max_initial_line_length: 4kb
http.max_header_size: 8kb
http.compression: true

network.host: 0.0.0.0

transport.host: 0.0.0.0
transport.tcp.connect_timeout: 30s
transport.ping_schedule: 5s
transport.tcp.port: 9300
transport.publish_port: 9300
transport.tcp.compress: true

discovery.seed_hosts: ["10.43.43.138", "10.43.43.149", "10.43.43.159"]
cluster.initial_master_nodes: ["10.43.43.138", "10.43.43.149", "10.43.43.159"]

discovery.zen.join_timeout: 10s
discovery.zen.minimum_master_nodes: 2
discovery.zen.ping_timeout: 100s
discovery.zen.fd.ping_timeout: 100s

thread_pool.write.queue_size: 1000

action.destructive_requires_name: true

indices.recovery.max_bytes_per_sec: 60mb
indices.fielddata.cache.size: 30%
indices.breaker.fielddata.limit: 60%
indices.breaker.request.limit: 40%
indices.breaker.total.limit: 75%
indices.breaker.total.use_real_memory: true

cluster.routing.allocation.disk.threshold_enabled: true
cluster.routing.allocation.disk.watermark.low: 90%
cluster.routing.allocation.disk.watermark.high: 90%
cluster.routing.allocation.node_concurrent_recoveries: 3
cluster.routing.allocation.node_initial_primaries_recoveries: 10
cluster.routing.allocation.awareness.force.zone.values: ["shanghai"]
cluster.routing.allocation.awareness.attributes: zone

```

- 节点2
```
cluster.name: qing-idc
node.name: es-2
node.master: true
node.data: true

node.attr.zone: "shanghai"
node.max_local_storage_nodes: 1

path.data: /data/elasticsearch/data
path.logs: /var/log/elasticsearch

bootstrap.memory_lock: true

http.host: 0.0.0.0
http.port: 9200
http.max_content_length: 100mb
http.max_initial_line_length: 4kb
http.max_header_size: 8kb
http.compression: true

network.host: 0.0.0.0

transport.host: 0.0.0.0
transport.tcp.connect_timeout: 30s
transport.ping_schedule: 5s
transport.tcp.port: 9300
transport.publish_port: 9300
transport.tcp.compress: true

discovery.seed_hosts: ["10.43.43.138", "10.43.43.149", "10.43.43.159"]
cluster.initial_master_nodes: ["10.43.43.138", "10.43.43.149", "10.43.43.159"]

discovery.zen.join_timeout: 10s
discovery.zen.minimum_master_nodes: 2
discovery.zen.ping_timeout: 100s
discovery.zen.fd.ping_timeout: 100s

thread_pool.write.queue_size: 1000

action.destructive_requires_name: true

indices.recovery.max_bytes_per_sec: 60mb
indices.fielddata.cache.size: 30%
indices.breaker.fielddata.limit: 60%
indices.breaker.request.limit: 40%
indices.breaker.total.limit: 75%
indices.breaker.total.use_real_memory: true

cluster.routing.allocation.disk.threshold_enabled: true
cluster.routing.allocation.disk.watermark.low: 90%
cluster.routing.allocation.disk.watermark.high: 90%
cluster.routing.allocation.node_concurrent_recoveries: 3
cluster.routing.allocation.node_initial_primaries_recoveries: 10
cluster.routing.allocation.awareness.force.zone.values: ["shanghai"]
cluster.routing.allocation.awareness.attributes: zone

```


- 节点3
```
cluster.name: qing-idc
node.name: es-3
node.master: true
node.data: true

node.attr.zone: "shanghai"
node.max_local_storage_nodes: 1

path.data: /data/elasticsearch/data
path.logs: /var/log/elasticsearch

bootstrap.memory_lock: true

http.host: 0.0.0.0
http.port: 9200
http.max_content_length: 100mb
http.max_initial_line_length: 4kb
http.max_header_size: 8kb
http.compression: true

network.host: 0.0.0.0

transport.host: 0.0.0.0
transport.tcp.connect_timeout: 30s
transport.ping_schedule: 5s
transport.tcp.port: 9300
transport.publish_port: 9300
transport.tcp.compress: true

discovery.seed_hosts: ["10.43.43.138", "10.43.43.149", "10.43.43.159"]
cluster.initial_master_nodes: ["10.43.43.138", "10.43.43.149", "10.43.43.159"]

discovery.zen.join_timeout: 10s
discovery.zen.minimum_master_nodes: 2
discovery.zen.ping_timeout: 100s
discovery.zen.fd.ping_timeout: 100s

thread_pool.write.queue_size: 1000

action.destructive_requires_name: true

indices.recovery.max_bytes_per_sec: 60mb
indices.fielddata.cache.size: 30%
indices.breaker.fielddata.limit: 60%
indices.breaker.request.limit: 40%
indices.breaker.total.limit: 75%
indices.breaker.total.use_real_memory: true

cluster.routing.allocation.disk.threshold_enabled: true
cluster.routing.allocation.disk.watermark.low: 90%
cluster.routing.allocation.disk.watermark.high: 90%
cluster.routing.allocation.node_concurrent_recoveries: 3
cluster.routing.allocation.node_initial_primaries_recoveries: 10
cluster.routing.allocation.awareness.force.zone.values: ["shanghai"]
cluster.routing.allocation.awareness.attributes: zone

```

注：jvm.options配置文件里面可以把内存大小设置为总大小的一半，再稍微小一点，比如宿主机64G，jvm设为31G
```
################################################################
## IMPORTANT: JVM heap size
################################################################
##
## You should always set the min and max JVM heap
## size to the same value. For example, to set
## the heap to 4 GB, set:
##
## -Xms4g
## -Xmx4g
##
## See https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html
## for more information
##
################################################################

# Xms represents the initial size of total heap space
# Xmx represents the maximum size of total heap space

-Xms31g
-Xmx31g


```
