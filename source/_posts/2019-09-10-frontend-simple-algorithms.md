---
title: 前端面试常用的简单排序算法
date: 2019-09-10 00:00:00
categories:
  - JavaScript
tags:
  - Javascript
  - 算法
---
- 冒泡排序

原理：每一次对比相邻两个数据的大小，按照升序/降序进行位置的交换

```javascript
function bubbleSort(arr){  const length = arr.length;  for(let i = 0; i < length;i++){    for(let j = 0; j < length - 1 -i;j++){      if(arr[j]>arr[j+1]){        let temp = arr[j+1];        arr[j+1] = arr[j];        arr[j] = temp;      }    }  }  return arr}
```

- 快速排序

原理：先找到一个基准点（一般是数组的中部），然后数组被该基准点分割为两部分，依次与该基准点数据比较，如果比他小放在左边，反之放右边。左右分别用一个空数组去存储比较厚的数据。最后递归上述操作，知道数组长度<=1

```javascript
function quickSort(arr){  if(arr.length <= 1){    return arr;  }  let mid = Math.floor(arr.length / 2);  let midItem = arr.splice(mid, 1)[0];  let left = [];  let right = [];  for(let i = 0;i < arr.length; i++){    if(arr[i] < midItem){      left.push(arr[i]);    }else{      right.push(arr[i]);    }  }    return quickSort(left).concat(midItem, quickSort(right));}
```

- 插入排序

原理：首先对前两个数据从小到大比较，接着将第三个数据与排好的前两个数据进行比较，将第三个数据插入合适的位置，以此类推。

```javascript
function insertSort(arr) {  let temp,j;  for(let i = 1; i < arr.length; i++) {    temp = arr[i];    j = i;    while(j > 0 && arr[j - 1] > temp) {      arr[j] = arr[j - 1];      j--;    }    arr[j] = temp;  }	return arr;}
```
