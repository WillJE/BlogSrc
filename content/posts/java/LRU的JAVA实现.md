---
title: "LRU的JAVA实现"
date: 2018-04-25T20:55:29+08:00
toc: true
isCJKLanguage: true
tags: 
  - LRU
---

什么是LRU算法?


LRU是Least Recently Used的缩写，即**最近最久未使用**，是一种操作系统中常用的页面置换算法。

知道了什么是LRU后，我们再来聊下它的使用场景

在工作中，对于Redis我们一定是比较熟悉的，它是一个内存数据库；因为它是内存数据库，并且内存的空间是有限的，如果Redis中数据量很大的话，内存就可能被占满，但是此时如果还有数据存入Redis的话，那该怎么办呢？这就是由Redis的的内存淘汰策略所决定的。

LRU最近最久未使用算法就是Redis的内存淘汰策略之一。

## 设计

### 1、要求

①、支持数据get查询和数据put插入；
②、此数据结构的操作需要满足时间复杂度为O(1)；

### 2、思路

根据要求的时间复杂度可以立马想到Hash表，Hash表的时间复杂度为O(1)，所以可以使用Map这种key-value数据结构来满足时间复杂度；

但是根据LRU最近最久未使用的原理，需要将最新访问的数据放到最前面，并且当缓存容量满了的时候，还需要将最近最久未使用的数据淘汰掉，所以还需要一种数据结构来标识最新访问数据（首部），最久未使用数据（尾部），这里可以使用双向链表实现；

所以设计的LRU的数据结构是：**HashMap + 双向链表** ；

> 注意：也可以使用 **LinkedHashMap** 尝试实现 LRU缓存的。

### 3、链表节点

> 因为LRU缓存设计中使用了双向链表，所以需要设计下链表中的节点类，如下：

```java

public class DoubleLinkedListNode {
  String key;
  Object value;
  // 头指针
  DoubleLinkedListNode pre;
  // 尾指针
  DoubleLinkedListNode next; 
  
  public DoubleLinkedListNode(String key, Object value) {
        this.key = key;
        this.value = value;
  }
}
```

## 完整代码

```java
public class LRUCache {
 
  private HashMap<String, DoubleLinkedListNode> map = new HashMap<String, DoubleLinkedListNode>();
  // 头结点
  private DoubleLinkedListNode head;
  // 尾节点
  private DoubleLinkedListNode tail;
  // 双向链表的容量
  private int capacity;
  // 双向链表中节点的数量
  private int size;
 
  public LRUCache(int capacity) {
    this.capacity = capacity;
    size = 0;
  }
 
  /**
   * @Description: 将节点设置为头结点
   * @param node
   */
  public void setHead(DoubleLinkedListNode node) {
    // 节点的尾指针执行头结点
    node.next = head;
    // 节点的头指针置为空
    node.pre = null;
    if (head != null) {
      // 将头结点的头指针执行节点
      head.pre = node;
    }
    head = node;
    if (tail == null) {
      // 如果双向链表中还没有节点时，头结点和尾节点都是当前节点
      tail = node;
    }
  }
 
  /**
   * @Description:将双向链表中的节点移除
   * @param node
   */
  public void removeNode(DoubleLinkedListNode node) {
    DoubleLinkedListNode cur = node;
    DoubleLinkedListNode pre = cur.pre;
    DoubleLinkedListNode post = cur.next;
    // 如果当前节点没有头指针的话，说明它是链表的头结点
    if (pre != null) {
      pre.next = post;
    } else {
      head = post;
    }
    // 如果当前节点没有尾指针的话，说明当前节点是尾节点
    if (post != null) {
      post.pre = pre;
    } else {
      tail = pre;
    }
  }
 
  /**
   * @Description:从缓存Cache中get
   * @param key
   * @return
   */
  public Object get(String key) {
    // 使用hashmap进行查询，时间复杂度为O(1)，如果进行链表查询，需要遍历链表，时间复杂度为O(n)
    if (map.containsKey(key)) {
      DoubleLinkedListNode node = map.get(key);
      // 将查询出的节点从链表中移除
      removeNode(node);
      // 将查询出的节点设置为头结点
      setHead(node);
      return node.value;
    }
    // 缓存中没有要查询的内容
    return null;
  }
 
  /**
   * @Description:将key-value存储set到缓存Cache中
   * @param key
   * @param value
   */
  public void set(String key, Object value) {
    if (map.containsKey(key)) {
      DoubleLinkedListNode node = map.get(key);
      node.value = value;
      removeNode(node);
      setHead(node);
    } else {
      // 如果缓存中没有词key-value
      // 创建一个新的节点
      DoubleLinkedListNode newNode = new DoubleLinkedListNode(key, value);
      // 如果链表中的节点数小于链表的初始容量（还不需要进行数据置换）则直接将新节点设置为头结点
      if (size < capacity) {
        setHead(newNode);
        // 将新节点放入hashmap中，用于提高查找速度
        map.put(key, newNode);
        size++;
      } else {
        // 缓存(双向链表)满了需要将"最近醉酒未使用"的节点(尾节点)删除，腾出新空间存放新节点
        // 首先将map中的尾节点删除
        map.remove(tail.key);
        // 移除尾节点并重新置顶尾节点的头指针指向的节点为新尾节点
        removeNode(tail);
        // 将新节点设置为头节点
        setHead(newNode);
        // 将新节点放入到map中
        map.put(key, newNode);
      }
    }
  }
 
  /**
   * @Description: 遍历双向链表
   * @param head
   *            双向链表的 头结点
   */
  public void traverse(DoubleLinkedListNode head) {
    DoubleLinkedListNode node = head;
    while (node != null) {
      System.out.print(node.key + "  ");
      node = node.next;
    }
    System.out.println();
  }
 
  // test
  public static void main(String[] args) {
    System.out.println("双向链表容量为6");
    LRUCache lc = new LRUCache(6);
 
    // 向缓存中插入set数据
    for (int i = 0; i < 6; i++) {
      lc.set("test" + i, "test" + i);
    }
 
    // 遍历缓存中的数据，从左到右，数据越不经常使用
    System.out.println("第一次遍历双向链表：(从头结点遍历到尾节点)");
    lc.traverse(lc.head);
 
    // 使用get查询缓存中数据
    lc.get("test2");
 
    // 再次遍历缓存中的数据，从左到右，数据越不经常使用,并且此次发现刚刚操作的数据节点位于链表的头结点了。
    System.out.println();
    System.out.println("get查询 test2节点后 ，第二次遍历双向链表：");
    lc.traverse(lc.head);
 
    // 再次向缓存中插入数据，发现缓存链表已经满了，需要将尾节点移除
    lc.set("sucess", "sucess");
 
    /**
     * 再次遍历缓存中的数据，从左到右，数据越不经常使用,并且此次发现刚刚set操作时由于链表满了， 就将尾节点test0
     * 移除了，并且将新节点置为链表的头结点。
     */
    System.out.println();
    System.out.println("put插入sucess节点后，第三次遍历双向链表：");
    lc.traverse(lc.head);
  }
}
```

