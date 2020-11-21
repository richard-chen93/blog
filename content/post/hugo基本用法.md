---
title: "Hugo基本用法"
date: 2020-10-28T10:29:18+08:00

---

## hugo本地创建、更新、删除文章后同步到gitpage的基本流程：

## 前提环境：
public目录位于blog目录下，属于blog的子仓库submodule 使用命令 git submodule status可看到
注意 写文章后直接sh deploy.sh，不用单独运行hugo相关任何命令

结论，改动blog仓库之前，确保public子仓库所有改动已提交 已push
问题： 如果仓库有子模块，任何情况下都先确保子模块commit和push以后，才可以同步父仓库？否则子模块就失效？


## 1、写文章
在blog项目根目录下执行 hugo new post/test.md 创建了一个md文件
vim content/post/test.md 移除 draft: true这一行  否则草稿不会公开为文章

## 2、发布文章到gitpage
blog根目录下执行deploy.sh脚本，成功以后等待约1分钟，gitpage上即可看到更新后的内容

## 3、修改、删除文章
只需要编辑或删除blog/content/post/下的md文件，然后再次在根目录执行deploy.sh脚本，即可同步到gitpage

## 4、同步本地blog仓库文件到github
任何本地blog根目录的文件，包括content/post下的md文件，或者config.toml配置文件，更新后都可以执行second-push.sh，远端仓库立即生效。second-push.sh内容为（git add --all . && git commit -m "update" && git push）

## 5、其他
对md文章或config.toml做任何改动以后，首先需要执行deploy.sh。然后如有需求再执行second-push.sh

## 其他：克隆此仓库
git clone git@github.com:richard-chen93/blog.git

## 其他  待删除，可以尝试的命令：
git submodule sync
git submodule init
git submodule update

## 添加tags
博客根目录下的archetypes目录下，也有一个default.md文件。这是hugo新建md文件的默认模板

## 启动实时预览（本地预览网站效果）
写一篇文章生成一次会很繁琐，可以通过启动网站预览，实时监控页面的更改并刷新页面。
hugo server -D
参数： -D 输出包括标记为 draft: true 的草稿文章

默认地址为 http://localhost:1313 如果 1313 端口被占用，会随机使用其他空端口。

## 若换了新电脑，要在新电脑上发布文章
* 1、将blog克隆到本地  
```
git clone git@github.com:richard-chen93/blog.git
```
* 2、进入blog根目录，删除public文件夹 
```
rm -rf public
```
* 3、用以下命令设置子模块
```
 git submodule init
 git submodule update
 git submodule status
 git submodule sync
```
此时执行deploy可能会报错：
fatal: You are not currently on a branch.
To push the history leading to the current (detached HEAD)
state now, use

    git push origin HEAD:<name-of-remote-branch>

可尝试下面的指令修复问题：(在blog目录或public目录下都做)
```
  git checkout main
  git push origin HEAD:main
  git push -f
```
如果再有如下报错：
```
Auto-merging search/index.json
CONFLICT (content): Merge conflict in search/index.json
Auto-merging post/index.html
Auto-merging index.html
Auto-merging archives/index.html
Automatic merge failed; fix conflicts and then commit the result.
```
这样处理：
```
git add search/index.json
git commit -s
git push

```
## 问题记录
执行 hugo --cleanDestinationDir, 若blog仓库content/post下有删除的md文章，则public/post下对应的html文章也会同步删除。然后执行deploy.sh之后，git就会报错：
```
 # On branch main
 # Untracked files:
 #   (use "git add <file>..." to 
 # include in what will be 
 # committed)
 #      ../content/post/1.md
nothing added to commit but untracked files present (use "git add" to track)
```
所以目前不要动public目录下的任何东西，更新文章只在blog下进行，再deploy到gitpage即可。



