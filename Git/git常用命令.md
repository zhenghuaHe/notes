
# git常用命令集

## 写完东西一次提交的过程
```
$  git add .                 #要提交的文件，可单独指定可以直接指定当前文件夹的所有
$  git commit -m "add file"　＃提交的备注信息，相当于说明
$  git push　　　　　　　　　　　＃推到仓库
```

## 分支常用命令
$ git branch -v （查看本地库中的所有分支）

$ git branch dev (创建一个新的分支)

c)、git checkout dev （切换分支）

d)、分支合并

i)、切换到接收修改的分支

git checkout master

ii)、执行merge命令

git merge dev

（注：切换分支后，在dev分支中做出的修改需要合并到被合并的分支master上)
