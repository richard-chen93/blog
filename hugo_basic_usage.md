# hugo基本用法
## 写博文
1、创建md文件并编辑
```
hugo new post/richard.md
```

3、生成html文件
```
hugo --buildDrafts
```

4、使用deploy.sh脚本，将public静态页面站点同步到git page仓库
```
sh deploy_to_git_page.sh
```
注：以上操作已用脚本简化，编辑完md文件后直接运行sh gitpage_push.sh


## 改博客页面配置
如果改动网站源码，如hugo的配置文件 config.toml：
运行 
```
update_all.sh
```
此脚本功能包括推送更改到hugo代码仓库，更新public下的html，推送至git page。

## 更新文章


## 删除文章