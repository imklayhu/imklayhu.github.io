---
title: "Node接收和处理前端的Ajax请求"
date: 2017-08-02 00:00:00
categories:
  - node
tags:
  - node
  - express
  - ajax
---
前几天在学习 `express` 的过程中，不想使用一些类似`ejs`这样的模板中的一些特性，所以尝试着使用ajax来与node后端交互。来这里记录一下。

1. 安装express
当然安装和使用express的前提是，你的设备已经有Node的环境了。没有的话自己去找吧～嘻嘻。    我的环境：`Ubuntu 16.04、node v6.10.2、npm 3.10.10`

- 使用`npm install -g express` ,全局安装express。使用命令`express --version`检查是否正确安装了，如果已经正确的安装，就会打印版本号。
需要注意的是，使用npm的时候有可能会出现权限不足的问题，这时只需要使用 `sudo npm install express`即可。

2. 创建一个express项目
- 命令行进入你想创建项目的路径，使用`express -e my-first-project`创建一个名为my-first-project的项目。

```
install dependencies:     $ cd my-first-project && npm install   run the app:     $ DEBUG=my-first-project:* npm start
```

- 提示我们进入项目目录，并安装依赖：`cd my-first-project && npm install` ,npm 就会开始下载一些项目需要的依赖啦，比如`ejs`

```
my-first-project@0.0.0 /media/clam/Document/WebStormworkspace/Vue/my-first-project├─┬ body-parser@1.17.2 │ ├── bytes@2.4.0 │ ├── content-type@1.0.2 │ ├── debug@2.6.7 │ ├── depd@1.1.1 │ ├─┬ http-errors@1.6.1 │ │ ├── depd@1.1.0 │ │ └── inherits@2.0.3 │ ├── iconv-lite@0.4.15 │ ├─┬ on-finished@2.3.0 │ │ └── ee-first@1.1.1 │ ├── qs@6.4.0 │ ├─┬ raw-body@2.2.0 │ │ └── unpipe@1.0.0 │ └─┬ type-is@1.6.15 │   ├── media-typer@0.3.0 │   └─┬ mime-types@2.1.16 │     └── mime-db@1.29.0 ├─┬ cookie-parser@1.4.3 │ ├── cookie@0.3.1 │ └── cookie-signature@1.0.6 ├─┬ debug@2.6.8 │ └── ms@2.0.0 ├── ejs@2.5.7 ├─┬ express@4.15.3 │ ├─┬ accepts@1.3.3 │ │ └── negotiator@0.6.1 │ ├── array-flatten@1.1.1 │ ├── content-disposition@0.5.2 │ ├── debug@2.6.7 │ ├── encodeurl@1.0.1 │ ├── escape-html@1.0.3 │ ├── etag@1.8.0 │ ├─┬ finalhandler@1.0.3 │ │ └── debug@2.6.7 │ ├── fresh@0.5.0 │ ├── merge-descriptors@1.0.1 │ ├── methods@1.1.2 │ ├── parseurl@1.3.1 │ ├── path-to-regexp@0.1.7 │ ├─┬ proxy-addr@1.1.5 │ │ ├── forwarded@0.1.0 │ │ └── ipaddr.js@1.4.0 │ ├── range-parser@1.2.0 │ ├─┬ send@0.15.3 │ │ ├── debug@2.6.7 │ │ ├── destroy@1.0.4 │ │ └── mime@1.3.4 │ ├── serve-static@1.12.3 │ ├── setprototypeof@1.0.3 │ ├── statuses@1.3.1 │ ├── utils-merge@1.0.0 │ └── vary@1.1.1 ├─┬ morgan@1.8.2 │ ├── basic-auth@1.1.0 │ └── on-headers@1.0.1 └─┬ serve-favicon@2.4.3   └── safe-buffer@5.0.1
```

震惊！居然有这么多..

- 接下来我们来看看项目的文件结构吧

```
.├── app.js├── bin│   └── www├── node_modules│   └── 这里有一堆文件..│   ├── package.json├── public│   ├── images│   ├── javascripts│   └── stylesheets│       └── style.css├── routes│   ├── index.js│   └── users.js└── views    ├── error.ejs    └── index.ejs
```

- bin 存放我们最终上线部署的文件;

- node_modules 存放我们项目中下载的依赖;

- package.json 我们项目的一些配置文件的设置，项目的信息等。

- public 存放一些静态文件，图片呀，字体呀，css呀，js呀什么的。

- routes 我们项目的路由就在这里编写，相当于controller。下面有两个示例路由文件。

- views  我们项目的视图就是放在这里的。下面有两个示例的试图文件，在这里你会发现是`.ejs`文件。这是因为我们在创建项目的时候使用了ejs模板引擎。等开始之后我们不会用他。

- app.js 这个文件，是我们项目的入口。

- 让我们来启动项目看效果吧～使用命令`node ./bin/www`或者`npm start`都可以启动项目。然后我们打开浏览器，输入 http://127.0.0.1:3000,就可以看到效果了。
Welcome to Express!

3. 进入正题
扯了那么多终于进入正题了。不过在此之前，我们首先要将.ejs文件改成.html,这样顺眼多了..

- 打开 app.js找到 `// view engine setup`，在下面添加代码

```
app.engine('.html', ejs.__express);app.set('view engine', 'html');
```

在顶端引入ejs

```javascript
var ejs = require('ejs');做完这些修改之后，记得将views文件夹下面的文件后缀全都修改成.html哈，当然虽然是.html文件，但是依旧可以使用ejs的特性。
```

