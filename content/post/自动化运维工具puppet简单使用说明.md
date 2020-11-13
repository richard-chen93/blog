---
title: "自动化运维工具puppet简单使用说明"
date: 2020-10-27T17:28:54+08:00
draft: false
---

# 自动化运维工具puppet简单使用说明

## 目录
------------
## 一、此实验中puppet的运行环境
### 1. 硬件清单
### 2. 软件清单
### 3. 准备yum源
### 4. 配置域名解析
### 5. Ntp时间同步
## 二、puppet安装配置过程
### 1. Puppet master安装配置
### 2. Puppet node安装配置
### 3. 分配证书，开启PUPPET服务
## 三、 申报站点清单中的资源，测试PUPPET能否工作。

-------------

## 正文

## 一、此实验中puppet的运行环境
### 1. 硬件清单
* puppet master：4cpu，8G memory，1TB ssd
* puppet node1：4cpu，8G memory，500GB ssd

### 2. 软件清单
master
* 主机名: pmaster.cn04-corp.int
* OS: centos 7.6
* puppet-master版本：3.6.2
* ip：10.193.194.102

node
* 主机名: pnode1.cn04-corp.int
* OS: centos 7.6
* puppet-master版本：3.6.2
* ip：10.193.194.105

### 3. 准备yum源
Yum源服务器已配置好，可直接使用脚本配置到本地：
```
wget http://10.193.200.6/yum.sh
sh yum.sh
```
### 4. 配置域名解析
Puppet系统需要主机名或ip来标识master和node，目前两台机器均使用hosts文件做域名解析。
```
cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.193.194.102  pmaster.cn04-corp.int
10.193.194.105  pnode1.cn04-corp.int
```
### 5. Ntp时间同步
puppet master和node之间需要时间同步，Ntp服务器位于10.193.202.1。
puppet master和node都需要安装ntp服务并配置。
```
yum install ntp
vim /etc/ntp.conf
```
ntp配置文件里注释掉原有ntp服务器并添加10.193.202.1
```
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst
server 10.193.202.1 iburst

vim /etc/ntp/step-tickers
#0.centos.pool.ntp.org	#注释掉

systemctl enable ntpd	#开机自启ntp服务
systemctl start ntpd	#启动ntp服务
ntpq -p		#查看ntp服务器列表
date			#查看时间是否一致
```
## 二、puppet安装配置过程
### 1. Puppet master安装配置
```
Yum install puppet-server	#安装
Vim /etc/puppet/puppet.conf	#修改配置文件
[agent]	#这里添加server和certname
server = pmaster.cn04-corp.int
certname = pmaster.cn04-corp.int
  
[master]	#这里新建【master】，添加certname
certname = pmaster.cn04-corp.int
```
### 2. Puppet node安装配置
```
Yum install puppet 	#安装pupet agent
Vim /etc/puppet/puppet.conf	#修改配置文件，添加以下master和certname
[agent]
server = pmaster.cn04-corp.int	#指定master，这里是主机名
certname = pnode1.cn04-corp.int	#指定node的证书名
runinterval = 60			#设定agent请求catalog的间隔，这里是60秒。
```
### 3. 分配证书，开启PUPPET服务
在Node1上，输入以下命令向Master申请证书：
```
Puppet agent -t
```
Master上查看待签发的证书,然后签发：
```
Puppet cert list
Puppet cert  --sign pnode1.cn04-corp.int
```

## 三、 申报站点清单中的资源，测试PUPPET能否工作。
### 1. 开启puppet服务
Master：
```
Systemctl enable puppetmaster
Systemctl start puppetmaster
```
Node1：
```
Systemctl enable puppet
Systemctl start puppet
```
### 2. 申报站点清单中的资源，测试puppet能否工作。
Master上建立站点清单，位于/etc/puppet/manifest/site.pp
编辑site.pp，进行资源申报：
```
vim /etc/puppet/manifest/site.pp

node pnode1{				#节点的主机名pnode1，不需要带域名.cn04-corp.int
file {'test':				#申报文件资源’test’，并定义各种状态
        path=>'/root/test.txt',
        owner=>'root',
        group=>'root',
        mode=>'644',
        content=>'puppet system works!',
}
exec {'test shell scripts':			#申报命令资源‘test shell scripts’，并定义各种状态
        path=>'/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin',
        command=>'sh /root/sh/test.sh',
        user=>root,
        group=>root,
}
}
```
Node1 上设定了agent请求catalog的间隔为1分钟，若需立即执行，可用命令：
```
Puppet agent -t
```
Node1执行完毕此命令后，查看Master的site.pp中定义的资源状态是否存在。
```
[root@pnode1 ~]# ls /root/*.txt
/root/name.txt  /root/test.txt
[root@pnode1 ~]#
```
存在说明puppet工作正常。
