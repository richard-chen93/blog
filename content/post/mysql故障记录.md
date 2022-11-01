---
title: "Mysql故障记录"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2020-12-07T11:12:10+08:00
draft: false
---

## OS和mysql版本

mysql5.7、centos7

## 报错记录

### 1、启动失败

mysql启动失败，报错  The server quit without updating PID file！
修改启动脚本 /etc/init.d/mysqld 约278行，增加--user=root参数
 $bindir/mysqld_safe --user=root --datadir="$datadir" --pid-file="$mysqld_pid_file_path"     $other_args >/dev/null &

确保/etc/下有my.cnf.d

### 2、无法安装、初始化

报错内容：

```
"mysqld: Can't read dir of '/etc/my.cnf.' (Errcode: 2 - No such file or directory)
```

解决：

确保有 ！includedir 且下面有空行

```
# include all files from the config directory
#
!includedir /etc/my.cnf.d

#
```

## 修改root密码

使用自动生成的密码登录mysql以后

修改密码mysql>  alter user 'root'@'localhost' identified by 'you_new_password';

## mysql主从同步集群搭建

### 1、两台装好mysql后修改配置文件

假设已经安装 A、B两台机器mysql，其中A作为mster，B作为slave。

* 两台机器my.cnf配置文件中server_id 的值不可相同，如A机器为：server_id = 1，B机器设置为 2

* 分别修改A/B两台机器/etc/my.cnf文件一项配置，并重启 mysql (service mysql restart)

```
#A机器 /etc/my.cnf:

log-bin=master-bin 

#B机器 /etc/my.cnf:

log-bin= relay-bin
```

### 2、A执行：

```
mysql -h 127.0.0.1 -u root -p #登录mysql
```

在mysql客户端执行命令：创建用户(sync/123456)来给slave同步使用

```
mysql> grant replication slave on *.* to 'sync'@'slave机器IP' identified by '123456'; 
```

查看master状态，输出如下

mysql> show master status; +*-------------------+-----------+--------------+------------------+-------------------+* | File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set | +*-------------------+-----------+--------------+------------------+-------------------+* | master-bin.000004 | 229548120 | | | | +*-------------------+-----------+--------------+------------------+-------------------+*

```
mysql> flush privileges; #刷新配置

service mysqld restart; # 重启mysql
```

### 3、B执行：

```
mysql -h 127.0.0.1 -u root -p #登录mysql
```

```
mysql> CHANGE MASTER TO

  -> MASTER_HOST='192.168.6.50', #master所在服务器的IP

  -> MASTER_USER='sync', #master授权的账号,此处应为sync'

  -> MASTER_PASSWORD='123456', # master授权的密码，此处应为123456

  -> MASTER_LOG_FILE='master-bin.000002',  #master的日志文件名master的show master status的file

  -> MASTER_LOG_POS=0 # master的日志所在位置master的show master status的Position; 注意这一行没有单引号，数值类型，也可以填写为0，由mysql自己获取具体的值

  -> ;
```

Query OK, 0 rows affected, 2 warnings (0.00 sec)

```
mysql>  start slave; # 开启复制
```

### 4、 验证，查看状态

重新登录mysql slave机器，查看其状态：

```
mysql> show slave status\G 
```

Slave_IO_State: Waiting for master to send event Master_Host: master的IP地址 Master_User: root Master_Port: 3306 Connect_Retry: 60 Master_Log_File: master-bin.000001 Read_Master_Log_Pos: 1516 Relay_Log_File: slave-bin.000004 Relay_Log_Pos: 1117 Relay_Master_Log_File: master-bin.000001 Slave_IO_Running: Yes Slave_SQL_Running: Yes ...... 

Slave*IO*Running: YES 表示slave的日志读取线程开启

Slave*SQL*Running: YES 表示SQL执行线程开启

两者都为YES表示主从模式成功。

## mysql主从不同步

待解决

不能创建用户

mysql> CREATE USER 'bond'@'%' IDENTIFIED BY 'bond_123456';
ERROR 1819 (HY000): Unknown error 1819

```
set global validate_password_policy=0;
select @@validate_password_length;
```

rm: cannot remove '/var/lock/subsys/mysql': Permission denied

rm -rf 删除它

sudo chown -R apps.apps /var/lock/subsys/
