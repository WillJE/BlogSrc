---
title: "vmvare虚拟机centos网络配置"
date: 2018-05-28T20:55:29+08:00
toc: true
isCJKLanguage: true
tags: 
  - linux
  - vmvare
---

## 第一步：重置虚拟网络设置

VMWARE->编辑->虚拟网络编辑器->  还原默认设置

![img](vmware虚拟机centos7网络配置.assets/13827699-31c7d6e0661ff85c.png)

## NAT设置

记住： 子网掩码和网关IP。 还原后的默认值即可以

![img](vmware虚拟机centos7网络配置.assets/13827699-06c70140c9433841.png)

![img](vmware虚拟机centos7网络配置.assets/13827699-89c6b35f707e25c8.png)

## 设置静态IP

`vi /etc/sysconfig/network-scripts/ifcfg-ens33`
 `ifcfg-ens33` 这个名字，每个人的电脑网卡不一样，可以从ifconfig 查看到。

![img](vmware虚拟机centos7网络配置.assets/13827699-b2990bf3b6f681e3.png)



![img](vmware虚拟机centos7网络配置.assets/13827699-ad81df40ae6b8f6b.png)

这里还要设置DNS，直接取物理机的DNS即可；通过

```shell
ifconfig /all
```

![image-20210614195506122](vmware虚拟机centos7网络配置.assets/image-20210614195506122.png)

重启网络服务

```shell
systemctl restart network
```

