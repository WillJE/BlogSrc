---
title: "Kubernetes port类型"
date: 2021-08-23T21:23:18+08:00
toc: true
isCJKLanguage: true
tags: 
  - kubernetes
---

k8s有几种port类型，分别是TargetPort，ContainerPort，NodePort，Port，那么该怎么区别她们呢，各自的使用场景又是什么呢，接下来这篇文章给你分析一下。

## ContainerPort

ContainerPort表示你使用的镜像需要开放的端口。例如，mysql 服务需要暴露 3306 端口，redis 暴露 6379 端口

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: redis-master
  labels: 
    name: redis-master
spec:
  replicas: 1
  selector:
    name: redis-master
  template:
    metadata:
      labels:
        name: redis-master
    spec:
      containers:
      - name: master
        image: kubeguide/redis-master
        ports:
        - containerPort: 6379	# 此处定义暴露的端口
```

## NodePort

一旦你的pod创建好了，k8s通过自己的网络插件给pod分配了一个仅供集群内部访问的IP，但是你的pod需要提供外部服务，所以这时你需要创建一个Service，Service类型为NodePort可以为一组pod提供外部访问的IP；

比如外部用户要访问k8s集群中的一个Web应用，那么我们可以配置对应service的`type=NodePort`，`nodePort=30001`。其他用户就可以通过浏览器`http://node:30001`访问到该web服务。

而数据库等服务可能不需要被外界访问，只需被内部服务访问即可，那么我们就不必设置service的NodePort。

## Port

Service共四种类型：Cluster-IP，NodePort，LoadBalancer，ExternalName，默认是Cluster-IP，仅供集群内部访问；

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

这个my-service的service绑定了app为MyApp的Pod，转发Tcp协议下80端口的流量并转发到对应的pod9376端口上；

更多关于service的内容可参考官网：https://kubernetes.io/docs/concepts/services-networking/service/

:port提供了集群内部客户端访问service的入口，即`clusterIP:port`。

> PS：默认Cluster-IP的targetport和port的值是一样的。

## TargetPort

targetPort是pod上的端口，从port/nodePort上来的数据，经过kube-proxy流入到后端pod的targetPort上，最后进入容器。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort            // 配置NodePort，外部流量可访问k8s中的服务
  ports:
  - port: 30080             // 服务访问端口，集群内部访问的端口
    targetPort: 80          // pod控制器中定义的端口（应用访问的端口）
    nodePort: 30001         // NodePort，外部客户端访问的端口
  selector:
    name: nginx-pod
```

