---
title: "Kafka与zookeeper的安装配置"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2020-11-26T18:47:39+08:00
draft: false
---

## 1、kafka架构图及下载
https://archive.apache.org/dist/kafka/0.11.0.0/kafka_2.11-0.11.0.0.tgz

![](https://i.bmp.ovh/imgs/2020/12/799f1bc647c4608b.png)

此外，java安装并配置好环境变量。

## 2、修改kafka配置文件
```
vim ./config/server.properties
broker.id=0 #每个broker的唯一标识，不可重复
delete.topic.enable=true #允许删除topic
log.dirs=/root/kafka/logs #出于安全考虑，修改默认log位置。kafka的消息队列数据和日志都存储在logs文件夹下面。
（logs文件夹在kafka根目录下创建）

#在zookeeper的数据机构中，每个子目录项如 NameService 都被称作为 znode(目录节点)，和文件系统一样，我们能够自由的增加、删除#znode，在一个znode下增加、删除子znode，唯一的不同在于znode是可以存储数据的
zookeeper.connect=s4:2181,s5:2181,s6:2181  #指定zookeeper集群
```

## 3、kafka和ZK集群配置文件同步

xync 分发同步 kafka和zk目录 （会经常用到同步工具xsync）

或使用mobaxterm的multi-exec功能同时修改多台机器的配置。

## 4、zookeeper的分布式安装配置
#### 4.1安装

kafka依赖于zookeeper，先下载安装好zookeeper。（三台机器都要安装配置，可以使用同步脚本xsync，或者mobaxterm的的multi-execution功能）
安装好后将zookeeper配置文件模板改为配置文件

```
mv zoo_sample.cfg zoo.cfg
vim zoo.cfg
dataDir=/tmp/zookeeper #修改默认路径，指定路径为/root/zookeeper/zkData

```
#### 4.2修改配置文件

在zkData目录下创建myid文件，myid文件内容（整型数字：1，2，3）对应三个集群节点的编号。
并在zoo.cfg文件末尾增加如下配置：

```
server.1=s4:2888:3888
server.2=s5:2888:3888
server.3=s6:2888:3888
```
数字123对应myid文件的内容，指定了节点的编号。
s4,s5,s6是主机名或IP；2888是follower与leader服务器通讯传递副本（replicator）的端口；3888是leader挂掉后集群重新选举时通信的端口。

#### 4.3启动验证

配置完毕启动zookeeper。查看状态，显示Mode为leader或follower即表示集群启动成功。

设置开机启动，使用admin用户启动zookeeper：

```
$ sudo su #切换到root用户
$ vim /etc/rc.d/rc.local
新增配置
su admin -c "/usr/local/zookeeper/startBase.sh"  #组件脚本全路径

```

startBase.sh脚本内容：

```
#!/bin/bash
# chkconfig:   2345 60 20
# description:  zookeeper start
APP_HOME=/usr/local/zookeeper/bin
cd $APP_HOME
echo $PWD
source /etc/profile
./zkServer.sh start ../conf/zoo.cfg
```

## 5、启动kafka服务并测试

```
  110  cd kafka/bin/
  106  sh bin/kafka-server-start.sh config/server.properties
  113  ./kafka-topics.sh --create --zookeeper s102:2181 --partitions 2 --replication-factor 2 --topic topic01
  117  ./kafka-topics.sh --list --zookeeper s102:2181
  118  ./kafka-topics.sh --list --zookeeper s103:2181
  119  ./kafka-topics.sh --list --zookeeper s104:2181
# 启动 kafka，指定配置文件
# 创建topic，指定zk服务器，分区数、副本数、topic名字
```



# 6、 生成，消费数据

