---
title: "go中的闭包"
date: 2021-05-15T22:12:16+08:00
toc: true
isCJKLanguage: true
tags: 
  - go
  - 闭包
---

## 匿名函数

参考博客：

- https://www.calhoun.io/what-is-a-closure/
- https://blog.cloudflare.com/a-go-gotcha-when-closures-and-goroutines-collide/

在说闭包之前，先说一下匿名函数，匿名函数就是没有名字的函数，可以将它理解为一个变量。看下面的例子：

```go
package main

import "fmt"

var DoStuff func() = func() {
  // Do stuff
}

func main() {
  DoStuff()

  DoStuff = func() {
    fmt.Println("Doing stuff!")
  }
  DoStuff()

  DoStuff = func() {
    fmt.Println("Doing other stuff.")
  }
  DoStuff()
}
//Doing stuff!
//Doing other stuff.
```

可以在这里查看：https://play.golang.org/p/WPHkRpCzH4f

## 闭包

闭包是匿名函数与匿名函数所引用环境的**组合**。匿名函数有动态创建的特性，**该特性使得匿名函数不用通过参数传递的方式，就可以直接引用外部的变量**。这就类似于常规函数直接使用全局变量一样，个人理解为：匿名函数和它引用的变量以及环境，类似常规函数引用全局变量处于一个包的环境。

```go
package main

import "fmt"

func main() {
  n := 0
  counter := func() int {
    n += 1
    return n
  }
  fmt.Println(counter())
  fmt.Println(counter())
}
//1
//2
```

可以在这里查看：https://play.golang.org/p/WOfBvm7UbLT

注意看变量``n``是没有通过变量传递给方法``counter()``的，而且看结果第二次执行的时候返回了2，说明这个``counter()``变量不仅仅是存储了一个函数的返回值，它同时存储了一个闭包的状态。

## 闭包作为函数返回值

匿名函数作为返回值，不如理解为闭包作为函数的返回值，如下代码：

```go
package main

import "fmt"

func main() {
  counter := newCounter()
  fmt.Println(counter())
  fmt.Println(counter())
}

func newCounter() func() int {
  n := 0
  return func() int {
    n += 1
    return n
  }
}
```

闭包被返回赋予一个同类型的变量时，同时赋值的是整个闭包的状态，该状态会一直存在外部被赋值的变量`counter`中，直到`counter`被销毁，整个闭包也被销毁。



## Golang并发中的闭包

输出从1-5的数字，我们可以这么写

```go
package main

import "fmt"

func main() {
	for i := 0; i < 5; i++ {
		fmt.Printf("%d ", i)
	}
}
```

如果要使用并发输出，使用``goroutine``，并使用信号量``sync.WaitGroup``保证同步。

```go
package main

import (
	"fmt"
    "runtime"
	"sync"
)

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())
    
	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func() {
			fmt.Printf("%d ", i)
			wg.Done()
		}()
	}
	
	wg.Wait()
}
/**结果
5 5 5 5 5
**/
```

这种现象的原因在于闭包共享外部的变量``i``，注意到，每次调用go就会启动一个``goroutine``，这需要一定时间；但是，启动的``goroutine``与循环变量递增不是在同一个``goroutine``，可以把i认为处于主``goroutine``中。启动一个``goroutine``的速度远小于循环执行的速度，所以即使是第一个``goroutine``刚起启动时，外层的循环也执行到了最后一步了。由于所有的``goroutine``共享``i``，而且这个i会在最后一个使用它的``goroutine``结束后被销毁，所以最后的输出结果都是最后一步的``i==5``。

怎么验证这个问题呢，我们在for循环中设置延时看一下：

```go
func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func() {
			fmt.Println(i)
			wg.Done()
		}()
		time.Sleep(1 * time.Second)   // 设置时间延时1秒
	}
	wg.Wait()
}
/**输出结果
0
1
2
3
4
**/
```

每一步循环至少间隔一秒，而这一秒的时间足够启动一个`goroutine`了，因此这样可以输出正确的结果。

在实际的工程中，不可能进行延时，这样就没有并发的优势，一般采取下面两种方法：

1. 共享的环境变量作为函数参数传递:

```go
func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func(i int) {
			fmt.Println(i)
			wg.Done()
		}(i)
	}
	wg.Wait()
}
/*
输出:
4
0
3
1
2
*/
```

输出结果不一定按照顺序，这取决于每个`goroutine`的实际情况，但是最后的结果是不变的。可以理解为，函数参数的传递是瞬时的，而且是在一个`goroutine`执行之前就完成，所以此时执行的闭包存储了当前`i`的状态。

2. 使用同名的变量保留当前的状态

```go
func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		i := i       // 注意这里的同名变量覆盖
		go func() {
			fmt.Println(i)
			wg.Done()
		}()
	}
	wg.Wait()
}
/*
输出结果：
4
2
0
3
1
结果顺序原因同1
*/
```

同名的变量`i`作为内部的局部变量，覆盖了原来循环中的`i`，此时闭包中的变量不在是共享外循环的`i`，而是都有各自的内部同名变量`i`，赋值过程发生于循环`goroutine`，因此保证了独立。

