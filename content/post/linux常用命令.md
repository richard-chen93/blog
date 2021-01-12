---
title: "Linux常用命令"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2020-12-25T10:25:09+08:00
draft: false
---



# 查看cpu信息

```
[root@AAA ~]# cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
     24         Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz

# 查看物理CPU个数
[root@AAA ~]# cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
2

# 查看每个物理CPU中core的个数(即核数)
[root@AAA ~]# cat /proc/cpuinfo| grep "cpu cores"| uniq
cpu cores    : 6

# 查看逻辑CPU的个数
[root@AAA ~]# cat /proc/cpuinfo| grep "processor"| wc -l
24
```

# 文本编辑

```
cat >> /etc/my.cnf << EOF
text 1
text 2
EOF
```

```
sed -i 's/原字符串/新字符串/' /home/1.txt
```

 sudo useradd cephuser ; echo cephuser | sudo passwd --stdin cephuser

我的macbook15，windows下的虚拟机：

```
sed -i 's/920f1da23253/920f1da23011/' /etc/sysconfig/network-scripts/ifcfg-ens33
sed -i 's/IPADDR=10.0.3.253/IPADDR=10.0.3.11/' /etc/sysconfig/network-scripts/ifcfg-ens33
systemctl restart network
```

