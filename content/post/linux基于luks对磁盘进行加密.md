---
title: "Linux基于luks对磁盘进行加密"
description: "this is discr"
tags: [ "technology" ]
categories: [ "technology" ]
date: 2021-07-05T17:49:07+08:00
draft: false
---





LUKS(Linux Unified Key Setup)为Linux硬盘加密提供了一种标准，它不仅能通用于不同的Linux发行版本，还支持多用户/口令。因为它的加密密钥独立于口令，所以如果口令失密，我们可以迅速改变口令而无需重新加密真个硬盘。通过提供一个标准的磁盘上的格式，它不仅方便之间分布的兼容性，而且还提供了多个用户密码的安全管理。必须首先对加密的卷进行解密,才能挂载其中的文件系统。



### 流程

**如果待加密的分区已经有数据了，那么请先备份。**
如果已经挂载了，也需要先卸载。

1. 格式化加密分区
2. 分区映射
3. 创建文件系统
4. 挂载

 
工具：cryptsetup（如果没有安装执行 yum install -y cryptsetup）

```
[root@node1 ~]# cryptsetup --help
cryptsetup 1.7.4
用法: cryptsetup [选项…] <动作> <动作特定参数>
 --version 打印软件包版本
 -v, --verbose 显示更详细的错误信息
 --debug 显示调试信息
 -c, --cipher=STRING 用于加密磁盘的密文（参见 /proc/crypto）
 -h, --hash=STRING 用于从密码创建加密密钥的哈希值
 -y, --verify-passphrase 两次询问密码以进行验证
 -d, --key-file=STRING 从文件读取密钥。
 --master-key-file=STRING 从文件读取卷（主）密钥。
 --dump-master-key 转储卷（主）密钥而不是键槽信息。
 -s, --key-size=位 加密密钥大小
 -l, --keyfile-size=字节 限制从密钥文件读取
 --keyfile-offset=字节 要从密钥文件跳过的字节数
 --new-keyfile-size=字节 限制从新增密钥文件的读取
 --new-keyfile-offset=字节 要从新增密钥文件跳过的字节数
 -S, --key-slot=INT 新密钥的槽号（默认为第一个可用的）
 -b, --size=扇区 设备大小
 -o, --offset=扇区 后端设备的起始偏移量
 -p, --skip=扇区 从开头要跳过的加密数据扇区数量
 -r, --readonly 创建只读映射
 -i, --iter-time=毫秒 LUKS 默认 PBKDF2 迭代时间（毫秒）
 -q, --batch-mode 不要请求确认
 -t, --timeout=秒 交互式密码提示符超时长度（秒）
 -T, --tries=INT 输入密码的最大重试频率
 --align-payload=扇区 于 <n> 个扇区边界处对其载荷数据 - 供 luks 格式用
 --header-backup-file=STRING 带有 LUKS 数据头和密钥槽备份的文件。
 --use-random 使用 /dev/random 生成卷密钥。
 --use-urandom 使用 /dev/urandom 生成卷密钥。
 --shared 与另一个不重合的加密段共享设备。
 --uuid=STRING 设备使用的 UUID 已占用。
 --allow-discards 允许设备的 discard（或称 TRIM）请求。
 --header=STRING 带有分离 LUKS 数据头的设备或文件。
 --test-passphrase 不要激活设备，仅检查密码。
 --tcrypt-hidden 使用隐藏数据头（隐藏 TCRYPT 设备）
 --tcrypt-system 设备为系统 TCRYPT 驱动器（带有引导器）。
 --tcrypt-backup 使用备份（次级）TCRYPT 标头。
 --veracrypt 同时扫描 VeraCrypt 兼容的设备。
 -M, --type=STRING 设备元数据类型：luks, 纯粹 (plain), loopaes, tcrypt.
 --force-password 禁用密码质量检查 (如果已启用)。
 --perf-same_cpu_crypt 使用 dm-crypt same_cpu_crypt 性能兼容性选项。
 --perf-submit_from_crypt_cpus 使用 dm-crypt submit_from_crypt_cpus 性能兼容性选项。
帮助选项：
 -?, --help 显示此帮助
 --usage 显示简短用法
<动作> 为其中之一：
 open <设备> [--type <类型>] [<名称>] - 以映射 <名称> 打开设备
 close <名称> - 关闭设备（移除映射）
 resize <名称> - 改变活动设备大小。
 status <名称> - 显示设备状态
 benchmark [--cipher <cipher>] - 测试密文
 repair <设备> - 尝试修复磁盘上的元数据
 erase <设备> - 清空所有密钥槽（移除加密密钥）
 luksFormat <设备> [<新密钥文件>] - 格式化一个 LUKS 设备
 luksAddKey <设备> [<新密钥文件>] - 向 LUKS 设备添加密钥
 luksRemoveKey <设备> [<密钥文件>] - 移除 LUKS 设备中指定的密钥或密钥文件
 luksChangeKey <设备> [<密钥文件>] - 更改 LUKS 设备中指定的密钥或密钥文件
 luksKillSlot <设备> <密钥槽> - 从 LUKS 设备清理标号为 <key slot> 的密钥
 luksUUID <设备> - 输出 LUKS 设备的 UUID（唯一标识符）
 isLuks <设备> - 从 <device> 探测 LUKS 分区标头
 luksDump <设备> - 调出 LUKS 分区信息
 tcryptDump <设备> - 调出 TCRYPT 设备信息
 luksSuspend <设备> - 挂起 LUKS 设备并清除密钥（冻结所有 IO 操作）。
 luksResume <设备> - 恢复已暂停的 LUKS 设备。
 luksHeaderBackup <设备> - 备份 LUKS 设备标头和密钥槽
 luksHeaderRestore <设备> - 恢复 LUKS 设备标头和密钥槽
你亦可使用老的 <动作> 语法别名：
 open: create (plainOpen), luksOpen, loopaesOpen, tcryptOpen
 close: remove (plainClose), luksClose, loopaesClose, tcryptClose
<name> 为要在 /dev/mapper 创建的设备
<device> 为加密设备
<key slot> 为需要更改的 LUKS 密钥槽
<key file> 提供给 luksAddKey 动作的密钥文件
默认集成的密钥和密码参数：
 密钥文件的最大大小：8192kB, 交互式密码的最大长度：512 (字符)
LUKS 的默认 PBKDF2 迭代时间：2000 (毫秒)
默认集成的设备密文参数：
 loop-AES：aes, 256 位密钥
 plain：aes-cbc-essiv:sha256, 密钥：256 位, 密码哈希：ripemd160
 LUKS1：aes-xts-plain64, 密钥：256 bits, LUKS 数据头哈希：sha256, RNG：/dev/urandom
```

