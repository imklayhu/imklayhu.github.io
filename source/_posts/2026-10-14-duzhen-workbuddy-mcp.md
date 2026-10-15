---
title: 独阵接上远程 MCP：在对话里管账号矩阵，但绝不替你自动发
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

今天可以正式说：**远程 HTTP MCP + 弹窗 OAuth 已上线**——WorkBuddy、Cursor、Claude Code、Codex、Grok Bot 等支持远程 HTTP MCP + OAuth 的客户端，都能在对话里查阅账号与内容、起草草稿、生成方案与封面；权限绑本人，写操作只落到站内草稿与方案。

一句话边界（和授权页、[/help/mcp](https://opc.ai-dddd.top/help/mcp) 同一句）：

> **MCP 只能创建或更新独阵里的草稿，不会代发到小红书、抖音、视频号或公众号。蚁小二的 CLI 可以代你发布；独阵的 MCP 不能。发到各平台仍要你自己完成。**

产品站：[opc.ai-dddd.top](https://opc.ai-dddd.top)（首页有 [#mcp](https://opc.ai-dddd.top/#mcp)）。仓库仍是私有仓 `self-media-ops`，这篇讲边界和施工，不贴真实密钥。

## 背景动机：网页是真相源，对话是操作面

独阵从 Day 1 就把状态钉在 Next + SQLite：账号、方案、内容库、日历、功能门控，全是网页工作台里的真相。工作台够用，但一人公司的真实节奏往往是：聊选题 → 切网页生成方案 → 再切回去改稿 → 再回网页点封面、进日历。上下文在两个窗口之间来回丢。

MCP（Model Context Protocol）补这一刀：**让客户端带着你的授权，调用独阵的工具**——而不是另造一套「聊天版 CMS」。人审 + 人工分发没变；变的是操作面可以待在对话里，而且**不用再本机塞 client_secret**。

## 做了什么：远程 MCP 地基 + 这一批 P1

两段施工叠在一起：

| 阶段 | PR（节选） | 内容 |
| --- | --- | --- |
| 远程 MCP 地基 | #88–#97 等 | OAuth / DCR / PKCE；`https://opc.ai-dddd.top/api/mcp`；41+ 读写工具与 inputSchema；帮助页与首页 `#mcp` |
| 运营 P1 | #112–#122 | 冷启动基线、流量主好/一般/差、一键铺排、PFR/成本看板、断更日历与周报、素材元数据写入、14+7 免费档、授权页钉死「只写草稿，不代发」、选题卡「你还有什么没讲」、备忘录粘贴导入草稿 |

### 授权怎么走（推荐：远程 HTTP）

在客户端配好 `url` 与 `oauth`（WorkBuddy 示例见下）后重连，大致会：

1. 探测 `https://opc.ai-dddd.top/api/mcp`（无 token → **401** + Protected Resource Metadata）；
2. 读 well-known；
3. **DCR（RFC 7591）** 注册到 `/register`；
4. **PKCE S256** 打开独阵授权页——同意前会看到「只写草稿，不代发」；同意后换 Bearer。

随时可在 **设置 → 已授权应用 → 解除授权**。stdio **不会**触发远程 OAuth，只适合站长协助的本机调试。

### WorkBuddy 配置示例（其它客户端同理，无需密钥）

```json
{
  "mcpServers": {
    "duzhen-ops": {
      "type": "http",
      "url": "https://opc.ai-dddd.top/api/mcp",
      "oauth": {
        "name": "独阵",
        "scope": "accounts:read contents:read plans:read templates:read covers:read assets:read calendar:read me:read traffic:read podcast:read comic:read accounts:write contents:write_draft contents:generate plans:write plans:generate templates:write covers:write covers:generate assets:write traffic:write podcast:write comic:write"
      }
    }
  }
}
```

完整 scope 与 FAQ 以 [/help/mcp](https://opc.ai-dddd.top/help/mcp) 为准。公开页可以贴完整 `mcp.json`，**不要**贴真实 `client_secret` / token。

## 这一批 P1：对话里能多干什么

### 冷启动基线（#112）

`get_account_baseline` / `add_account_baseline_samples` / `delete_account_baseline_sample`：把历史表现一行一条粘进账号（一次 1–3 条），给后续对比用。**不开流量主也能用**，和账号设置页一致。无样本时 median 为 null、`comparison.visible` 为 false——不会用假 0 糊弄你。

### 流量主：好 / 一般 / 差（#113）

已开通流量主时，`judge_traffic_verdict` 的 verdict 只能是 `good` / `ok` / `bad`。可判已有一笔，也可记新的一笔并可选回流到内容——只会打上「表现:好 / 一般 / 差」标签，**不会改成已发布**。调用方传来的 median 会被忽略；留空的阅读量不当成 0。

### 一键铺排（#114）

`preview_week_layout` 只预览不写库；`layout_week_from_plan` 在独阵日历里放**可再编辑的占位**（状态可以是「已排期」），**不写 `published_at`，不会代发**。

### PFR / 成本看板（#115）

`get_pfr_summary`（本人排期履约率）、`get_cost_summary`（本人估算成本）：只读本人数据，不能改价，也不能替你确认发布。没有到期排期时 rate 为 null，文案是「样本积累中」，不会给出 0%。

### 断更日历与周报（#117）

`get_streak_calendar` / `get_week_report`（`calendar:read`）：标出应更新但未履约或未就绪的日子，以及本周排期数、你在站内记下的确认发布条数、断更日。这两个工具**不写库、不铺排、不代发**。

### 素材元数据（#118）

`update_asset_metadata`（需 `assets:write`）：只改标签、备注、平台和用途，**不改文件、不删文件、不把内容改成已发布**。读侧有 `list_assets` / `get_asset` / `list_unused_assets`。

### 免费档：14 天试用 + 7 天只读宽限（#119）

试用进行中可以写；到期后 7 天只读宽限，宽限结束后仍然只读。【写】和生成（含创建草稿、铺排、生成方案、更新素材标签）返回 403；【读】仍可用。站长和管理员不限期。当前没有在线付费。

### 「只写草稿，不代发」写进授权（#120）

授权同意页、帮助页、首页 FAQ 同一句对照：**蚁小二 CLI 可以代发；独阵 MCP 不能。** `create_content_draft` / `update_content_draft` 拒绝 `published_at`、`scheduled_at`，以及「已发布」「已排期」「待发布」。站内点「确认已发布」也只是记账，不会代发。

### 选题建议：「你还有什么没讲」（#121）

内容库和方案详情共用一块 **你还有什么没讲**：角标分 **未覆盖话题**、**未用素材**、**可翻新旧稿**；某一源没有条目时不渲染空卡，和网页一致。

- `list_topic_suggestions`（`contents:read`）：只读。可选 `plan_id`，带上才包含该方案的未覆盖话题；**已引用的素材不会出现**；7 天内点过「不感兴趣」的 key 也会藏起来。
- `adopt_topic_suggestion`（`contents:write_draft`）：采纳一条，**只建独阵草稿**。未用素材会写入 `content_asset_refs`；可翻新旧稿是复制成标题「翻新：…」的新草稿，**不调用模型、不重写正文**。不会代发到小红书、抖音、视频号或公众号。
- `dismiss_topic_suggestion`（`contents:write_draft`）：不感兴趣，只对当前用户 **隐藏 7 天**，不改稿、不发布。


### 备忘录粘贴 → 多条草稿（#122）

`import_memo_drafts`（`contents:write_draft`）：把备忘录 / 笔记里整段粘贴进来，按分隔拆成**多条独阵草稿**。只写草稿箱，**不会代发**到小红书、抖音、视频号或公众号。对话里可以说「把这段备忘录拆成草稿导入」。权威参数以部署后的 [/help/mcp](https://opc.ai-dddd.top/help/mcp) 为准。

## 关键设计：两层闸 + 复用既有路径

```
MCP 客户端 (type: http + oauth)
  → 探测 /api/mcp → DCR + PKCE 授权页（「只写草稿，不代发」）
  → Bearer 调工具
       ↓
scope 校验 → feature gates → 试用写锁 → 业务写库 / 既有生成路径
```

1. **读写分工具 + inputSchema**，不是万能 `run_sql`。
2. **Scope、功能门控、试用写锁**三层：traffic / podcast / comic 要开通；试用到期只读。
3. **生成路径复用网页那套** LangGraph / 封面流水线，真相仍在 SQLite。
4. **远程 OAuth 把密钥从用户配置里拿掉**，邀请制试用才接得上手。

## 明确不做

- 自动 / 代发到任何社交平台（对照：蚁小二 CLI 可以，独阵 MCP 不可以）；
- 跨用户读写、管理员提权；
- 把 `client_secret` / token 写进公开文档；
- 把「一键铺排」或「确认已发布」偷偷当成外发。

想试的话：先按 [opc.ai-dddd.top](https://opc.ai-dddd.top) 申请试用（14 天 + 7 天只读宽限），再走 [/help/mcp](https://opc.ai-dddd.top/help/mcp)。

## 小结

独阵这一刀，不是「又多了一个 AI 聊天入口」，而是把可审流水线接到远程 MCP 客户端：

- 远程 HTTP + 弹窗 OAuth，多客户端可用，授权绑本人、随时可撤；
- 冷启动基线、铺排、断更/PFR、素材标签、流量主评判、选题建议、**备忘录导入草稿**都能在对话里动；
- 出口仍是**草稿 + 人审 + 你自己去各平台发**。

网页还是真相源；对话变成第二块键盘。上一篇讲「为什么不做自动发布」，这篇讲「在不做自动发布的前提下，助手怎么真的帮得上忙——而且授权页就把代发边界钉死」。
