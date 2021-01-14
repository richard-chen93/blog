---
title: "Ceph 12.2"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-01-14T11:18:09+08:00
draft: false
---

## 一、主机规划

| 主机名称 |      系统      |     IP      |    配置    |
| :------: | :------------: | :---------: | :--------: |
|    s7    | CentOS7.6.1810 | 10.10.10.47 | 1C1G50G+5G |
|    s8    | CentOS7.6.1810 | 10.10.10.48 | 1C1G50G+5G |
|    s9    | CentOS7.6.1810 | 10.10.10.49 | 1C1G50G+5G |

磁盘规划

50G系统盘，5G磁盘为OSD

## 二、环境准备

环境准备好，避免踩坑！



4台机器，s10为ceph-deploy。

s7 s8 s9为3个node，拥有空闲磁盘sdb，5G

### 1、时间同步

s7作为ntp服务器，s8-10作为客户端

```bash
sudo yum -y install ntp ntpdate
timedatectl set-timezone Asia/Shanghai
```

#### 1.s7 节点配置

```bash
sudo vim /etc/ntp.conf


restrict 10.3.3.7 mask 255.255.255.0 nomodify notrap  #配置集群的IP段

server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10

sudo systemctl enable ntpd
sudo systemctl restart ntpd
sudo systemctl status ntpd

ntpstat
ntpq -p
date
```

#### 2.其他节点配置

```bash
sudo vim /etc/ntp.conf


restrict 10.3.3.7 mask 255.255.255.0 nomodify notrap #IP为node1的ip地址
server  10.3.3.7     # #IP为node1的ip地址

sudo systemctl enable ntpd
sudo systemctl restart ntpd
sudo systemctl status ntpd

ntpstat
ntpq -p
date
```



### 2、ssh免密登录和sudo无需密码权限

s10 需要使用cephuser用户ssh免密登录3个node。

* 4台机器创建cephuser用户。用户名 “ceph” 保留给了 Ceph 守护进程。如果 Ceph 节点上已经有了 “ceph” 用户，升级前必须先删掉这个用户。

```
 sudo useradd cephuser ; echo cephuser | sudo passwd --stdin cephuser
```

* 4台机器设定cephuser用户无密码sudo权限

```
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
sudo chmod 0440 /etc/sudoers.d/cephuser
```

* 在S10上使用cephuser用户执行ssh免密登录配置脚本sshops-init.sh "s7,s8,s9,s10"



### 3、在4台机器上配置ceph 的yum源，安装依赖包

* yum源

  ```bash
  sudo vi /etc/yum.repos.d/ceph.repo
  ```

  把如下内容粘帖进去，保存到 /etc/yum.repos.d/ceph.repo 文件中。

  ```js
  cat > /etc/yum.repos.d/ceph.repo <<EOF
  [ceph-luminous-noarch]
  name = ceph-luminous-noarch
  baseurl = https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-luminous/el7/noarch/
  enabled = 1
  gpgcheck = 0
  gkgkey = http://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc
  [ceph-luminous-x64]
  name = ceph-luminous-x64
  baseurl = https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-luminous/el7/x86_64/
  enabled = 1
  gpgcheck = 0
  gkgkey = http://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc
  EOF
  sudo yum makecache
  ```

  

  

* 安装pip包：

```
wget https://files.pythonhosted.org/packages/5f/ad/1fde06877a8d7d5c9b60eff7de2d452f639916ae1d48f0b8f97bf97e570a/distribute-0.7.3.zip
sudo yum -y install unzip
unzip distribute-0.7.3.zip
cd distribute-0.7.3
sudo python setup.py install
```

* 安装rpm包：

```
sudo yum -y install deltarpm
```



## 三、Ceph部署

使用`ceph-deploy`工具部署

### 3.1 使用国内源

```shell
export CEPH_DEPLOY_REPO_URL=http://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-luminous/el7
export CEPH_DEPLOY_GPG_URL=http://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc
```



### 3.2 安装`ceph-deploy`

ceph安装过程中依赖部分epel软件源

```shell
yum -y install epel-release
# 使用国内epel源
sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!http://mirrors\.tuna!https://mirrors.tuna!g' \
    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
yum -y install ceph-deploy
```



### 3.3 创建工作目录

```bash
mkdir my-cluster
cd my-cluster
```



### 3.4 创建`ceph`集群，部署新的`monitor`节点

