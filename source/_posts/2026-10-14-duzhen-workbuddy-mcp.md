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

今天可以正式说：**远程 HTTP MCP + WorkBuddy 弹窗 OAuth 已上线**——在对话里查阅账号与内容、起草草稿、生成方案与封面；权限绑本人，写操作只落到站内草稿与方案，**发布仍在各平台后台由你完成**。产品站：[opc.ai-dddd.top](https://opc.ai-dddd.top)（首页有 [#mcp](https://opc.ai-dddd.top/#mcp)）；公开说明：[/help/mcp](https://opc.ai-dddd.top/help/mcp)。仓库仍是私有仓 `self-media-ops`，这篇讲边界和施工，不贴真实密钥。

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

人审 + 人工分发没变。变的是：操作面可以待在对话里，而且**不用再本机塞 client_secret**。

## 做了什么：从 stdio 一期，到远程 HTTP + 弹窗授权

不是一个 PR 糊完，是两段施工：

| 阶段 | PR | 内容 |
| --- | --- | --- |
| 一期地基 | #88–#91 | OAuth 授权页 / token / 撤销；stdio 连接器 `packages/ops-mcp`；41 个【读】/【写】工具；公开页 `/help/mcp`；Next 对 `packages/**` 的 exclude |
| 远程与体验 | #93–#97 | 远程 `https://opc.ai-dddd.top/api/mcp`（Streamable HTTP）；DCR + PKCE S256 弹窗授权；`tools/list` 真实 inputSchema；帮助页深色代码块与复制；首页 `#mcp` 区块与 sitemap |

一期把「能授权、能调工具、边界写死」钉住；这一轮把 WorkBuddy 原生体验补齐——`type: http` + `oauth`，浏览器弹窗同意即可，stdio 退成高级备选。

### 授权怎么走（推荐：远程 HTTP）

在 WorkBuddy 的 `mcp.json` 配好 `url` 与 `oauth` 后重连，客户端会大致走：

1. 探测 `https://opc.ai-dddd.top/api/mcp`（无 token → **401**，并带上 Protected Resource Metadata 地址）；
2. 读 `/.well-known/oauth-protected-resource` 与 `/.well-known/oauth-authorization-server`；
3. **动态注册客户端（DCR，RFC 7591）**到 `/register`，登记本次回调（自定义 scheme 或本机随机端口）；
4. 用 **PKCE S256** 打开独阵授权页（须已登录）；同意后换 Bearer，之后工具调用自动带上。

随时可在 **设置 → 已授权应用 → 解除授权**；撤销后该应用下的 access / refresh 立刻失效。Token 只绑定当前用户；OAuth 路径上抬不成管理员。

说明：**stdio 连接器不会触发 WorkBuddy 的远程 OAuth**；只有 `type: http` / `sse` 会走上述流程。

### WorkBuddy 侧怎么配（推荐，无需密钥）

```json
{
  "mcpServers": {
    "duzhen-ops": {
      "type": "http",
      "url": "https://opc.ai-dddd.top/api/mcp",
      "oauth": {
        "name": "独阵",
        "scope": "accounts:read contents:read plans:read templates:read covers:read assets:read calendar:read me:read traffic:read podcast:read comic:read accounts:write contents:write_draft contents:generate plans:write plans:generate templates:write covers:write covers:generate traffic:write podcast:write comic:write"
      }
    }
  }
}
```

步骤：保存 → 在 WorkBuddy 重连「duzhen-ops」→ 浏览器登录独阵并点同意 → 回对话用自然语言调用（如「列出我的账号」）。完整 scope 与 FAQ 以 [/help/mcp](https://opc.ai-dddd.top/help/mcp) 为准。

高级备选：本机 stdio + 固定 loopback 仍可用 `packages/ops-mcp`，需站长下发的 `client_id` / `client_secret`。密钥只放本机，**勿进 Git、勿进公开页、勿进聊天截图**。

### 工具一览（41）与 inputSchema

读（22）：账号 / 画像、内容库、方案、文章基座模板、封面基座、素材元数据、工作台与排期、用量与功能门控、平台枚举；以及受门控的流量主 / 播客单集 / 漫画流水线只读。

写（19）：创建/更新账号与画像；**仅草稿**的创建/更新；从方案 AI 生成内容（全部进草稿箱）；方案的创建/更新与 AI 生成；模板与封面基座的元数据维护；封面叠字生成；受门控的流量主写入、创建漫画 run。

写工具里刻意没有「改成已发布 / 填 `published_at`」这类口子——草稿就是草稿。**#96 之后 `tools/list` 带上真实 inputSchema**，自然语言选型能看见参数，而不只是一串工具名。

## 关键链路：探测 → DCR/PKCE → Bearer → 工具分发

```
WorkBuddy (type: http + oauth)
  → 探测 /api/mcp（401 + resource_metadata）
  → well-known + DCR(/register) + PKCE 授权页
  → Bearer 调用 MCP 工具
       ↓
resolveOAuthBearer → oauthTenantContext（role: user）
  → scope 校验 → feature gates → 业务写库 / 触发既有生成路径
```

几点我觉得「值钱」：

1. **读写分工具，而不是一个万能 `run_sql`。** 工具名和描述前缀固定【读】/【写】，再加 inputSchema，客户端按意图选型；服务端用 scope 硬拦。比「一个 chat 接口什么都能干」可审计得多。

2. **Scope 与功能门控两层闸。** 就算 token 里带了 `podcast:read`，账号 `enabled_features` 没开播客，照样 403。试用默认 core-only（账号 / 方案 / 内容 / 素材 / 排期 / 封面）的产品决策，从网页侧栏一路贯彻到 MCP。traffic / podcast / comic 另受功能门控。

3. **复用既有生成路径，不另起炉灶。** `generate_ops_plan` / `generate_contents_from_plan` / `generate_content_cover` 走的仍是网页那套 LangGraph / 封面流水线，只是入口换成了 Bearer。状态真相还在 SQLite，对话只是另一个 client。

4. **远程 OAuth 把密钥从用户配置里拿掉。** 一期 stdio 要站长发机密客户端；远程 HTTP 用 DCR + PKCE，公开文档可以贴完整 `mcp.json` 而不贴 secret——这对邀请制试用很关键。

5. **公开说明与首页入口对齐。** `/help/mcp` 配置区改成深色代码块（可复制）；首页 `#mcp` 讲清能力与边界；sitemap 含说明页——功能上了线，试用用户找得到。

## 踩坑与取舍

**取舍：先 OAuth 地基，再远程弹窗。** #88/#89 先钉授权、token、撤销与 41 工具；#93–#95 再放远程 MCP 与 DCR/PKCE。拆开的好处是鉴权模型可以单独测：登录必需、用户绑定、A↛B、撤销即失效——再放开 WorkBuddy 原生探测流。

**取舍：推荐远程，stdio 降级为高级备选。** 远程路径不需要本机 `client_secret`；stdio 不会触发远程 OAuth，只适合站长协助的本机调试。文档和首页 CTA 都指向 http + oauth，避免新人一上来卡在密钥分发。

**取舍：二进制封面底图仍建议网页上传。** MCP 管元数据与叠字生成；大文件上传继续走 Web。边界清楚，连接器也更瘦。

**踩坑：Next 打包会扫到 `packages/**`。** MCP 包进 monorepo 后，tsconfig 若把 `packages/**` 吃进 Next 编译，构建会炸。#91 的 exclude——这类「功能本身对、构建路径没跟上」的坑，比业务逻辑更烦人。

**踩坑：未知 scope 必须拒绝，而不是静默忽略。** 客户端拼错一个 scope，若服务端当没看见，用户以为自己拿到了写权限，实际没有——排障地狱。拒绝 + 明确错误，比「兼容一下」更省后半夜。

## 明确不做与下一步

和上一篇、试用页一致，MCP 仍然不做：

- 自动发布到任何社交平台；
- 跨用户读写、管理员提权；
- 把 `client_secret` / token 写进公开文档或页面回显；
- 一期就把所有平台原生发布 API 接进来。

下一步务实：邀请制用户里，谁真的会把 WorkBuddy 接到独阵上？读写比例怎样？哪些工具用了三次、哪些从未被点——这些数据比再堆十个工具有用。想试的话，先按 [opc.ai-dddd.top](https://opc.ai-dddd.top) 申请试用，再走 [/help/mcp](https://opc.ai-dddd.top/help/mcp)。

## 小结

独阵这一刀，不是「又多了一个 AI 聊天入口」，而是把可审流水线的操作面接到对话客户端：

- **远程 HTTP + 弹窗 OAuth**，授权绑本人，随时可撤；
- 读写分工具，inputSchema 可被自然语言选型；
- 功能门控从网页贯到 MCP；
- 出口仍是草稿 + 人审 + 人工分发。

网页还是真相源；对话变成第二块键盘。上一篇讲「为什么不做自动发布」，这篇讲「在不做自动发布的前提下，怎么让助手真的帮得上忙——而且不用先找站长要一把密钥」。
