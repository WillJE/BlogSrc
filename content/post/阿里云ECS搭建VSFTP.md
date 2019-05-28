---
title: "阿里云ECS搭建VSFTP"
date: 2019-05-28T11:19:42+08:00
lastmod: 2019-05-28T11:19:42+08:00
draft: false
tags: ["VSFTP"]
categories: ["centos"]
author: "will"

autoCollapseToc: true
contentCopyright: '<a href="https://github.com/gohugoio/hugoBasicExample" rel="noopener" target="_blank">See origin</a>'
---



### 安装VSFTPD

使用yum安装vsftpd

```java
yum install vsftpd
```

如果需要连接其他FTP服务器，则可以安装FTP客户端

```
yum install ftp
```



#### 查看是否安装成功

查看vsftpd服务的状态

```systemctl status vsftpd.service```

开启vsftpd服务systemctl 

```start vsftpd.service```

此时，启动报错：

```
[root@VM_0_2_centos /]# systemctl start vsftpd
Job for vsftpd.service failed because the control process exited with error code. See "systemctl status vsftpd.service" and "journalctl -xe" for details.
```

先查看是否端口占用

```
[root@VM_0_2_centos /]# lsof -i:21
COMMAND     PID USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
pure-ftpd 16235 root    4u  IPv4 1014289      0t0  TCP *:ftp (LISTEN)
pure-ftpd 16235 root    5u  IPv6 1014290      0t0  TCP *:ftp (LISTEN)
//IPv4 ipv6 不能同时listen.
[root@VM_0_2_centos /]# kill -9 16235
[root@VM_0_2_centos /]# lsof -i:21
```

再启动

```
[root@VM_0_2_centos /]# systemctl start vsftpd
[root@VM_0_2_centos /]# systemctl status vsftpd
● vsftpd.service - Vsftpd ftp daemon
   Loaded: loaded (/usr/lib/systemd/system/vsftpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-12-27 15:43:59 CST; 3s ago
  Process: 19444 ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf (code=exited, status=0/SUCCESS)
 Main PID: 19445 (vsftpd)
   CGroup: /system.slice/vsftpd.service
```

此时启动成功

设置vsftpd服务开机自启动

```
systemctl enable vsftpd.service
```



### 添加用户

```
adduser userftp
passwd userftp
```

禁止用户的ssh登陆权限，只运行FTP访问：

```
usermod -s /sbin/nologin userftp
```



### 配置VSFTP

打开配置文件

```
vi /etc/vsftpd/vsftpd.conf
```



关闭匿名访问：

```
anonymous_enable=NO
```

去掉local_enable的注释，修改为开启：

```
local_enable=YES
```

限制用户仅能访问自己的主目录：

```
chroot_local_user=YES
```

设置用户的主目录：（不设置时，默认为用户的家目录/home/userftp）

```
local_root=/data/test
```

重启服务：

```
systemctl restart vsftpd.service
```

### 连接测试

```
ftp 47.98.169.0.22

ftp>pwd
Remode directory:/home/userftp

ftp>bye
221 Goodbye.
```



### 使用ftp工具连接

使用FileZilla连接，输入主机和用户密码后报

```
服务器发回了不可路由的地址,使用服务器地址代替
```

#### 原因

专有网络的ECS系统中，没有公网IP地址，是经NAT与互联网连接，且ECS创建过程中的默认安全组规则没有针对FTP的快捷选项。建议在Linux系统里使用sftp协议替换ftp使用。 



#### 解决

更改Filezilla设置，编辑 - 设置 - 连接-FTP-被动模式，将“使用服务器的外部IP地址来代替”改为“回到主动模式”即可。