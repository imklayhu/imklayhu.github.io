# Hexo 博客恢复迁移报告

## 当前状态

- 当前工作分支：`source`
- 备份分支（本地）：`master-backup-20260327`
- `master` 分支未被改动（仍可作为线上静态站点历史快照）
- Hexo 源码结构已恢复（`source/`、`themes/`、`scaffolds/`、`_config.yml`、`package.json`）
- 自定义域名已保留：`source/CNAME` -> `zone.ai-dddd.top`
- `hexo g` 构建验证通过

## 已完成配置

- `_config.yml` 已设置：
  - `title: 拖泥脑湿的博客`
  - `subtitle: "Tony's Notebook"`
  - `author: Klay-Clam`
  - `description: A Blog Powered By Hexo`
  - `url: https://zone.ai-dddd.top`
  - `deploy` 目标分支：`master`
- 依赖兼容问题已处理（Node 22 环境下的 `strip-ansi` 兼容）

## 已恢复文章（Markdown）

当前 `source/_posts` 共 31 篇：

- `2017-07-26-MongoDB.md`
- `2017-08-02-nodeExpressAjax.md`
- `2017-08-10-nodeedgecsharp.md`
- `2017-08-12-newarticleplan.md`
- `2017-08-14-esgenerators.md`
- `2017-08-19-mongodumpandrestore.md`
- `2017-10-16-callapplybind.md`
- `2017-summary.md`
- `2018-01-07-2018-projection.md`
- `2018-07-12-hello-world.md`
- `2018-07-16-codewars-first.md`
- `2018-mid-year-summary.md`
- `2018-projection.md`
- `2019-of-mine.md`
- `2020-01-02-Untitled.md`
- `CodeWars-2.md`
- `array-item-square.md`
- `awesome-idea.md`
- `codewars-first.md`
- `copy-from-baidu.md`
- `es6-notes.md`
- `frontend-simple-algorithms.md`
- `javascript-oop-1.md`
- `javascript-scope-and-closure-repost.md`
- `javascript-variable-hoisting.md`
- `let-and-const.md`
- `oop-shi-shen-me.md`
- `sinopia-internal-npm.md`
- `test-new-doc.md`
- `wechat-miniprogram-tabbaritem.md`
- `xiamen-meituan-interview-summary.md`

## 待人工精修建议

批量从旧 HTML 恢复为 Markdown 后，建议你后续按需做这些精修：

- 优化代码块排版（部分文章代码仍为单行）
- 统一文件命名风格（目前存在“旧命名 + 日期命名”混用）
- 校正少量分类/标签大小写（如 `javascript` / `JavaScript`）
- 检查个别文章中的历史外链、图片和示例地址

## 后续操作（网络恢复后）

1. 推送备份分支（强烈建议）

```bash
git push -u origin master-backup-20260327
```

2. 推送源码分支

```bash
git push -u origin source
```

3. 日常写作发布（在 `source` 分支）

```bash
npx hexo new post "文章标题"
npx hexo g
npx hexo d
```

