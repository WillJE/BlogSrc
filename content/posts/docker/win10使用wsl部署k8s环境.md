---
title: "Win10使用wsl部署k8s环境"
date: 2021-04-24T21:57:01+08:00
toc: true
isCJKLanguage: true
tags: [Kubernetes]
---

# 前提

- 安装docker和go环境
- 配置wsl2

这个可以看之前的文章[win10安装docker](https://willje.github.io/posts/%E4%BB%8E%E4%B8%80%E4%B8%AAyaml%E6%96%87%E4%BB%B6%E8%AF%BB%E5%8F%96%E5%A4%9A%E4%B8%AA%E6%96%87%E6%A1%A3/)

# 安装kubectl

安装kubectl有几种方法，具体可以看[install-kubectl-windows/](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)

1. 直接使用`curl`

```bash
curl -LO https://dl.k8s.io/release/v1.21.0/bin/windows/amd64/kubectl.exe
```

如果提示`curl`命令不存在，可以先安装一下curl，不过这里建议直接用github的`curl`（如果你安装了github的话），目录在`github安装目录/mingw64/bin`，不过使用这个需要配置到环境变量的`path`里。

配置好之后curl会直接将kubectl可执行文件下载到bash的执行目录下，默认应该是`c:/users/username`下，然后将这个文件配置到环境变量里就行了，我这里是直接把这个文件拷贝到之前那个`curl`那个目录下了。

kubectl不用安装，配置好环境变量之后就可以在wsl（ubuntu）中执行`kubectl version`

```bash
will@DESKTOP-N0FI3QF:~$ kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.7", GitCommit:"1dd5338295409edcfff11505e7bb246f0d325d15", GitTreeState:"clean", BuildDate:"2021-01-13T13:23:52Z", GoVersion:"go1.15.5", Compiler:"gc", Platform:"linux/amd64"}
```

这时因为没有配置集群，所以只有客户端版本。

# 安装kind

具体参考这个官方[博客](https://kubernetes.io/blog/2020/05/21/wsl-docker-kubernetes-on-the-windows-desktop/)

```bash
# Download the latest version of KinD
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-linux-amd64
# Make the binary executable
chmod +x ./kind
# Move the binary to your executable path
sudo mv ./kind /usr/local/bin/
```

学习一下kind的命令

```bash
will@DESKTOP-N0FI3QF:~$ kind
kind creates and manages local Kubernetes clusters using Docker container 'nodes'

Usage:
  kind [command]

Available Commands:
  build       Build one of [base-image, node-image]
  create      Creates one of [cluster]
  delete      Deletes one of [cluster]
  export      exports one of [logs]
  get         Gets one of [clusters, nodes, kubeconfig-path]
  help        Help about any command
  load        Loads images into nodes
  version     prints the kind CLI version

Flags:
  -h, --help              help for kind
      --loglevel string   logrus log level [panic, fatal, error, warning, info, debug] (default "warning")
      --version           version for kind

Use "kind [command] --help" for more information about a command.
```



# 创建第一个集群

```bash
echo $KUBECONFIG
# Check if the .kube directory is created > if not, no need to create it
ls $HOME/.kube
# Create the cluster and give it a name (optional)
kind create cluster --name wslkind
# Check if the .kube has been created and populated with files
ls $HOME/.kube
will@DESKTOP-N0FI3QF:~$ kind create cluster --name willkind
Creating cluster "willkind" ...
 ✓ Ensuring node image (kindest/node:v1.13.4) 🖼
⢎⡀ Preparing nodes 📦
⠈⠁ Preparing nodes 📦
⢀⡱ Preparing nodes 📦
 ✓ Preparing nodes 📦
 ✓ Creating kubeadm config 📜
 ✓ Starting control-plane 🕹️
Cluster creation complete. You can now use the cluster with:

export KUBECONFIG="$(kind get kubeconfig-path --name="willkind")"
kubectl cluster-info

will@DESKTOP-N0FI3QF:~$ kubectl cluster-info
Kubernetes master is running at https://localhost:41825
KubeDNS is running at https://localhost:41825/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
will@DESKTOP-N0FI3QF:~$ kubectl get nodes
NAME                     STATUS   ROLES    AGE   VERSION
willkind-control-plane   Ready    master   12m   v1.13.4
```

这时我们就完成了简单的单节点的集群创建

从安装打印出的输出来看，分为4步：

1. 查看本地上是否存在一个基础的安装镜像，默认是 kindest/node:v1.13.4，这个镜像里面包含了需要安装的所有东西，包括了 kubectl、kubeadm、kubelet 二进制文件，以及安装对应版本 k8s 所需要的镜像，都以 tar 压缩包的形式放在镜像内的一个路径下
2. 准备你的 node，这里就是做一些启动容器、解压镜像之类的工作

1. 生成对应的 kubeadm 的配置，之后通过 kubeadm 安装，安装之后还会做另外的一些操作，比如像我刚才仅安装单节点的集群，会帮你删掉 master 节点上的污点，否则对于没有容忍的 pod 无法部署。
2. 启动完毕



查看当前集群的运行情况

```bash
will@DESKTOP-N0FI3QF:~$ kubectl get po -n kube-system
NAME                                             READY   STATUS    RESTARTS   AGE
coredns-86c58d9df4-6gdmr                         1/1     Running   0          161m
coredns-86c58d9df4-nc7nt                         1/1     Running   0          161m
etcd-willkind-control-plane                      1/1     Running   0          160m
kube-apiserver-willkind-control-plane            1/1     Running   0          160m
kube-controller-manager-willkind-control-plane   1/1     Running   0          160m
kube-proxy-2b6qs                                 1/1     Running   0          161m
kube-scheduler-willkind-control-plane            1/1     Running   0          160m
weave-net-h2rt8                                  2/2     Running   0          161m
```

默认方式启动的节点类型是 control-plane 类型，包含了所有的组件。包括2 * coredns、etcd、api-server、controller-manager、kube-proxy、sheduler，网络插件方面默认使用的是 weave，且目前只支持 weave，不支持其他配置，如果需要可以修改 kind 代码进行定制。



基本上，kind 的所有秘密都在那个基础镜像中。下面是基础容器内部的 /kind 目录，在 bin 目录下安装了 kubelet、kubeadm、kubectl 这些二进制文件，images 下面是镜像的 tar 包，kind 在启动基础镜像后会执行一遍 docker load 操作将这些 tar 包导入。manifests 下面是 weave 的 cni。

# 参考文章

- https://kubernetes.io/blog/2020/05/21/wsl-docker-kubernetes-on-the-windows-desktop/

- https://zhuanlan.zhihu.com/p/61492135