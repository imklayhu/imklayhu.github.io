---
title: "MongoDB 数据库的备份、恢复和迁移"
date: 2017-08-19 00:00:00
categories:
  - 数据库
tags:
  - MongoDB
---
MongoDB 数据库的备份

```
# （ubuntu用户）进入命令行，输入一下命令，查看mongodump的参数和用法> mongodump --help# （Windows用户）打开cmd ，cd 进入MongoDB安装目录下的bin目录。我的是C:\MongoDB\bin,输入以下命令查看mongodump的参数和用法> mongodump.exe /help
```

 
在这两天我项目中遇到的问题，需要的参数主要有以下(以ubuntu为例，windows下把参数的 `--` 换成 `/`即可)：

```
--username=<username>  // --username:tanker--password=<password> // --password:tanker--host=<hostname> // --host:127.0.0.1:27017--out=<directory-path> // --out:/var/lib/mongodb/dump--db=<database-name> // --db=tank
```

开始备份：

```
> mongodump --username:tanker --password:tanker --host:127.0.0.1:27017 --db:tank --out:/var/lib/mongodb/dump# 备份成功会有提示，不成功会提示你 mongodump --help
```

从备份文件恢复数据库、迁移数据库
之前你已经备份了数据库了，我还没有尝试其他的数据库迁移的方法，我的方法就是—将之前电脑备份的数据库文件copy到现在需要恢复或者迁移的服务器。[emmmm…]我们将备份文件复制到这台服务器的存放数据库文件位置，我的机器是 `/var/lib/mongodb/`,也就是说，现在备份文件的位置是`/var/lib/mongodb/dump/tank/`

开始，从备份文件中恢复数据库使用的命令是 `mongorestore`:

```
# 同样的我们可以使用以下命令查看他的参数和使用方法mongorestore --help
```

在开始备份之前，我希望你在本地已经创建好了数据库，并为数据库创建了管理用户或者读写用户

来看看`mongorestore`都有哪些我需要的参数吧

```
--host=<hostname> // --host:127.0.0.1:27017--username=<username> // --username:tanker--password=<password> // --password:tanker--db=<database-name> // --db:tank--dir=<directory-name> // --dir:/var/lib/mongodb/dump/tank/
```

开始恢复数据库啦～

```
mongorestore --username:tanker --password:tanker --host:127.0.0.1:27017 --db:tank --dir:/var/lib/mongodb/dump/tank/# 恢复成功会有提示，失败提示你去使用 mongorestore --help
```

至此，我的阉割版的MongoDB 数据库的备份、恢复和迁移已经结束了。enjoy～
