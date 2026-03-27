---
title: "JavaScript 中的call(),apply()和bind()"
date: 2017-10-16 00:00:00
categories:
  - javascript
tags:
  - call
  - apply
  - bind
---
一、细节

- javascript 中函数存在“定义时上下文”，“运行时上下文”

- 上下文是可变的

1. `call()``call()`,为改变某个函数运行时的上下文(context)而存在的，换句话说，是为了改变函数内部的`this`指向.

```
// demo1var sayKlay = {    name :"Klay",    say : function(){        console.log(this.name);    }}var sayClam = {    name : 'Clam' }/* sayClam()没有say方法，但是sayKlay()有呀所以可以去把sayKlay.say()方法的运行时上下文也就是运行时的this的指向，指向sayClam()这个时候低啊用say()方法就可以sayClam了。*/sayKlay.say.call(sayClam); // Clam// demo2function a(xx) {             this.b = xx; } var o = {}; a.call(o, 5); console.log(a.b);    // undefined console.log(o.b);    // 5
```

参考：MDN call()方法

2.apply()
`apply()`与`call()`作用没有区别，用法与call()方法稍有区别，就是call()的第二个参数(调用函数使用的参数)，是一个一个传入的；而apply()的第二个参数的值是使用数组的形式传入的

```javascript
function add(a,b) {             this.sum = a + b; } var o = {}; add.call(o, 5,5);console.log(o.sum);    // 10add.apply(o,[3,5]);console.log(o.sum);    // 8
```

参考 MDN apply()方法

3.bind()bind()的作用其实与call()以及apply()都是一样的，都是为了改变函数运行时的上下文，bind()与后面两者的区别是，call()和apply()在调用函数之后会立即执行，而bind()方法调用并改变函数运行时的上下文的之后，返回一个新的函数，在我们需要调用的地方去调用他。

```
// bind()方法并不会直接调用，只是改变了函数的上下文，并成为一个副本var button = document.getElementById("button"),    text = document.getElementById("text");button.onclick = function() {    alert(this.id); // 弹出text}.bind(text);// ie6-ie8不支持bind()方法，所以要用下面的方法去模拟bind()if (!function() {}.bind) {    Function.prototype.bind = function(context) {        var self = this            , args = Array.prototype.slice.call(arguments);                    return function() {            return self.apply(context, args.slice(1));            }    };}
```

参考MDN bind()方法

二、总结利用上面的`call()`,`apply()`和`bind()`方法，可以在代码复用减少代码的冗余上面有很大的帮助，以前编码的过程中，的确是没有很好的利用，希望在今后的编码的过程中自己可以努力的去尝试，去试错。

enjoy~
