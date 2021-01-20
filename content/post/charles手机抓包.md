---
title: "Charles手机抓包"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-20T23:15:49+08:00
draft: false
---

# charles抓包工具的使用：手机抓包设置和安装证书

![img](https://csdnimg.cn/release/blogv2/dist/pc/img/reprint.png)

[dufufd](https://blog.csdn.net/dufufd) 2019-01-16 16:17:48 ![img](https://csdnimg.cn/release/blogv2/dist/pc/img/articleReadEyes.png) 4645 ![img](https://csdnimg.cn/release/blogv2/dist/pc/img/tobarCollect.png) 收藏 4

分类专栏： [Web](https://blog.csdn.net/dufufd/category_7017455.html)

http://www.cnblogs.com/cnhkzyy/p/9535030.html

 

# 一. 设置手机抓包

## 第一步：在charles里设置允许手机联网的权限，并设置接入接口

在Charles的菜单栏上选择"Proxy"->"Proxy Settings"，填入代理端口8888（注意，这个端口不一定填写8888，也可以写别的端口），并且勾上”Enable transparent HTTP proxying”，这样就完成了在Charles上的设置

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825173158666-191153404.png)

在"Help"->"Local IP Address"中可以查看本机的ip地址，当然也可以在cmd中通过ipconfig查看

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825173400916-1214055123.png)

## 第二步：设置手机代理

以荣耀8为例，选中wifi名字，右击，选择修改网络

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825173506122-1474946534.png)

显示高级选项，输入服务器主机名和服务器端口，点击保存

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825173858898-327058277.png)

# 二. 为避免(PC/Phone)抓取HTTPS失败和乱码，需要下载安装SSL/HTTPS证书

==========================电脑端=============================

## 第一步：电脑安装SSL证书

选择 "Help" -> "SSL Proxying" -> "Install Charles Root Certificate"，如果设置了安全防护，会ranging输入系统的帐号密码

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825174637880-572616760.png)

这时开始安装charles证书，一路点击下一步即可

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825174812018-2119491648.png)

## 第二步：配置SSL的抓取域名

找到"Proxy"->"SSL Proxying Settings..."，点击

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825175219071-1052113309.png)

然后选中启用SSL代理(Enable SSL Proxying)，charles的Location配置都是支持通配符的，因此在Host里设置一个"*"就可以，port不写

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825175512884-663424194.png)

如果需要配置某个指定域名，也是在Host里填写，配置指定域名时，一般Port是443，这样就可以抓取到到HTTPS的内容了

==========================手机端=============================

## 第一步：手机安装SSL证书

进入"Help"->"Install Charles Root Certificate on a Mobile Device or remote Browser"，点击

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825180625239-104764890.png)

这时会有一个弹框，意思是要给手机设置代理，内容是192.168.1.103:8888，然后用手机浏览器打开chls.pro/ssl

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825180911841-545517043.png)

 点击立即下载

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180825182519249-1163216572.png)

在手机设置->高级设置->安全里开启未知来源应用下载和外部来源应用安装

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180826145931504-730962711.png)

在手机文件管理里找到证书，将后缀pem改成crt，点击安装即可

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180826150314947-970874423.png)

这时发现手机上的HTTPS也能抓取下来了

![img](https://images2018.cnblogs.com/blog/1186367/201808/1186367-20180826150836190-190088689.png)