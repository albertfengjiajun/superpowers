---
name: design
description: 方案设计与计划生成——当用户说"设计方案"、"生成计划"、"创建规格"、"写实现计划"时使用。关键词：设计、方案、计划、规划、生成工件、design、plan、propose、spec、artifact。这是完整AI编程工作流的第二步，在/explore之后、/build之前运行，将探索结论转化为可执行的结构化工件。
---

# Design — 方案设计

这是四步工作流的 **第二步**：`/explore` → `/design` → `/build` → `/done`

本技能编排 **opsx:propose** + **superpowers:write-plan**，将探索结论转化为 OpenSpec 工件 + 细粒度实现计划。

---

## 前提条件

在运行 `/design` 前，应已有：
- 探索结论（来自 `/explore` 或用户直接描述的需求）
- 明确的目标功能名称（用于 OpenSpec 变更命名）

若需求尚不清晰，先运行 `/explore`。

---

## 执行顺序

### 第一步：调用 opsx:propose

使用 Skill 工具调用 `opsx:propose`，传入变更名称或需求描述。

opsx:propose 会生成：
- **proposal.md** — 做什么、为什么做
- **design.md** — 如何做（架构决策）
- **tasks.md** — 业务级任务列表（每项通常对应数小时工作）

完成后显示变更状态：`openspec status --change "<name>"`

---

### 第二步：调用 superpowers:write-plan

使用 Skill 工具调用 `superpowers:write-plan`，传入以下上下文：

```
基于刚生成的 tasks.md，将每个业务任务分解为 2-5 分钟的代码步骤。
tasks.md 路径：openspec/changes/<name>/tasks.md
plan.md 保存至：docs/superpowers/plans/YYYY-MM-DD-<name>.md
```

writing-plans 会：
- 读取 tasks.md 获取业务任务列表
- 为每个业务任务生成多个细粒度步骤（写失败测试 → 运行确认失败 → 实现最小代码 → 运行测试确认通过 → 提交）
- 映射每个步骤涉及的文件
- 输出完整的 `plan.md`

---

## 上下文传递规则

- writing-plans **直接读取** tasks.md，不重复询问需求
- plan.md 的粒度：每步 2-5 分钟，TDD 优先，频繁提交
- 若 tasks.md 描述不够具体，writing-plans 会询问澄清

---

## 输出工件

| 工件 | 位置 | 内容 |
|------|------|------|
| proposal.md | openspec/changes/\<name\>/ | 目标与范围 |
| design.md | openspec/changes/\<name\>/ | 架构与决策 |
| tasks.md | openspec/changes/\<name\>/ | 业务任务清单 |
| plan.md | docs/superpowers/plans/ | 细粒度代码步骤 |

---

## 工作流衔接

完成后运行 `/build`，它会读取 plan.md 驱动子代理实现，并同步 tasks.md 中的复选框。
