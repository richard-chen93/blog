---
title: "安装部署prometheus"
date: 2020-11-20T13:24:36+08:00
tags: [ "technology" ]
categories: [ "technology" ]
---

1sssssss

## 环境准备

* 3台机器centos7，1台prometheus服务器，主机名S0，1台grafana服务器S1，1台客户端S2
* prometheus版本为prometheus-2.5.0.linux-amd64
* 3台机器时间同步好
```
yum install ntpdate -y
ntpdate cn.ntp.org.cn
timedatectl set-timezone Asia/Shanghai
date
```

## 在S0上安装Prometheus并运行
```
tar xf prometheus-2.5.0.linux-amd64.tar.gz
mv prometheus-2.5.0.linux-amd64 /usr/local/prometheus
cd /usr/local/prometheus
./prometheus --config.file="/usr/local/prometheus/prometheus.yml" &
ss -tunpl | grep 9090
```
若9090端口被Prometheus程序占用，说明启动成功，浏览器打开http://10.3.3.30:9090
http://10.3.3.30:9090/metrics可看到所有监控到的数据

## 在被监控主机S2上安装node-exporter组件并运行
```
tar xf node_exporter-0.16.0.linux-amd64.tar.gz
mv node_exporter-0.16.0.linux-amd64 /usr/local/node_exporter
cd /usr/local/node_exporter/
nohup ./node_exporter &
ss -tunpl | grep 9090
```
使用nohup后即使终端关闭，node_exporter程序也会继续运行
浏览器打开http://10.3.3.30:9100
http://10.3.3.32:9100/metrics可看到所有收集到的数据

## 让Prometheus服务器拉取node节点信息
```
vim /usr/local/prometheus/prometheus.yml
  - job_name: 'node01'
    static_configs:
    - targets: ['10.3.3.32:9100']
```
在文件末尾添加节点信息

## 重启Prometheus服务并查看节点信息
```
pkill prometheus
./prometheus --config.file="/usr/local/prometheus/prometheus.yml" &
```
## 添加mysql监控
在s2上安装启动mariadb，为监控系统添加账户mysql_monitor,密码123,授予权限。
安装使用mysqld_exporter组件,放到/usr/local/mysqld_exporter文件夹下面。
```
mysql
grant select,replication client,process ON *.* to 'mysql_monitor'@'localhost' identified by '123';
flush privileges;
exit;
```
进入/usr/local/mysqld_exporter/, 修改mysql_exporter配置，添加mysql用户密码。然后启动mysql_exporter
```
vim ./.my.cnf
[client]
user=mysql_monitor
password=123
nohup ./mysqld_exporter --config.my-cnf=/usr/local/mysqld_exporter/.my.cnf &
lsof -i:9104
```
修改Prometheus服务器配置文件，添加mysql监控项。在主配置文件最后再添加下面三行：
```
  - job_name: 'nodeS2_mariadb'
    static_configs:
    - targets: ['10.3.3.32:9104']
```

## 安装grafana服务器软件
在s1上安装：
```
wget https://dl.grafana.com/oss/release/grafana-5.3.4-1.x86_64.rpm
sudo rpm -i --nodeps grafana-5.3.4-1.x86_64.rpm
systemctl enable grafana-server
systemctl start grafana-server
ss -tunpl | grep 3000
```
浏览器打开http://10.3.3.31:3000 admin/admin
登录grafana后添加dashboard、编辑、选择数据源即可

## 添加grafana图形监控模板：
### 下载图形监控模板
https://github.com/percona/grafana-dashboards
下载后压缩包里面dashboards文件夹里面的所有jason文件就是图形监控模板文件。
在grafana中导入特点的jason文件。
### 设置数据库源
grafana监控界面里，configuration-data source，之前添加的数据源名称必须改为：Prometheus。然后mysql的监控就可以正常展示

## 配置alertmanager
Alertmanager 部署
普罗米修斯将数据采集和告警通知分成了两个模块。报警规则配置在普罗米修斯上（警报规则文件），然后发送报警信息到 AlertManger，AlertManager来管理这些报警信息，同时提供了聚合分组、告警抑制等高级功能，还支持通过 Email、WebHook 等多种方式发送告警消息提示。
（1）解压【alertmanager-0.21.0.linux-amd64.zip】压缩文件到指定目录
（2）进入目录，修改 alertmanager.yml 配置文件，该文件用于配置告警通知，这里提供的是163邮件的通知的样例
•	你需要在这里配置上邮箱的 SMTP 服务器配置


•	在这里配置上告警通知的接收人。mail-error 表示严重等级的告警通知（比如服务宕机），mail-warning 表示紧急等级的告警通知（比如内存使用快满了）


（3）默认端口为 9093，可通过修改sh脚本修改端口

（4）如果修改了端口，需要在普罗米修斯的配置文件（prometheus.yml）中对应修改端口，然后重启普罗米修斯，使得普罗米修斯和 Alertmanager 可以正常通信。普罗米修斯prometheus.yml对应的alertmanager设置项为：
```
# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['10.3.3.31:9093']

rule_files:
  # 告警规则配置文件位置
  - "rules/*.yml"

  - job_name: 'alertmanager'
    static_configs:
      - targets: ['172.20.32.218:9093']

./promtool check config prometheus.yml
```



