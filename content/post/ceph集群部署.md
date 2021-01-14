---
title: "Ceph集群部署"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-12T10:27:48+08:00
draft: false
---





# 1、环境准备

环境准备好，避免踩坑！



4台机器，s10为ceph-deploy。

s7 s8 s9为3个node，拥有空闲磁盘sdb，10G



ceph-deploy --version  1.5.39

ceph version 10.2.11

## 1、时间同步

s7作为ntp服务器，s8-10作为客户端

```bash
sudo yum -y install ntp ntpdate
```

#### 1.s7 节点配置

```bash
sudo vim /etc/ntp.conf


restrict 10.3.3.7 mask 255.255.255.0 nomodify notrap  #配置集群的IP段

server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10

sudo systemctl enable ntpd
sudo systemctl restart ntpd
sudo systemctl status ntpd

ntpstat
ntpq -p
date
```

#### 2.其他节点配置

```bash
sudo vim /etc/ntp.conf


restrict 10.3.3.7 mask 255.255.255.0 nomodify notrap #IP为node1的ip地址
server  10.3.3.7     # #IP为node1的ip地址

sudo systemctl enable ntpd
sudo systemctl restart ntpd
sudo systemctl status ntpd

ntpstat
ntpq -p
date
```



## 2、ssh免密登录和sudo无需密码权限

s10 需要使用cephuser用户ssh免密登录3个node。

* 4台机器创建cephuser用户。用户名 “ceph” 保留给了 Ceph 守护进程。如果 Ceph 节点上已经有了 “ceph” 用户，升级前必须先删掉这个用户。

```
 sudo useradd cephuser ; echo cephuser | sudo passwd --stdin cephuser
```

* 4台机器设定cephuser用户无密码sudo权限

```
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
sudo chmod 0440 /etc/sudoers.d/cephuser
```

* 在S10上使用cephuser用户执行ssh免密登录配置脚本sshops-init.sh "s7,s8,s9,s10"



## 3、在4台机器上配置ceph 的yum源，安装依赖包

* yum源

  ```bash
  sudo vi /etc/yum.repos.d/ceph.repo
  ```

  把如下内容粘帖进去，保存到 /etc/yum.repos.d/ceph.repo 文件中。

  ```js
  [ceph]
  name=ceph
  baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/x86_64/
  gpgcheck=0
  priority=1
  
  [ceph-noarch]
  name=cephnoarch
  baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/noarch/
  gpgcheck=0
  priority=1
  
  [ceph-source]
  name=Ceph source packages
  baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/SRPMS
  gpgcheck=0
  priority=1
  ```

   

* 安装pip包：

```
wget https://files.pythonhosted.org/packages/5f/ad/1fde06877a8d7d5c9b60eff7de2d452f639916ae1d48f0b8f97bf97e570a/distribute-0.7.3.zip
sudo yum -y install unzip
unzip distribute-0.7.3.zip
cd distribute-0.7.3
sudo python setup.py install
```

* 安装rpm包：

```
sudo yum -y install deltarpm
```

排错参考：http://www.voidcn.com/article/p-rougfoll-ov.html

集群搭建：http://docs.ceph.org.cn/start/quick-ceph-deploy/





## 4、s10安装ceph-deploy

安装ceph-deploy

```bash
sudo yum -y install ceph-deploy
```

 查看ceph-deploy是否安装成功

```
ceph-deploy --version
```





# 2、搭建集群



## 1、说明



第一次练习时，我们创建一个 Ceph 存储集群，它有一个 Monitor 和两个 OSD 守护进程。一旦集群达到 `active + clean` 状态，再扩展它：增加第三个 OSD 、增加元数据服务器和两个 Ceph Monitors。为获得最佳体验，先在管理节点上创建一个目录，用于保存 `ceph-deploy` 生成的配置文件和密钥对。

```
mkdir my-cluster
cd my-cluster
```

