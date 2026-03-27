---
title: "ECMAscript 6 深入浅出学习笔记-generators"
date: 2017-08-14 00:00:00
categories:
  - node
tags:
  - es6
  - node
---
深入浅出ES6（三）：生成器 Generators 

从一个简单的示例开始

```
function* quips(name){    yield "你好 " + name + "!";    yield "巴拉巴拉";    if(name.startsWith('X)){        yield "你的名字 " + name + " 首字母是X，这很酷";    }    yield "我们下次再见！";}
```

当我们调用上述程序,并在console中输出结果的时候发生了什么?

```javascript
var iter = quips("Xjorendorff");console.log(iter.next());console.log(iter.next());console.log(iter.next());console.log(iter.next());console.log(iter.next());// console.log(){ value: '你好 Xjorendorff!', done: false }{ value: '巴拉巴拉', done: false }{ value: '你的名字 Xjorendorff 首字母是X，这很酷', done: false }{ value: '我们下次再见！', done: false }{ value: undefined, done: true }
```

generators函数与普通函数的区别
- 普通函数使用function声明，而generators函数使用function*声明

- 在生成器函数内部，有一种类似return的语法：关键字yield。二者的区别是，普通函数只可以return依次，而生成器函数可以yield多次（包括一次）。在生成器的执行过程中，遇到yield表达式立即暂停，后续可恢复执行状态。
这就是普通函数和生成器函数之间最大的区别，普通函数不能自暂停，而generators函数可以。

generators函数调用过程
- 当调用一个生成器时，程序并没有立即执行，而是返回一个已经暂停的生成器对象

`{ value: '你好 Xjorendorff!', done: false }`

- 每当你调用生成器对象的`.next()`方法时，函数调用将其自身解冻并一直运行到下一个yield表达式，再次暂停。

- 调用最后一个iter.next()时，我们最终抵达生成器函数的末尾，所以返回结果中done的值为true。抵达函数的末尾意味着没有返回值，所以返回结果中value的值为undefined。

```
> { value: '巴拉巴拉', done: false }> { value: '你的名字 Xjorendorff 首字母是X，这很酷', done: false }> { value: '我们下次再见！', done: false }> { value: undefined, done: true }>
```

生成器是迭代器！使用generators构建一个迭代器：

```
function* range(start,stop){    for(var i = start;i<stop;i++)        yield i;}
```

所有的生成器都有内建的`.next()`和`[Symbol.iterator]()`方法的实现。你只需编写循环部分的行为。

“当你的语言不再简练，说出的话就会变得难以理解”

```
// 简化数组构建函数。// 假设你有一个函数，每次调用的时候返回一个数组结果// like this:// 拆分一维数组icons// 根据长度rowLengthfunction splitIntoRows(icons, rowLength) {  var rows = [];  for (var i = 0; i < icons.length; i += rowLength) {    rows.push(icons.slice(i, i + rowLength));  }  return rows;}//使用generators 实现该方法function* splitIntoRows(icons,rowLength){    for(var i = 0;i < icons.lengthl;i+=rowLength){        yield icons.slice(i,i + rowLength);    }}
```

生成器与异步代码

```
// 同步代码function makeNoise(){    shake();    rattle();    roll();}//使用 generators 特性实现异步function makeNoise_async(){    return Q.async(function* (){        yield shake_async();        yield shake_async();        yield roll_async();    });}
```

到此为止，generators的相关基础看完了。这是一个非常有趣而且有用的特性，希望在今后的实战中在合适的场景使用它。enjoy~
