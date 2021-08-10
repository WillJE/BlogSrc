---
title: "由浅入深聊聊Golang的context"
date: 2021-05-01T16:23:40+08:00
toc: true
isCJKLanguage: true
tags: [go,context]
---

## context详解

### 1.1 产生背景

在go的1.7之前，context还是非编制的(包golang.org/x/net/context中)，golang团队发现context这个东西还挺好用的，很多地方也都用到了，就把它收编了，**1.7版本正式进入标准库**。

context常用的使用姿势： 1.web编程中，一个请求对应多个goroutine之间的数据交互 2.超时控制 3.上下文控制

### 1.2 context的底层结构

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key interface{}) interface{}
}
```

这个就是Context的底层数据结构，来分析下：

| 字段     | 含义                                                         |
| -------- | ------------------------------------------------------------ |
| Deadline | 返回一个time.Time，表示当前Context应该结束的时间，ok则表示有结束时间 |
| Done     | 当Context被取消或者超时时候返回的一个close的channel，告诉给context相关的函数要停止当前工作然后返回了。(这个有点像全局广播) |
| Err      | context被取消的原因                                          |
| Value    | context实现共享数据存储的地方，是协程安全的（还记得之前有说过[map是不安全](https://blog.csdn.net/u011957758/article/details/82846609)的？所以遇到map的结构,如果不是sync.Map,需要加锁来进行操作） |

同时包中也定义了提供cancel功能需要实现的接口。这个主要是后文会提到的“取消信号、超时信号”需要去实现。

```go
// A canceler is a context type that can be canceled directly. The
// implementations are *cancelCtx and *timerCtx.
type canceler interface {
	cancel(removeFromParent bool, err error)
	Done() <-chan struct{}
}
```

那么库里头提供了4个Context实现，来供大家玩耍

| 实现      | 结构体                                                       | 作用                                                         |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| emptyCtx  | type emptyCtx int                                            | 完全空的Context，实现的函数也都是返回nil，仅仅只是实现了Context的接口 |
| cancelCtx | type cancelCtx struct {   Context   mu   sync.Mutex   done     chan struct{}      children map[canceler]struct{}   err      error   } | 继承自Context，同时也实现了canceler接口                      |
| timerCtx  | type timerCtx struct {    cancelCtx   timer *time.Timer // Under cancelCtx.mu.   deadline time.Time } | 继承自**cancelCtx**，增加了timeout机制                       |
| valueCtx  | type valueCtx struct {   Context   key, val interface{} }    | 存储键值对的数据                                             |

### 1.3 context的创建

为了更方便的创建Context，包里头定义了Background来作为所有Context的根，它是一个emptyCtx的实例。

```go
var (
    background = new(emptyCtx)
    todo       = new(emptyCtx) // 
)

func Background() Context {
    return background
}
```

你可以认为所有的Context是树的结构，Background是树的根，当任一Context被取消的时候，那么继承它的Context 都将被回收。

## 2.context实战应用

### 2.1 WithCancel

实现源码：

```go
func WithCancel(parent Context) (ctx Context, cancel CancelFunc) {
	c := newCancelCtx(parent)
	propagateCancel(parent, &c)
	return &c, func() { c.cancel(true, Canceled) }
}
```

实战场景： 执行一段代码，控制**执行到某个度**的时候，整个程序结束。

吃汉堡比赛，奥特曼每秒吃0-5个，计算吃到10的用时 实战代码：

```go
func main() {
	ctx, cancel := context.WithCancel(context.Background())
	eatNum := chiHanBao(ctx)
	for n := range eatNum {
		if n >= 10 {
			cancel()
			break
		}
	}

	fmt.Println("正在统计结果。。。")
	time.Sleep(1 * time.Second)
}

