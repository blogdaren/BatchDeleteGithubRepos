
## 一个纯粹的Shell脚本
在线一个个删除项目太麻烦了，有了这个脚本就好了：专门用于批量删除github个人名下的项目.

## 如何使用该脚本？
直接使用自带的`sh`命令执行，默认无参会显示如下详细使用说明：


```
[脚本执行说明]

$ sh BatchDeleteGithubRepos.sh [show|fetch|remove]

[可用命令说明]

1. show:   查看本地自行配置好的待删公共项目
2. fetch:  根据用户名在线查询名下的公共项目
2. remove: 根据配置文件批量删除指定公共项目

[脚本使用说明]

1. 首先手动打开本批量删除脚本, 总共需要配置两个选项：username 和 token
2. 在脚本开头处配置在GIHUB官网上的个人用户名,  即: USERNAME='在这里填写你自己的用户名'
3. 在脚本开头处配置在GIHUB官网上生成好的TOKEN, 即: TOKEN='在这里填写你自己的TOKEN'
4. 在脚本的同级目录下手动创建一个文本文件，文件名必须命名为：repos.txt, 用于配置待删项目
5. 打开repos.txt文件新增待删项目，支持批量删除，所以一行一个, 格式形如：username/reponame
6. 最后保存脚本，然后执行: sh BatchDeleteGithubRepos.sh [show|fetch|remove]
```

## 使用技巧
当待删项目较多的时候，手动一行一行配置多少还是有些笨拙，
可以配合fetch命令先导出到待删配置文件，然后再修改下就好了：

```
$ sh BatchDeleteGithubRepos.sh fetch > repos.txt
```