```bash
ceph-deploy new s7 s8 s9
```



### 3.5 修改配置文件

增加`public_network`和`cluster_network`配置

```bash
vim ceph.conf
...
public_network = 10.10.10.0/24
cluster_network = 10.10.10.0/24
```



### 3.6 安装Ceph到各个节点

需要指定版本，不指定默认安装最新的版本

```bash
ceph-deploy install --release luminous s7 s8 s9
```



### 3.7 查看ceph版本

```bash
ceph --version
ceph version 12.2.13 (584a20eb0237c657dc0567da126be145106aa47e) luminous (stable)
```



### 3.8 获取密钥key，会在my-cluster目录下生成几个key

```bash
ceph-deploy mon create-initial
```



### 3.9 分发key

```bash
ceph-deploy admin s7 s8 s9
```



### 3.10 初始化磁盘

```bash
ceph-deploy osd create s7 --data /dev/vdb
ceph-deploy osd create s8 --data /dev/vdb
ceph-deploy osd create s9 --data /dev/vdb
```



### 3.11 查看osd设备列表

```bash
ceph osd tree
ID CLASS WEIGHT  TYPE NAME           STATUS REWEIGHT PRI-AFF
-1       0.58589 root default
-3       0.19530     host s7
 0   hdd 0.19530         osd.0           up  1.00000 1.00000
-5       0.19530     host s8
 1   hdd 0.19530         osd.1           up  1.00000 1.00000
-7       0.19530     host s9
 2   hdd 0.19530         osd.2           up  1.00000 1.00000
```

### 3.12 给admin key赋权限

```bash
chmod +r /etc/ceph/ceph.client.admin.keyring
```



### 3.13 创建ceph 管理进程服务

```bash
ceph-deploy mgr create s7 s8 s9
```



### 3.14 检查健康状况

```bash
ceph health
HEALTH_OK
```



## 四、Ceph块存储

### 4.1 创建存储池

```bash
rados mkpool rbd
successfully created pool rbd
```



### 4.2 创建块设备

```bash
rbd create rbd1 --size 1024
```



### 4.3 查看创建的rbd

```bash
rbd list
rbd1

# 查看rbd细节
rbd --image rbd1 info
rbd image 'rbd1':
	size 1GiB in 256 objects
	order 22 (4MiB objects)
	block_name_prefix: rbd_data.103d6b8b4567
	format: 2
	features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
	flags:
	create_timestamp: Sat Jun 20 21:17:50 2020
```



### 4.4 映射到磁盘

```bash
rbd feature disable rbd1 object-map fast-diff deep-flatten
sudo rbd map rbd/rbd1
/dev/rbd0

5# 格式化磁盘
sudo mkfs.xfs /dev/rbd0
# 挂载
sudo mount /dev/rbd0 /opt
```



### 4.5 删除块设备

```bash
rbd rm rbd1
Removing image: 100% complete...done.
```



### 4.6 删除存储池

默认情况下mon节点不允许删除pool

```bash
rados rmpool rbd rbd --yes-i-really-really-mean-it
Check your monitor configuration - `mon allow pool delete` is set to false by default, change it to true to allow deletion of pools
# 修改ceph.conf
vim /etc/ceph/ceph.conf
...
mon_allow_pool_delete = true

# 重启ceph-mon.target
systemctl restart ceph-mon.target
```



再次删除pool

```bash
rados rmpool rbd rbd --yes-i-really-really-mean-it
successfully deleted pool rbd
```



## 五、Ceph对象存储

### 5.1 创建对象存储网关

```bash
1ceph-deploy rgw create s7 s8 s9
```



创建完成之后默认监听7480端口。然后可以使用负载均衡的方式转发到后端服务。

### 5.2 创建s3用户

```bash
radosgw-admin user create --uid=admin --display-name=admin --email=admin@example.com
{
    "user_id": "admin",
    "display_name": "admin",
    "email": "admin@example.com",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "admin",
            "access_key": "837H72BJ7KJ4ZO7Q7PJL",
            "secret_key": "GYgDMcqxFI68A5K10sWlA2GF9cknohFPqUb6499b"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw"
}
```



记住用户的 `access_key`和`secret_key`，后面需要用到这些信息用于访问s3服务。

### 5.3 删除用户

```bash
1radosgw-admin user rm --uid=admin
```



### 5.4 使用s3cmd客户端访问

安装s3cmd