func chiHanBao(ctx context.Context) <-chan int {
	c := make(chan int)
	// 个数
	n := 0
	// 时间
	t := 0
	go func() {
		for {
			//time.Sleep(time.Second)
			select {
			case <-ctx.Done():
				fmt.Printf("耗时 %d 秒，吃了 %d 个汉堡 \n", t, n)
				return
			case c <- n:
				incr := rand.Intn(5)
				n += incr
				if n >= 10 {
					n = 10
				}
				t++
				fmt.Printf("我吃了 %d 个汉堡\n", n)
			}
		}
	}()

	return c
}
```

输出：

```go
我吃了 1 个汉堡
我吃了 3 个汉堡
我吃了 5 个汉堡
我吃了 9 个汉堡
我吃了 10 个汉堡
正在统计结果。。。
耗时 6 秒，吃了 10 个汉堡 
```

### 2.2 WithDeadline & WithTimeout

实现源码：

```go
func WithDeadline(parent Context, d time.Time) (Context, CancelFunc) {
	if cur, ok := parent.Deadline(); ok && cur.Before(d) {
		// The current deadline is already sooner than the new one.
		return WithCancel(parent)
	}
	c := &timerCtx{
		cancelCtx: newCancelCtx(parent),
		deadline:  d,
	}
	propagateCancel(parent, c)
	dur := time.Until(d)
	if dur <= 0 {
		c.cancel(true, DeadlineExceeded) // deadline has already passed
		return c, func() { c.cancel(true, Canceled) }
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.err == nil {
		c.timer = time.AfterFunc(dur, func() {
			c.cancel(true, DeadlineExceeded)
		})
	}
	return c, func() { c.cancel(true, Canceled) }
}

func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc) {
	return WithDeadline(parent, time.Now().Add(timeout))
}
```

实战场景： 执行一段代码，控制**执行到某个时间**的时候，整个程序结束。

吃汉堡比赛，奥特曼每秒吃0-5个，用时10秒，可以吃多少个 实战代码：

```go
func main() {
    // ctx, cancel := context.WithDeadline(context.Background(), time.Now().Add(10))
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	chiHanBao(ctx)
	defer cancel()
}

func chiHanBao(ctx context.Context) {
	n := 0
	for {
		select {
		case <-ctx.Done():
			fmt.Println("stop \n")
			return
		default:
			incr := rand.Intn(5)
			n += incr
			fmt.Printf("我吃了 %d 个汉堡\n", n)
		}
		time.Sleep(time.Second)
	}
}
```

输出：

```go
我吃了 1 个汉堡
我吃了 3 个汉堡
我吃了 5 个汉堡
我吃了 9 个汉堡
我吃了 10 个汉堡
我吃了 13 个汉堡
我吃了 13 个汉堡
我吃了 13 个汉堡
我吃了 14 个汉堡
我吃了 14 个汉堡
stop 
```

### 2.3 WithValue

实现源码：

```go
func WithValue(parent Context, key, val interface{}) Context {
	if key == nil {
		panic("nil key")
	}
	if !reflect.TypeOf(key).Comparable() {
		panic("key is not comparable")
	}
	return &valueCtx{parent, key, val}
}
```

实战场景： 携带关键信息，为全链路提供线索，比如接入elk等系统，需要来一个trace_id，那WithValue就非常适合做这个事。 实战代码：

```go
func main() {
	ctx := context.WithValue(context.Background(), "trace_id", "88888888")
	// 携带session到后面的程序中去
	ctx = context.WithValue(ctx, "session", 1)

	process(ctx)
}

func process(ctx context.Context) {
	session, ok := ctx.Value("session").(int)
	fmt.Println(ok)
	if !ok {
		fmt.Println("something wrong")
		return
	}

	if session != 1 {
		fmt.Println("session 未通过")
		return
	}

	traceID := ctx.Value("trace_id").(string)
	fmt.Println("traceID:", traceID, "-session:", session)
}
```

输出：

```
traceID: 88888888 -session: 1
```

## 3.context建议

不多就一个。

**Context要是全链路函数的第一个参数**。

```go
func myTest(ctx context.Context)  {
    ...
}
```