---
title: "Vim常见用法和配置"
date: 2020-11-21T22:18:50+08:00
tags: [ "technology" ]
categories: [ "technology" ]
---

## vim tab改为4个空格
```
cat >> /etc/vimrc << EOF
set ts=4
set expandtab
set autoindent
EOF
```