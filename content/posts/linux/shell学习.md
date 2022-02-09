## 概述

shell是一种解释器，用来

Linux操作系统的核心是kernal（内核）！
当应用程序在执行时，需要调用计算机硬件的cpu,内存等资源！
程序将指令发送给内核执行！
为了防止程序发送一些恶意指令导致损坏内核，在内核和应用程序接口之间，设置一个中间层，称为shell!

![img](shell学习.assets/1075188-20191221111411013-65042932.png)

我们可以通过 cat /etc/shells 查看系统提供的Shell解析器种类

```sh
[damon@hadoop97 ~]$ cat /etc/shells 
/bin/sh
/bin/bash
/sbin/nologin
/bin/dash
/bin/tcsh
/bin/csh
```

这里要说一下的是系统默认的解析器是bash

```sh
[damon@hadoop97 bin]$ echo $SHELL
/bin/bash
```

也可以这样查看

```sh
head -1 /etc/passwd //查看etc/passwd的第一行内容
```

每一个bash都是一个解释器，在你登录之后系统会启动默认设置的shell，也就是bash。此时在bash下再执行bash，即又开启了一个解释器。

```sh
bash //开启了一个新的解释器
pstree  //查看进程树
```

![image-20220124174530887](shell学习.assets/image-20220124174530887.png)

此时可以退出当前bash，使用exit命令。

## bash的优点

1. 快捷键，
   1. ctrl+A：将光标移至行首；
   2. ctrl+E：将光标移至行尾；
   3. ctrl+D：结束任务
   4. ctrl+U：删除前面所有内容
   5. ctrl+w：删除前面一个单词，以空格为界
2. 历史记录
3. 补齐命令：tab键
4. 管道|，覆盖重定向 >，追加重定向 >>

### 执行脚本的方式

赋予执行权限（``chmod +x ``脚本文件名），直接执行

- 绝对路径执行
- 相对路径执行

不需要文件有可执行的权限

- sh | bash 脚本文件名
- source 脚本文件名（不会启动子进程，可通过pstree查看进程树）

## 变量

```sh
a=1
echo $1

x=centos
echo ${x}7.1 //centos7.1
```

### 变量类型

环境变量（etc/profile或~/.bash_profile）

- 命令env可以列出所有环境变量

位置变量（存储脚本执行时的参数）

- 使用$n表示，n为数字序列号

预定义变量（用来保存脚本程序的执行信息）

- 能直接使用这些变量，但不能直接为这些变量赋值
- $0：表示当前所在的进程或脚本名
- $$：表示当前运行进程的PID号
- $?：命令执行后的返回状态，0表示正常，1或其他值表示异常
- $#：已加载的位置变量的个数
- $*：所有变量的值

### 区分多种引号的区别

- 双引号""：允许扩展，以$引用其他变量
- 单引号''：禁用扩展，即便$也视为普通字符
- 反引号``：将命令的执行输出作为变量值，$()与反引号等效

![image-20220209141543202](shell学习.assets/image-20220209141543202.png)

不加引号，使用``touch a b c``，会创建三个文件，而使用``touch "a b c"``则只创建了a b c这一个文件，同理在删除文件的时候也是一样的。`` rm -rf a b c``

单引号和双引号的区别

![image-20220209170056796](shell学习.assets/image-20220209170056796.png)

反引号使用

![image-20220209170229271](shell学习.assets/image-20220209170229271.png)

### read标准输入取值

read从键盘读入变量值完成赋值

- read [-p "提示信息"] 变量名
- -p可选，-t可指定超时秒数，-s设置是否在终端显示输入的内容

```sh
#!/bin/bash
read -p "请输入用户名：" name
read -p "请输入密码：" -s pass
useradd "$name"
echo "$pass" | passwd --stdin "$name"
```

### 变量的作用范围

局部变量

- 新定义的变量默认只在当前Shell环境中有效，无法在子Shell环境中使用

全局变量

- 全局变量在当前Shell及子Shell环境中均有效

![image-20220209171512460](shell学习.assets/image-20220209171512460.png)

## shell中的运算

使用$[]算式替换

- 格式：$[整数1 运算符 整数2]
- 计算结果替换表达式本身，可结合echo命令输出

![image-20220209172131837](shell学习.assets/image-20220209172131837.png)

### bc计算器

bash内建机制仅支持整数运算，不支持小数运算，可以通过计算器软件bc实现小数运算

- 如果没有该软件需要使用yum安装
- bc支持交互式和非交互式两种方式计算，scale=n可以约束小数位

```sh
yum -y install bc
```

![image-20220209173122003](shell学习.assets/image-20220209173122003.png)

交互执行，使用quit退出。

非交互使用，小数的大小比较

- bc支持的比较操作符：>、 >=、 <、 <=、 ==、 !=
- 表达式成立返回1，否则返回0

![image-20220209173241343](shell学习.assets/image-20220209173241343.png)

## linux文本三剑客

[shell三剑客实战](https://blog.windanchaos.tech/2020/05/17/shell%E4%B8%89%E5%89%91%E5%AE%A2%E5%AE%9E%E6%88%98/)

- awk：最基本的作用，按规则输出列。

- sed，用途：数据选、换、增、查。
- grep，数据查找和定位。

## 参考

- [视频学习](https://www.bilibili.com/video/BV1qA411L7XW?p=3&spm_id_from=pageDriver)

