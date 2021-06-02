---
title: "Golang template 使用样例"
date: 2021-03-10T16:23:40+08:00
toc: true
isCJKLanguage: true
tags: [template,go]
---

Go标准库提供了几个package可以产生输出结果，而[text/template ](https://golang.org/pkg/text/template/)提供了基于模板输出文本内容的功能。[html/template](https://golang.org/pkg/html/template/)则是产生 安全的HTML格式的输出。

## 01 text/template样例

Golang `text/template` 包是一个数据驱动的模版渲染工具。提供条件判断，数组或map遍历；参数赋值，函数或方法调用；自定义函数扩展，模板嵌套及重用等功能。基于该工具，可以轻松实现复杂场景的文本渲染。如[Helm Template](https://helm.sh/docs/chart_template_guide/getting_started/)基于此实现了功能强大的Kubernetes配置文件渲染工作。

```go
package main

import (
	"os"
	"strings"
	"text/template"
)

const text = `
{{/* This is a zoo template */}}
{{with .Name}}Welcome to {{.}}{{end}}
There are {{len .Animals}} animals, they are: 
{{range .Animals}}
{{- . | upper -}},
{{end}}
{{if gt (len .Zookeepers) 0}}
There are {{len .Zookeepers}} zookeepers, they are:
{{range $no, $name := .Zookeepers}}
{{printf "%03d" $no}}: {{$name -}}
{{end}}
{{end}}
{{block "Welcome" .Name}}You're welcome to visit {{.}} next time!{{end}}
`

type Zoo struct {
	Name       string
	Animals    []string
	Zookeepers map[int]string
}

func main() {
	// template
	tpl := template.Must(template.New("zoo").Funcs(template.FuncMap{
		"upper": func(s string) string { // self-defined functions
			return strings.ToUpper(s)
		},
	}).Parse(text))

	// zookeepers
	zooKeepers := map[int]string{
		0: "Alan",
		1: "Larry",
		2: "Alice",
	}

	// zoo
	zoo := &Zoo{
		"Beijing Zoo",
		[]string{"elephant", "tiger", "dolphin"},
		zooKeepers,
	}

	// execute
	tpl.Execute(os.Stdout, zoo)
}
```

运行结果

```bash
Welcome to Beijing Zoo
There are 3 animals, they are: 
ELEPHANT,
TIGER,
DOLPHIN,


There are 3 zookeepers, they are:

000: Alan
001: Larry
002: Alice

You're welcome to visit Beijing Zoo next time!
```

## 02 html/template样例

以下内容主要来自：[Go标准库：Go template用法详解](https://www.cnblogs.com/f-ck-need-u/p/10053124.html)

### 入门示例

先看一个例子，以下为test.html文件的内容，里面使用了一个template语法`{{.}}`。

```html
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Go Web</title>
	</head>
	<body>
		{{ . }}
	</body>
</html>
```

以下是test.html同目录下的一个go web程序：

```go
package main

import (
	"html/template"
	"net/http"
)

func tmpl(w http.ResponseWriter, r *http.Request) {
	t1, err := template.ParseFiles("test.html")
	if err != nil {
		panic(err)
	}
	t1.Execute(w, "hello world")
}

func main() {
	server := http.Server{
		Addr: "127.0.0.1:8080",
	}
	http.HandleFunc("/tmpl", tmpl)
	server.ListenAndServe()
}
```

前面的html文件中使用了一个template的语法`{{.}}`，这部分是需要通过go的template引擎进行解析，然后替换成对应的内容。

在go程序中，handler函数中使用`template.ParseFiles("test.html")`，它会自动创建一个模板(关联到变量t1上)，并解析一个或多个文本文件(不仅仅是html文件)，解析之后就可以使用`Execute(w,"hello world")`去执行解析后的模板对象，执行过程是合并、替换的过程。例如上面的`{{.}}`中的`.`会替换成当前对象"hello world"，并和其它纯字符串内容进行合并，最后写入w中，也就是发送到浏览器"hello world"。

本文不解释这些template包的函数、方法以及更底层的理论知识，本文只解释template的语法，如果觉得这些无法理解，或者看不懂官方手册，请看[深入剖析Go template](https://www.cnblogs.com/f-ck-need-u/p/10035768.html)。

### 关于点“.”和作用域

在写template的时候，会经常用到"."。比如`{{.}}`、`{{len .}}`、`{{.Name}}`、`{{$x.Name}}`等等。

在template中，点"."代表**当前作用域的当前对象**。它类似于java/c++的this关键字，类似于perl/python的self。如果了解perl，它更可以简单地理解为默认变量`$_`。

例如，前面示例test.html中`{{.}}`，这个点是顶级作用域范围内的，它代表`Execute(w,"hello worold")`的第二个参数"hello world"。也就是说它代表这个字符串对象。

再例如，有一个Person struct。

```go
type Person struct {
	Name string
	Age  int
}

func main(){
	p := Person{"longshuai",23}
	tmpl, _ := template.New("test").Parse("Name: {{.Name}}, Age: {{.Age}}")
	_ = tmpl.Execute(os.Stdout, p)
}
```

这里`{{.Name}}`和`{{.Age}}`中的点"."代表的是顶级作用域的对象p，所以Execute()方法执行的时候，会将`{{.Name}}`替换成`p.Name`，同理`{{.Age}}`替换成`{{p.Age}}`。

但是并非只有一个顶级作用域，range、with、if等内置action都有自己的本地作用域。它们的用法后文解释，这里仅引入它们的作用域来解释"."。

例如下面的例子，如果看不懂也没关系，只要从中理解"."即可。

```go
package main

import (
	"os"
	"text/template"
)

type Friend struct {
	Fname string
}
type Person struct {
	UserName string
	Emails   []string
	Friends  []*Friend
}

func main() {
	f1 := Friend{Fname: "xiaofang"}
	f2 := Friend{Fname: "wugui"}
	t := template.New("test")
	t = template.Must(t.Parse(
`hello {{.UserName}}!
{{ range .Emails }}
an email {{ . }}
{{- end }}
{{ with .Friends }}
{{- range . }}
my friend name is {{.Fname}}
{{- end }}
{{ end }}`))
	p := Person{UserName: "longshuai",
		Emails:  []string{"a1@qq.com", "a2@gmail.com"},
		Friends: []*Friend{&f1, &f2}}
	t.Execute(os.Stdout, p)
}
```

输出结果

```bash
hello longshuai!

an email a1@qq.com
an email a2@gmail.com

my friend name is xiaofang
my friend name is wugui
```

这里定义了一个Person结构，它有两个slice结构的字段。在Parse()方法中：

- 顶级作用域的`{{.UserName}}`、`{{.Emails}}`、`{{.Friends}}`中的点都代表Execute()的第二个参数，也就是Person对象p，它们在执行的时候会分别被替换成p.UserName、p.Emails、p.Friends。
- 因为Emails和Friend字段都是可迭代的，在`{{range .Emails}}...{{end}}`这一段结构内部`an email {{.}}`，这个"."代表的是range迭代时的每个元素对象，也就是p.Emails这个slice中的每个元素。
- 同理，with结构内部`{{range .}}`的"."代表的是p.Friends，也就是各个，再此range中又有一层迭代，此内层`{{.Fname}}`的点代表Friend结构的实例，分别是`&f1`和`&f2`，所以`{{.Fname}}`代表实例对象的Fname字段。

剩余内容可以去[原文](https://www.cnblogs.com/f-ck-need-u/p/10053124.html)查看。

## 02 参考资料

- https://golang.org/pkg/html/template/
- https://www.cnblogs.com/f-ck-need-u/p/10053124.html