---
title: "Golang中defer的那些事"
date: 2021-04-05T12:13:54+08:00
draft: false
categories: [go]
tags: [defer]
---

Golang中的defer关键字实现比较特殊的功能，按照官方的解释，defer后面的表达式会被放入一个列表中，在当前方法返回的时候，列表中的表达式就会被执行。一个方法中可以在一个或者多个地方使用defer表达式，这也是前面提到的，为什么需要用一个列表来保存这些表达式。在Golang中，defer表达式通常用来处理一些清理和释放资源的操作。



貌似看起来比较难懂，其实，如果你用过C#，一定记得那个用起来非常方便的using语句，defer可以理解成为了实现类似的功能。不过比起C#的using语句，defer的行为稍微复杂一些，想要彻底理解defer，需要了解Golang中defer相关的一些特性。

通过一个简单的例子，我们就可以大致了解defer的用法：

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }

    written, err = io.Copy(dst, src)
    dst.Close()
    src.Close()
    return
}
```

CopyFile方法简单的实现了文件内容的拷贝功能，将源文件的内容拷贝到目标文件。咋一看还没什么问题，不过Golang中的资源也是需要释放的，假如os.Create方法的调用出了错误，下面的语句会直接return，导致这两个打开的文件没有机会被释放。这个时候，defer就可以派上用场了。

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }
    defer src.Close()

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }
    defer dst.Close()

    return io.Copy(dst, src)
}
```

这是使用defer改进过后的例子：改进的代码中两处都使用到了defer表达式，表达式的内容就是关闭文件。前面介绍过，虽然表达式的具体行为是关闭文件，但是并不会被马上执行，两个表达式都会被放入一个list，等待被调用。先卖个关子，这个list可以看作是一个栈(stack)的结构，是一个后进先出的栈。

知道了defer的基本用法，我们得继续深入了解一下defer的一些特性：



- **defer表达式中变量的值在defer表达式被定义时就已经明确**

```go
func a() {
    i := 0
    defer fmt.Println(i)
    i++
    return
}
```

上面的这段代码，defer表达式中用到了i这个变量，i在初始化之后的值为0，接着程序执行到defer表达式这一行，表达式所用到的i的值就为0了，接着，表达式被放入list，等待在return的时候被调用。所以，后面尽管有一个i++语句，仍然不能改变表达式 fmt.Println(i)的结果。



所以，程序运行结束的时候，输出的结果是0而不是1。



- **defer表达式的调用顺序是按照先进后出的方式**

```go
func b() {
    defer fmt.Print(1)
    defer fmt.Print(2)
    defer fmt.Print(3)
    defer fmt.Print(4)
}
```

前面已经提到过，defer表达式会被放入一个类似于栈(stack)的结构，所以调用的顺序是后进先出的。所以，上面这段代码输出的结果是4321而不是1234。在实际的编码中应该注意，程序后面的defer表达式会被优先执行。



- **defer表达式中可以修改函数中的命名返回值**

Golang中的函数返回值是可以命名的，这也是Golang带给开发人员的一个比较方便特性。

```go
func c() (i int) {
    defer func() { i++ }()
    return 1
}
```

上面的示例程序，返回值变量名为i，在defer表达式中可以修改这个变量的值。所以，虽然在return的时候给返回值赋值为1，后来defer修改了这个值，让i自增了1，所以，函数的返回值是2而不是1。



理解了defer的三个特性，用到defer的时候就能心中有数了。



## 参考资料

- [理解 Go 语言 defer 关键字的原理](https://www.infoq.cn/article/oxyy2lrptjbdm7u1utkq)
- [理解defer](https://sanyuesha.com/2017/07/23/go-defer/)
- [Golang中defer的那些事](https://xiaozhou.net/something-about-defer-2014-05-25.html)