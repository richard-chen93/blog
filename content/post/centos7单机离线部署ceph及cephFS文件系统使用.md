---
title: "Centos7单机离线部署ceph及cephFS文件系统使用"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2020-12-01T12:56:16+08:00
draft: false
---

# 一、实验背景

**1. 内网环境下，无法连接互联网，需要搭建ceph，为分布式集群提供ceph文件系统**

**2. 要实现脚本的自动化安装，shell脚本或者ansible playbook，不使用ceph-deploy工具**

我们需要在一台能联网的实验机机器上，将ceph集群安装所需的主包及其依赖一次性下载，编写安装脚本，然后在目标机器上搭建本地yum源，实现离线安装。

我们先实现搭建本地仓库，在目标机器上手动安装。

 

# 二、实验环境

```
操作系统：CentOS7.5 Minimal

联网的实验机： 192.168.1.101

cephServer(node01): 192.168.1.103 

**cephServer(node01)数据盘：/dev/sdb 100G**

cephClient： 192.168.1.106
```

 

```
操作系统：CentOS7.6 desktop

联网的实验机： 10.3.3.39

cephServer(node01): 10.3.3.39

**cephServer(node01)数据盘：/dev/sdb 100G**

cephClient： 10.3.3.39
```

```
关闭selinux

# setenforce 0

# sed  -i  's/^SELINUX=.*/SELINUX=permissive/g'  /etc/selinux/config

 

设置防火墙，放行相关端口

# systemctl  start  firewalld

# systemctl enable firewalld 

# firewall-cmd --zone=public --add-port=6789/tcp --permanent

# firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent

# firewall-cmd --reload
```



# 三、在联网的实验机下载ceph主包及其依赖

**添加ceph官方yum镜像仓库**

```
vi   /etc/yum.repos.d/ceph.repo
```

```
[Ceph]

name=Ceph packages for $basearch

baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/$basearch

enabled=1

gpgcheck=1

type=rpm-md

gpgkey=https://download.ceph.com/keys/release.asc

priority=1

[Ceph-noarch]

name=Ceph noarch packages

baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/noarch

enabled=1

gpgcheck=1

type=rpm-md

gpgkey=https://download.ceph.com/keys/release.asc

priority=1

[ceph-source]

name=Ceph source packages

baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/SRPMS

enabled=1

gpgcheck=1

type=rpm-md

gpgkey=https://download.ceph.com/keys/release.asc


```

将按照包下载到cephDeps 目录下，生成tar.gz包

```
yum clean all
yum repolist 
yum list all |grep ceph
yum  -y install epel-release 
yum -y install yum-utils 
yum -y install createrepo 
mkdir /root/cephDeps 
repotrack  ceph ceph-mgr ceph-mon ceph-mds ceph-osd ceph-fuse ceph-radosgw  -p  /root/cephDeps
createrepo  -v   /root/cephDeps
tar  -zcf    cephDeps.tar.gz   /root/cephDeps
```

# 四、在cephServer(node01)上搭建 本地yum源

将cephDeps.tar.gz拷贝到cephServer(node01)服务器

```
tar -zxf cephDeps.tar.gz 
```



```
vim build_localrepo.sh

##################################################



#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )

cd "$parent_path"

mkdir /etc/yum.repos.d/backup

mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup

#create local repositry

rm -rf /tmp/localrepo

mkdir -p /tmp/localrepo

cp -rf ./cephDeps/* /tmp/localrepo

echo "

[localrepo]

name=Local Repository

baseurl=file:///tmp/localrepo

gpgcheck=0

enabled=1" > /etc/yum.repos.d/ceph.repo

yum clean all

##################################################


sh -x build_localrepo.sh

yum repolist
```



用本地yum源安装ceph组件

```
yum -y install ceph ceph-mds ceph-mgr ceph-osd ceph-mon

yum list installed | grep ceph

ll /etc/ceph/

ll /var/lib/ceph/
```



配置ceph组件

```
这里未配置：
创建集群id**

 uidgen

 

用uidgen 生成一个uuid 例如 ee741368-4233-4cbc-8607-5d36ab314dab
```

```
grep -i uuid /etc/sysconfig/network-scripts/ifcfg-ens33
UUID=99cf6cf1-1646-4dbd-bb74-71db9c1dc139
```



**创建ceph主配置文件**

\# vim /etc/ceph/ceph.conf

\######################################

```
[global]

fsid = 99cf6cf1-1646-4dbd-bb74-71db9c1dc139

mon_initial_members = node01

mon_host = 10.3.3.39

mon_max_pg_per_osd = 300

 

auth_cluster_required = cephx

auth_service_required = cephx

auth_client_required = cephx

 

osd_pool_default_size = 1

osd_pool_default_min_size = 1

osd_journal_size = 1024

osd_crush_chooseleaf_type = 0

 

public_network = 10.3.3.0/24

cluster_network = 10.3.3.0/24

[mon]

mon allow pool delete = true
```

\###################################

