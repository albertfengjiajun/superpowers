---
name: build
description: 实现执行——当用户说"开始实现"、"开始开发"、"执行计划"、"写代码"时使用。关键词：实现、开发、构建、执行、编码、build、implement、develop、code、execute。这是完整AI编程工作流的第三步，读取plan.md驱动子代理实现，同步tasks.md进度，每个任务完成后做双阶段代码审查。
---

# Build — 实现执行

这是四步工作流的 **第三步**：`explore` → `design` → `build` → `done`

本技能编排 **using-git-worktrees** + **subagent-driven-development**（主线）+ tasks.md 复选框同步 + **verification-before-completion**。

---

## 前提条件

在运行技能 `build` 前，应已有：
- `docs/superpowers/plans/YYYY-MM-DD-<name>.md` — 细粒度实现计划（来自 `/design`）
- `openspec/changes/<name>/tasks.md` — 业务任务清单（用于同步进度）

若计划文件不存在，先运行 `design`技能，若技能不存在，停止当前任务，并向用户反馈。

---

## 执行顺序

### 第一步：调用技能 using-git-worktrees或者superpowers:using-git-worktrees

使用 Skill 工具调用 `using-git-worktrees` 或者 `superpowers:using-git-worktrees`。

这会：
- 创建隔离的 git worktree（基于当前 HEAD 的新分支）
- 验证工作目录安全性
- 切换到隔离工作空间

**为什么先隔离**：避免实验性代码污染主分支，方便后续技能 `done` 时选择合并/PR/丢弃。

---

### 第二步：调用技能 subagent-driven-development或者superpowers:subagent-driven-development（主线）

使用 Skill 工具调用 `subagent-driven-development` 或者 `superpowers:subagent-driven-development`，传入：

```
实现计划文件：docs/superpowers/plans/YYYY-MM-DD-<name>.md
每个任务完成后：同步 openspec/changes/<name>/tasks.md 中对应复选框
```

subagent-driven-development 会：
- 为每个独立任务派遣全新子代理（隔离上下文，防止污染）
- 子代理遵循 TDD（先写失败测试 → 实现 → 验证通过 → 提交）
- 每个任务完成后做**双阶段代码审查**：
  1. 规范合规审查（是否符合 design.md 和架构约束）
  2. 代码质量审查（可读性、命名、结构）

---

### 第三步：同步 tasks.md 复选框

每个 plan.md 任务组完成后，更新对应的 tasks.md 业务任务状态：

```
将 openspec/changes/<name>/tasks.md 中对应任务的 `- [ ]` 改为 `- [x]`
```

**判断对应关系**：plan.md 中的任务组名称通常对应 tasks.md 中的业务任务标题。若无法确定对应关系，在完成一批步骤后统一更新已完成的业务任务。

---

### 第四步：调用技能 verification-before-completion或者superpowers:verification-before-completion

所有 plan.md 任务完成后，使用 Skill 工具调用 `verification-before-completion` 或者`superpowers:verification-before-completion`。

这会：
- 运行完整测试套件，要求看到真实输出
- 验证核心功能路径可用
- **不允许仅凭记忆断言测试通过**——必须有当场运行的证据

**停止条件**：若验证失败，停在此步，等待用户修复后重新触发技能 `build` 或手动修复。

---

## 关键原则

- **subagent-driven-development 是主线**，tasks.md 仅用于同步进度
- **每个子代理获得精确上下文**，不继承会话历史
- **TDD 贯穿始终**：测试先行，实现跟随
- **频繁提交**：每个小步骤完成即提交

---

## 工作流衔接

全部通过后运行技能 `done`，处理分支归并和 OpenSpec 归档。
