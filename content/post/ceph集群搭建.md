---
title: "Ceph集群搭建"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-04T17:05:40+08:00
draft: false
---

# 1、准备工作

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

 ceph-deploy new s102