做完这些修改之后，记得将views文件夹下面的文件后缀全都修改成.html哈，当然虽然是.html文件，但是依旧可以使用ejs的特性。

- 编写前端视图文件就在 `index.html`文件的基础上修改好了。下面是我写的demo：

```
// index.html<!DOCTYPE html><html>  <head>    <title>Demo</title>    <link rel='stylesheet' href='/stylesheets/style.css' />    <script src="/javascripts/jquery.min.js"></script>  </head>  <body>    <nav>      <input type="text" id="searchKeyWord"><button type="button" id="search">Search</button>    </nav>    <div>      <label for="title">Title:</label>      <input type="text" id="title" value="" placeholder="TITLE"><br>      <label for="content">Content:</label>      <input type="text" id="content" value="" placeholder="Content"><br>      <button id="submit">submit</button>    </div>  </body></html>
```

写到这里，觉得还是给这个小项目创建一个数据库吧，这样写起来可能更有意思一点。

- 创建数据库

```
# 已经开启了用户认证，所以首先在命令行中先为数据库创建用户>mongo>use blog >db.createUser(  {    user:'bloger',    pwd:'bloger',    roles:[      {        role:'readWrite',        db:'blog'      }    ]  })#创建成功
```

进入项目目录，安装mongoose,打开 `package.json`，添加mmongoose依赖。

```
"dependencies": {    "body-parser": "~1.17.1",    "cookie-parser": "~1.4.3",    "debug": "~2.6.3",    "ejs": "~2.5.6",    "express": "~4.15.2",    "morgan": "~1.8.1",    "serve-favicon": "~2.4.2",    "mongoose":"4.11.5" // 添加mongoose依赖  }# 保存之后，在命令行中重新安装依赖> npm install
```

创建结构如下目录：

```
│—— models|  └── dbs│     ├── contents.js└── db.js
```

以下是 db.js的内容：

```javascript
var mongoose = require('mongoose');// 设置存储路径var DB_URL = 'mongodb://bloger:bloger@127.0.0.1:27017/blog';//连接数据库mongoose.connect(DB_URL);// 连接成功之后输出语句mongoose.connection.on("connected",function(){    console.log('Mongoose connect ' + DB_URL + ' success');});// 数据库连接失败之后 输出错误信息mongoose.connection.on('error',function(err){    console.log("Mongoose connect error: " + err);});// 断开数据库连接之后 输出日志mongoose.connection.on("disconnected",function(){    console.log('Mongoose connect disconnected');})module.exports = mongoose;
```

以下是contents.js的内容：

```javascript
var mongoose = require('../db');var Schema = mongoose.Schema;var blogSchema = new Schema({    title:String,    author:String,    content:String,    date: Date})module.exports = mongoose.model('blog',blogSchema);
```

以上就是在命令行建立数据库、为数据库创建用户以及服务端使用mongoose模块操作数据库的代码。接下来，来看看前端如何使用ajax发起post请求。

- 前端发起ajax请求

```
<!-- 使用jquery 来写ajax。首先在head标签中引入jquery。才能在这里用的。 --><!-- script --><script>    $(function () {      $("#submit").click(function () {          var url = "/"; /*后端暴露给前端的接口*/          var data = {            title: $('#title').val(),            author: $('#author').val(),            content: $('#content').val()          }          $.ajax({            url: url,            data: data,            dataType: 'json',            method: 'post',            success: function (result) {              console.log(result);            },            error: function (err) {              console.log("something error: " + err);            }          });        })    })  </script>
```

- 后端如何接收和处理ajax的post请求

```
// router/index.jsvar express = require('express');var router = express.Router();// 引入数据库模块var blogSchema = require('../models/dbs/contents');/* GET home page. */router.get('/', function(req, res, next) {  res.render('index.html');});// post 请求router.post('/',function(req,res,next){  // 接收和处理post请求  var blogStatus = new blogSchema({    title: req.body.title,    author:req.body.author,    content:req.body.content,    date: new Date()  });  blogSchema.collection.insert(blogStatus,function(err,result){    if(err){      console.log("insert error: "+ err);    }else{      console.log("insert success: "+result);      res.send(result);      //res.location('/allblogs');    }  });});module.exports = router;
```

- 好的，现在让我们来启动项目，看看效果。

```
# 首先启动mongodb服务sudo systemctl start mongod# 输入密码node ./bin/www(node:5289) DeprecationWarning: `open()` is deprecated in mongoose >= 4.11.0, use `openUri()` instead, or set the `useMongoClient` option if using `connect()` or `createConnection()`. See http://mongoosejs.com/docs/connections.html#use-mongo-clientDb.prototype.authenticate method will no longer be available in the next major release 3.x as MongoDB 3.6 will only allow auth against users in the admin db and will no longer allow multiple credentials on a socket. Please authenticate using MongoClient.connect with auth credentials.Mongoose connect mongodb://bloger:bloger@127.0.0.1:27017/blog success
```

打开浏览器，访问：localhost:3000 或者 127.0.0.1：3000

- 让我们输入内容

- node后台就会看到请求已经成功而且数据库数据插入已经完成。

```
# 查看数据库>mongo >use blog>db.auth("bloger","bloger")1>show collectionsblogs>db.blogs.find(){ "_id" : ObjectId("5987221da7794315386922c9"), "title" : "first", "author" : "Klay", "content" : "success?", "date" : ISODate("2017-08-06T14:05:17.563Z") }
```

至此,前端ajax与node后台的交互，全部完成。demo很粗糙，但是应该能说明问题。有时间再做打磨吧～enjoy.

demo[呆萌] 在这里
