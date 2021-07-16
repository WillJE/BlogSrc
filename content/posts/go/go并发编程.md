# go并发编程

```go
package main

import "fmt"

func add(a, b int) {
    var c = a + b
    fmt.Printf("%d + %d = %d", a, b, c)
}

func main() {
    go add(1, 2)
}
```

在这段代码中包含了两个协程，一个是显式的，通过 `go` 关键字声明的这条语句，表示启用一个新的协程来处理加法运算，另一个是隐式的，即 `main` 函数本身也是运行在一个主协程中，该协程和调用 `add` 函数的子协程是并发运行的两个协程，就好比从 `go` 关键字开始，从主协程中叉出一条新路。

和之前不使用协程的方式相比，由此也引入了不确定性：我们不知道子协程什么时候执行完毕，运行到了什么状态。在主协程中启动子协程后，程序就退出运行了，这就意味着包含这两个协程的处理进程退出了，**所以，我们运行这段代码，不会看到子协程里运行的打印结果，因为还没来得及执行它们，进程就已经退出了**。另外，我们也不要试图从 `add` 函数返回处理结果，因为在主协程中，根本获取不到子协程的返回值，从子协程开始执行起就已经和主协程没有任何关系了，返回值会被丢弃。

如果要显示出子协程的打印结果，一种方式是在主协程中等待足够长的时间再退出，以便保证子协程中的所有代码执行完毕：

```go
package main

import (
	"fmt"
	"time"
)

func add(a, b int) {
	var c = a + b
	fmt.Printf("%d + %d = %d", a, b, c)
}

func main() {
	go add(1, 2)
	time.Sleep(time.Second)
}
//
1 + 2 = 3
```

## Waitgroup

在并发编程里，`sync.WaitGroup`并发原语的使用频率非常高，经常用于协同等待场景，如果在执行任务的这些worker `goroutine` 还没全部完成，等待的 `goroutine` 就会阻塞在检查点，直到所有woker `goroutine` 都完成后才能继续执行。

```go
func add(a, b int) {
	defer waitgroup.Done()
	var c = a + b
	fmt.Printf("%d + %d = %d", a, b, c)
}

func main() {
	waitgroup.Add(1)
	go add(1, 2)
	waitgroup.Wait()
}
```

### 测试

```go
package main
import (
	"sync"
	"time"
)
func main() {
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		time.Sleep(time.Millisecond)
		wg.Done()
		wg.Add(1)
	}()
	wg.Wait()
}
```

- A: 不能编译
- B: 无输出，正常退出
- C: 程序hang住
- **D: panic**

```go
package main
import (
	"fmt"
	"sync"
)
func main() {
	var wg sync.WaitGroup
	wg.Add(2)
	var ints = make([]int, 0, 1000)
	go func() {
		for i := 0; i < 1000; i++ {
			ints = append(ints, i)
		}
		wg.Done()
	}()
	go func() {
		for i := 0; i < 1000; i++ {
			ints = append(ints, i)
		}
		wg.Done()
	}()
	wg.Wait()
	fmt.Println(len(ints))
}
```

- A: 不能编译
- B: 输出`2000`
- **C: 输出可能不是`2000`**
- D: panic

这个问题需要归咎到slice上，我们都知道slice是对数组一个连续片段的引用，当slice扩容时，可能底层的数组会被换掉。所以，如果在换底层数组之前，切片同时被多个goroutine拿到，并执行append操作。那么很多goroutine的append结果会被覆盖，导致n个gouroutine append后，长度小于n。

解决方式就是加锁；

## 锁

golang 中的 sync 包实现了两种锁：

- Mutex：互斥锁
- RWMutex：读写锁，RWMutex 基于 Mutex 实现

### Mutex

- Mutex 为互斥锁，Lock() 加锁，Unlock() 解锁
- 在一个 goroutine 获得 Mutex 后，其他 goroutine 只能等到这个 goroutine 释放该 Mutex
- 使用 Lock() 加锁后，不能再继续对其加锁，直到利用 Unlock() 解锁后才能再加锁
- 在 Lock() 之前使用 Unlock() 会导致 panic 异常
- 已经锁定的 Mutex 并不与特定的 goroutine 相关联，这样可以利用一个 goroutine 对其加锁，再利用其他 goroutine 对其解锁
- 在同一个 goroutine 中的 Mutex 解锁之前再次进行加锁，会导致死锁
- 适用于读写不确定，并且只有一个读或者写的场景

#### 测试

```go
package main
import (
	"fmt"
	"sync"
)
var mu sync.Mutex
var chain string
func main() {
	chain = "main"
	A()
	fmt.Println(chain)
}
func A() {
	mu.Lock()
	defer mu.Unlock()
	chain = chain + " --> A"
	B()
}
func B() {
	chain = chain + " --> B"
	C()
}
func C() {
	mu.Lock()
	defer mu.Unlock()
	chain = chain + " --> C"
}
```

- A: 不能编译
- B: 输出 `main --> A --> B --> C`
- C: 输出 `main`
- **D: panic**

