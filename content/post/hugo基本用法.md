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
只需要编辑或删除blog/content/post/test.mde文件，然后再次在根目录执行deploy.sh脚本，即可同步到gitpage

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

## 启动实时预览（本地预览网站效果）
写一篇文章生成一次会很繁琐，可以通过启动网站预览，实时监控页面的更改并刷新页面。

hugo server -D
参数： -D 输出包括标记为 draft: true 的草稿文章

默认地址为 http://localhost:1313 如果 1313 端口被占用，会随机使用其他空端口。

## 若换了新电脑，要在新电脑上发布文章
1、将blog克隆到本地  git clone git@github.com:richard-chen93/blog.git
2、进入blog根目录，删除public文件夹 rm -rf public
3、用以下命令设置子模块
  612  git submodule init
  615  git submodule update
  616  git submodule status
  617  git submodule sync
4、好了以后执行deploy.sh，若有问题可尝试下面的指令修复问题：
  628  git push origin HEAD:main
  629  git checkout main
  630  git push
