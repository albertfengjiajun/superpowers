---
name: done
description: 完成归档——当用户说"完成了"、"提交代码"、"归档变更"、"合并分支"、"创建PR"时使用。关键词：完成、归档、结束、发布、合并、提交、done、finish、archive、merge、PR、release、close。这是完整AI编程工作流的最后一步，先验证测试通过，再提供分支处理选项（合并/PR/保留/丢弃），最后归档OpenSpec工件。
---

# Done — 完成归档

这是四步工作流的 **最后一步**：`/explore` → `/design` → `/build` → `/done`

本技能编排 **verification-before-completion** + **finishing-a-development-branch** + **opsx:archive**。

---

## 前提条件

在运行 `/done` 前，应已完成：
- `/build` 的所有任务
- 代码已在 worktree 分支上提交

---

## 执行顺序

### 第一步：调用 verification-before-completion

使用 Skill 工具调用 `verification-before-completion`。

这会：
- 运行完整测试套件，要求看到**当场运行的真实输出**
- 验证核心功能路径可用
- 检查没有遗漏的 TODO 或 failing tests

**硬性停止条件**：若验证失败（测试不通过、功能路径报错），**立即停止**，不继续后续步骤。

等待用户修复后重新触发 `/done`，或用 `/build` 继续修复。

---

### 第二步：调用 finishing-a-development-branch

验证通过后，使用 Skill 工具调用 `finishing-a-development-branch`。

这会呈现 4 个选项供用户选择：
1. **直接合并到主分支** — 适合小改动
2. **创建 Pull Request** — 适合需要 code review 的改动
3. **保留分支待用** — 适合还需要继续工作的情况
4. **丢弃变更** — 适合实验性探索不需要保留的情况

执行用户选择的操作后，清理 worktree。

---

### 第三步：调用 opsx:archive

使用 Skill 工具调用 `opsx:archive`，传入当前变更名称。

opsx:archive 会：
- 检查工件完整性（proposal.md、design.md、tasks.md）
- 检查 tasks.md 中未完成任务（`- [ ]`），若有则提示确认
- 如有 delta specs，提示同步到主 specs 后再归档
- 将变更目录移至 `openspec/changes/archive/YYYY-MM-DD-<name>/`

**注意**：若第二步选择了"丢弃变更"，仍建议归档 OpenSpec 工件以保留决策记录，但用户可选择跳过。

---

## 输出摘要

完成后显示：

```
工作流完成
- 分支：<merge/PR/保留/丢弃>
- OpenSpec 归档：openspec/changes/archive/YYYY-MM-DD-<name>/
- 测试：全部通过（有证据）
```

---

## 异常情况处理

| 情况 | 处理 |
|------|------|
| 第一步测试失败 | 立即停止，不继续；告知用户需先修复 |
| 第二步用户选择丢弃 | 仍询问是否归档 OpenSpec 工件 |
| opsx:archive 发现未完成任务 | 提示用户确认，不强制阻止 |
| 无 OpenSpec 变更（纯代码项目） | 跳过第三步，直接结束 |
