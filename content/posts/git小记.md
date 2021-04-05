---
title: "Git小记"
date: 2020-10-05T12:10:00+08:00
draft: true
---

# 分支

## 查看本地分支

```
git branch
```

## 查看远程分支

```
git branch -r
```

## 查看本地和远程所有分支

```
git branch -a
```

## 创建分支

```
git branch [name]//该命令创建分支后不会马上切换到新分支
```

## 创建分支并切换到该分支

```
git checkout -b [name]
```

## 切换分支

```
git checkout [name]

如果希望强制切换，即放弃本地修改，则使用命令
git checkout -f newBranch
```

## 删除分支

```
git branch -d [name] //选项只能删除已经参与了合并的分支，对于未有合并的分支是无法删除的。
如果想强制删除一个分支，可以使用-D选项
```

这只是删除本地分支，删除远程分支使用

```
git push origin -d [name]
```

## 合并分支

```
git merge [name] //将名称为[name]的分支与当前分支合并
```

## 创建远程分支

就是将本地分支提交到远程

```
git push origin [name]
```

另一种方式

```
git push <远程主机名> <本地分支名>:<远程分支名>
```

# 提交

```
git push <远程主机名> <本地分支名>:<远程分支名>
```



# 常用操作

### 合并本地两个分支

**场景**：在一个dev分支开发时，突然出现一个bug需要修改，此时可以选择在dev分支上或者master分支上新建一个分支fixbug01分支；

在fixbug01分支完成bug修复后，需要将fixbug01的修改合并到dev上，以便继续开发，此时可以按照这样操作；

> 参考：[git 使用merge 对本地分支进行合并 并进行代码提交的流程](https://www.cnblogs.com/lowmanisbusy/p/9054087.html)

1. 将fixbug01的修改commit，进行merge前两个分支的修改都要commit
2. 切换到dev分支，`git merge fixbug01`，执行该命令前确保两个分支的修改都已经commit了

- - merge 遇见冲突后会直接停止，等待手动解决冲突并重新提交 commit 后，才能再次 merge
  - merge 是一个合并操作，会将两个分支的修改合并在一起，默认操作的情况下会提交合并中修改的内容



# 参考资料

- [廖雪峰的Git教程](https://www.liaoxuefeng.com/wiki/896043488029600/900003767775424)
- [git 使用merge 对本地分支进行合并 并进行代码提交的流程](https://www.cnblogs.com/lowmanisbusy/p/9054087.html)