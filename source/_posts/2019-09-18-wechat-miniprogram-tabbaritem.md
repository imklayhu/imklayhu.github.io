---
title: 微信小程序 wx.setTabBarItem()需要注意的地方
date: 2019-09-18 00:00:00
categories:
  - javascript
---
官方的文档没有提到，这个api是需要在tabbar页面调用的，在非tabbar页面调用的时候，会报错.

```
errmsg: settabbaritem:fail not tabbar page
```

找了半天是在开发社区找到的，现在又找不到那个帖子了。先在这里记一下。

peace✌️

- 简书地址阅读地址
