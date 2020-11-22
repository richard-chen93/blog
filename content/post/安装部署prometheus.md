---
title: "安装部署prometheus"
date: 2020-11-20T13:24:36+08:00
tags: [ "technology" ]
categories: [ "technology" ]
draft: true
---

# 环境准备
* 3台机器centos7，1台prometheus服务器，主机名S0，1台grafana服务器S1，1台客户端S2
* prometheus版本为prometheus-2.5.0.linux-amd64
* 3台机器时间同步好
```
yum install ntpdate -y
ntpdate cn.ntp.org.cn
timedatectl set-timezone Asia/Shanghai
date
```

# 在S0上安装Prometheus并运行
```
tar xf prometheus-2.5.0.linux-amd64.tar.gz
mv prometheus-2.5.0.linux-amd64 /usr/local/prometheus
cd /usr/local/prometheus
./prometheus --config.file="/usr/local/prometheus/prometheus.yml" &
ss -tunpl | grep 9090
```
若9090端口被Prometheus程序占用，说明启动成功，浏览器打开http://10.3.3.30:9090
http://10.3.3.30:9090/metrics可看到所有监控到的数据

# 在被监控主机S2上安装node-exporter组件并运行
```
tar xf node_exporter-0.16.0.linux-amd64.tar.gz
mv node_exporter-0.16.0.linux-amd64 /usr/local/node_exporter
cd /usr/local/node_exporter/
nohup ./node_exporter &
ss -tunpl | grep 9090
```
使用nohup后即使终端关闭，node_exporter程序也会继续运行
浏览器打开http://10.3.3.30:9090
http://10.3.3.32:9100/metrics可看到所有收集到的数据

# 让Prometheus服务器拉取node节点信息
```
vim /usr/local/prometheus/prometheus.yml
  - job_name: 'node01'
    static_configs:
    - targets: ['10.3.3.32:9100']
```
在文件末尾添加节点信息

# 重启Prometheus服务并查看节点信息
```
pkill prometheus
./prometheus --config.file="/usr/local/prometheus/prometheus.yml" &
```







