---
title: "Docker常用操作"
date: 2020-11-13T23:07:07+08:00
tags: [ "technology" ]
categories: [ "technology" ]
---
## docker以host模式启动容器，并指定名称和共享盘
docker container run -it --name mhost --privileged=true --net=host -p 8000:80 -v /mhost_volume:/data/ {docker image id}

## 进入容器
[root@localhost ~]# docker exec -it <CONTAINER ID> bash
进入后发现没有ifconfig，直接yum安装
ifconfig报错
yum install -y net-tools

## 常用参数含义

docker ps -a --no-trunc 查看容器的启动命令。

-td 后台运行。

- it ：互动模式登录容器，并分配一个终端
- name ：指定容器名称
- p ：小p指定容器的80端口映射为宿主机的7879端口。
- rm ：表示退出容器时，容器一起删除
- v ：指定volumes，格式为： 宿主机共享目录：容器目录  ，这样宿主机的/ken目录就被挂载到了容器的/data/目录下了
-- privileged=true: 使共享的目录可以访问

## 将容器打包成镜像
docker commit --change='CMD ["/auto_sshd.sh"]' -c "EXPOSE 22" test-centos1 centos_sshd:7.0
命令注释： --change : 将后期使用此镜像运行容器时的命令参数、开放的容器端口提前设置好。

## 打包镜像到tar包
docker save -o centos7_django_mhost_v1.2.tar  centos7_django_mhost_v1.2

## 解压tar包到image
docker load -i {image_name}.tar



## docker查看、停止、删除容器

$ docker ps // 查看所有正在运行容器 

$ docker stop containerId // containerId 是容器的ID 

$ docker ps -a // 查看所有容器 $ docker ps -a -q // 查看所有容器ID 

$ docker stop $(docker ps -a -q) // stop停止所有容器 

$ docker rm $(docker ps -a -q) //  remove删除所有容器