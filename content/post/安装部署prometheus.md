---
title: "安装部署prometheus"
date: 2020-11-20T13:24:36+08:00
draft: true
---

# 环境准备
* 3台机器centos7，1台prometheus服务器，1台client，1台grafana服务器.
* prometheus版本为prometheus-2.5.0.linux-amd64
* 3台机器时间同步好
```
yum install ntpdate -y
ntpdate cn.ntp.org.cn
timedatectl set-timezone Asia/Shanghai
date
```