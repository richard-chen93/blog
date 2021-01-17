---
title: "CentOS7扩容根分区"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-17T21:38:42+08:00
draft: false
---

# CentOS7扩容根分区(LVM+非LVM)

[![img](https://upload.jianshu.io/users/upload_avatars/3259553/ee147e16c19d?imageMogr2/auto-orient/strip|imageView2/1/w/96/h/96/format/webp)](https://www.jianshu.com/u/cc8aeffd7d42)

[神冰凰](https://www.jianshu.com/u/cc8aeffd7d42)关注

0.6612018.06.14 14:11:25字数 312阅读 18,450

# CentOS7，LVM根分区扩容步骤：

1.查看现有分区大小

> df -TH

![img](https://upload-images.jianshu.io/upload_images/3259553-89b0157044970265.png?imageMogr2/auto-orient/strip|imageView2/2/w/531/format/webp)

LVM分区，磁盘总大小为20G,根分区总容量为17G

2.关机增加大小为30G(测试环境使用的Vmware Workstation)

![img](https://upload-images.jianshu.io/upload_images/3259553-2797e3050686449b.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

扩展分区到30G

3.查看扩容后磁盘大小

> df -TH
>
> lsblk

![img](https://upload-images.jianshu.io/upload_images/3259553-a0366bb674b44f12.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

磁盘总大小为30G,根分区为17G

4.创建分区

> fdisk /dev/sda

![img](https://upload-images.jianshu.io/upload_images/3259553-1cbe7facdadff9bd.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

将sda剩余空间全部给sda3

5.刷新分区并创建物理卷

> partprobe /dev/sda
>
> pvcreate /dev/sda3

![img](https://upload-images.jianshu.io/upload_images/3259553-e1ba05156f11b547.png?imageMogr2/auto-orient/strip|imageView2/2/w/444/format/webp)

6.查看卷组名称，以及卷组使用情况

> vgdisplay

![img](https://upload-images.jianshu.io/upload_images/3259553-700e6cb7fb268306.png?imageMogr2/auto-orient/strip|imageView2/2/w/476/format/webp)

VG Name为centos

7.将物理卷扩展到卷组

> vgextend centos /dev/sda3

![img](https://upload-images.jianshu.io/upload_images/3259553-cf6f3d4e807acaa5.png?imageMogr2/auto-orient/strip|imageView2/2/w/366/format/webp)

使用sda3扩展VG  centos 

8.查看当前逻辑卷的空间状态

> lvdisplay

![img](https://upload-images.jianshu.io/upload_images/3259553-67cac8c1c780248d.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

需要扩展LV  /dev/centos/root

9.将卷组中的空闲空间扩展到根分区逻辑卷

> lvextend -l +100%FREE /dev/centos/root

![img](https://upload-images.jianshu.io/upload_images/3259553-585215fcd2940e25.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

10.刷新根分区

> xfs_growfs /dev/centos/root

![img](https://upload-images.jianshu.io/upload_images/3259553-96b258ed69c7b8fe.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

11.查看磁盘使用情况，扩展之前和之后是不一样的

![img](https://upload-images.jianshu.io/upload_images/3259553-4e8cbb4522f57cb4.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

根分区已经变成27G

# CentOS7，非LVM根分区扩容步骤：

1.查看现有的分区大小

![img](https://upload-images.jianshu.io/upload_images/3259553-9faab28c65c03ffb.png?imageMogr2/auto-orient/strip|imageView2/2/w/453/format/webp)

非LVM分区，目前磁盘大小为20G，根分区总容量为17G

2.关机增加磁盘大小为30G

![img](https://upload-images.jianshu.io/upload_images/3259553-20ca17c409690a17.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

3.查看磁盘扩容后状态

> lsblk
>
> dh -TH

![img](https://upload-images.jianshu.io/upload_images/3259553-a5c1e6baf7a3a080.png?imageMogr2/auto-orient/strip|imageView2/2/w/427/format/webp)

现在磁盘总大小为30G,根分区为17G

4.进行分区扩展磁盘，**记住根分区起始位置和结束位置**

![img](https://upload-images.jianshu.io/upload_images/3259553-1d6519285921f2bb.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

5.删除根分区，切记不要保存

![img](https://upload-images.jianshu.io/upload_images/3259553-7ebfd645ff37877f.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

6.创建分区，箭头位置为分区起始位置

![img](https://upload-images.jianshu.io/upload_images/3259553-3f4f974ae31f41dc.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

7.保存退出并刷新分区

> partpeobe /dev/sda

![img](https://upload-images.jianshu.io/upload_images/3259553-4f504e0fd59f7380.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

8.查看分区状态

![img](https://upload-images.jianshu.io/upload_images/3259553-199fb2bc6db5ab71.png?imageMogr2/auto-orient/strip|imageView2/2/w/513/format/webp)

这里不知道为啥变成19G了。。

9.刷新根分区并查看状态

> xfs_growfs /dev/sda3

![img](https://upload-images.jianshu.io/upload_images/3259553-b67666e234494064.png?imageMogr2/auto-orient/strip|imageView2/2/w/554/format/webp)

根分区大小已变为27G