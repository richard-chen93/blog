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

查看所有连接mysql的客户端ip

`SELECT substring_index(host,` `':'``,1) AS host_name,state,count(*) FROM information_schema.processlist GROUP BY state,host_name;`

## 修改root密码

使用自动生成的密码登录mysql以后

修改密码mysql>  alter user 'root'@'localhost' identified by 'you_new_password';

## 忘记root密码

vim /etc/my.cnf

```
[mysqld]
skip-grant-tables  #添加这一行
```

```
service mysqld restart
```

```
mysql -h 127.0.0.1 -uroot
use mysql;

SHOW VARIABLES LIKE 'validate_password%'; 
set global validate_password_policy=LOW;
set global validate_password_length=6;

flush privileges;   #此步骤必须
alter user 'root'@'localhost' identified by 'TD@123';


ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'TD@123';
flush privileges;
quit
```

```
# my.cnf配置文件去掉skip-grant-tables 这一行，重启mysql
```

智邦部署，安装cdh时，mysql需要配置validate_password=off;

```
1、登录mysql

set global validate_password_policy=0;

set global validate_password_length=4;

2、/etc/my.cnf增加配置

validate_password=off;

3、重启mysql
```

## 不能创建用户

mysql> CREATE USER 'bond'@'%' IDENTIFIED BY 'bond_123456';
ERROR 1819 (HY000): Unknown error 1819

```
set global validate_password_policy=0;
select @@validate_password_length;
```

rm: cannot remove '/var/lock/subsys/mysql': Permission denied

rm -rf 删除它

sudo chown -R apps.apps /var/lock/subsys/

# 数据库迁移

导出表结构、数据、函数、存储过程

/usr/local/mysql/bin/mysqldump -ntd -R cuckoo-als  > ./cuckoo_als.sql -uroot -p

导入

进入该库，source als.sql;

导出事件

/usr/local/mysql/bin/mysqldump -E -ndt zto_qykf -u root -p > shijian.sql

导入 source .sql;w



监控

mysql exporter



CREATE USER 'exporter'@'%' IDENTIFIED BY 'ztky@123';

GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';



vim .my.cnf

[client]
user=exporter
password=ztky@123





nohup ./mysqld_exporter --web.listen-address=:9306 --config.my-cnf=/apps/svr/mysqld_exporter/.my.cnf > /apps/logs/mysqld_exporter/exporter.log 2>&1 &
