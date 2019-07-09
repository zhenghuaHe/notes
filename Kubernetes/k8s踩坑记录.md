1. 问题表现为容器不存在，而实际容器又在
```Jul  2 15:52:09 mwteck202 dockerd: time="2019-07-02T15:52:09.091845876+08:00" level=error msg="Handler for GET /v1.27/containers/931024e051fd5c451091f967d6d6775c49209aa826c46018115474ac5a2e931a/json returned error: open /data/docker/overlay/76dd094e4a3c0c954ac1e35d5cd24a7b0abb731cde43ff365ef4a7f5381f8668/lower-id: no such file or directory"
Jul  2 15:52:09 mwteck202 kubelet: E0702 15:52:09.092106    7048 kuberuntime_manager.go:857] PodSandboxStatus of sandbox "931024e051fd5c451091f967d6d6775c49209aa826c46018115474ac5a2e931a" for pod "api-statistics-python-64d9bd7845-9nx76_t3(9cf74331-8d8d-11e9-9009-848f69dc76b3)" error: rpc error: code = Unknown desc = Error: No such container: 931024e051fd5c451091f967d6d6775c49209aa826c46018115474ac5a2e931a
```
方法：删除pods,docker ps -a|grep dockername 删除掉他重新建立pods ,再不行就deployment然后再删除dockername
