---
title: "Deploy Hugo Site_on Github Pages"
date: 2020-10-27T18:16:10+08:00
tags: [ "technology" ]
categories: [ "technology" ]
---

# 将hugo静态博客网页部署到github上

## 1、选择gitpage的类型
2种github page：个人、项目。这里选个人。

## 2、建立gitpage和hugo代码仓库
在github上以自己的用户名+github.io为名建立page的仓库，如我的用户名richard-chen93, 仓库名为richard-chen93.github.io
创建一个仓库用于存放hugo的代码，例如取名为blog。将此blog克隆至本地。将本地能正常运行的hugo站点文件拷贝到blog。
注意：新建立的github.io仓库（任何新建的仓库都建议先添加一个文件，比如readme.md）务必先提交一次再使用submodule。如现在github 页面上进入此仓库，随便新建任何一个文件，点提交。否则仓库可能无法使用或无法添加子仓库。
## 3、删除public目录，建立页面文件的子仓库。
删除blog项目根目录下的public目录,并建立git子仓库
```
rm -rf public
git submodule add -b main git@github.com:richard-chen93/richard-chen93.github.io.git public
```
建立子仓库后，当你执行hugo命令，生成public下的页面文件时，public目录会有一个不同的远程源

## 4、修改hugo配置文件
在hugo站点配置文件 config.toml中，baseurl设置为你的站点名称，如 https://richard-chen93.github.io


## 5、部署脚本，直接拿来用
在blog根目录执行hugo.exe命令后，会在public文件夹生成页面文件。使用deploy.sh脚本即可推送到github上
```
#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project.
hugo ## if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master
```
可以使用deploy.sh ＋ commit message来提交

至此几分钟后即可打开你的gitpage页面。
https://richard-chen93.github.io