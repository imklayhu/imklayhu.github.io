---
title: 关于返回数组元素平方的一道面试题
date: 2019-12-31 00:00:00
categories:
  - JavaScript
tags:
  - 面试题
  - Array
---
#### 题目

```javascript
let arr = [1, 2, 3];
console.log(arr.square()); // [1, 4, 9]
```

#### 实现

```javascript
Array.prototype.square = function () {
  return this.map(function (item) {
    return item * item;
  });
};
```

peace✌️
