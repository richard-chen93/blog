---
title: "Nginx使用教程"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2022-04-21T11:47:28+08:00
draft: false
---

# 1、准备nginx环境

使用docker准备4台nginx容器，nginx做反向代理，nginx1-3做静态web服务器



```
docker run -itd --net host --name nginx  -p 80:80 \
-v /data/docker/nginx/conf/vhost:/etc/nginx/conf.d:rw \
-v /home/admin/nginx/logs:/var/log/nginx:rw \
-v /home/admin/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:rw \
-v /home/admin/nginx/html:/etc/nginx/html:rw \
nginx


docker run -itd --net host --name nginx-1  -p 8001:8001 \
-v /data/docker/nginx/conf/vhost:/etc/nginx/conf.d:rw \
-v /home/admin/nginx-1/logs:/var/log/nginx:rw \
-v /home/admin/nginx-1/conf/nginx.conf:/etc/nginx/nginx.conf:rw \
-v /home/admin/nginx-1/html:/etc/nginx/html:rw \
nginx

docker run -itd --net host --name nginx-2  -p 8002:8002 \
-v /data/docker/nginx/conf/vhost:/etc/nginx/conf.d:rw \
-v /home/admin/nginx-2/logs:/var/log/nginx:rw \
-v /home/admin/nginx-2/conf/nginx.conf:/etc/nginx/nginx.conf:rw \
-v /home/admin/nginx-2/html:/etc/nginx/html:rw \
nginx


docker run -itd --net host --name nginx-3  -p 8003:8003 \
-v /data/docker/nginx/conf/vhost:/etc/nginx/conf.d:rw \
-v /home/admin/nginx-3/logs:/var/log/nginx:rw \
-v /home/admin/nginx-3/conf/nginx.conf:/etc/nginx/nginx.conf:rw \
-v /home/admin/nginx-3/html:/etc/nginx/html:rw \
nginx


```



# 2、搭建反向代理实现负载均衡

```

#轮询
upstream mycluster {
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

#权重
upstream mycluster {
    server 127.0.0.1:8001 weight=1;
    server 127.0.0.1:8002 weight=1;
    server 127.0.0.1:8003 weight=10;
}

#ip 哈希
upstream mycluster {
    ip_hash;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

worker_processes  1;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

upstream mycluster {
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}
    server {
        listen       80;
        server_name  localhost;
        location / {
            proxy_set_header  Host  $host;
            proxy_set_header  X-Real-IP  $remote_addr;
            proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;

            proxy_pass http://mycluster;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```