### 1. 环境

------

- OS: centos7.6

```

```

### 2. 创建加密分区

------

首先，我们添加一块硬盘/dev/sdb作为测试用，如下：

```
[root@node1 ~]# fdisk -l
磁盘 /dev/sdb：8589 MB, 8589934592 字节，16777216 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘 /dev/sda：8589 MB, 8589934592 字节，16777216 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x000bfe7f
设备 Boot Start End Blocks Id System
/dev/sda1 * 2048 2099199 1048576 83 Linux
/dev/sda2 2099200 16777215 7339008 8e Linux LVM
磁盘 /dev/mapper/centos-root：6652 MB, 6652166144 字节，12992512 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘 /dev/mapper/centos-swap：859 MB, 859832320 字节，1679360 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
```

下来我们格式化加密分区

```
[root@node1 ~]# cryptsetup luksFormat /dev/sdb
WARNING!
========
这将覆盖 /dev/sdb 上的数据，该动作不可取消。
Are you sure? (Type uppercase yes): YES  # 注意这里必须是大写的YES
输入密码：
确认密码：
```

### 5. 利用 key file 加密分区(选项)

------

除了密码之外，还可以选择使用 key file 解密你的硬盘，也就是相当于一个密钥，当然可以也可以只使用 key file 或者同时使用密码与 key file