```bash
1yum -y install s3cmd
```



配置s3客户端

```bash
s3cmd --configure \
        --access_key=837H72BJ7KJ4ZO7Q7PJL \
        --secret_key=GYgDMcqxFI68A5K10sWlA2GF9cknohFPqUb6499b \
        --host=10.10.10.47:7480 \
        --host-bucket=test-bucket \
        --no-ssl

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key [837H72BJ7KJ4ZO7Q7PJL]:
Secret Key [GYgDMcqxFI68A5K10sWlA2GF9cknohFPqUb6499b]:
Default Region [US]:

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [10.10.10.47:7480]:

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [test-bucket]:

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program [/usr/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [No]:

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't connect to S3 directly
HTTP Proxy server name:

New settings:
  Access Key: 837H72BJ7KJ4ZO7Q7PJL
  Secret Key: GYgDMcqxFI68A5K10sWlA2GF9cknohFPqUb6499b
  Default Region: US
  S3 Endpoint: 10.10.10.47:7480
  DNS-style bucket+hostname:port template for accessing a bucket: test-bucket
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] y
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Not configured. Never mind.

Save settings? [y/N] y
Configuration saved to '/root/.s3cfg'
```



创建bucket

```bash
s3cmd mb s3://test-bucket
Bucket 's3://test-bucket/' created
```



查看bucket

```bash
s3cmd ls
2020-06-20 14:54  s3://test-bucket
```



上传文件到bucket

```bash
s3cmd put ceph.conf s3://test-bucket
upload: 'ceph.conf' -> 's3://test-bucket/ceph.conf'  [1 of 1]
 340 of 340   100% in    2s   163.23 B/s  done
```



查看bucket中的文件

```bash
s3cmd ls s3://test-bucket
2020-06-20 14:55          340  s3://test-bucket/ceph.conf
```



更多s3cmd的操作可使用`s3cmd -h`查看或者通过访问[s3cmd官网](http://s3tools.org/)查看。

## 六、Ceph-Dashboard

Ceph 的监控可视化界面方案很多—-grafana、Kraken。但是从Luminous开始，Ceph 提供了原生的Dashboard功能，通过Dashboard可以获取Ceph集群的各种基本状态信息。

### 6.1 配置Dashboard

```bash
# 开启mgr功能
ceph mgr module enable dashboard

# 生成并安装自签名的证书
ceph dashboard create-self-signed-cert  

# 创建一个dashboard登录用户名密码
ceph dashboard ac-user-create guest 1q2w3e4r administrator 
```



### 6.2 修改默认配置

```bash
# 指定集群dashboard的访问端口
ceph config-key set mgr/dashboard/server_port 7000

# 指定集群 dashboard的访问IP
ceph config-key set mgr/dashboard/server_addr $IP 
```



### 6.3 开启Object Gateway管理功能

```bash
# 创建rgw用户
radosgw-admin user info --uid=admin

# 提供Dashboard证书
ceph dashboard set-rgw-api-access-key $access_key
ceph dashboard set-rgw-api-secret-key $secret_key

# 配置rgw主机名和端口
ceph dashboard set-rgw-api-host 192.168.0.251
```



了解更多`/usr/lib64/ceph/mgr/dashboard/README.rst`

- **原文作者：**[黄忠德](https://huangzhongde.cn/)
- **原文链接：**https://huangzhongde.cn/post/Linux/Ceph_luminous_deploy/
- **版权声明：**本作品采用[知识共享署名-非商业性使用-禁止演绎 4.0 国际许可协议](https://creativecommons.org/licenses/by-nc-nd/4.0/)进行许可，非商业转载请注明出处（作者，原文链接），商业转载请联系作者获得授权。



## See Also

- [Ceph-10.2.10安装配置](https://huangzhongde.cn/post/ceph-10-install/)
- [Redis高可用之redis-cluster集群](https://huangzhongde.cn/post/Linux/Redis_HA_cluster_mode/)
- [Redis高可用之哨兵模式](https://huangzhongde.cn/post/Linux/Redis_HA_sentinel_mode/)
- [使用HAProxy+Pacemaker部署RabbitMQ高可用集群](https://huangzhongde.cn/post/Linux/RabbitMQ_HA_with_haproxy_and_pacemaker/)
- [MariaDB HA之Galera集群](https://huangzhongde.cn/post/Linux/MariaDB_HA_Galera_with_haproxy_and_pacemaker/)