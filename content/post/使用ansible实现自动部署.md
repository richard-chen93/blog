---
title: "使用ansible实现自动部署"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-05-25T10:36:14+08:00
draft: false
---



# 1、角色roles

一条命令将多个角色的目录创建好：

```
mkdir -p roles/{nginx,mysql,kafka,es,as,zk,tomcat,kibana,prometheus}/{files,handlers,tasks,templates,vars}
```

```
touch roles/{nginx,mysql,kafka,es,as,zk,tomcat,kibana,prometheus}/{files,handlers,tasks,templates,vars}/main.yml
```

