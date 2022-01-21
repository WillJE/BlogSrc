---
title: "使用Docker安装GitLab"
date: 2021-08-24T21:51:51+08:00
toc: true
isCJKLanguage: true
tags: 
  - Docker
  - GitLab
---
## 安装GitLab

gitlab 镜像分为两个版本：

gitlab-ce 社区版
gitlab-ee 企业收费版

这里使用社区版则可，直接安装官方镜像，目前(2020/1/14)官方镜像大小约1.8G，如果你没有设置Docker镜像源，Docker会默认从国外Docker官方Hub去拉去进行，速度难以让人接受，参考「Centos7安装docker-ce」一文进行设置。

拉取gitlab-ce源

```bash
docker pull gitlab/gitlab-ce:latest
```

### 运行Gitlab

下载完后，先不急着运行Gitlab，为了避免容器运行时数据丢失，需要使用Docker volume（容器卷）方式来将数据映射到本地，这里创建`/home/gitlab`目录来存放相应的数据，具体对应关系如下表。

| 宿主机位置 | 容器位置 | 作用 |
| --- | --- | --- |
| /home/gitlab/config | /etc/gitlab | 用于存储 GitLab 配置文件 |
| /home/gitlab/logs | /var/log/gitlab | 用于存储日志 |
| /home/gitlab/data | /var/opt/gitlab | 用于存储应用数据 |

通常gitlab会与git配置使用，而git会采用ssh协议来操作git仓库，而我们连接宿主机时也使用ssh，如果不修改默认sshd端口，git使用默认配置就会出现问题，这里将主机的sshd端口从22端口改为15678端口。

Centos7防火墙机制改为了firewall，拥有更加严格的安全机制，你需要按照下面方式去修改。

1.编辑` /etc/ssh/sshd_config`，将 #Port 22 注释去掉，将数字 22 更改为 15678。

2.重启sshd服务

```bash
systemctl restart sshd
```

3.配置firewall，使15678端口可以对外提供服务，否则无法使用ssh进行远程登录了。

```bash
semanage port -a -t ssh_port_t -p tcp 15678
firewall-cmd --permanent --add-port=15678/tcp
firewall-cmd --reload 
```

完整上面两项配置，就可以运行docker了。

```bash
docker run \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --volume /home/gitlab/config:/etc/gitlab \
    --volume /home/gitlab/logs:/var/log/gitlab \
    --volume /home/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce
```

这里将主机的 443、80、22 端口直接转发到容，同时利用--volume将gitlab的配置、日志与数据都持久化到本地

除了修改宿主机sshd端口外，你还可以选择另外一种方法，就是修改gitlab容器相应的端口，但生产环境通常会不启用22端口，避免被人恶意暴力尝试，各位可以进一步优化。

## 使用 docker-compose 安装

使用 docker-compose 可以更方便配置、安装 gitlab。安装 gitlab 的 `docker-compose.yml` 文件如下：

```bash
version: '3'
services:
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: '127.0.0.1'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://127.0.0.1'
    ports:
      - '80:80'
      - '443:443'
      - '22:22'
    volumes:
      - '/Users/lihao/code/docker/gitlab-compose/config:/etc/gitlab'
      - '/Users/lihao/code/docker/gitlab-compose/logs:/var/log/gitlab'
      - '/Users/lihao/code/docker/gitlab-compose/data:/var/opt/gitlab'
```

可以看到，`docker-compose.yml` 文件的参数与上述 `docker run` 命令的参数相似。为了方便配置 gitlab 的 `external_url` 配置，我们通过直接指定环境变量 `GITLAB_OMNIBUS_CONFIG` 的方式实现。

另外，为了与上面安装的 gitlab 数据不冲突，我们使用了本地另一个目录来保存容器的数据。

关闭上面启动的 gitlab 容器，然后在 `docker-compose.yml` 文件所在目录，执行以下命令：

```bash
docker-compose up -d
```

## 使用Gitlab

Gitlab容器启动后，直接访问 [http://ip](https://link.segmentfault.com/?url=http%3A%2F%2Fip) 就可以进入gitlab访问页面，第一步要做的就是给root用户设置密码，设置完后，通过root + 设置的密码登录。

## 参考资料

- https://docs.gitlab.com/omnibus/docker/