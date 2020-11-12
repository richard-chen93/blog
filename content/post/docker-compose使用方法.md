---
title: "Docker Compose"
date: 2020-10-29T18:40:08+08:00

---

docker-compose

1.安装扩展源

sudo yum -y install epel-release

2.安装python-pip模块

sudo yum install python-pip

3.查看docker-compose版本

docker-compose version

# 提示未找到命令

4.通过命令进行安装

cd /usr/local/bin/

wget https://github.com/docker/compose/releases/download/1.14.0-rc2/docker-compose-Linux-x86_64

rename docker-compose-Linux-x86_64 docker-compose docker-compose-Linux-x86_64

chmod +x /usr/local/bin/docker-compose

5.再通过docker-compose version命令进行查看
