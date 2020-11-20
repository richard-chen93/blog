---
title: "ssh"
date: 2020-10-29T18:43:21+08:00

---

# linux更改 ssh 私钥 Passphrase
```
$ cd ~/.ssh
$ ssh-keygen -f id_rsa -p
```


# ssh连接速度慢
修改sshd_config文件：
UseDNS no
GSSAPIAuthentication no


# 实现免密登陆
1、在客户端生成密钥对,默认在~/.ssh文件夹下
ssh-keygen
2、将公钥上传到服务器
ssh-copy-id root@10.0.0.1
3、验证。

