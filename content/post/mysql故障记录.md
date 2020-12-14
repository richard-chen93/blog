---
title: "Mysql故障记录"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2020-12-07T11:12:10+08:00
draft: false
---

mysql5.7
mysql启动失败，报错  The server quit without updating PID file！
修改启动脚本 /etc/init.d/mysqld 约278行，增加--user=root参数
 $bindir/mysqld_safe --user=root --datadir="$datadir" --pid-file="$mysqld_pid_file_path"     $other_args >/dev/null &

确保/etc/下有my.cnf.d



#修改密码mysql>  alter user 'root'@'localhost' identified by 'youpassword';