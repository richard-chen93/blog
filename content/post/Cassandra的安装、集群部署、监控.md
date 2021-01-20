---
title: "Cassandra的安装、集群部署、监控"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-20T11:16:14+08:00
draft: false
---

[「已注销」](https://blog.csdn.net/ytulnj) 2017-11-22 15:18:45 ![img](https://csdnimg.cn/release/blogv2/dist/pc/img/articleReadEyes.png) 2697 ![img](https://csdnimg.cn/release/blogv2/dist/pc/img/tobarCollect.png) 收藏 2

分类专栏： [随笔](https://blog.csdn.net/ytulnj/category_6983294.html) 文章标签： [cassandra](https://www.csdn.net/tags/MtTaEg0sNDAxMjMtYmxvZwO0O0OO0O0O.html) [集群](https://www.csdn.net/tags/MtTaEg0sMDE5MzUtYmxvZwO0O0OO0O0O.html)

# 1、集群部署

一：前提
安装jdk1.8以上，python2.7
二：安装Cassandra
Cassandra的下载地址：http://cassandra.apache.org/download/
下载后将文件解压到某目录下，
然后配置环境变量
`CASSANDRA_HOME`为你解压的目录，
path为`%CASSANDRA_HOME%\bin`
然后用管理员身份运行cmd（不然可能提示权限不够）
进入Cassandra目录下的bin，
执行`cassandra`
![这里写图片描述](https://img-blog.csdn.net/20171122151305607?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQveXR1bG5q/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
然后如果成功会出一大堆东西，并且不能再输入命令；
三：查询状态
再打开一个cmd窗口，原来的不要关闭
进入bin文件夹
执行`nodetool status`
![这里写图片描述](https://img-blog.csdn.net/20171122151507193?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQveXR1bG5q/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
这是成功状态，
然后输入`cqlsh`进入编写sql
![这里写图片描述](https://img-blog.csdn.net/20171122151640075?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQveXR1bG5q/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

*如果执行cqlsh时出现`Can't detect python version`需要到pylib目录下执行`python setup.py install`*

出现cqlsh>开头就表示你现在正在编写sql；
四：查询命令
查看表空间 `describe keyspaces`；
查看已有表：`describe tables`;
查看表结构：`describe table table_name`;

**以上是单个几点的安装，下面是多个节点的集群部署：**
修改配置文件：`cassandra.yaml`
`cluster_name`：集群名称。
如果启动过数据库再修改集群名称需要先执行命令:
进入cqlsh执行
`UPDATE system.local SET cluster_name = '你修改后的名称' where key='local';`
退出cqlsh状态，执行`nodetool flush system`
`seeds`节点，将每个节点的ip加进去，`"x.x.x.x,xx.xx.xx.xx"`不用加尖括号！
`listen_address`改为自己的ip地址
`rpc_address`改为自己的ip地址
重启数据库。
再次执行cqlsh命令，后面需要加自己的ip



# 2、监控

通过MX4J HTTP 适配器 健康 cassandra

配置步骤如下：

1. 下载最新的MX4J binary(e.g. mx4j-3.0.2.tar.gz):[ 下载](https://sourceforge.net/projects/mx4j/files/MX4J Binary/3.0.2/?SetFreedomCookie)

2. 解压缩，吧mx4j-tools.jar 文件(在压缩包的 /lib/mx4j-tools.jar)复制到Cassandra的lib文件夹里(e.g. /usr/share/cassandra/lib)

3. 在Cassandra的配置文件cassandra-env.sh文件中，在最下方添加下列内容：



```ini
MX4J_ADDRESS="-Dmx4jaddress=<Cassandra Node IP>"   # e.g. localhost or 127.0.0.1
MX4J_PORT="-Dmx4jport=<MX4J port>"                 # default port: 8081
JVM_OPTS="$JVM_OPTS $MX4J_ADDRESS"
JVM_OPTS="$JVM_OPTS $MX4J_PORT"
```



4. 重启cassandra服务： sudo service cassandra restart， 随后，可以在cassandra的system log( /var/log/cassandra/system.log )里找到如下信息：



```css
INFO  [main] 2016-06-20 10:18:11,493 Mx4jTool.java:63 - mx4j successfully loaded
```

5. 打开浏览器，输入地址：localhost:8081