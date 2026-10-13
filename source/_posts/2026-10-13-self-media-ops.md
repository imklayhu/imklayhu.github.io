---
title: 独阵：给一人公司的账号矩阵工作台，我是怎么把「写到发布前」做成可审流水线的
date: 2026-10-13 15:30:00
categories:
  - 逼逼叨叨
tags:
  - 独阵
  - OPC
  - Next.js
  - LangGraph
  - 自媒体
  - 一人公司
---

先说清楚：这不是一篇「AI 颠覆自媒体」的 PPT 文案，是一篇「我把小红书 / 抖音 / 视频号 / 公众号 / X 的方案→草稿→审核，拆成一条可审流水线」的施工笔记。产品对外叫 **独阵**，站在这儿：[opc.ai-dddd.top](https://opc.ai-dddd.top)。仓库名还是 `self-media-ops`，**私有仓**，外面 clone 不了——这篇只讲边界和架构，不贴密钥内网。

同类的小玩意儿还有 [FatTI](https://fatti.ai-dddd.top)、[DevEase](https://devease.ai-dddd.top)、[训记](https://xunji.ai-dddd.top)，以及上一篇写的 [Lead Radar](https://zone.ai-dddd.top/2026/10/13/lead-radar/)——都是「自己先用、再考虑别人能不能用」那挂的。这篇只深挖独阵。

## 背景动机：一人多号，本质是切后台

故事起因也很朴素。一人公司（OPC）要同时养几个号：公众号写长文、小红书发图文、抖音口播、视频号再切一刀、偶尔还想在 X 上丢一句英文。日常操作大概是：

1. 备忘录里记选题；
2. 表格里排谁哪天发；
3. Chat 对话框里生成一段；
4. 复制到各平台后台改格式；
5. 封面另开一个工具叠字；
6. 发完再回头找数据。

能做，但很碎。更烦的是：**「方案」和「草稿」散落在三个 App 里**，过两周你自己都对不上「这条笔记到底对应哪根内容支柱」。

所以最初的问题就一句话：**给一人公司一个多平台账号矩阵运营工作台——方案、AI 写作、封面/配图、排期与审核；发布仍在各平台后台由人完成。**

注意最后半句：人工分发。不是全自动发帖机。这个边界从 Day 1 就钉死了，README 和开放试用页也反复写——不接官方发布 / 数据 API，无爬虫，无浏览器自动化。和 Lead Radar「人审卡片才算交付」是同一套哲学，只是战场从获客换成了内容生产。

## 做了什么：六步主闭环，再挂两条垂类流水线

产品侧一句话（和营销首页对齐）：**一个人，也能运营一整个账号矩阵。** 公众号、小红书、抖音、视频号、X 的运营方案、AI 写作、封面配图和排期，都在一个地方；你只做判断和审核，系统不替你自动发布。

落地页把主闭环写成六步，和实现是对齐的：

1. **接入账号**：登记平台、人设、流量主标记；内容与排期按账号归档；
2. **生成运营方案**：LangGraph 出 pillars / cadence / tone / platform_playbook，你来取舍；
3. **AI 辅助写作**：按平台 Skill 出多条草稿，账号级还带 `adapted_copy`；
4. **配图与封面**：底图上传 / 叠字 regenerate；公众号长文还能切成竖版素材；
5. **人工审核排期**：内容库筛选 + 日历；系统不自动发布；
6. **复盘数据**：可选记阅读 / 播放 / 收益（流量主默认对试用关闭）。

另外两条垂类流水线，共用同一套「Next 持状态 + agent 干活」的 harness：

- **播客「推上AI」**：`fetch → score → select → script → synthesize → assemble`（止于 MP3；历史 video 阶段已下线）。热点走 TikHub，TTS 默认千问，Web 台逐步审核；红线命中要人确认。
- **漫画套图**：`character_sheet → comic_base → storyboard → panels → lettering`，竖屏 1080×1920 双竖格，Pillow 叠字。

邀请制试用写得很直白：14 天免费，审核通过后站长**手工**发邀请注册链接（不会自动发邮件）；播客 / 漫画 / 流量主默认未开，可按需申请。核心矩阵（账号 / 方案 / 内容 / 封面）先跑通再说。

## 关键链路 / 技术点：状态在 Next，算力在 agent

### 总览

```
浏览器 → Next.js (:3010) → SQLite (OPS_DATA_DIR / data/ops.db)
                ↓ HTTP / SSE
         content-agent (:3011) → LangGraph + podcast/comic workers
                ↓
         skills/*/SKILL.md + OpenAI 兼容 LLM（+ TikHub / TTS / 千问图像）
```

公网只反代 Web；**不暴露 3011**。Docker Compose 三件套：`web` + `agent`（含 ffmpeg，内存限 4G）+ `cron`（北京时间建期 / 清音频）。

### 技术选型（为什么这么拧）

| 层 | 选型 | 一句话理由 |
|----|------|------------|
| Web UI / API | **Next.js 14** App Router + TypeScript + Tailwind | 营销落地与工作台同域；生产 standalone |
| 状态存储 | **better-sqlite3** | 单机够用；Next 独占状态机，增量 `ensure*Schema` |
| 内容 Agent | **FastAPI** + **LangGraph** | 无状态 worker：claim → 执行 → result |
| 技能契约 | `skills/*/SKILL.md` | 改平台规范改 MD，少改代码 |
| LLM | 阿里云 DashScope 兼容（默认 `qwen3.8-flash`）；敏感题材可路由专用模型 | 未配专用通道则明确报错，不静默降级 |
| 播客数据 / TTS | TikHub + Qwen TTS（可 CosyVoice / MiniMax） | 热点进、脚本出、音色统一 |
| 漫画图像 | 千问 MaaS（与 Token Plan LLM Key 分离） | 出图账单别和聊天糊在一起 |
| 部署 | Docker Compose + Caddy / Cloudflare Tunnel | 数据 durable 卷；受信反代 |

### 几个我觉得「值钱」的设计

**1. Skill.md 当平台契约**

`ops-planner`、各平台写作、`podcast-*`、`gongzhonghao-cover` 全是带 YAML frontmatter 的 Markdown。平台篇幅 / 格式速查在 `references/platform-specs.md`（有 MIT/Chuluu 归因）。Prompt 漂移时改文件，比改一堆散落的 Python 字符串清醒。

**2. LangGraph 节点 + SSE 进度**

真源节点（README 略写了一层，源码多一步 polish）：

`load_context` → `plan` → `select_platform_skills` → `generate_contents` → **`polish_gongzhonghao`** → `package`

`mode` 可以是 `plan` | `contents` | `run`。长耗时走 SSE：`status` → `result` / `error`；Next 代理事件，并在 `result` 时落库。UI 不能对着空白转圈——部署脚本还会清 `http_proxy`、给 localhost 设 `NO_PROXY`，否则 Node `fetch` 到 `127.0.0.1:3011` 会莫名其妙 failed。

**3. 公众号 polish：校验 → 重写 → 套基座**

生成后不是直接交差。站长路径会 lint（免责 / 说教 / 结构 / 重复），命中则最多几轮重写，再套 HTML 基座模板；长文（方案字数下限 ≥1500）走「大纲 → 并行分节」，因为单次 JSON 让模型一次吐整篇，实测经常停在 400–1000 字。试用路径是中性 starter 模板，**不跑站长私有风格**——`style_profile=owner | neutral` 从 Day 1 就隔离。

**4. 双模型路由（只打该打的）**

默认百炼。仅当本次涉及公众号账号、且方案 / brief / 标题等命中敏感题材关键词时，才走专用模型；没配好就报错，绝不静默降级成「看起来能写其实被审查截断」。细节不在博客里展开——产品边界是合规敏感题材有专用通道，其余走默认。

**5. 播客 / 漫画共用 harness**

Next + SQLite = **唯一状态源**；agent 无状态。阶段大致是 `pending → running → awaiting_review | approved | failed | stale`（播客另有 `redline_flagged`）。闸口 `manual | auto` 在建 run 时从 config **快照**；产物版本不可变，上游一变下游标 `stale`。两条垂类流水线长得像，是故意的——少发明第二套状态机。

**6. Docker 三件套 + 不暴露 agent**

旧 host 脚本已转发到 compose。联调 Ubuntu / 验收播客音频以 Docker 为准。公网信任模型：不采信未列入白名单的 `X-Forwarded-*`；preload 写不可伪造的 peer-ip。危险 wipe 要 `ADMIN_API_TOKEN` + `X-Confirm-Wipe: YES`。

**7. 开放试用：租户隔离与 feature gates**

试用期是邀请制，不是「注册即全开」。`owner_user_id` + `requireTenant`；审批默认 **core-only**（流量主 / 播客 / 漫画关着）。站长封面、owner-private 模板卷、私有 VOICE_RULES，都不能泄漏给试用用户——这是 P0，不是礼貌性问题。

## 踩坑与取舍（吐槽时间）

**取舍一：不做自动发布。**  
技术上不是不能接各平台 API 或浏览器自动化，但合规和产品边界都说「管理与草稿」。人审 + 人工分发。草稿质量再好，批量代发也是把自己和用户一起送进平台风控的最快路径。

**取舍二：状态机归 Next，agent 无状态。**  
早期如果让 Python 进程持有业务真相，重启和扩容都会变成玄学。SQLite 单机够用；Postgres 只在规格里当 P2 触发条件，不假装已经需要。

**取舍三：站长风格与试用彻底切开。**  
锋利的写作立场、长文流水线、站长 HTML 基座，只在 `style_profile=owner` 启用。试用看到的是中性模板。曾经差点把站长封面 / 模板泄漏出去——隔离补丁比多写两个功能按钮重要。

**取舍四：视频脚本 / CapCut 一键仍是 PoC。**  
`docs/agents.md` 里诚实写着未完成。不假装已交付。播客止于 MP3，漫画止于套图交付物。

**踩坑：localhost + http_proxy。**  
容器 / 宿主机一开系统代理，Next 调本机 agent 就 `fetch failed`。部署清代理 + `NO_PROXY`，血泪换的。

**踩坑：伪造 X-Forwarded-Proto。**  
反代没配对时，Secure cookie 和「到底是不是 HTTPS」会错乱。后来改成只信任白名单代理，peer-ip 由 preload 写入。

**踩坑：单次 JSON 吐长文不够。**  
公众号要深度长文时，靠一轮 chat_json 只会灌水或提前收工。改成大纲并行分节 + 定向补写（禁止整稿复述凑字），字数和可读性才同时站住。

**踩坑：开放试用前的 SEO 地基。**  
中间件曾经「未登录一律 302 登录页」，搜索引擎蜘蛛永远只看见登录页。后来补公开路径白名单、sitemap、canonical、结构化数据，并把页头「内测」badge 拿掉——品牌词要先能被收录，再谈转化。

## 明确不做与下一步

明确不做（和 README / 试用页一致）：

- 官方发布 / 数据 API、自动发布、爬虫、浏览器自动化；
- 细粒度多用户 RBAC / 云端同步（试用期仅 admin|user + 租户隔离）；
- 每用户独立 LLM Key、一期 SaaS 计费（邀请制免费）；
- 播客多频道产品化；content-agent 内嵌登录。

下一步很务实：邀请制先验证留存，再谈订阅；CapCut / 视频脚本等 PoC 成熟再收进主路径。仓库从 2026-09-14 建仓到 10 月中公网邀请试用，大约一个月——MVP 账号 / 内容库 / 日历，再到方案生成、播客、漫画、开放试用与 SEO，是一段连续施工，不是一次「发布会」。

## 小结

独阵对我来说，不是「又一个 AI 写作 Demo」，而是一条可审的内容生产 harness：

- 入口够清楚（账号 → 方案 → 草稿）；
- 中间够抠（Skill 契约、SSE、闸口快照、stale、双模型路由）；
- 出口够稳（人审 + 人工分发；试用与站长风格隔离）。

它现在已经挂在 [opc.ai-dddd.top](https://opc.ai-dddd.top)，使用说明在站内 `/help`。想试用就按首页表单申请——邀请码一对一，数据只你自己可见。别指望我在博客评论区贴 `.env` 和私有仓权限。

同类互推：[FatTI](https://fatti.ai-dddd.top) / [DevEase](https://devease.ai-dddd.top) / [训记](https://xunji.ai-dddd.top) / [Lead Radar](https://zone.ai-dddd.top/2026/10/13/lead-radar/)。接下来如果还写，大概会是播客六阶段闸口合集，或者「为什么试用默认 core-only」。这篇先到这儿。

peace✌️
