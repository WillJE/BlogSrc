---
title: "Centos安装Nodejs和Python"
date: 2021-10-30T20:55:29+08:00
toc: true
isCJKLanguage: true
tags: 
  - Centos
  - Nodejs
  - Python
---

## 一、node.js安装

首先下载并解压安装包：
注:历史版本可自行去[https://nodejs.org/dist/](https://link.segmentfault.com/?url=https%3A%2F%2Fnodejs.org%2Fdist%2F)下载

```bash
$ wget https://npm.taobao.org/mirrors/node/v14.5.0/node-v14.5.0-linux-x64.tar.gz
$ tar -xzf node-v14.5.0-linux-x64.tar.gz
```

在`/usr/local/bin`中建立软连接方便我们在全局快捷运行
注：因为我得nodejs包是在`/data/bin/nodejs`中，各位看官请根据自己解压得路接自行更改

```bash
# 以下是把bin中所有都建立软连接
$ ln -s /data/bin/nodejs/default/bin/* /usr/local/bin/
```

查看`node.js`是否安装成功

```bash
$ node -v
$ npm -v
```

## 二、修改源

```bash
#查看当前镜像源
$ npm config get registry
#设置淘宝镜像源
$ npm config set registry=https://registry.npm.taobao.org
```

## 三、安装Python

先本地下载安装包，https://www.python.org/downloads/source/，然后上传到服务器上

### 1. 我们先看看现有的 python2在哪里

```bash
[root@lidan /]# whereis python
python: /usr/bin/python /usr/bin/python2.7 /usr/bin/python.bak /usr/lib/python2.7 /usr/lib64/python2.7 /etc/python /usr/include/python2.7 /usr/share/man/man1/python.1.gz
[root@lidan bin]# ll python*
lrwxrwxrwx. 1 root root    9 5月  27 2016 python2 -> python2.7
-rwxr-xr-x. 1 root root 7136 11月 20 2015 python2.7
lrwxrwxrwx. 1 root root    7 5月  27 2016 python.bak -> python2
```

### 2. 接下来我们要安装编译 Python3的相关包

```bash
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel
```

这里面有一个包很关键`libffi-devel`，因为只有3.7才会用到这个包，如果不安装这个包的话，在 make 阶段会出现如下的报错：

```bash
# ModuleNotFoundError: No module named '_ctypes'
```

### 3. 安装pip，因为 CentOs 是没有 pip 的。

```bash
#运行这个命令添加epel扩展源 
yum -y install epel-release 
#安装pip 
yum install python-pip
```

### 4. 可以用 python 安装一下 wget

```bash
pip install wget
```

### 5. 我们可以下载 python3.7的源码包了

```bash
wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
#解压缩
tar -zxvf Python-3.7.0.tgz

#进入解压后的目录，依次执行下面命令进行手动编译
./configure prefix=/usr/local/python3 
make && make install
```

如果最后没提示出错，就代表正确安装了，在/usr/local/目录下就会有python3目录

### 6. 添加软链接

```bash
#添加python3的软链接 
ln -s /usr/local/python3/bin/python3.7 /usr/bin/python3
#添加 pip3 的软链接 
ln -s /usr/local/python3/bin/pip3.7 /usr/bin/pip3
#测试是否安装成功了 
python3 -V
```

