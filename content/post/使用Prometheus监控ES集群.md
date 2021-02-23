---
title: "使用Prometheus监控ES集群"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-02-06T21:51:41+08:00
draft: false
---

# 1、准备环境

监控系统下载运行prometheus和alertmanager，被监控的ES集群下载运行node_exporter和elasticsearch_exporter



# 2、修改配置

## 1、prometheus配置：



```
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - s4:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
   - "alerts/*.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']

  - job_name: 'S5'
    static_configs:
    - targets: ['10.3.3.5:9100']

  - job_name: 'S6_mariadb'
    static_configs:
    - targets: ['10.3.3.6:9104']

  - job_name: 'S5_elasticsearch'
    scrape_interval: 60s
    scrape_timeout:  30s
    metrics_path: "/metrics"
    static_configs:
    - targets:
      - '10.3.3.5:9108'
      labels:
        service: elasticsearch
    relabel_configs:
      - source_labels: [__address__]
        regex: '(.*)\:9109'
        target_label:  'instance'
        replacement:   '$1'
      - source_labels: [__address__]
        regex:         '.*\.(.*)\.lan.*'
        target_label:  'environment'
        replacement:   '$1'
```



## 2、alertmanager配置

alertmanager.yml

```
global:
  # 当Alertmanager持续多长时间未接收到告警后标记告警状态为resolved（已解决），默认为5m
  resolve_timeout: 5m
  # 全局的SMTP服务器配置
  smtp_smarthost: 'smtp.126.com:25'
  smtp_from: 'maple34@126.com'
  smtp_auth_username: 'maple34@126.com'
  smtp_auth_password: '{{password}}'


route:
  group_by: ['alertname']
  # 有的时候为了能够一次性收集和发送更多的相关信息时，可以通过group_wait参数设置等待时间，
  # 如果在等待时间内当前group接收到了新的告警，这些告警将会合并为一个通知向receiver发送，默认为30s
  group_wait: 10s
  # 定义相同的Group之间发送告警通知的时间间隔，默认为5m
  group_interval: 20s
  # 如果已经成功发送了一个警告，在再次发送通知之前需要等待多长时间，默认为4h
  repeat_interval: 1m
  receiver: 'mail-error'
  routes:
  - match:
      level: '严重'
    receiver: 'mail-error'
  - match:
      level: '紧急'
    receiver: 'mail-warning'
    repeat_interval: 10m


receivers:
- name: 'mail-error'
  email_configs:
  - to: 345999369@qq.com

- name: 'mail-warning'
  email_configs:
  - to: maple34@126.com
```

## 3、alertmanager告警规则配置

在prometheus监控主机的prometheus根目录下，建立rules文件夹，放置告警规则配置文件。

```
[admin@s4 prometheus-2.5.0]$ ls rules/
es_alert.yml os_alert.yml
```

### OS存活状态和内存使用率：

OS宕机或系统内存使用率大于70%触发告警

os_alert.yml

```
groups:
- name: OS_alert
  rules:
  - alert: InstanceDown
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Instance {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minutes."

  - alert: NodeMemoryUsage
    expr: (node_memory_MemTotal_bytes - (node_memory_MemFree_bytes+node_memory_Buffers_bytes+node_memory_Cached_bytes )) / node_memory_MemTotal_bytes * 100 > 70
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "{{$labels.instance}}: High Memory usage detected"
      description: "{{$labels.instance}}: Memory usage is above 70% (current value is:{{ $value }})"

```

### ES集群多个指标不正常触发告警：

es_alert.yml

```
groups:
- name: ES_Alert
  rules:
  ##########  集群健康状态：红色  ###############
  - alert: Elastic_Cluster_Health_RED
    expr: elasticsearch_cluster_health_status{color="red"}==1 
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Instance {{ $labels.instance }}: not all primary and replica shards are allocated in elasticsearch cluster {{ $labels.cluster }}"
      description: "Instance {{ $labels.instance }}: not all primary and replica shards are allocated in elasticsearch cluster {{ $labels.cluster }}."
 
 ##########  集群健康状态：黄色  ###############
  - alert: Elastic_Cluster_Health_Yellow 
    expr: elasticsearch_cluster_health_status{color="yellow"}==1
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: " Instance {{ $labels.instance }}: not all primary and replica shards are allocated in elasticsearch cluster {{ $labels.cluster }}" 
      description: "Instance {{ $labels.instance }}: not all primary and replica shards are allocated in elasticsearch cluster {{ $labels.cluster }}."
 
   ##########  ES JVM堆内存使用率超过百分之80  ###############
  - alert: Elasticsearch_JVM_Heap_Too_High
    expr: elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.8
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "ElasticSearch node {{ $labels.instance }} heap usage is high "
      description: "The heap in {{ $labels.instance }} is over 80% for 15m."
          
  - alert: Elasticsearch_health_up
    expr: elasticsearch_cluster_health_up !=1
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: " ElasticSearch node: {{ $labels.instance }} last scrape of the ElasticSearch cluster health failed"                               
      description: "ElasticSearch node: {{ $labels.instance }} last scrape of the ElasticSearch cluster health failed"
          
          
  - alert: Elasticsearch_Count_of_JVM_GC_Runs
    expr: rate(elasticsearch_jvm_gc_collection_seconds_count{}[5m])>5
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "ElasticSearch node {{ $labels.instance }}: Count of JVM GC runs > 5 per sec and has a value of {{ $value }} "
      description: "ElasticSearch node {{ $labels.instance }}: Count of JVM GC runs > 5 per sec and has a value of {{ $value }}"
          
  - alert: Elasticsearch_GC_Run_Time
    expr: rate(elasticsearch_jvm_gc_collection_seconds_sum[5m])>0.3
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: " ElasticSearch node {{ $labels.instance }}: GC run time in seconds > 0.3 sec and has a value of {{ $value }}"
      description: "ElasticSearch node {{ $labels.instance }}: GC run time in seconds > 0.3 sec and has a value of {{ $value }}"
    
  - alert: Elasticsearch_health_timed_out
    expr: elasticsearch_cluster_health_timed_out>0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: " ElasticSearch node {{ $labels.instance }}: Number of cluster health checks timed out > 0 and has a value of {{ $value }}"
      description: "ElasticSearch node {{ $labels.instance }}: Number of cluster health checks timed out > 0 and has a value of {{ $value }}"

```