```GO
package main
import (
	"fmt"
	"sync"
)
type MyMutex struct {
	count int
	sync.Mutex
}
func main() {
	var mu MyMutex
	mu.Lock()
	var mu2 = mu
	mu.count++
	mu.Unlock()
	mu2.Lock()
	mu2.count++
	mu2.Unlock()
	fmt.Println(mu.count, mu2.count)
}
```

- A: 不能编译
- B: 输出 `1, 1`
- C: 输出 `1, 2`
- **D: panic**

这个原因就是同步对象使用过之后不能再被拷贝，如果上面把`mu.Lock()`和`var mu2 = mu`这两行进行交换一下就可以了。
使用过后不可以复制的对象有：

```GO
// A Cond must not be copied after first use.
type Cond struct 
// A Map must not be copied after first use.
type Map struct
// A Mutex must not be copied after first use.
type Mutex struct
// A Pool must not be copied after first use.
type Pool struct
// A RWMutex must not be copied after first use.
type RWMutex struct
// A WaitGroup must not be copied after first use.
type WaitGroup struct
```

### RWMutex

- RWMutex 是单写多读锁，该锁可以加多个读锁或者一个写锁
- 读锁占用的情况下会阻止写，不会阻止读，多个 goroutine 可以同时获取读锁
- 写锁会阻止其他 goroutine（无论读和写）进来，整个锁由该 goroutine 独占
- 适用于读多写少的场景

#### Lock() 和 Unlock()

- Lock() 加写锁，Unlock() 解写锁
- 如果在加写锁之前已经有其他的读锁和写锁，则 Lock() 会阻塞直到该锁可用，为确保该锁可用，已经阻塞的 Lock() 调用会从获得的锁中排除新的读取器，即写锁权限高于读锁，有写锁时优先进行写锁定
- 在 Lock() 之前使用 Unlock() 会导致 panic 异常

#### RLock() 和 RUnlock()

- RLock() 加读锁，RUnlock() 解读锁
- RLock() 加读锁时，如果存在写锁，则无法加读锁；当只有读锁或者没有锁时，可以加读锁，读锁可以加载多个
- RUnlock() 解读锁，RUnlock() 撤销单词 RLock() 调用，对于其他同时存在的读锁则没有效果
- 在没有读锁的情况下调用 RUnlock() 会导致 panic 错误
- RUnlock() 的个数不得多余 RLock()，否则会导致 panic 错误

```GO
package main
import (
	"fmt"
	"sync"
	"time"
)
var mu sync.RWMutex
var count int
func main() {
	go A()
	time.Sleep(2 * time.Second)
	mu.Lock()
	defer mu.Unlock()
	count++
	fmt.Println(count)
}
func A() {
	mu.RLock()
	defer mu.RUnlock()
	B()
}
func B() {
	time.Sleep(5 * time.Second)
	C()
}
func C() {
	mu.RLock()
	defer mu.RUnlock()
}
```

- A: 不能编译
- B: 输出 `1`
- C: 程序hang住
- **D: panic**

这一题的原因也是一样的，`G`A休眠之后状态就会变为等待，此时,主`G`去那锁也没有那到，就会变为不可运行状态，并让出`cpu`,此时所有的`G`都不可运行就出现死锁了。

## Channel

熟悉Golang的人都知道一句名言：“使用通信来共享内存，而不是通过共享内存来通信”。这句话有两层意思，Go语言确实在`sync`包中提供了传统的锁机制，但更推荐使用`channel`来解决并发问题。

从字面上看，`channel`的意思大概就是管道的意思。`channel`是一种go协程用以接收或发送消息的安全的消息队列，`channel`就像两个go协程之间的导管，来实现各种资源的同步。

使用`channel`时有几个注意点：

- 向一个`nil` `channel`发送消息，会一直阻塞；
- 向一个已经关闭的`channel`发送消息，会引发运行时恐慌`（panic）`；
- channel`关闭后不可以继续向`channel`发送消息，但可以继续从`channel`接收消息；`
- `当`channel`关闭并且缓冲区为空时，继续从从`channel`接收消息会得到一个对应类型的零值。

```go
package main
import (
	"fmt"
	"runtime"
	"time"
)
func main() {
	var ch chan int
	go func() {
		ch = make(chan int, 1)
		ch <- 1
	}()
	go func(ch chan int) {
		time.Sleep(time.Second)
		<-ch
	}(ch)
	c := time.Tick(1 * time.Second)
	for range c {
		fmt.Printf("#goroutines: %d\n", runtime.NumGoroutine())
	}
}
```

- A: 不能编译
- B: 一段时间后总是输出 `#goroutines: 1`
- **C: 一段时间后总是输出 `#goroutines: 2`**
- D: panic

```go
package main
import "fmt"
func main() {
	var ch chan int
	var count int
	go func() {
		ch <- 1
	}()
	go func() {
		count++
		close(ch)
	}()
	<-ch
	fmt.Println(count)
}
```

- A: 不能编译
- B: 输出 `1`
- C: 输出 `0`
- **D: panic**

```go
var ch chan int
ch := make(chan int)

结果：
/**
1
panic: send on closed channel
或者
1
**/
```

题目来源：https://colobu.com/2019/04/28/go-concurrency-quizzes/

