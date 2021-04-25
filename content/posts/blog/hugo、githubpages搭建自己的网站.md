---
title: "Hugo、githubpages搭建自己的网站"
date: 2019-04-05T15:18:03+08:00
toc: true
isCJKLanguage: true
tags: [hugo]
---

## 安装hugo

直接[官网](https://gohugo.io/)安装，windows下载的是一个压缩包，解压下来就能使用，不过要把该路径配置到环境变量里。

检查安装

```bash
hugo version
```

## 使用hugo

创建站点

```bash
hugo new site [your site name]
```

下一步是选择主题，我的主题是[LoveIt](https://github.com/dillonzq/LoveIt)。

将该主题增加到网站的配置文件config.toml中，这样才能生效：

```bash
'theme = "hermit"
```

测试下是否成功，运行：

```bash
$ hugo serve
```

## 增加文章

```bash
hugo new posts/my-first-post.md
```

这会在 content/posts 目录下生成一个 my-first-post.md 文件，里面内容如下：

```bash
---
title: "Hugo、githubpages搭建自己的网站"
date: 2020-04-05T15:18:03+08:00
draft: true
---
```

draft表示这是个草稿，当你使用

```bash
hugo serve
```

启动时，草稿文档是不会渲染的，你可以将它改为false，或者使用

```bash
hugo server D
```

本地渲染。

## 使用 GitHub Pages 部署站点

这是 GitHub 为你和你的项目准备网站的，GitHub Pages 官方站点：https://pages.github.com/，大概就是通过将网站内容放到 GitHub，通过 GitHub Pages 可以弄出一个自己的站点。它最常使用的是通过 Jekyll 这个站点生成器生成静态页面，有兴趣的自行查阅资料了解。我们应该使用 Hugo 生成静态页面，因此直接将静态页面部署到 GitHub Pages。

### 配置仓库

配置仓库就是建一个和GithubID同名的仓库，这个教程有很多，可以参考[这里](https://polarisxu.studygolang.com/posts/talk/myblog-with-hugo-github-pages/)来配置。

### 部署我们的站点

这里有两种做法。

**1）方法一**

上面 Hugo 项目的代码直接推送到 GitHub Pages 这个仓库中，在通过 Hugo 生成静态页面时，指定目标目录为 docs：

```bash
$ hugo -d docs
```

这样 docs 下面的内容就是静态页面，是网站最终展示的内容。

**2）方法二**

Hugo 源网站内容单独放在一个仓，比如我放在了https://github.com/WillJE/BlogSrc 这个仓库。这样分两个仓库相对麻烦先。但也有一个好处：GitHub Pages 站点有内容大小限制：不能超过 1 GB，这样分开可以节省空间，而且 Hugo 内容和站点解耦。

因此每次在 Hugo 站点项目写完文章后，需要生成静态内容，拷贝到 GitHub Pages 仓库，提交代码等。把这些步骤写成一个脚本，瞬间变简单了。

```bash
#!/bin/sh

hugo

cp -rf public/* ../willJE.github.io/docs/

cd ../willJE.github.io/

git add * && git commit -m 'new article' && git push

cd ../willJE/
```

