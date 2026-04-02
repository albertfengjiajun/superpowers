# Antigravity Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 按任务逐步执行本计划。步骤使用 checkbox（`- [ ]`）语法进行跟踪。

**Goal:** 在不修改任何现有 Superpowers 文件的前提下，通过扁平化全局 skill 安装和薄入口项目 workflows，增加 zero-intrusion 的 Antigravity support。

**Architecture:** 新增 installer scripts，把根目录 `skills/*` 暴露为一级的全局 Antigravity skills；新增四个薄入口 `.agent/workflows/superpowers-*.md`；并在新建的 Antigravity 文档中说明 installation 和 troubleshooting。除非手工验证证明必须使用，否则 v1 不引入 rules。

**Tech Stack:** PowerShell、POSIX shell、Markdown workflows、filesystem links/junctions

**Spec:** `docs/superpowers/specs/2026-04-02-antigravity-support-design.md`

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `scripts/antigravity/install-skills.ps1` | Windows 下的扁平化全局 skill 安装 | Create |
| `scripts/antigravity/install-skills.sh` | Unix 下的扁平化全局 skill 安装 | Create |
| `scripts/antigravity/remove-skills.ps1` | Windows 下已安装 links 的清理 | Create |
| `scripts/antigravity/remove-skills.sh` | Unix 下已安装 links 的清理 | Create |
| `.agent/workflows/superpowers-design.md` | 薄入口 design workflow | Create |
| `.agent/workflows/superpowers-plan.md` | 薄入口 planning workflow | Create |
| `.agent/workflows/superpowers-execute.md` | 薄入口 execution workflow | Create |
| `.agent/workflows/superpowers-finish.md` | 薄入口 finishing workflow | Create |
| `docs/README.antigravity.md` | 安装与 troubleshooting 文档 | Create |

---

### Task 1: 创建 Windows skill installer

**Files:**
- Create: `scripts/antigravity/install-skills.ps1`

- [x] **Step 1: 创建目标目录骨架**
- [x] **Step 2: 增加动态 skill discovery**
- [x] **Step 3: 增加安全的扁平化 junction 创建逻辑**
- [x] **Step 4: 增加最终 summary 输出**
- [x] **Step 5: 在本地环境运行 installer 并验证输出**

### Task 2: 创建 Unix skill installer

**Files:**
- Create: `scripts/antigravity/install-skills.sh`

- [x] **Step 1: 创建 script header**
- [x] **Step 2: 增加动态 skill discovery**
- [x] **Step 3: 增加 symlink 创建逻辑**
- [x] **Step 4: 增加 summary 输出并设置 executable bit**
- [x] **Step 5: 运行 installer 并验证输出**

### Task 3: 创建 cleanup scripts

**Files:**
- Create: `scripts/antigravity/remove-skills.ps1`
- Create: `scripts/antigravity/remove-skills.sh`

- [x] **Step 1: 创建 PowerShell cleanup script**
- [x] **Step 2: 创建 Unix cleanup script**
- [x] **Step 3: 设置 Unix cleanup script 为 executable**
- [x] **Step 4: 验证两个 cleanup scripts 无 parse error**

### Task 4: 新增 `/superpowers-design`

**Files:**
- Create: `.agent/workflows/superpowers-design.md`

- [x] **Step 1: 创建 workflow 文件，明确使用 `brainstorming`**
- [x] **Step 2: 验证 frontmatter、描述和跳转语义**

### Task 5: 新增 `/superpowers-plan`

**Files:**
- Create: `.agent/workflows/superpowers-plan.md`

- [x] **Step 1: 创建 workflow 文件，明确使用 `writing-plans`**
- [x] **Step 2: 验证 design context 缺失时会跳转到 `/superpowers-design`**

### Task 6: 新增 `/superpowers-execute`

**Files:**
- Create: `.agent/workflows/superpowers-execute.md`

- [x] **Step 1: 创建 workflow 文件，默认使用 `subagent-driven-development`，inline fallback 为 `executing-plans`**
- [x] **Step 2: 验证缺少 implementation plan 时会跳转到 `/superpowers-plan`**

### Task 7: 新增 `/superpowers-finish`

**Files:**
- Create: `.agent/workflows/superpowers-finish.md`

- [x] **Step 1: 创建 workflow 文件，明确使用 `finishing-a-development-branch`**
- [x] **Step 2: 验证未完成工作会回跳到 `/superpowers-execute`**

### Task 8: 新增 Antigravity 文档

**Files:**
- Create: `docs/README.antigravity.md`

- [x] **Step 1: 写入文档头与 install model**
- [x] **Step 2: 补充 Windows / macOS / Linux installation instructions**
- [x] **Step 3: 补充 nested install 失效的 troubleshooting，以及 v1 不使用 rules 的说明**
- [x] **Step 4: 验证 markdown code fences 平衡**

### Task 9: 做最终验证

**Files:**
- Read: `scripts/antigravity/*.ps1`
- Read: `scripts/antigravity/*.sh`
- Read: `.agent/workflows/superpowers-*.md`
- Read: `docs/README.antigravity.md`

- [x] **Step 1: 验证 Antigravity workflow 文件存在**
- [x] **Step 2: 验证 Windows installer 生成的是一级全局 skill 目录**
- [x] **Step 3: 验证没有新增 `.agent/rules`**
- [x] **Step 4: 验证没有修改任何现有文件，只有新增文件属于 Antigravity support layer**
