---
title: "KVM虚拟机安装和常用操作"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-18T22:23:17+08:00
draft: false
---

# 1、centos7安装kvm

## 1、前提条件

**2.** 首先验证**CPU**是否支持虚拟化，输入有**vmx**或**svm**就支持，支持虚拟化则就支持**KVM**

```
[root@openstack ~]# cat /proc/cpuinfo | egrep 'vmx|svm'
```

**3.** 查看是否加载**KVM**

```
[root@openstack ~]# lsmod | grep kvm

kvm_intel       170086 0 

kvm          566340 1 kvm_intel

irqbypass       13503 1 kvm
```

这表明已经加载，如果没有加载则执行以下命令加载KVM

```
[root@openstack ~]# modprobe kvm
```



## 2、 安装**KVM**相关软件包

```
sudo yum install qemu-kvm qemu-img \

 virt-manager libvirt libvirt-python virt-manager \

 libvirt-client virt-install virt-viewer -y
```

qemu-kvm: KVM模块

libvirt: 虚拟管理模块

virt-manager: 图形界面管理虚拟机

virt-install: 虚拟机命令行安装工具



启动**libvirt**并设置开机自启动

```
[root@openstack ~]# systemctl start libvirtd

[root@openstack ~]# systemctl enable libvirtd
```



# 2、常用操作

## 1、创建虚拟机（命令行）

```
qemu-img create -f qcow2 /kvm_images/vm1.qcow2 10G
```

```
virt-install --name=vm1 --vcpus=1 --memory=512 --location=/tmp/CentOS-7-x86_64-Minimal-2009.iso --disk path=/kvm_images/vm1.qcow2,size=10,format=qcow2 --network bridge=virbr0 --graphics none --extra-args='console=ttyS0' --force
```

## 2、扩容磁盘

* 查看磁盘虚拟机详细配置信息，找到虚拟机使用的磁盘镜像位置。

  virsh edit {vm name}

* 扩容磁盘镜像

  ```
  qemu-img	resize /kvm_images/app5.raw	+200G
  ```

* 虚拟机里查看扩容后的磁盘大小

  fdisk -l

  若没有变大，宿主机执行 virsh destroy {vm_name}，强关虚拟机，再开起来virsh start {vm_name}

* 虚拟机扩容文件系统

  ```
  xfs_grows /dev/vdb
  ```

  