#### 5.1 生成随机 key file(选项)

------

```
[root@node1 ~]# dd if=/dev/urandom of=/root/enc.key bs=1 count=4096
记录了4096+0 的读入
记录了4096+0 的写出
4096字节(4.1 kB)已复制，0.00967434 秒，423 kB/秒
[root@node1 ~]# ls
anaconda-ks.cfg enc.key kubernetes
```

#### 5.2 添加 key file 作为密码之一(选项)

------

```
[root@node1 ~]# cryptsetup luksAddKey /dev/sdb /root/enc.key
输入任意已存在的密码：
```

### 6. 移除解密密码

------

如果你想使用file key 作为密码，那么可以将刚刚设置的密码删除，反之不用管，直接看第七步
移除普通密码

```
[root@node1 ~]# cryptsetup luksRemoveKey /dev/sdb
输入要移除的密码：
```

移除 key file 密码

```
[root@node1 ~]# cryptsetup luksRemoveKey -d /root/enc.key /dev/sdb
WARNING!
========
这是最后一个密钥槽。设备在清空此密钥后将不可用。
Are you sure? (Type uppercase yes): YES
```

**注意**：千万不要将所有密码移除，至少需要留有一个密码访问设备，移除操作不可撤销

### 7. 分区映射与挂载

------

#### 7.1 分区映射

------

```
[root@node1 ~]# cryptsetup luksOpen /dev/sdb data2
输入 /dev/sdb 的密码：
```

#### 7.2 key file分区映射(选项)

------

```
也可以通过key file做映射
[root@node1 ~]# cryptsetup luksOpen -d /root/enc.key /dev/sdb data2
```

#### 7.3 创建文件系统

------

在挂载使用之前，我们仍然需要对设备创建文件系统才可以使用，可以选择任何你喜欢的文件系统，例如 btrfs，ext4，vfat，ntfs等

```
[root@node1 ~]# mkfs.ext4 /dev/mapper/data2
mke2fs 1.42.9 (28-Dec-2013)
文件系统标签=
OS type: Linux
块大小=4096 (log=2)
分块大小=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
524288 inodes, 2096640 blocks
104832 blocks (5.00%) reserved for the super user
第一个数据块=0
Maximum filesystem blocks=2147483648
64 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
 32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632
Allocating group tables: 完成
正在写入inode表: 完成
Creating journal (32768 blocks): 完成
Writing superblocks and filesystem accounting information: 完成
```

#### 7.4 挂载

------

现在可以像正常分区一样挂载我们的加密分区设备了

```
[root@node1 ~]# mkdir /data2
[root@node1 ~]# mount /dev/mapper/data2 /data2
[root@node1 ~]# df -h
文件系统 容量 已用 可用 已用% 挂载点
/dev/mapper/centos-root 6.2G 1.8G 4.5G 28% /
devtmpfs 4.4G 0 4.4G 0% /dev
tmpfs 4.4G 0 4.4G 0% /dev/shm
tmpfs 4.4G 8.5M 4.4G 1% /run
tmpfs 4.4G 0 4.4G 0% /sys/fs/cgroup
/dev/sda1 1014M 143M 872M 15% /boot
tmpfs 883M 0 883M 0% /run/user/0
/dev/mapper/data2 7.8G 36M 7.3G 1% /data2
```

#### 7.5 卸载挂载点并关闭加密分区

------

```
[root@node1 /]# umount /data2
[root@node1 /]# cryptsetup luksClose data2
```

### 8. 总结

------

在完成整个步骤以后，您现在需要做的就是妥善保管您的加密存储，可采用同样的方式加密多个设备进行备份，因为谁也不能保证这移动设备会不会在什么时候丢掉。

转载至: https://it.baiked.com/linux/2499.html