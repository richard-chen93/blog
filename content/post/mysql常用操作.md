---
title: "Mysql常用操作"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-12T10:30:40+08:00
draft: false
---

## 安装完初始化：

```
mysql_secure_installation
```

## 创建用户

```
CREATE USER 'panda'@'localhost' IDENTIFIED BY 'panda';
```

## 允许其他IP访问数据库 %代表任意IP 

```
GRANT ALL PRIVILEGES ON *.*  TO 'panda'@'%' IDENTIFIED BY  'panda' WITH GRANT OPTION;

flush privileges;
```

## 创建数据库表

```
CREATE TABLE IF NOT EXISTS `runoob_tbl`(
   `runoob_id` INT UNSIGNED AUTO_INCREMENT,
   `runoob_title` VARCHAR(100) NOT NULL,
   `runoob_author` VARCHAR(40) NOT NULL,
   `submission_date` DATE,
   PRIMARY KEY ( `runoob_id` )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

