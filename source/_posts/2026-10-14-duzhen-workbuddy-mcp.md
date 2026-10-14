---
title: 独阵接上 WorkBuddy MCP：在对话里管账号矩阵，但绝不替你自动发
date: 2026-10-14 17:00:00
categories:
  - 逼逼叨叨
tags:
  - 独阵
  - OPC
  - MCP
  - WorkBuddy
  - OAuth
  - 自媒体
  - 一人公司
---

上一篇写完独阵的「方案→草稿→人审」流水线之后（[施工笔记在这儿](https://zone.ai-dddd.top/2026/10/13/self-media-ops/)），还缺一块：**人已经在对话里干活了，为什么还要切回网页点按钮？**

今天合进主线的就是这块：**WorkBuddy MCP**——把独阵接进 WorkBuddy 自定义 MCP，读写分工具，权限绑本人；草稿、方案、封面都能在对话里动，**发布仍在各平台后台由你完成**。产品站：[opc.ai-dddd.top](https://opc.ai-dddd.top)；公开说明：[/help/mcp](https://opc.ai-dddd.top/help/mcp)。仓库仍是私有仓 `self-media-ops`，这篇讲边界和施工，不贴真实密钥。

## 背景动机：网页是真相源，对话是操作面

独阵从 Day 1 就把状态钉在 Next + SQLite：账号、方案、内容库、日历、功能门控，全是网页工作台里的真相。工作台够用，但一人公司的真实节奏往往是：

1. 打开 WorkBuddy / 对话助手，聊选题；
2. 再切到独阵网页生成方案；
3. 再切回去改稿；
4. 再回网页点封面、进日历。

能跑，但上下文在两个窗口之间来回丢。MCP（Model Context Protocol）正好补这一刀：**让对话客户端带着你的授权，调用独阵的工具**——读你的账号与内容，写草稿与方案，触发生成——而不是另造一套「聊天版 CMS」。

边界依然写死（和首页 FAQ、上一篇一致）：

- **不**自动发布到小红书 / 抖音 / 视频号 / 公众号 / X；
- **不**代管各平台账号密码；
- **不**跨用户、不提权成管理员。

人审 + 人工分发没变。变的是：操作面可以待在对话里。

## 做了什么：OAuth 一期 + 41 个读写工具 + 公开说明

这次不是一个 PR 糊完，是三刀连砍（已合 `main`）：

| PR | 内容 |
|----|------|
| [#88](https://github.com/imklayhu/self-media-ops/pull/88) | WorkBuddy OAuth phase-1：授权页同意/拒绝、换 token、刷新、撤销；设置页「已授权应用 → 解除授权」 |
| [#89](https://github.com/imklayhu/self-media-ops/pull/89) | MCP 连接器：`packages/ops-mcp` stdio + 服务端 `/api/mcp/tools`；**41** 个工具，描述一律带 **【读】** / **【写】** |
| [#90](https://github.com/imklayhu/self-media-ops/pull/90) | 公开中文说明页 `/help/mcp`（未登录可看），首页导航/页脚挂「MCP 说明」 |

### 授权怎么走

1. 浏览器打开 `https://opc.ai-dddd.top/oauth/authorize?...`（须已登录独阵）；
2. 同意页展示应用名、你的邮箱、本次 scopes——读与写分得清；
3. 同意后跳白名单 `redirect_uri`，带一次性 `code`；客户端用 `code` + `client_secret` 换 `access_token` / `refresh_token`；
4. 随时可在 **设置 → 已授权应用 → 解除授权**；撤销后该 grant 下 token 立刻失效。

未传 `scope` 时，默认只有核心只读：`accounts:read contents:read plans:read`。要写草稿、触发生成，必须在授权链接里**显式**带上对应 scope。未知 scope **直接拒绝**。

Token 只绑定一个 `user_id`；`oauthTenantContext` 强制 `role: user`——OAuth 路径上**抬不成管理员**。

### 工具一览（41）

**读（22）**：账号 / 画像、内容库、方案、文章基座模板、封面基座、素材元数据、工作台与排期、用量与功能门控、平台枚举；以及受门控的流量主 / 播客单集 / 漫画流水线只读。

**写（19）**：创建/更新账号与画像；**仅草稿**的创建/更新；从方案 AI 生成内容（全部进草稿箱）；方案的创建/更新与 AI 生成；模板与封面基座的元数据维护；封面叠字生成；受门控的流量主写入、创建漫画 run。

写工具里刻意没有「改成已发布 / 填 `published_at`」这类口子——草稿就是草稿。

### WorkBuddy 侧怎么配

本地 `packages/ops-mcp` 一次 `npm install`，在 WorkBuddy 的 `mcp.json` 里挂 stdio 进程，环境变量指向现网 `OPS_PUBLIC_URL=https://opc.ai-dddd.top`，再塞 access / refresh / client 凭证。配置示例与 FAQ 都在公开页，这里不复读占位符——**真实 `client_secret` / token 只放本机，别进仓库、别进聊天截图**。

## 关键链路：Bearer → 租户上下文 → 工具分发

```
WorkBuddy
   ↓ stdio MCP（packages/ops-mcp）
POST /api/mcp/tools/:name   Authorization: Bearer <access_token>
   ↓ resolveOAuthBearer → oauthTenantContext（role: user）
scope 校验 → feature gates → 业务写库 / 触发既有生成路径
```

几点我觉得「值钱」：

**1. 读写分工具，而不是一个万能 `run_sql`。**  
工具名和描述前缀固定【读】/【写】，方便客户端按意图选型；服务端再用 scope 硬拦。比「一个 chat 接口什么都能干」可审计得多。

**2. Scope 与功能门控两层闸。**  
就算 token 里带了 `podcast:read`，账号 `enabled_features` 没开播客，照样 403。试用默认 core-only（账号 / 方案 / 内容 / 素材 / 排期 / 封面）的产品决策，从网页侧栏一路贯彻到 MCP。

**3. 复用既有生成路径，不另起炉灶。**  
`generate_ops_plan` / `generate_contents_from_plan` / `generate_content_cover` 走的仍是网页那套 LangGraph / 封面流水线，只是入口换成了 Bearer。状态真相还在 SQLite，对话只是另一个 client。

**4. 公开说明页与 SEO 白名单对齐。**  
`/help/*` 本来就可匿名访问；这次把 MCP 说明补进 sitemap 和首页入口，避免「功能上了线、蜘蛛和试用用户都找不到」。

## 踩坑与取舍

**取舍：先 OAuth，再 MCP。**  
#88 只做授权落地页、token、撤销与设置解绑；#89 才挂工具。拆开的好处是鉴权模型可以单独测：登录必需、用户绑定、A↛B、撤销即失效——vitest 里先钉死，再放开 41 个入口。

**取舍：默认同意只有核心只读。**  
很多人会图省事把「全权限」设成默认。我故意反着来：忘写 scope = 只能看。要动草稿、要触发生成，必须在授权链接里写明白。同意页上读/写分开展示，减少「我只是想让助手帮我看一眼内容库」却一键给了写权限的事故。

**取舍：二进制封面底图仍建议网页上传。**  
MCP 管元数据与叠字生成；大文件上传继续走 Web。一期不做「对话里塞整张底图」——边界清楚，连接器也更瘦。

**踩坑：Next 打包会扫到 `packages/**`。**  
MCP 包放进 monorepo 后，tsconfig 若把 `packages/**` 吃进 Next 编译，构建会炸。合入前补了 exclude（#91）——这类「功能本身对、构建路径没跟上」的坑，比业务逻辑更烦人。

**踩坑：未知 scope 必须拒绝，而不是静默忽略。**  
客户端拼错一个 scope 字符串，若服务端当没看见，用户以为自己拿到了写权限，实际没有——排障地狱。拒绝 + 明确错误，比「兼容一下」更省后半夜。

## 明确不做与下一步

和上一篇、试用页一致，MCP **仍然不做**：

- 自动发布到任何社交平台；
- 跨用户读写、管理员提权；
- 把 `client_secret` 写进公开文档或页面回显；
- 一期就把所有平台原生发布 API 接进来。

下一步务实：邀请制用户里，谁真的会把 WorkBuddy 接到独阵上？读写比例怎样？哪些工具用了三次、哪些从未被点——这些数据比再堆十个工具有用。公开说明页已经挂着；想试的话，先按 [opc.ai-dddd.top](https://opc.ai-dddd.top) 申请试用，再走 [/help/mcp](https://opc.ai-dddd.top/help/mcp)。

## 小结

独阵这一刀，不是「又多了一个 AI 聊天入口」，而是把**可审流水线的操作面**接到对话客户端：

- 授权绑本人，随时可撤；
- 读写分工具，默认只读；
- 功能门控从网页贯到 MCP；
- 出口仍是草稿 + 人审 + 人工分发。

网页还是真相源；对话变成第二块键盘。上一篇讲「为什么不做自动发布」，这篇讲「在不做自动发布的前提下，怎么让助手真的帮得上忙」。

同类互推：[FatTI](https://fatti.ai-dddd.top) / [DevEase](https://devease.ai-dddd.top) / [训记](https://xunji.ai-dddd.top) / [Lead Radar](https://zone.ai-dddd.top/2026/10/13/lead-radar/) / [独阵上一篇](https://zone.ai-dddd.top/2026/10/13/self-media-ops/)。

peace✌️
