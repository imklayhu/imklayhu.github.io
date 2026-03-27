---
title: "CodeWars 使用记录（一）"
date: 2018-07-16 00:00:00
categories:
  - javascript
tags:
  - accum
  - bit count
---
这两天在网上发现了codewars这个网站，感觉有点意思。在上班无聊的时候我就试了下，好玩hhh。现在将我尝试的几道题记录一下。后面也可以试试去`leetcode`试试

accum题目描述：

This time no story, no theory. The examples below show you how to write function accum:

```
Examples:  accum("abcd");    // "A-Bb-Ccc-Dddd"  accum("RqaEzty"); // "R-Qq-Aaa-Eeee-Zzzzz-Tttttt-Yyyyyyy"  accum("cwAt");    // "C-Ww-Aaa-Tttt"
```

The parameter of accum is a string which includes only letters from `a..z` and `A..Z.`

我的解答：

as了，限于水平我只能写到这种方法，后面想到好的方法我再来补充

```javascript
function accum(s) {    let s_cp = s.split('');    for (let i = 0; i < s_cp.length; i++) {        let o = s_cp[i];        s_cp[i] = s_cp[i].toUpperCase();        for(let j = 0; j < i; j++){            if(/[A-Z]/.test(o)){                s_cp[i] = s_cp[i] + o.toLowerCase();            }else{                s_cp[i] = s_cp[i] + o;            }        }    }    s_cp = s_cp.join("-").toString().replace(/,/g, '');    //  console.log(s_cp)    return s_cp;}
```

Bit Counting题目描述：

Write a function that takes an (unsigned) integer as input, and returns the number of bits that are equal to one in the binary representation of that number.

Example: The binary representation of `1234` is `10011010010`, so the function should return `5` in this case.

我的解答：

```javascript
var countBits = function(n) {  // Program Me  let a = n.toString('2').split('');    let count = 0;    for(let i = 0; i < a.length;i++){        if(a[i] == 1){            count++;        }    }    // console.log(count);    return count;  };
```

Find the next perfect square!题目描述：

You might know some pretty large perfect squares. But what about the NEXT one?

Complete the findNextSquare method that finds the next integral perfect square after the one passed as a parameter. Recall that an integral perfect square is an integer `n` such that `sqrt(n)` is also an integer.

If the parameter is itself not a perfect square, than `-1` should be returned. You may assume the parameter is positive.

```
Examples:findNextSquare(121) --> returns 144findNextSquare(625) --> returns 676findNextSquare(114) --> returns -1 since 114 is not a perfect
```

我的解法： 

```javascript
function findNextSquare(sq) {    if (Math.sqrt(sq).toString().indexOf('.') === -1) {        return (Math.sqrt(sq) + 1) * (Math.sqrt(sq) + 1);    } else {        console.log(-1);        return -1;    }}
```

Build a pile of Cubes题目描述：Your task is to construct a building which will be a pile of n cubes. The cube at the bottom will have a volume of `n^3`, the cube above will have volume of `(n-1)^3` and so on until the top which will have a volume of `1^3`.

You are given the total volume m of the building. Being given m can you find the number n of cubes you will have to build?

The parameter of the function findNb (find_nb, find-nb, findNb) will be an integer m and you have to return the integer n such as `n^3 + (n-1)^3 + ... + 1^3 = m` if such a n exists or -1 if there is no such n.

```
Examples:findNb(1071225) --> 45findNb(91716553919377) --> -1
```

我的解法：

```javascript
function findNb(m) {    // your code    let res = (Math.sqrt(1 + 8 * (Math.sqrt(m))) - 1) / 2;    if(res.toString().indexOf('.') == -1){        return res;    }else{        return -1;    }}
```

目前就做了这几道题，觉得还是挺好玩的，上班再也不愁无聊的时候干嘛了～enjoy！
