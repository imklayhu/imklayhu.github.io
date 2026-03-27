---
title: sinopia搭建内部npm后端和在客户端如何使用内部npm进行开发
date: 2018-07-26 00:00:00
categories:
  - node
tags:
  - npm
  - sinopia
---
`sinopia`搭建内部`npm`
服务器：CentOS 7原料：安装Node.js,npm

1. 使用`npm`安装`yarn`在CentOS使用nvm安装好指定版本的NodeJS之后，使用npm安装yarn模块。使用yarn进行node package的管理。（优势，速度比npm快，install成功率更高）使用如下命令：

```
# 全局安装yarnnpm install -g yarn
```

2. 使用`yarn`安装和配置`sinopia`全局安装yarn之后，使用yarn全局安装sinopia，运行sinopia。发现未找到sinopia命令。

```
# 全局安装sinopiayarn global add sinopia# 运行sinopiasinopia# 未找到sinopia命令
```

需要使用命令`yarn global bin`查看yarn下载的依赖安装的位置，加入系统的path中。

```
yarn global bin# /home/unisolnpmadmin/.yarn/bin# 使用下面的命令把yarn的path加入系统的pathexport PATH=$PATH:/home/unisolnpmadmin/.yarn/bin
```

配置完成之后，使用sinopia命令启动sinopia服务

```
sinopia# warn  --- config file - /home/unisolnpmadmin/.config/sinopia/config.yaml# warn  --- http address - http://localhost:4873/# 打印出来的就是sinopia的配置文件地址和服务启动的端口信息
```

接下来修改sinopia的配置文件，使得其他的客户端可以访问这个服务。

```
## This is the default config file. It allows all users to do anything,# so don't use it on production systems.## Look here for more config file examples:# https://github.com/rlidwka/sinopia/tree/master/conf## path to a directory with all packagesstorage: ./storageauth:  htpasswd:    file: ./htpasswd    # Maximum amount of users allowed to register, defaults to "+inf".    # You can set this to -1 to disable registration.    #max_users: 1000# a list of other known repositories we can talk touplinks:  npmjs:    url: https://registry.npmjs.org/packages:  '@*/*':    # scoped packages    access: $all    publish: $authenticated  '*':    # allow all users (including non-authenticated users) to read and    # publish all packages    #    # you can specify usernames/groupnames (depending on your auth plugin)    # and three keywords: "$all", "$anonymous", "$authenticated"    access: $all    # allow all known users to publish packages    # (anyone can register by default, remember?)    publish: $authenticated    # if package is not available locally, proxy requests to 'npmjs' registry    proxy: npmjs# log settingslogs:  - {type: stdout, format: pretty, level: http}  #- {type: file, path: sinopia.log, level: info}# 这里添加listen，其他的客户端也可以访问该服务。listen: 0.0.0.0:4873
```

以上的配置修改之后，重新一下sinopia，这时候发现其他的客户端还不能访问这个服务，还需要开放CentOS的防火墙和指定端口。

3. 开放CentOS的指定端口
使用firewalld修改和配置CentOS的防火墙

1.启动防火墙

```
systemctl start firewalld
```

2.禁用防火墙

```
systemctl stop firewalld
```

3.设置开机启动

```
systemctl enable firewalld
```

4.停止并禁用开机启动

```
sytemctl disable firewalld
```

5.重启防火墙

```
firewall-cmd --reload
```

6.查看状态

```
systemctl status firewalld或者 firewall-cmd --state
```

7.查看版本

```
firewall-cmd --version
```

8.查看帮助

```
firewall-cmd --help
```

9.查看区域信息

```
firewall-cmd --get-active-zones
```

10.查看指定接口所属区域信息

```
firewall-cmd --get-zone-of-interface=eth0
```

11.拒绝所有包

```
firewall-cmd --panic-on
```

12.取消拒绝状态

```
firewall-cmd --panic-off
```

13.查看是否拒绝

```
firewall-cmd --query-panic
```

14.将接口添加到区域(默认接口都在public)

```
firewall-cmd --zone=public --add-interface=eth0(永久生效再加上 --permanent 然后reload防火墙)
```

