---
title: javascript 中的变量提升的问题
date: 2017-10-22 00:00:00
categories:
  - javascript
tags:
  - 变量提升
---
## 变量提升

变量提升即将变量声明提升到它所在作用域的最开始的部分，即函数声明和变量声明总是被JavaScript解释器隐式地提升(hoist)到包含他们的作用域的最顶端。在ES6之前，JavaScript没有块级作用域(一对花括号{}即为一个块级作用域)，只有全局作用域和函数作用域。
 

- 首先看一段简单的代码

```javascript
var name = 'Clam';(function (){    console.log(name);})();// Clam
```

上面的代码很简单。闲先声明一个变量名为`name`的变量，同时赋值为`Clam`。后面是一个立即执行函数，在函数体中控制台输出`name`。结果为`Clam`,没毛病~接着看下面的代码。

- 简单的修改一下上面的代码

```javascript
var name = 'Clam';(function (){    console.log(name);    var name = 'Klay';})()
```

首先我们自己分析一下上面的代码哈：首先声明了一个变量`name`并且赋值为`Clam`,紧接着也是一个立即执行函数，在函数体中首先控制台输出了`name`,但是之后，又声明了赋值了一次变量`name`。
那我来猜想一下，恩，控制台输出了`Clam`,但是在立即执行函数结束之后，变量`name`的值被修改成了`Klay`。
但是，上面的代码运行的结果是:

```
undifined// exm??
```

这就是我今天关注的东西：变量提升。

前面说过，变量提升会将变量的声明提升到其作用域的最前端。这里，`name`所在的作用域就是指这个函数作用域，上面的代码就相当于以下代码。

```javascript
var name = 'Clam';(function (){    var name;    console.log(name); //undefined    name = 'Klay';})()
```

## 函数提升
js中创建函数有两种方式：函数声明式和函数字面量式。只有函数声明才存在函数提升。

```
console.log(f1); // function f1() {}   console.log(f2); // undefined  function f1() {}var f2 = function() {}
```

以上，enjoy
