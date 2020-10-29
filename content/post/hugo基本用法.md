---
title: "Hugo基本用法"
date: 2020-10-28T10:29:18+08:00

---

## 写博文
1、创建md文件并编辑。注意draft: trues时，处于草稿状态时不发布。处于false状态时才发布。
```
hugo new post/richard.md
```

3、生成html文件
```
hugo
```

4、使用deploy.sh脚本，将public静态页面站点同步到git page仓库
```
sh deploy_to_git_page.sh
```


## 假如还改动了博客页面配置
改动网站源码，如hugo的配置文件 config.toml：
运行 
```
sh update.sh
sh deploy_to_git_page.sh
```
此脚本功能包括推送更改到hugo代码仓库，更新public下的html，推送至git page。

## 更新文章


## 删除文章

## 其他
6. 启动实时预览（本地预览网站效果）
写一篇文章生成一次会很繁琐，可以通过启动网站预览，实时监控页面的更改并刷新页面。

hugo server -D
参数： -D 输出包括标记为 draft: true 的草稿文章

默认地址为 http://localhost:1313 如果 1313 端口被占用，会随机使用其他空端口。
