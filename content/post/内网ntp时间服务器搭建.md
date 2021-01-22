---
title: "内网ntp时间服务器搭建"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-03T20:57:51+08:00
draft: false
---

###  安装NPT（所有节点）

配置了ntp启动正常，设置开机自启，发现重启后启动不起来，且无任何报错？ 坑爹！disable 和stop chronyd !

我们建议在所有 Ceph 节点上安装 NTP 服务，以免因时钟漂移导致故障。

```bash
sudo yum install ntp ntpdate
```

#### 1.node1节点配置

 node1节点作为ntp服务器

```bash
sudo vim /etc/ntp.conf	#删除所有默认的restrict 和 server配置，添加以下内容：
```

```js
restrict 10.3.3.4 mask 255.255.255.0 nomodify notrap  #配置集群的IP段

server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10
```

```bash
sudo systemctl enable ntpd
sudo systemctl restart ntpd
systemctl status ntpd
```

#### 2.其他节点配置

```bash
sudo vim /etc/ntp.conf
```

```js
restrict 10.3.3.4 mask 255.255.255.0 nomodify notrap #IP为node1的ip地址
server  10.3.3.4     # #IP为node1的ip地址
```

```bash
sudo systemctl enable ntpd
sudo systemctl restart ntpd
systemctl status ntpd
```

#### 3.查看时间同步状态

```bash
$ ntpstat  #这里显示的是与local本地同步的，代表还没有和外网服务器进行时间同步
#synchronised to local net (127.127.1.0) at stratum 11
#   time correct to within 11 ms
#   polling server every 64 s
#输出上述内容代表同步成功
```