15.设置默认接口区域

```
firewall-cmd --set-default-zone=public(立即生效，无需重启)
```

16.更新防火墙规则

```
firewall-cmd --reload或firewall-cmd --complete-reload(两者的区别就是第一个无需断开连接，就是firewalld特性之一动态添加规则，第二个需要断开连接，类似重启服务)
```

17.查看指定区域所有打开的端口

```
firewall-cmd --zone=public --list-ports
```

18.在指定区域打开端口（记得重启防火墙）

```
firewall-cmd --zone=public --add-port=80/tcp(永久生效再加上 --permanent)
```

我们只需要开放端口4873就可以，然后重启防火墙。

现在我们在客户端访问 `http://serverip:4873`的时候，就会看到，sinopia已经可以访问了。

4. 使用`pm2`保护内部`sinopia`的进程node的进程很脆弱，所以我们使用pm2保护sinopia的进程。

```
# 安装pm2yarn global add pm2# 使用pm2启动sinopiapm2 start `which sinopia`
```

关于pm2，有好多好用的东西，查看服务的日志，查看服务的状态等。有待挖掘。

至此，sinopia的服务端的配置稍微告一段落，更多个性化的配置，可以在后面添加。接下来介绍一下开发者如何在自己的客户端上使用刚才搭建的sinopia的服务。

客户端如何使用内部npm进行开发
关键字：`npm、yarn、nvm、nrm`

1. 使用`npm`下载`yarn`鉴于很多时候，yarn的package的管理效率高于npm，所以我们使用安装yarn下载我们需要的一些包。下载方式前面已经介绍过了，不赘述。

2. 使用`yarn`下载`nrm`mrn是管理npm下载node package的源的工具，使用nrm可以优雅的控制使用哪一个源来进行`npm install xxx`.我们选择使用yarn全局安装

```
yarn global add nrm
```

安装完成之后，先来看看当前客户端有哪些npm install的源。

```
nrm ls* npm ---- https://registry.npmjs.org/  cnpm --- http://r.cnpmjs.org/  taobao - https://registry.npm.taobao.org/  nj ----- https://registry.nodejitsu.com/  rednpm - http://registry.mirror.cqupt.edu.cn/  npmMirror  https://skimdb.npmjs.com/registry/  edunpm - http://registry.enpmjs.org/
```

3. 配置客户端的`npm --registry`接下来使用nrm把我们的sinopia源添加进去。

```
nrm add unisolnpm http://192.168.90.185:4873    add registry unisolnpm success
```

再次运行`nrm ls`

```
* npm ---- https://registry.npmjs.org/  cnpm --- http://r.cnpmjs.org/  taobao - https://registry.npm.taobao.org/  nj ----- https://registry.nodejitsu.com/  rednpm - http://registry.mirror.cqupt.edu.cn/  npmMirror  https://skimdb.npmjs.com/registry/  edunpm - http://registry.enpmjs.org/  unisolnpm -  http://192.168.90.185:4873/
```

然后我们使用nrm切换到内部的npm源中

```
nrm use unisolnpm
```

4. 客户端创建用户和登录接下来我们就可以使用npm在内部npm 服务上创建用户了。

使用命令

```
npm adduser # 接下来根据指示操作就可以完成注册用户。# 使用 npm login进行登录操作npm login# 根据指示填写信息，就可以完成登录。
```

5. `install package`和`publish package`登录npm之后，我们就可以使用我们内部的npm源进行node package的安装和发布了。

`install package`当我们使用`npm install xxx`安装`xxx`时，假设在内部的`storage`存在该模块，就会直接下载该模块，假设不存在，就会使用在`sinopia`配置文件中配置的源进行拉取安装，并在`sinopia`的`storage`中进行缓存，方便下次安装。

`publish package`

- 使用`npm init`初始化

- 进入该项目目录，然后使用`npm publish`进行发布

```
npm publish# 打印出发布的包名和版本信息，表示发布成功。
```

发布的时候要注意包名称和版本号冲突的问题，稍作修改就搞了。

后面还需要进行更多的研究。

以上，搭建内部的npm源服务就结束了，enjoy～
