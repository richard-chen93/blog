---
title: "使用ansible批量管理windows服务器"
date: 2020-11-13T21:27:02+08:00
---

# 使用ansible批量管理windows服务器

## 前提
* windows被控端防火墙信任规则，允许5985端口通过。
* 对于旧版本windows 服务器需要
安装Framework 3.0+
更改powershell策略为remotesigned
升级PowerShell至3.0+
设置Windows远端管理，英文全称WS-Management（WinRM）




## windows被控端设置：
```
get-executionpolicy
set-executionpolicy remotesigned

winrm quickconfig -force
winrm enumerate winrm/config/listener
winrm e winrm/config/listener
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```
#### 命令解释：
* 0.打开服务器运行脚本功能：
* 1 winrm service 默认都是未启用的状态，先查看状态；如无返回信息，则是没有启动；如果没启动，则打开 计算机管理>服务：启用 WRM服务 并设置为自动运行
* 2 针对winrm service 进行基础配置：
* 3 查看winrm service listener:
* 4 为winrm service 配置auth:
* 5 为winrm service 配置加密方式为允许非加密：
* 6 至此，winrm service 已经启用，可以正常使用；但是步骤4和5在windows重启后会失效，大概3分钟后会恢复，因为winrm服务默认设置为延迟启动。


## linux控制端设置：
```
yum -y install ansible
yum -y install python-pip
pip install --upgrade pip --trusted-host 10.193.194.101
pip install pywinrm --trusted-host 10.193.200.6
python -m pip install paramiko PyYAML Jinja2 httplib2 six
```
## linux控制端添加被控主机清单，运行playbook剧本操作被控主机
```
vim /etc/ansible/hosts
[Win_server]
192.168.1.105 ansible_ssh_user="Administrator" ansible_ssh_pass="123456" ansible_ssh_port=5985 ansible_connection="winrm" ansible_winrm_server_cert_validation=ignore
```
```
ansible tserver -m win_ping

vim /root/test.yml

---
- hosts: tserver
  tasks:
    - name: push scripts
      win_copy : src=/root/config_disk.ps1 dest=C:\\config_disk.ps1
      remote_user: Administrator
    - name: run scripts
      win_shell : C:\config_disk.ps1
      remote_user: Administrator
```

## 其他备注
* vmwar虚拟机模板策略中，设置windows策略时，以下两条命令无效：
```
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```