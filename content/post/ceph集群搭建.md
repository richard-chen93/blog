---
title: "Ceph集群搭建"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-04T17:05:40+08:00
draft: false
---

# 1、准备工作

* 5台机器，s3	s4 	s102,103,104。	s3是部署机器，s4是ceph客户端。	102-104是ceph节点

ntp时间同步、hosts文件域名可访问、ssh免密登录、yum源等先配置好。

## yum源文件内容：

```
cat > /etc/yum.repos/ceph.repo < EOF

[ceph]
name=ceph
baseurl=https://download.ceph.com/rpm-luminous/el7/noarch
enable=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc

EOF

yum makecache

```



## yum -y install ceph-deploy

## 安装一个python包

```
wget https://files.pythonhosted.org/packages/5f/ad/1fde06877a8d7d5c9b60eff7de2d452f639916ae1d48f0b8f97bf97e570a/distribute-0.7.3.zip

unzip distribute-0.7.3.zip

sudo python setup.py install
```



# 2、使用ceph-deploy安装

 s3上使用ceph用户执行：ceph-deploy new s102





3、vim ceph.repo

```
[Ceph-SRPMS]
name=Ceph SRPMS packages
baseurl=https://mirrors.aliyun.com/ceph/rpm-jewel/el7/SRPMS/
enabled=1
gpgcheck=0
type=rpm-md

[Ceph-noarch]
name=Ceph noarch packages
baseurl=https://mirrors.aliyun.com/ceph/rpm-jewel/el7/noarch/
enabled=1
gpgcheck=0
type=rpm-md

[Ceph-x86_64]
name=Ceph x86_64 packages
baseurl=https://mirrors.aliyun.com/ceph/rpm-jewel/el7/x86_64/
enabled=1
gpgcheck=0
type=rpm-md
```



3、

```
sudo yum makecache ;yum -y install epel-release;yum -y install ceph ceph-radosgw
```

