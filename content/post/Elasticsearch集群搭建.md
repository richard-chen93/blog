---
title: "Elasticsearch集群搭建"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-24T17:23:09+08:00
draft: false
---

# 1、环境

es版本：	7.8.1

centos7：  s4,s5,s6

配置：4c 3G



3台机器必须调整最大进程数，root执行：

```
echo "fs.file-max = 2000000" >> /etc/sysctl.conf
echo "vm.max_map_count = 655360" >> /etc/sysctl.conf
sysctl -p

echo "ulimit -u 10000" >> /etc/profile
```

# 2、配置

elasticsearch.yml配置文件。3台机器的node.name分别修改为：node-1,node-2,node-3。其余不变。

```
#集群名称
cluster.name: test-app

#节点名称，集群中保持唯一
node.name: node-1
node.master: true
#绑定远程地址，为了安全通常是指定具体的地址，这里仅仅是测试，放开允许所有远程来源访问
network.host: 0.0.0.0

#开放http接口，默认就是9200
http.port: 9200

#集群节点之间（集群协商、指令传输等）通信的端口
transport.tcp.port: 9300

#允许前端跨域访问
http.cors.enabled: true

#设置允许的跨域的来源，*表示允许所有跨域来源
http.cors.allow-origin: "*"

#设置发现集群节点主机列表
discovery.seed_hosts: ["s4:9300","s5:9300","s6:9300"]

#初始化集群的master节点的候选列表，列表中的节点都可能竞选成为master节点
cluster.initial_master_nodes: ["s4:9300","s5:9300","s6:9300"]
```

# 3、启动并验证

./bin/elasticsearch

查看集群信息：http://s4:9200/_cat/health?v