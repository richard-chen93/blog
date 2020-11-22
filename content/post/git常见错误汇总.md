---
title: "Git常见错误汇总"
date: 2020-10-27T18:15:05+08:00
tags: [ "technology" ]
categories: [ "technology" ]
---

## 1 无法push
A git directory for 'public' is found locally with remote(s):
  origin        https://github.com/richard-chen93/.........git
If you want to reuse this local git directory instead of cloning again from
  https://github.com/richard-chen93/......git
use the '--force' option. If the local git directory is not the correct repo
or you are unsure what this means choose another name with the '--name' option.

删除.git\modules 的 public

## 2 git push时总让输入密码
git push的时候每次都要输入用户名和密码的问题解决
换了个ssh key,发现每次git push origin master的时候都要输入用户名和密码
原因是在添加远程库的时候使用了https的方式。。所以每次都要用https的方式push到远程库
查看使用的传输协议:
git remote -v

git remote rm origin
git remote add origin git@github.com:username/repository.git
git push -u origin master

git remote -v


## 无法push 
git push -u origin master
error: src refspec master does not match any
error: failed to push some refs to 'github.com:richard-chen93/hugo.git'

reset --hard：重置stage区和工作目录:
reset --hard 会在重置 HEAD 和branch的同时，重置stage区和工作目录里的内容。当你在 reset 后面加了 --hard 参数时，你的stage区和工作目录里的内容会被完全重置为和HEAD的新位置相同的内容。换句话说，就是你的没有commit的修改会被全部擦掉。

例如你在上次 commit 之后又对文件做了一些改动：把修改后的ganmes.txt文件add到stage区，修改后的shopping list.txt保留在工作目录

## 05 git submodule add error: does not have a commit checked out
1、新建的仓库，要至少提交一次更改（比如直接在github web页面随便添加一个任何文件，然后点提交。）
2、删除public文件夹。


## 06 fatal: You are not currently on a branch. To push the history leading to the current (detached HEAD) state now, use      git push origin HEAD:<name-of-remote-branch>

运行命令
git checkout main
即可解决

## 07
如下报错：
```
Auto-merging search/index.json
CONFLICT (content): Merge conflict in search/index.json
Auto-merging post/index.html
Auto-merging index.html
Auto-merging archives/index.html
Automatic merge failed; fix conflicts and then commit the result.
```
处理方法：
```
git add search/index.json
git commit -s
git push

```


                
