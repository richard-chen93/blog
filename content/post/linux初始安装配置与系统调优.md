---
title: "Linux初始安装配置与系统调优"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-24T16:43:05+08:00
draft: false
---

# 前言

centos7系统，最小化安装系统后：关闭防火墙和selinux、安装常用工具、设置yum源、创建普通用户admin、cephuser，设置ntp、系统和进程级别的文件句柄

# 1、一键搞定脚本

```
#!/bin/bash

##########optimize system
cat >> /etc/security/limits.conf << EOF
* soft noproc  65535
* hard noproc  65535
* soft nofile  1000000
* hard nofile  1000000
EOF
echo "fs.file-max = 2000000" >> /etc/sysctl.conf
sysctl -p
echo "ulimit -u 60000" >> /etc/profile
source /etc/profile
cd

#############disable and stop selinux & firewalld

sed  -i 's/#UseDNS yes/UseDNS no/g'  /etc/ssh/sshd_config
sed  -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g'  /etc/ssh/sshd_config
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/ssh/sshd_config
setenforce 0
systemctl diable firewalld
systemctl stop firewalld



###########set aliyun mirror

yum -y install wget
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

yum makecache



############install common soft

yum -y install epel-release git ntp ntpdate curl vim net-tools python36 python-pip lrzsz
yum -y groupinstall "Fonts"

############### add chinese language
echo 'export LC_ALL="zh_CN.UTF-8"' >> /etc/profile
source /etc/profile



############### add common users
echo "admin ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/admin

sudo useradd cephuser ; echo cephuser | sudo passwd --stdin cephuser
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
sudo chmod 0440 /etc/sudoers.d/cephuser


################# make ceph yum repo
cat > /etc/yum.repos.d/ceph.repo <<EOF
[ceph-luminous-noarch]
name = ceph-luminous-noarch
baseurl = https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-luminous/el7/noarch/
enabled = 1
gpgcheck = 0
gkgkey = http://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc
[ceph-luminous-x64]
name = ceph-luminous-x64
baseurl = https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-luminous/el7/x86_64/
enabled = 1
gpgcheck = 0
gkgkey = http://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc
EOF
sudo yum makecache


################# install ceph needed pakages
wget https://files.pythonhosted.org/packages/5f/ad/1fde06877a8d7d5c9b60eff7de2d452f639916ae1d48f0b8f97bf97e570a/distribute-0.7.3.zip
sudo yum -y install unzip
unzip distribute-0.7.3.zip
cd distribute-0.7.3
sudo python setup.py install
sudo yum -y install deltarpm

```



### 



# 2、非脚本

## 设置最大进程数和句柄

添加用户级别句柄和进程 root执行

* ```
  cat >> /etc/security/limits.conf << EOF
  * soft noproc  65535
  * hard noproc  65535
  * soft nofile  1000000
  * hard nofile  1000000
  EOF
  sysctl -w  fs.file-max =65536
  echo "ulimit -u 10000" >> /etc/profile
  source /etc/profile
  cd
  ```

  

说明：\* 代表针对所有用户

noproc 是代表最大进程数

nofile 是代表最大文件打开数

系统级别句柄



设置各linux 用户的最大进程数，下面把某linux用户的最大进程数设为10000个：



### 

## 常用的初始配置，加快dns，关闭selinux和防火墙

```
sed  -i 's/#UseDNS yes/UseDNS no/g'  /etc/ssh/sshd_config
sed  -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g'  /etc/ssh/sshd_config
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/ssh/sshd_config
setenforce 0
systemctl diable firewalld
systemctl stop firewalld
```





centos7:

```
yum -y install wget
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo

yum makecache
```



## 安装常用组件

```
yum -y update 
yum -y install epel-release git ntp ntpdate curl vim net-tools python36 python-pip
```



## pip:

```
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

pip install django-bootstrap3==6.2.2 -i http://mirrors.aliyun.com/pypi/simple --trusted-host=mirrors.aliyun.com
```


## Mac:

修改 pip.conf 文件

```
vim $HOME/Library/Application Support/pip/pip.conf
```

如果没有上面的目录,在如下目录创建 pip.conf

$HOME/.config/pip/pip.conf

修改内容如下：

```
[global]

index-url = https://pypi.tuna.tsinghua.edu.cn/simple12
```

## Windows:

修改 pip.conf 文件 (没有就创建一个)

%APPDATA%\pip\pip.ini

修改内容如下：

```
[global]

index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```




## docker：

Ubuntu 16.04+、Debian 8+、CentOS 7+
创建或修改 /etc/docker/daemon.json：

```
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://1nj0zren.mirror.aliyuncs.com",
        "https://docker.mirrors.ustc.edu.cn",
        "http://f1361db2.m.daocloud.io",
        "https://registry.docker-cn.com"
    ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Docker 中国官方镜像

https://registry.docker-cn.com


Docker Hub

DaoCloud 镜像站

http://f1361db2.m.daocloud.io

可登录，系统分配

Docker Hub

Azure 中国镜像

https://dockerhub.azk8s.cn


Docker Hub、GCR、Quay

科大镜像站

https://docker.mirrors.ustc.edu.cn


Docker Hub、GCR、Quay

阿里云

https://<your_code>.mirror.aliyuncs.com

需登录，系统分配

Docker Hub

七牛云

https://reg-mirror.qiniu.com


Docker Hub、GCR、Quay

网易云

https://hub-mirror.c.163.com


Docker Hub

腾讯云

https://mirror.ccs.tencentyun.com


Docker Hub

检查加速器是否生效
命令行执行 docker info，如果从结果中看到了如下内容，说明配置成功。

```
Registry Mirrors:
 [...]
 https://registry.docker-cn.com/
```

# 3、系统调优

limits.conf 和sysctl.conf区别在于limits.conf是针对用户，而sysctl.conf是针对整个系统参数配置。

limits.conf文件实际是Linux PAM（插入式认证模块，Pluggable Authentication Modules中pam_limits.so的配置文件），突破系统的默认限制，对系统访问资源有一定保护作用，当用户访问服务器时，服务程序将请求发送到PAM模块，PAM模块根据服务名称在/etc/pam.d目录下选择一个对应的服务文件，然后根据服务文件的内容选择具体的PAM模块进行处理。 

## limits.conf

说明：\* 代表针对所有用户

noproc 是代表最大进程数

nofile 是代表最大文件打开数

```
*  soft noproc  65535
*  hard noproc  65535
*  soft nofile  1000000
*  hard nofile  1000000
```



## /etc/sysctl.conf

**查看系统级别最大文件句柄数**

```
cat /proc/sys/fs/file-max
```

------

**修改最大文件句柄数：永久生效**

**1、修改配置文件加入内核参数/etc/sysctl.conf**

```
echo "fs.file-max = 2000000" >> /etc/sysctl.conf
```

50W并发可设置 = 999999

注：修改范围为系统所有进程可打开的最大文件句柄

**2、使修改配置立即生效：**

```
sysctl -p
```

## 用户最大进程数

设置各linux 用户的最大进程数，下面把某linux用户的最大进程数设为10000个：

```
echo "ulimit -u 60000" >> /etc/profile
source /etc/profile
```

