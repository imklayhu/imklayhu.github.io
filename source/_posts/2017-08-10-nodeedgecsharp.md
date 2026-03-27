---
title: "通过edge.js调用C# 动态链接库 dll，我踩踩坑什么的"
date: 2017-08-10 00:00:00
categories:
  - node
tags:
  - node
  - edge.js
  - C#
---
使用edge.js调用.dll文件 第二次补充：edgejs按我个人理解，是一个允许通过Node去调用 C# 的一个库。因为最近的项目需要才接触的。具体参考这里[edge.js Github]

使用npm init初始化项目，安装依赖edge,npm install -gd edge.C#代码，经过编译之后生成了print.dll文件 

```
using System;using System.Collections.Generic;using System.Linq;using System.Text;using System.Threading.Tasks;namespace print{    public class Print    {        public async Task<object> getPrinter(Object input)        {            String [] printers = (String[])input;            String Printer = "";            String TagPrinter = "";            String Scanner = "";            for (int i = 0; i < printers.Length; i++)            {                Printer = printers[0].ToString();                TagPrinter = printers[1].ToString();                Scanner = printers[2].ToString();            }                        usePrinter(Printer);                        useTagPrinter(TagPrinter);                        useScanner(Scanner);            return null;        }        public static void usePrinter(string printer)        {            Console.WriteLine(printer);        }        public static void useTagPrinter(string printer)        {            Console.WriteLine(printer);        }        public static void useScanner(string printer)        {            Console.WriteLine(printer);        }    }}
```

```
///index.js文件代码var edge = require('edge');var url = require('url');var util = require('util');var getPrinter = edge.func('E:/workspace/Csharpworkspace/nodecs/print.dll');var input = ['Printer','TagPrinter','Scanner'];getPrinter(input,function(error,result){    if(error) throw error;    console.log(result);});
```

node index运行
C# 要用突然学了两天 :-) ，额~然后报错的信息如下。

```
E:\workspace\Csharpworkspace\nodecs\node_modules\edge\lib\edge.js:169    return edge.initializeClrFunc(options);                ^Error: 未能从程序集“print, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null”中加载类型“print.Startup”。    at Error (native)    at Object.exports.func (E:\workspace\Csharpworkspace\nodecs\node_modules\edge\lib\edge.js:169:17)    at Object.<anonymous> (E:\workspace\Csharpworkspace\nodecs\index.js:3:23)    at Module._compile (module.js:570:32)    at Object.Module._extensions..js (module.js:579:10)    at Module.load (module.js:487:32)    at tryModuleLoad (module.js:446:12)    at Function.Module._load (module.js:438:3)    at Module.runMain (module.js:604:10)    at run (bootstrap_node.js:394:7)
```

请问这个是什么问题呢？

补充：以为有可能是nod找不到.dll文件，又增加了

```javascript
var url = require('url');var util = require('util');
```

以上是我之前发布的一个提问，一段时间之后我在另一位大神的博客找到了答案，以及如何解决的方案。在这里做一个记录。大神的博客在这里http://www.cnblogs.com/sfcyyc/p/4633441.html

根据上述博客，我的解决方法。

```
///index.js文件代码var edge = require('edge');var input = ['Printer','TagPrinter','Scanner'];var getPrinter = edge.func({    assemblyFile:"E:/workspace/Csharpworkspace/nodecs/print.dll",    typeName:"print.Print",    methodName: "getPrinter"});getPrinter(input,function(err,result){    if (err) throw err;       console.log(result);});
```

这样应该是可以完成的，根据自己的具体情况，方法大同小异。[逃..]
