---
title: "Harbor搭建与使用"
date: 2020-11-13T22:48:36+08:00
tags: [ "technology" ]
categories: [ "technology" ]
---

## 安装
harbor支持k8s的helm安装和本地安装，这里使用本地安装。
### 1.	前置条件
 1.1安装docker并运行
     yum install docker
     systemcal start docker
     systemctl enable docker
### 2.	安装docker-compost
  2.1安装依赖包
2.1 yum install -y py-pip  python-dev libffi-dev openssl-dev gcc libc-dev make

2.2  curl	-L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

2.3  chmod +x /usr/local/bin/docker-compose


### 3.	下载安装包
https://github.com/goharbor/harbor/releases
tar xf harbor-offline-installer-v1.10.0.tgz

### 4.	修改配置文件
harbor.cfg
4.1修改hostname选项
hostname = A.B.C.D  # 写你自己的网址或IP，公网访问要写公网IP
4.2支持Http 访问
customize_crt = false  #新版中可能没有这项
注释掉https
4.3运行
4.3.1修改完配置文件后，运行 ./prepare，它会哪所配置文件修改一文件
 如果是offline版的目录中有打包的image文件
docker load -i harbor.v1.10.0.tar.gz
4.3.2运行 ./install.sh
运行成功，docker container ls 查看，可以看到服务已经起来了。
 docker container ls

```
CONTAINER ID        IMAGE                                                     COMMAND                  CREATED             STATUS                    PORTS                       NAMES
da7981437516        goharbor/harbor-jobservice:v1.10.0                        "/harbor/harbor_jobs…"   39 seconds ago      Up 35 seconds (healthy)                               harbor-jobservice
534f615a8b49        goharbor/nginx-photon:v1.10.0                             "nginx -g 'daemon of…"   39 seconds ago      Up 34 seconds (healthy)   0.0.0.0:80->8080/tcp        nginx
6115684ab10b        goharbor/harbor-core:v1.10.0                              "/harbor/harbor_core"    40 seconds ago      Up 38 seconds (healthy)                               harbor-core
db6b18042976        goharbor/harbor-registryctl:v1.10.0                       "/home/harbor/start.…"   43 seconds ago      Up 40 seconds (healthy)                               registryctl
63c70e50cd7f        goharbor/registry-photon:v2.7.1-patch-2819-2553-v1.10.0   "/home/harbor/entryp…"   43 seconds ago      Up 39 seconds (healthy)   5000/tcp                    registry
46e4a59d052b        goharbor/harbor-db:v1.10.0                                "/docker-entrypoint.…"   43 seconds ago      Up 40 seconds (healthy)   5432/tcp                    harbor-db
4ced2cd0ee8f        goharbor/harbor-portal:v1.10.0                            "nginx -g 'daemon of…"   43 seconds ago      Up 39 seconds (healthy)   8080/tcp                    harbor-portal
691ab7bfb4bf        goharbor/redis-photon:v1.10.0                             "redis-server /etc/r…"   43 seconds ago      Up 40 seconds (healthy)   6379/tcp                    redis
3431bbc1606e        goharbor/harbor-log:v1.10.0                               "/bin/sh -c /usr/loc…"   45 seconds ago      Up 42 seconds (healthy)   127.0.0.1:1514->10514/tcp   harbor-log
```

## 常用管理命令
•	停止服务： docker-compose stop
•	开始服务： docker-compose start
Web登入
http://192.168.3.200
默认账号admin  密码Harbor12345
通过安装包中的harbor.yml
修改docker配置
docker 默认是按 https 请求的，由于我搭的私有库是 http 的，所以需要修改 docker 配置，将信任的库的地址写上
修改文件 /etc/docker/daemon.json
{
  "insecure-registries": [
    "192.168.3.200"
  ]
}
systemctl restart docker
制作镜像
将 mongo 制作成一个私有镜像， mongo 为我之前从 docker hub 上拉取的镜像。
docker tag mongo A.B.C.D/ainirobot/nebulae_mongo:0.0.1

## 上传镜像
1. 先登陆私有库
docker login A.B.C.D
2.	PUSH
docker push A.B.C.D/ainirobot/nebulae_mongo:0.0.1