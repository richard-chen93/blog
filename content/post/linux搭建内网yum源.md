---
title: "Linux搭建内网yum源"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-25T17:21:15+08:00
draft: false
---

# 1、安装yum工具

```
yum -y install createrepo
```

# 2、指定yum仓库路径

```
mkdir /repo
```

# 3、创建本地repo仓库

```
createrepo -pdo /repo /repo
```



# 4、清空或者备份出 /etc/yum.repos.d 下所有的源。

```
mv /etc/yum.repos.d/*.repo /tmp
yum clean all
```

# 5、配置本地yum源

```
cat >> /etc/yum.repos.d/Centos-Base.repo << EOF
[centos7]
name=CentOS7-local
baseurl=file:///repo
gpgcheck=0
enabled=1
EOF
```

# 6、测试

```
yum makecache
yum -y install unzip
```

