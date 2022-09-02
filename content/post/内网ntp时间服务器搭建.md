---
title: "内网ntp时间服务器搭建"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-03T20:57:51+08:00
draft: false
---

### 安装NPT（所有节点）

配置了ntp启动正常，设置开机自启，发现重启后启动不起来，且无任何报错？ 坑d！disable 和stop chronyd !

我们建议在所有 Ceph 节点上安装 NTP 服务，以免因时钟漂移导致故障。

```bash
sudo yum install ntp ntpdate
```

#### 1.node1节点配置

 node1节点作为ntp服务器

```bash
sudo vim /etc/ntp.conf    #删除所有默认的restrict 和 server配置，添加以下内容：
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

#### ntpd与ntpdate修改时间的区别

ntpd 不仅仅是时间同步服务器，他还可以做客户端与标准时间服务器进行同步时间，而且是平滑同步，并非ntpdate立即同步，在生产环境中**慎用ntpdate**，也正如此两者不可同时运行。

时钟的跃变，对于某些程序会导致**很严重**的问题。许多应用程序依赖连续的时钟——毕竟，这是一项常见的假定，即，取得的时间是线性的，一些操作，例如数据库事务，通常会地依赖这样的事实：时间不会往回跳跃。不幸的是，ntpdate调整时间的方式就是我们所说的”跃变“：在获得一个时间之后，ntpdate使用settimeofday设置系统时间，这有几个非常明显的问题：

第一，这样做**不安全**。ntpdate的设置依赖于ntp服务器的安全性，攻击者可以利用一些软件设计上的缺陷，拿下ntp服务器并令与其同步的服务器执行某些消耗性的任务。由于ntpdate采用的方式是跳变，跟随它的服务器无法知道是否发生了异常（时间不一样的时候，唯一的办法是以服务器为准）。

第二，这样做**不精确**。一旦ntp服务器宕机，跟随它的服务器也就会无法同步时间。与此不同，ntpd不仅能够校准计算机的时间，而且能够校准计算机的时钟。

第三，这样做**不够优雅**。由于是跳变，而不是使时间变快或变慢，依赖时序的程序会出错（例如，如果ntpdate发现你的时间快了，则可能会经历两个相同的时刻，对某些应用而言，这是致命的）。

因而，唯一一个可以令时间发生跳变的点，是计算机刚刚启动，但还没有启动很多服务的那个时候。其余的时候，理想的做法是使用ntpd来校准时钟，而不是调整计算机时钟上的时间。

NTPD 在和时间服务器的同步过程中，会把 BIOS 计时器的振荡频率偏差——或者说 Local Clock 的自然漂移(drift)——记录下来。这样即使网络有问题，本机仍然能维持一个相当精确的走时
