---
title: "Golang里的iota"
date: 2021-03-17T16:23:40+08:00
draft: false
categories: [go]
tags: [iota]
---

# 认识

有些概念有名字，并且有时候我们关注这些名字，甚至（特别）是在我们代码中。

```go
const (
    CCVisa            = "Visa"
    CCMasterCard      = "MasterCard"
    CCAmericanExpress = "American Express"
)
```

在其他时候，我们仅仅关注能把一个东西与其他的做区分。有些时候，有些时候一件事没有本质上的意义。比如，我们在一个数据库表中存储产品，我们可能不想以 string 存储他们的分类。我们不关注这个分类是怎样命名的，此外，该名字在市场上一直在变化。



我们仅仅关注它们是怎么彼此区分的。

```go
const (
    CategoryBooks    = 0
    CategoryHealth   = 1
    CategoryClothing = 2
)
```

使用 0, 1, 和 2 代替，我们也可以选择 17， 43， 和 61。这些值是任意的。



常量是重要的，但是它们很难推断，并且难以维护。在一些语言中像 Ruby 开发者通常只是避免它们。在 Go，常量有许多微妙之处。当用好了，可以使得代码非常优雅且易维护的。



看下面一段代码：

```go
const (
    a = iota
    b
    c
)
```

相信你能脱口答出来，常量 a 等于 0，此后定义的常量依次递增，b = 1，c = 2。没毛病，这有何难？



看看下面这段代码，尝试理解一下：

```go
const a = iota

const (
	b = iota
)

const (
	c = 10
	d = iota
	e
	f = "hello"
	// nothing
	g
	h = iota
	i
	j = 0
	k
	l, m = iota, iota
	n, o

	p = iota + 1
	q
	_
	r = iota * iota
	s
	t = r
	u
	v = 1 << iota
	w
	x = iota * 0.01
	y float32 = iota * 0.01
	z
)
```

# 理解

### 第一步：不同 const 定义块互不干扰

```go
const a = iota

const (
	b = iota
)
```

由于 a 和 b 在不同的定义块里，互不影响，所以 a 等于 0 且 b 也等于 0，也不会影响后面的常量定义。所以下面我们重点看后面的常量 c 到 z 。



### 第二步：所有注释行和空行全部忽略

没错，你应该注意到我在代码里安插了一行毫无意义的注释和一行莫名其妙的空行，这是我故意为之，但不用多想，这完全不会影响常量的定义，直接忽略即可。



但需要注意的是，代码_并不是一个空行，它是一个省略了标识符也省略了表达式的常量定义，这一点你需要清楚，不要大意。



所以现在你脑中的代码应该是这样：

```go
const (
	c = 10
	d = iota
	e
	f = "hello"
	g
	h = iota
	i
	j = 0
	k
	l, m = iota, iota
	n, o
	p = iota + 1
	q
	_
	r = iota * iota
	s
	t = r
	u
	v = 1 << iota
	w
	x = iota * 0.01
	y float32 = iota * 0.01
	z
)
```



### 第三步：没有表达式的常量定义复用上一行的表达式

这一步比较关键，golang 在常量定义时是可以省略表达式的，编译时会自动复用上一行的表示式。你问如果上一行也省略了表达式怎么办，继续往上找嘛，由此可见，一个常量定义代码块的第一行定义是不可以省略，否则就不明所以了。

要注意这个特性跟 iota 是没有关系的，即使定义时没有用到 iota，这个特性也仍然有效。

到这里，思路就开始清晰了：

```go
const (
	c = 10
	d = iota
	e = iota
	f = "hello"
	g = "hello"
	h = iota
	i = iota
	j = 0
	k = 0
	l, m = iota, iota
	n, o = iota, iota
	p = iota + 1
	q = iota + 1
	_ = iota + 1
	r = iota * iota
	s = iota * iota
	t = r
	u = r
	v = 1 << iota
	w = 1 << iota
	x = iota * 0.01
	y float32 = iota * 0.01
	z float32 = iota * 0.01
)
```

### 第四步：从第一行开始，iota 从 0 逐行加一

这是一个比较容易混淆人的点，就是赋值表达式里无论是否引用了 iota，也无论引用了多少次，iota 的都会从常量定义块的第一行（注意这里不计空行和注释）开始计数，从 0 开始，逐行加一。

所以在这一步里我们先不用管常量定义的表达式是什么，先把 iota 在当前行的位置的值先写出来，这有助于防止被混淆视听。

形如：

```go
const (
	c = 10 // iota = 0
	d = iota // iota = 1
	e = iota // iota = 2
	f = "hello" // iota = 3
	g = "hello" // iota = 4
	h = iota // iota = 5
	i = iota // iota = 6
	j = 0 // iota = 7
	k = 0 // iota = 8
	l, m = iota, iota // iota = 9
	n, o = iota, iota // iota = 10
	p = iota + 1 // iota = 11
	q = iota + 1 // iota = 12
	_ = iota + 1 // iota = 13
	r = iota * iota // iota = 14
	s = iota * iota // iota = 15
	t = r // iota = 16
	u = r // iota = 17
	v = 1 << iota // iota = 18
	w = 1 << iota // iota = 19
	x = iota * 0.01 // iota = 20
	y float32 = iota * 0.01 // iota = 21
	z float32 = iota * 0.01 // iota = 22
)
```



### 第五步：替换所有 iota

最后一步就比较无脑了，逐行替换出现的 iota 为真实值即可：

```go
const (
	c = 10 // iota = 0
	d = 1 // iota = 1
	e = 2 // iota = 2
	f = "hello" // iota = 3
	g = "hello" // iota = 4
	h = 5 // iota = 5
	i = 6 // iota = 6
	j = 0 // iota = 7
	k = 0 // iota = 8
	l, m = 9, 9 // iota = 9
	n, o = 10, 10 // iota = 10
	p = 11 + 1 // iota = 11
	q = 12 + 1 // iota = 12
	_ = 13 + 1 // iota = 13
	r = 14 * 14 // iota = 14
	s = 15 * 15 // iota = 15
	t = r // iota = 16
	u = r // iota = 17
	v = 1 << 18 // iota = 18
	w = 1 << 19 // iota = 19
	x = 20 * 0.01 // iota = 20
	y float32 = 21 * 0.01 // iota = 21
	z float32 = 22 * 0.01 // iota = 22
)
```

到这里，事情已经水落石出。

无它。

# 参考文章

- [彻底搞懂 golang 里的 iota](https://blog.wolfogre.com/posts/golang-iota/)

- [iota: Golang 中优雅的常量](https://segmentfault.com/a/1190000000656284)