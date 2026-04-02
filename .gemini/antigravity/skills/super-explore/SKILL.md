---
name: explore
description: 需求探索与方案讨论——当用户提到想法、需求、功能调研、问题分析、系统探索、技术比较时立即使用。关键词：探索、需求、想法、调研、分析、讨论方案、探讨、explore、investigate、brainstorm、idea、requirement。这是完整AI编程工作流的第一步，用户说"我想做X"或"帮我想想Y"时优先触发。
---

# Explore — 需求探索

这是四步工作流的 **第一步**：`explore` → `design` → `build` → `done`

本技能编排 **opsx:explore** + **superpowers:brainstorm或者brainstorming** 完成从模糊想法到经用户批准的清晰设计。

---

## 执行顺序

### 第一步：调用 opsx:explore

使用 Skill 工具调用 `opsx:explore`，将用户输入的想法/问题作为上下文传入。

opsx:explore 会：
- 检查现有 OpenSpec 变更（`openspec list --json`）
- 读取已有工件（proposal.md、design.md、tasks.md）作为背景
- 以开放、好奇的姿态探索问题空间
- 用 ASCII 图可视化架构/流程
- 发现隐藏的复杂性和关键决策点

**退出条件**：探索出足够清晰的问题轮廓后，自然过渡到下一步。

---

### 第二步：调用 superpowers:brainstorm

使用 Skill 工具调用 `superpowers:brainstorm` 或者 `brainstorming` ，将第一步的探索结论作为上下文。

brainstorming 会：
- 提出 2-3 种实现方案并分析权衡
- 逐步呈现设计，每节获得用户确认
- 将批准的设计写入 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` 并提交
- **最终调用 writing-plans 技能**（这是 brainstorming 的标准终态）

---

## 关键说明

- **不实现代码**：explore 阶段只思考、探索、记录，不写应用代码
- **用户批准是关卡**：brainstorming 必须获得用户明确批准设计后才结束
- **opsx 工件可选**：若项目有 OpenSpec，探索结论可选择性保存到 proposal.md

---

## 工作流衔接

完成后，用户可运行 `design` 技能生成结构化的 OpenSpec 工件（proposal.md + design.md + tasks.md）和细粒度的实现计划（plan.md）。

若 brainstorming 已自动调用 writing-plans，则可直接跳到 `build` 技能。

