---
title: "在CentOS7中配置NFS服务器和客户端"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2022-09-02T17:36:24+08:00
draft: false
---

原文地址：

[在 CentOS/RHEL 7 中配置 NFS 服务器和客户端-之路教程](https://www.onitroad.com/jc/linux/centos/service/nfs/how-to-configure-nfs-server-and-client-in-centos-rhel-7.html)

在 CentOS/RHEL 7 中配置 NFS 服务器和客户端

在本文中，我们将在 CentOS/RHEL 7 中配置 NFS Server 和 Client 以共享目录。

NFS（网络文件系统）是一种分布式文件系统，用于在网络客户端之间共享文件。  
NFS 由 Sun Microsystem 于 1984 年开发。  
NFS 是 Linux 各种发行版中共享文件的事实上的标准。  
它有许多功能可以在特定客户端之间安全地共享文件。  
它还支持基于 Kerberos 的身份验证。

## 配置环境

### NFS 服务器

主机名：nfsserver.onitroad.com  
IP：192.168.1.100  
操作系统：CentOS

### NFS 客户端

主机名：nfsclient.onitroad.com  
IP：192.168.1.101  
操作系统：CentOS

## 在 CentOS/RHEL 7 上配置 NFS 服务器

登录到NFS 服务器。

要配置 NFS 服务器，我们必须安装 nfs-utils 包。  
通常，在安装 Red Hat Enterprise Linux (RHEL) 或者 CentOS 7 时会自动安装此软件包。  
但是，我们可以随时使用 yum 命令进行安装。

| 1   | `[root@nfsserver ~]``# yum install -y nfs-utils` |
| --- | ------------------------------------------------ |

nfs-utils 已经安装在我们的系统上。

创建一个目录以与其他客户端共享。

| 1<br><br>2<br><br>3 | `[root@nfsserver ~]``# mkdir /nfsshare`<br><br>`[root@nfsserver ~]``# chgrp nfsnobody /nfsshare/`<br><br>`[root@nfsserver ~]``# chmod g+w /nfsshare/` |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |

我们创建了一个目录 /nfsshare，将其组更改为 nfsnobody 并且已将 w 权限授予组。  
因此，匿名用户可以在此共享目录上创建文件。

调整 /nfsshare 目录的 SELinux 类型。

| 1<br><br>2<br><br>3 | `[root@nfsserver ~]``# semanage fcontext -a -t nfs_t "/nfsshare(/.*)?"`<br><br>`[root@nfsserver ~]``# restorecon -Rv /nfsshare/`<br><br>`restorecon reset` `/nfsshare` `context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:nfs_t:s0` |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

如果 semanage 命令在系统上不可用，则安装 policycoreutils-python 包。

现在通过 NFS 将此目录导出/共享到特定客户端。

| 1<br><br>2 | `[root@nfsserver ~]``# echo '/data/nfsdata TLVM202016003(rw,sync)' >> /etc/exports`<br><br>`[root@nfsserver ~]``# exportfs -r` |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------ |

启用并启动 nfs-server 服务。

| 1<br><br>2 | `[root@nfsserver ~]``# systemctl start nfs-server ; systemctl enable nfs-server`<br><br>`ln` `-s` `'/usr/lib/systemd/system/nfs-server.service'` `'/etc/systemd/system/nfs.target.wants/nfs-server.service'` |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |

允许 nfs 和其他补充服务通过 Linux 防火墙。

| 1<br><br>2<br><br>3<br><br>4 | `[root@nfsserver ~]``# firewall-cmd --permanent --add-service={mountd,nfs,rpc-bind}`<br><br>`success`<br><br>`[root@nfsserver ~]``# firewall-cmd --reload`<br><br>`success` |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

NFS 服务器已配置。

## 在 CentOS/RHEL 7 上配置 NFS 客户端

登录到 NFS 客户端  
并安装 nfs-utils 包。

| 1   | `[root@nfsclient ~]``# yum install -y nfs-utils` |
| --- | ------------------------------------------------ |

创建一个目录，从 nfsserver.onitroad.com 挂载共享目录。

| 1   | `[root@nfsclient ~]``# mkdir /mnt/nfsshare` |
| --- | ------------------------------------------- |

检查来自 nfsserver.onitroad.com 的共享目录。

| 1<br><br>2<br><br>3<br><br>4 | `[root@nfsclient ~]``# showmount -e nfsserver.onitroad.com`<br><br>`Export list` `for` `nfsserver.onitroad.com:`<br><br>`/nfsshare` `nfsclient.onitroad.com`<br><br>`[root@nfsclient ~]``#` |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

通过在 /etc/fstab 中添加以下条目来永久挂载此共享目录。

| 1<br><br>2<br><br>3 | `[root@nfsclient ~]``# echo 'nfsserver.onitroad.com:/nfsshare /mnt/nfsshare nfs defaults,_netdev 0 0' >> /etc/fstab`<br><br>`[root@nfsclient ~]``# mount -a`<br><br>`[root@nfsclient ~]``#` |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

检查挂载目录的状态。

| 1<br><br>2 | `[root@nfsclient ~]``# mount \| grep nfs`<br><br>`nfsserver.onitroad.com:``/nfsshare` `on` `/mnt/nfsshare` `type` `nfs4 (rw,relatime,vers=4.0,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.1.202,local_lock=none,addr=192.168.1.200,_netdev)` |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

在此共享目录中创建一个文件，以验证文件权限。

| 1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7<br><br>8 | `[root@nfsclient ~]``# cd /mnt/nfsshare/`<br><br>`[root@nfsclient nfsshare]``# touch test1`<br><br>`[root@nfsclient nfsshare]``# ls -al`<br><br>`total 0`<br><br>`drwxrwxr-x. 2 root      nfsnobody 18 Jul 31 07:32 .`<br><br>`drwxr-xr-x. 4 root      root      31 Jul 31 07:23 ..`<br><br>`-rw-r--r--. 1 nfsnobody nfsnobody  0 Jul 31 07:32 test1`<br><br>`[root@nfsclient nfsshare]``#` |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

我们已在 CentOS/RHEL 7 上成功配置 NFS 服务器和客户端，并在该客户端上持久挂载 NFS 共享。

# windows客户端挂载nfs磁盘

# 如何在 windows server 2008 上面 挂载NFS

发布于2020-12-30 16:37:31阅读 8590

首先， 你在一台[服务器](https://cloud.tencent.com/product/cvm?from=10680)上面配置好NFS 服务器：然后按照一下步骤：

**mounting the nfs on windows server 2008 r2:**

- open Windows Server 的Dos window（not powershell），typing： **servermanagercmd.exe -install FS-NFS-Services**
- to ensure that the disk map still exists after the system is restarted：
   **net use /persistent:yes**
- mount the nfs on z:

**mount IP:/Share -o nolock,rsize=1024,wsize=1024,timeo=15 z:**

# macos挂载

服务器需要加上  /data/nfsdata *(rw,sync,insecure)
