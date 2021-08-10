---
title: "kafka入门"
date: 2020-07-29T21:23:18+08:00
toc: true
isCJKLanguage: true
tags: 
  - kafka
---

Kafka是最初由Linkedin公司开发，是一个分布式、支持分区的（partition）、多副本的（replica），基于zookeeper协调的分布式消息系统，它的最大的特性就是可以实时的处理大量数据以满足各种需求场景：比如基于hadoop的批处理系统、低延迟的实时系统、Storm/Spark流式处理引擎，web/nginx日志、访问日志，消息服务等等，用scala语言编写，Linkedin于2010年贡献给了Apache基金会并成为顶级开源 项目。

# 快速入门

Kafka 官网的下载地址是 [kafka.apache.org/downloads](https://link.juejin.cn/?target=https%3A%2F%2Fkafka.apache.org%2Fdownloads) ；

## 安装

我们使用docker-compose安装，由于Kafka是用Scala语言开发的，运行在JVM上，因此在安装Kafka之前需要先安装JDK。

还有kafka也依赖zookeeper，所以需要先安装zookeeper。环境准备，

step1:[安装docker compose](https://yeasy.gitbook.io/docker_practice/compose/usage)

step2:准备一个`docker-compose.yml`文件

使用Kafka官方镜像，

```shell
docker pull wurstmeister/kafka
```

默认情况下，会拉取kafka的latest版本。

此外，对于搭建一个Kafka集群外，除了kafka镜像外，还需要额外拉取两个镜像：

1. zookeeper(wurstmeister/zookeeper:latest)
2. kafka-manager(sheepkiller/kafka-manager:latest)

```yaml
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper
    ports:
      - "2181:2181"
  kafka:
    image: wurstmeister/kafka
    ports:
      - "9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.99.100  # 修改为本机地址
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/localtime:/etc/localtime
  kafka-manager:  
    image: sheepkiller/kafka-manager # 镜像：开源的web管理kafka集群的界面
    environment:
        ZK_HOSTS: 192.168.99.100 # 修改为本机地址
    ports:  
      - "9000:9000"
```

Step3：启动服务

```shell
docker-compose up -d
```

Step4：对Kafka进行扩、缩容

```shell
docker-compose scale kafka=3
```

## 消息引擎模型

**我们用一句话概括Kafka就是它是一款开源的消息引擎系统。**

其中最常见的两种消息引擎模型是点对点模型和发布／订阅模型

### 点对点模型

点对点模型是基于队列提供消息传输服务的，该模型定义了消息队列、发送者和接收者 , 提供了一种点对点的消息传递方式，即发送者发送每条消息到队列的指定位置，接收者从指定位置获取消息，一旦消息被消费， 就会从队列中移除该消息 。 每条消息由一个发送者生产出来， 且只被一个消费者处理一一发送者和消费者之间是一对一的关系。

![img](Kafka入门.assets/722d93b9f9f947ea8794de02daf99128~tplv-k3u1fbpfcp-watermark.image)


### 发布订阅模型

发布／订阅模型与前一种模型不同， 它有主题(topic)的概念。 这种模型也定义了类似于生产者／消费者这样的角色，即发布者和订阅者，发布者将消息生产出来发送到指定的topic中， 所有订阅了该 topic的订阅者都可以接收到该topic下的所有消息，通常具有相同订阅 topic 的所有订阅者将接收到 同样的消息。

![img](Kafka入门.assets/e2c96246cc1d4b0ea272e74e8d2b3b63~tplv-k3u1fbpfcp-watermark.image)

## 基本概念

### Message

既然Kafka是消息引擎，这里的消息就是指 Kafka 处理的主要对象

### Broker

broker 指一个 kafka 服务器。如果多个 broker 形成集群会依靠 Zookeeper 集群进行服务的协调管理。

生产者发送消息给 Kafka 服务器。消费者从 Kafka 服务器读取消息。

### Topic和Partition

topic代表了一类消息， 也可以认为是消息被发送到的地方。 通常我们可以使用 topic 来区分实际业务， 比如业务 A 使用 一个 topic ， 业务 B 使用另外一个 topic。

Kafka 中的 topic 通常都会被多个消费者订阅， 因此出于性能的考量 ， Kafka 并不是 topic-message 的两级结构， 而是采用了 topic-partition-message 的三级结构来分散负 载。 从本质上说， 每个 Kafka topic 都由若干个 partition 组成。

![img](Kafka入门.assets/52dc6359f785472a9086bb8708d869c9~tplv-k3u1fbpfcp-watermark.image)

如图： topic 是由多个 partition 组成的， 而 Kafka 的 partition 是不可修改的有序消息序列， 也可以说是有序的消息日志。 每个 partition 有自己专属的 partition 号， 通常是从 0 开始的。 用户对 partition 唯一能做的操作就是在消息序列的尾部追 加写入消息。 partition 上的每条消息都会被分配一个唯一 的序列号。

该序列号被称为位移（ offset ） 是从 0 开始顺序递增 的整数。 位移信息可以唯一定位到某 partition 下的一条消息 。

**kafka为什么要设计分区？**

解决伸缩性的问题。假如一个broker积累了太 多的数据以至于单台 Broker 机器都无法容纳了，此时应该怎么办呢？一个很自然的想法就 是，能否把数据分割成多份保存在不同的 Broker 上？所以kafka设计了分区

### Producer&Consumer

向主题发布消息的客户端应用程序称为生产者（Producer），生产者程序通常持续不断地 向一个或多个主题发送消息，而订阅这些主题消息的客户端应用程序就被称为消费者 （Consumer）。和生产者类似，消费者也能够同时订阅多个主题的消息。

### Consumer Group

Consumer Group 是指组里面有多个消费者或消费者实例，它 们共享一个公共的 ID，这个 ID 被称为 Group ID。组内的 所有消费者协调在一起来消费订阅主题的所有分区（Partition）。当然，每个分区只能由同一个消费者组内的一个 Consumer 实例来消费。

**Consumer Group 三个特性。**

1. Consumer Group 下可以有一个或多个 Consumer 实 例。
2. Group ID 是一个字符串，在一个 Kafka 集群中，它标识 唯一的一个 Consumer Group。
3. Consumer Group 下所有实例订阅的主题的单个分区， 只能分配给组内的某个 Consumer 实例消费。这个分区 当然也可以被其他的 Group 消费。

**还记得上面提到的两种消息引擎模型**

Kafka 仅仅使用 Consumer Group 这一种机制，却同时实现了传统消息引 擎系统的两大模型：如果所有实例都属于同一个 Group， 那么它实现的就是点对点模型；如果所有实例分别属于不同的 Group，那么它实现的就是发布 / 订阅模型。

**在实际使用场景中，一个 Group 下该有多少个 Consumer 实例呢？**

理想情况下， Consumer 实例的数量应该等于该 Group 订阅主题的分区 总数。

举个简单的例子，假设一个 Consumer Group 订阅了 3 个 主题，分别是 A、B、C，它们的分区数依次是 1、2、3， 那么通常情况下，为该 Group 设置 6 个 Consumer 实例是 比较理想的情形，因为它能最大限度地实现高伸缩性。

#### 消费顺序问题

按照上面的设计，可能会导致消费顺序问题，下面一一介绍

**乱序场景一**

因为一个topic可以有多个partition，kafka只能保证partition内部有序

当partition数量=同一个消费者组中消费者数量时，可能需要顺序的数据分布到了不同的partition，导致处理时乱序

**解决方案**

1、可以设置topic 有且只有一个partition

2、根据业务需要，需要顺序的指定为同一个partition

**乱序场景二**

对于同一业务进入了同一个消费者组之后，用了多线程来处理消息，会导致消息的乱序

**解决方案**

消费者内部根据线程数量创建等量的内存队列，对于需要顺序的一系列业务数据，根据key或者业务数据，放到同一个内存队列中，然后线程从对应的内存队列中取出并操作。

### Rebalance

Rebalance 本质上是一种协议，规定了一个 Consumer Group 下的所有 Consumer 如何达成一致，来分配订阅 Topic 的每个分区。比如某个 Group 下有 20 个 Consumer 实例，它订阅了一个具有 100 个分区的 Topic。正常情况下，Kafka 平均会为每个 Consumer 分配 5 个分区。这个分配的过程就叫 Rebalance。

**Consumer Group 何时进行 Rebalance 呢？ Rebalance 的触发条件有 3 个。**

1. 组成员数发生变更。比如有新的 Consumer 实例加入组 或者离开组，或是有 Consumer 实例崩溃被“踢 出”组。
   1. 订阅主题数发生变更。Consumer Group 可以使用正则 表达式的方式订阅主题，比如`consumer.subscribe(Pattern.compile(“t.*c”))` 就表 明该 Group 订阅所有以字母 t 开头、字母 c 结尾的主 题。在 Consumer Group 的运行过程中，你新创建了一 个满足这样条件的主题，那么该 Group 就会发生 Rebalance。
2. 订阅主题的分区数发生变更。Kafka 当前只能允许增加一 个主题的分区数。当分区数增加时，就会触发订阅该主题的所有 Group 开启 Rebalance。

Rebalance 过程对 Consumer Group 消费过程有极大的影响。会stop the world，简称 STW。我们知道在 STW 期间，所有应用线程都会停止工作，表现为整个应用程序僵在那边一动不动。Rebalance 过程也和这个 类似，在 Rebalance 过程中，所有 Consumer 实例都会停止消费，等待 Rebalance 完成。这是 Rebalance 为人诟病 的一个方面。

Rebalance 是 Kafka 消费者端实现高可用的重要手段。

### Offset

前面说过，topic partition 下的每条消息都被分配一个位移值。 实际上 ，Kafka消费者端也有位移（ offset）的概念， 但一定要注意 这两个offset 属于不同的概念。

![img](Kafka入门.assets/21d3dc1beb0c47a492e9af6087656fb9~tplv-k3u1fbpfcp-watermark.image)

显然， 每条消息在某个 partition 的位移是固定的， 但消费该 partition 的消费者的位移会随着消费进度不断前移。

### Replica

既然我们己知 partition 是有序消息日志， 那么一定不能只保存这一份日志，否则一旦保存 partition 的 Kafka 服务器挂掉了， 其上保存的消息也就都丢失了。 分布式系统必然要实现高可靠性， 而目前实现的主要途径还是依靠冗余机制，通过备份多份日志 。 这些备份日志在 Kafka 中被称为副本（ replica ），它们存在的唯一目的就是防止数据丢失

**副本分为两类 ：**

领导者副本（ leader replica ）和追随者副本（ follower replica ）。

follower replica 是不能提供服务给客户端的，也就是说不负 责响应客户端发来的消息写入和消息消费请求。它只是被动地向领导者副本（ leader replica ）获取数据， 而 一旦 leader replica 所在的 broker 岩机， Kafka 会从剩余的 replica 中选举出新的 leader 继续提供服务。

### Leader和Follower

前面说的， Kafka 的 replica 分为两个角色：领导者（ leader ）和追随者（ follower ） 。 Kafka 保证同一个 partition 的多个 replica 一定不会分配在同一台 broker 上 。 毕竟如果同一个 broker 上有同一个 partition 的多个 replica， 那么将无法实现备份冗余的效果。

![img](Kafka入门.assets/3d36fd3a385841eb9a8a12164231b9ce~tplv-k3u1fbpfcp-watermark.image)


### ISR

ISR 的全称是 in-sync replica，翻译过来就是与 leader replica 保持同步的 replica 集合 。

Kafka 为 partition 动态维护一个 replica 集合。该集合中的所有 replica 保存的消息日志都与leader replica 保持同步状态。只有这个集合中的 replica 才能被选举为 leader，也只有该集合中 所有 replica 都接收到了同一条消息， Kafka 才会将该消息置于“己提交”状态，即认为这条消 息发送成功。

如果因为各种各样的原因，一小部分 replica 开始落后于 leader replica 的进度 。当滞后 到 一定程度时， Kafka 会将这些 replica “踢”出 ISR。相反地，当这些 replica 重新“追上”了 leader 的进度时 ， 那么 Kafka 会将它们加 回到 ISR 中。这一切都 是自动维护的， 不需要用户进行人工干预。

### 小结

**最后用1张图来展示上面提到的这些概念以及运行流程：**

![img](Kafka入门.assets/16eb068cc433bb21)

如上图所示，一个典型的 Kafka 集群中包含若干Producer（可以是web前端产生的Page View，或者是服务器日志，系统CPU、Memory等），若干broker（Kafka支持水平扩展，一般broker数量越多，集群吞吐率越高），若干Consumer Group，以及一个Zookeeper集群。Kafka通过Zookeeper管理集群配置，选举leader，以及在Consumer Group发生变化时进行rebalance。Producer使用push模式将消息发布到broker，Consumer使用pull模式从broker订阅并消费消息。



## Kafka为什么这么快



**顺序读写**

kafka的消息是不断追加到文件中的，这个特性使kafka可以充分利用磁盘的顺序读写性能

顺序读写不需要硬盘磁头的寻道时间，只需很少的扇区旋转时间，所以速度远快于随机读写

**零拷贝**

服务器先将文件从复制到内核空间，再复制到用户空间，最后再复制到内核空间并通过网卡发送出去，而零拷贝则是直接从内核到内核再到网卡，省去了用户空间的复制。

Zero copy对应的是Linux中sendfile函数，这个函数会接受一个offsize来确定从哪里开始读取。现实中，不可能将整个文件全部发给消费者，他通过消费者传递过来的偏移量来使用零拷贝读取指定内容的数据返回给消费者。

关于零拷贝可以看看这篇文章：[什么是零拷贝](https://willje.github.io/posts/linux/%E4%BB%80%E4%B9%88%E6%98%AF%E9%9B%B6%E6%8B%B7%E8%B4%9D/)

**分区**

kafka中的topic中的内容可以被分为多分partition存在,每个partition又分为多个段segment,所以每次操作都是针对一小部分做操作，很轻便，并且增加`并行操作`的能力。

**批量发送**

kafka允许进行批量发送消息，producter发送消息的时候，可以将消息缓存在本地,等到了固定条件发送到kafka

1. 等消息条数到固定条数
2. 一段时间发送一次

**数据压缩**

Kafka还支持对消息集合进行压缩，Producer可以通过GZIP或Snappy格式对消息集合进行压缩。

压缩的好处就是减少传输的数据量，减轻对网络传输的压力。

Producer压缩之后，在Consumer需进行解压，虽然增加了CPU的工作，但在对大数据处理上，瓶颈在网络上而不是CPU，所以这个成本很值得