注意： `ceph-deploy` 会把文件输出到当前目录，所以请确保在此目录下执行 `ceph-deploy` 。

Important:

如果你是用另一普通用户登录的，不要用 `sudo` 或在 `root` 身份运行 `ceph-deploy` ，因为它不会在远程主机上调用所需的 `sudo` 命令。



如果在某些地方碰到麻烦，想从头再来，可以用下列命令清除配置：

```
ceph-deploy purgedata {ceph-node} [{ceph-node}]
ceph-deploy forgetkeys
```

用下列命令可以连 Ceph 安装包一起清除：

```
ceph-deploy purge {ceph-node} [{ceph-node}]
```

如果执行了 `purge` ，你必须重新安装 Ceph 。



## 2、创建ceph集群

Note： 在管理节点上，进入刚创建的放置配置文件的目录，用 `ceph-deploy` 执行如下步骤。

1、创建集群。

```
ceph-deploy new s7
```



在当前目录下用 `ls` 和 `cat` 检查 `ceph-deploy` 的输出，应该有一个 Ceph 配置文件、一个 monitor 密钥环和一个日志文件。详情见 [ceph-deploy new -h](http://docs.ceph.org.cn/rados/deployment/ceph-deploy-new) 。

2、把 Ceph 配置文件里的默认副本数从 `3` 改成 `2` ，这样只有两个 OSD 也可以达到 `active + clean` 状态。把下面这行加入 `[global]` 段：

```
 sed -i '$a\osd pool default size = 2' ceph.conf
```

3、如果你有多个网卡，可以把 `public network` 写入 Ceph 配置文件的 `[global]` 段下。详情见[网络配置参考](http://docs.ceph.org.cn/rados/configuration/network-config-ref)。

```
public network = {ip-address}/{netmask}
```

4、安装 Ceph 。

```
ceph-deploy install s7 s8 s9 s10
```

`ceph-deploy` 将在各节点安装 Ceph 。 **注：**如果你执行过 `ceph-deploy purge` ，你必须重新执行这一步来安装 Ceph 。

5、配置初始 monitor(s)、并收集所有密钥：

```
ceph-deploy mon create-initial
```

完成上述操作后，当前目录里应该会出现这些密钥环：

- `{cluster-name}.client.admin.keyring`
- `{cluster-name}.bootstrap-osd.keyring`
- `{cluster-name}.bootstrap-mds.keyring`
- `{cluster-name}.bootstrap-rgw.keyring`



# 3、增加/删除osd

## 创建 OSD

你可以用 `create` 命令一次完成准备 OSD 、部署到 OSD 节点、并激活它。 `create` 命令是依次执行 `prepare` 和 `activate` 命令的捷径。

如果创建osd失败，怎么弄都是失败，那就将各node sdb都分区为sdb1,xfs格式，并且创建osd时使用s7:/dev/sdb1， 而不是/dev/sdb。  因为没有时间和精力为了一个别人的BUG而执着于此，切记！

```
ceph-deploy osd create s7:/dev/sdb s8:/dev/sdb  #在两个节点创建osd
ceph-deploy osd create osdserver1:sdb:/dev/ssd1 #数据放sdb，日志放ssd盘
```

## 把配置文件和 admin 密钥拷贝到管理节点和 Ceph 节点

```
 ceph-deploy admin s7 s8 s9 s10
```

ceph mds stat 查看MDS

## 确保ceph.client.admin.keyring的权限正确

```
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
```

## 安装 radosgw

```
ceph-deploy rgw create s7
```



##  检查集群的健康状况和OSD节点状况

```js
 ceph health
 ceph -s
cluster 3756d8ae-6f85-40f0-abd3-2a2863ec37dc
     health HEALTH_OK
     monmap e1: 1 mons at {node1=192.168.6.150:6789/0}
            election epoch 3, quorum 0 node1
     osdmap e20: 2 osds: 2 up, 2 in
            flags sortbitwise,require_jewel_osds
      pgmap v44: 112 pgs, 7 pools, 1588 bytes data, 171 objects
            225 MB used, 3563 GB / 3563 GB avail
                 112 active+clean
  client io 50376 B/s rd, 0 B/s wr, 49 op/s rd, 32 op/s wr

```

查看是否安装成功

```bash
 curl http://s7:7480

<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<Owner>
<ID>anonymous</ID>
<DisplayName/>
</Owner>
<Buckets/>
</ListAllMyBucketsResult>
```



# 4、ceph文件系统

Ceph 文件系统要求 Ceph 存储集群内至少有一个 [*Ceph 元数据服务器*](http://docs.ceph.org.cn/glossary/#term-63)。

## 1、增加一元数据服务器

部署完监视器和 OSD 后，还可以部署元数据服务器。

```
ceph-deploy mds create s7:{daemon-name}] [{host-name}[:{daemon-name}] ...]
```

如果你想在同一主机上运行多个守护进程，可以为每个进程指定名字（可选）。

## 2、拆除一元数据服务器

尚未实现……？

## 3、创建文件系统

一个 Ceph 文件系统需要至少两个 RADOS 存储池，一个用于数据、一个用于元数据。配置这些存储池时需考虑：

- 为元数据存储池设置较高的副本水平，因为此存储池丢失任何数据都会导致整个文件系统失效。
- 为元数据存储池分配低延时存储器（像 SSD ），因为它会直接影响到客户端的操作延时。

关于存储池的管理请参考 [*存储池*](http://docs.ceph.org.cn/rados/operations/pools/) 。例如，要用默认设置为文件系统创建两个存储池，你可以用下列命令：

```
$ ceph osd pool create cephfs_data <pg_num>
$ ceph osd pool create cephfs_metadata <pg_num>
```

创建好存储池后，你就可以用 `fs new` 命令创建文件系统了：

```
$ ceph fs new <fs_name> <metadata> <data>
```

例如：

```
$ ceph fs new cephfs cephfs_metadata cephfs_data
$ ceph fs ls
name: cephfs, metadata pool: cephfs_metadata, data pools: [cephfs_data ]
```

文件系统创建完毕后， MDS 服务器就能达到 *active* 状态了，比如在一个单 MDS 系统中：

```
$ ceph mds stat
e5: 1/1/1 up {0=a=up:active}
```

建好文件系统且 MDS 活跃后，你就可以挂载此文件系统了：

要挂载 Ceph 文件系统，如果你知道监视器 IP 地址可以用 `mount` 命令、或者用 `mount.ceph` 工具来自动解析监视器 IP 地址。例如：

```
sudo mkdir /mnt/mycephfs
sudo mount -t ceph 192.168.0.1:6789:/ /mnt/mycephfs
```

要挂载启用了 `cephx` 认证的 Ceph 文件系统，你必须指定用户名、密钥。

```
sudo mount -t ceph 192.168.0.1:6789:/ /mnt/mycephfs -o name=admin,secret=AQATSKdNGBnwLhAAnNDKnH65FmVKpXZJVasUeQ==
```

前述用法会把密码遗留在 Bash 历史里，更安全的方法是从文件读密码。例如：

```
sudo mount -t ceph 192.168.0.1:6789:/ /mnt/mycephfs -o name=admin,secretfile=/etc/ceph/admin.secret
```

关于 cephx 参见[认证](http://docs.ceph.org.cn/rados/operations/authentication/)。

要卸载 Ceph 文件系统，可以用 `unmount` 命令，例如：

```
sudo umount /mnt/mycephfs
```









# 其他：

我的thinkpad，克隆虚拟机后的操作：

```
sudo sed -i "s/1f76218ec253/1f76218ec222/g" /etc/sysconfig/network-scripts/ifcfg-ens33
sudo sed -i "s/IPADDR=10.3.3.253/IPADDR=10.3.3.222/g" /etc/sysconfig/network-scripts/ifcfg-ens33
sudo systemctl restart network
cd
```



