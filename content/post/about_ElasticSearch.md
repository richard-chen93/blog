---
title: "About_ElasticSearch"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2020-11-24T15:06:06+08:00
draft: false
---

## 下载、校验
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.2.tar.gz
sha1sum elasticsearch-5.0.2.tar.gz 
tar -xzf elasticsearch-5.0.2.tar.gz
cd elasticsearch-5.0.2/ 
./bin/elasticsearch

## 验证
curl localhost:9200

{
  "name" : "Cp8oag6",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "AT69_T_DTp-1qgIJlatQqA",
  "version" : {
    "number" : "5.0.2",
    "build_hash" : "f27399d",
    "build_date" : "2016-03-30T09:51:41.449Z",
    "build_snapshot" : false,
    "lucene_version" : "6.2.1"
  },
  "tagline" : "You Know, for Search"
}


## Running as a daemon

./bin/elasticsearch -d -p pid

## shutdown ES
kill `cat pid`


# kibana 相关
kinaba允许远程访问，这里改localhost为本机ip
#server.host: "10.3.3.30"


