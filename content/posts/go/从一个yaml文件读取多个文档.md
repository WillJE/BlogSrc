---
title: "从一个yaml文件读取多个文档"
date: 2021-04-17T16:25:38+08:00
toc: true
isCJKLanguage: true
tags: [yaml,go]
---

# 简单需求

最近一个需求，从一个yaml文件中读取多个文档，例如有下面的文档结构：

```yaml
name: "doc first"
---
name: "second"
---
name: "skip 3, now 4"
---
```

通过`gopkg.in/yaml.v3``Deocder`可以帮我们解析出来，默认使用"---"来区分不同的文档。

```go
package main

import "fmt"
import "gopkg.in/yaml.v3"
import "os"
import "errors"
import "io"

type Spec struct {
    Name string `yaml:"name"`
}

func main() {
    f, err := os.Open("spec.yaml")
    if err != nil {
        panic(err)
    }
    d := yaml.NewDecoder(f)
    for {
        // create new spec here
        spec := new(Spec)
        // pass a reference to spec reference
        err := d.Decode(&spec)
        // check it was parsed
        if spec == nil {
            continue
        }
        // break the loop in case of EOF
        if errors.Is(err, io.EOF) {
            break
        }
        if err != nil {
            panic(err)
        }
        fmt.Printf("name is '%s'\n", spec.Name)
    }
}
```

# 复杂需求

因为现在的GRPC项目中，`yaml`结构体用到了`any`类型，此时用上面那种方式，解析会出错，所以思来想去，好像只能按行读取yaml文件，然后根据"---"来区分不同的文档，单独解析每个文档即可。



具体可看代码：

```go
f,_ := os.open(filename)
buf := bufio.NewReader(f)
var eachDocument string
byteSlice := make([][]byte, 0)
for {
    b, errR := buf.ReadBytes('\n')
    if errR != nil {
        if errR == io.EOF {
            eachDocument = eachDocument + string(b)
            jsonByte := []byte(eachDocument)
            byteSlice = append(byteSlice, jsonByte)
            break
        }
    } else if "---\r\n" == string(b) {
        eachDocument = eachDocument + string(b)
        jsonByte := []byte(eachDocument)
        byteSlice = append(byteSlice, jsonByte)
        eachDocument = ""
    } else {
        eachDocument = eachDocument + string(b)
    }
}
```

这个`byteSlice`结构体就是我们解析出来的文档。

# 参考资料

- https://stackoverflow.com/questions/53464099/read-multiple-yamls-in-a-file