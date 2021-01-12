---
title: "安装并监控memcached"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-12T10:34:35+08:00
draft: false
---

# 1、安装httpd memcached php php-memcache

```
sudo yum -y install httpd memcached php php-memcache
```

# 2、配置php-memcache扩展

Note： 是memcache，而不是memcached

```
vim /etc/php.ini #末尾添加如下配置
extension_dir = “/usr/lib64/php/modules”
```

# 3、启动httpd、memcached

```
memcached -d -u root -l 127.0.0.1 -p 11211 -m 128 {PID_file}  #提前创建该pid文件
sudo systemctl start httpd

echo "<?php phpinfo(); ?>" > /var/www/html/index.php  #测试php是否正常

memcached-tool 127.0.0.1:11211 stats  #查看memcached状态，是否已启动
cat /etc/sysconfig/memcached		#查看memcached配置信息
```



# 4、下载安装memadmin

  1. 下载地址 http://www.junopen.com/memadmin
  2. 将压缩包解压到/var/www/html
  3. 此文件可设定用户名密码 config.php
  4. 浏览器打开监控 : http://example.com/memadmin/index.php