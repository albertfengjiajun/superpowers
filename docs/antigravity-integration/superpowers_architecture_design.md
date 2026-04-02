# Superpowers 代码仓库架构设计

## 概述

Superpowers 是一个 AI 编码代理的完整软件开发工作流框架，v2.0 之后采用**双仓库架构**设计，将 Plugin 和 Skills 分离为独立的版本控制单元。这使得：
- 插件保持轻量级（仅作为启动引导程序）
- Skills 库独立版本化和社区驱动
- 用户能够通过标准 Git 工作流贡献改进

---

## 架构分层

### 1. 用户交互层（User Interaction Layer）

**平台支持**

| 平台 | 集成方式 | 主仓库 |
|------|--------|--------|
| **Claude Code** | 官方插件市场 | `obra/superpowers` |
| **Cursor** | 插件系统 | 支持 `.cursor-plugin` 配置 |
| **VS Code** | Copilot CLI 插件 | `earchibald/vsc-superpowers` 包装器 |
| **Gemini CLI** | 扩展系统 | `gemini-extension.json` |
| **OpenAI Codex** | 手动安装 | `.codex/INSTALL.md` 脚本 |
| **OpenCode** | 手动安装 | `.opencode/INSTALL.md` 脚本 |

每个平台有特定的入口点和 hook 注册机制，但最终都指向同一个 Skills 仓库。

---

### 2. 插件 Shim 层（Plugin Shim Layer）

**Architecture**：轻量级引导程序，负责生命周期管理

**文件位置**

```
obra/superpowers/
├── .claude-plugin/          # Claude Code 插件配置
├── .cursor-plugin/          # Cursor 插件配置
├── .codex/                  # Codex 手动安装脚本
├── .opencode/               # OpenCode 手动安装脚本
├── .github/                 # CI/CD 和 GitHub Actions
├── README.md                # 主入口文档
├── RELEASE-NOTES.md         # 版本历史与架构变更
├── package.json             # 插件元数据（仅记录，不执行）
└── gemini-extension.json    # Gemini 扩展清单
```

**核心职责**

1. **初始化脚本** (`initialize-skills.sh`)
   - 在 session-start hook 触发时执行
   - 克隆或更新 `obra/superpowers-skills` 到本地
   - 验证 Git 状态（本地领先、落后、分叉）
   - 自动处理 fork 和 branch 创建

2. **Hook 管理**
   - `session-start`：检查并拉取最新 skills
   - `post-commit`（可选）：验证测试通过（铁律：提交前必须测试）

3. **路径管理**
   - 跨平台一致性：Windows 使用 `%USERPROFILE%`，Unix 使用 `~`
   - 符号链接或接合点（Windows）指向共享缓存

---

### 3. Skills 仓库（Independent Skills Repository）

**仓库**：`obra/superpowers-skills`  
**位置**：自动克隆至用户的本地配置目录

**特点**
- 独立版本化，与插件分离发布
- 用户可 fork，提交 PR，社区驱动
- 自动更新：每个 session 开始时检查上游

**目录结构**

```
skills/
├── testing/
│   ├── test-driven-development/
│   │   └── SKILL.md
│   └── verification-before-completion/
│       └── SKILL.md
│
├── debugging/
│   ├── systematic-debugging/
│   │   └── SKILL.md
│   ├── root-cause-tracing/
│   │   └── SKILL.md
│   └── condition-based-waiting/
│       └── SKILL.md
│
├── collaboration/
│   ├── brainstorming/
│   │   └── SKILL.md
│   ├── writing-plans/
│   │   └── SKILL.md
│   ├── executing-plans/
│   │   └── SKILL.md
│   ├── dispatching-parallel-agents/
│   │   └── SKILL.md
│   ├── requesting-code-review/
│   │   └── SKILL.md
│   ├── receiving-code-review/
│   │   └── SKILL.md
│   ├── using-git-worktrees/
│   │   └── SKILL.md
│   └── finishing-a-development-branch/
│       └── SKILL.md
│
├── meta/
│   ├── writing-skills/
│   │   └── SKILL.md
│   ├── using-superpowers/
│   │   └── SKILL.md
│   └── find-skills/
│       └── SKILL.md
│
├── architecture/
│   ├── breaking-down-system-design/
│   │   └── SKILL.md
│   ├── identifying-architectural-seams/
│   │   └── SKILL.md
│   └── [...more architecture patterns]/
│
└── README.md (contributes guide)
```

---

### 4. 单个 Skill 的内部结构

**文件格式**：纯 Markdown，无编译

**`SKILL.md` 文件模板**

```markdown
---
title: Skill Name
description: Short description
trigger: "Pattern that activates this skill"
when: "When this skill should be used"
next-skills: ["skill-name-1", "skill-name-2"]
---

# Skill Title

## When to use
Socratic questions and decision criteria.

## Steps
1. **Step title**: Detailed instruction
   - Substep with code examples or verification steps
   - Clear success criteria

2. **Next phase**:
   - Calls to other skills via `invoke-skill(skill-name)`

## Anti-patterns
What NOT to do.

## Examples
Real-world workflow examples.
```

**关键属性**

| 属性 | 目的 | 示例 |
|------|------|------|
| `title` | 显示名称 | "Test-Driven Development" |
| `description` | 一句话摘要 | "Write tests before implementation" |
| `trigger` | 触发条件（自然语言） | "help me design this feature" |
| `when` | 在工作流中的位置 | "After brainstorming, before implementation" |
| `next-skills` | 后续可以调用的 skill | `["writing-plans", "using-git-worktrees"]` |

---

### 5. Skills 发现与解析（Discovery & Resolution）

**发现机制**

```javascript
// 伪代码：平台特定的发现过程
On Session Start:
  1. 扫描 ~/.config/superpowers/skills/
  2. 读取每个 SKILL.md 的 YAML frontmatter
  3. 建立 (skill-name → SKILL.md 路径) 的索引
  4. 注册到平台的 skill 系统
    - Claude Code: 直接可用于 `/skills` 命令
    - Cursor: 可用于 `/` 命令匹配
    - VS Code Copilot: 加载到 .github/prompts/
```

**解析优先级（三级制）**

当同名 skill 存在于多个位置时：

```
优先级高 → 优先级低

1. 项目特定 skill (~/{project}/.superpowers/skills/)
2. 个人 skill (~/.superpowers/personal-skills/)
3. 核心 skill (obra/superpowers-skills 内置)
```

示例：
- 默认使用核心库的 `test-driven-development`
- 项目可覆盖：创建 `.superpowers/skills/test-driven-development/SKILL.md`
- 个人可覆盖：创建 `~/.superpowers/personal-skills/test-driven-development/SKILL.md`

**命名空间前缀**

显式引用被覆盖的 skill：

```
/skills superpowers:test-driven-development    # 总是使用核心版本
```

---

## 完整工作流

### 代理工作流程图

```
用户请求 ("help me build a payment system")
    ↓
[Session Start Hook]
  - 初始化或更新 skills 仓库
  - 索引所有 SKILL.md 文件
    ↓
[自动触发：brainstorming]
  - 提出设计问题
  - 分段展示架构
  - 让用户审批
  - 保存设计文档 → docs/superpowers/specs/YYYY-MM-DD-payment-design.md
    ↓
[自动触发：using-git-worktrees]
  - 创建新的 git worktree（隔离分支）
  - 运行项目设置
  - 验证清洁的测试基线
    ↓
[自动触发：writing-plans]
  - 将设计分解为 2-5 分钟的微任务
  - 每个任务：精确文件路径 + 完整代码 + 验证步骤
    ↓
[自动触发：subagent-driven-development]
  - 为每个任务启动新的 subagent
  - 两阶段审查：
    1. 规格合规性检查
    2. 代码质量审查
  - 失败时阻止进行
    ↓
[自动触发：test-driven-development（每个任务中）]
  - RED：写失败的测试
  - GREEN：写最小化代码使测试通过
  - REFACTOR：改进代码
  - 提交
    ↓
[自动触发：requesting-code-review]
  - 审查输出是否符合计划
  - 按严重程度报告问题
  - 临界问题阻止进行
    ↓
[自动触发：finishing-a-development-branch]
  - 验证所有测试通过
  - 提供选项：
    - 合并到 main
    - 创建 GitHub PR
    - 保留 worktree
    - 丢弃
    ↓
完成（用户可继续迭代）
```

---

## 核心设计原则

### 1. 分离关切（Separation of Concerns）

**Plugin**（轻量）
- 仅处理启动和配置管理
- 最小化平台特定代码
- 与 skills 解耦

**Skills**（厚重）
- 所有工作流逻辑
- 平台无关的指令
- 社区贡献的重点

### 2. 声明式触发

Skills 不是编程函数，而是**声明式文档**：
- 无需特殊语法激活（不是 `/skill name` 命令）
- Agent 根据 `trigger` 字段识别上下文自动调用
- 通过 `next-skills` 编排工作流链

示例：
```yaml
trigger: "design.*architecture|spec.*requirements|plan.*feature"
when: "At the start of a feature or major refactoring"
next-skills:
  - "writing-plans"
  - "using-git-worktrees"
```

### 3. TDD 与红绿重构

`test-driven-development` skill 强制：
1. 先写失败的测试
2. 运行测试，确保失败
3. 写最小化代码使测试通过
4. 重构以改进代码质量
5. 提交

删除任何在测试之前写的代码。

### 4. 门控与审批

关键决策点设置**人类审批门**：
- 设计审批：用户必须同意 spec
- 计划审批：用户启动 subagent 工作
- 代码审查门：关键问题阻止进行

---

## 多平台集成示例

### Claude Code（官方市场）

```bash
/plugin install superpowers@claude-plugins-official
```

入口点：`.claude-plugin/manifest.json`
- 注册 session-start hook
- 指向 initialize-skills.sh
- 自动发现 skills 路径

### VS Code + Copilot CLI

包装器项目：`earchibald/vsc-superpowers`

```bash
copilot plugin add https://github.com/earchibald/vsc-superpowers
```

工作流：
1. 自动克隆 `obra/superpowers` 到 `~/.cache/superpowers`
2. 创建符号链接：`.superpowers/ → ~/.cache/superpowers`
3. 复制 skills 到 `.github/prompts/`（供 Copilot 调用）
4. 生成 `.github/copilot-instructions.md`

### Codex / OpenCode（手动）

用户运行：
```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md
```

脚本自动化：
1. 克隆 skills 仓库到平台指定位置
2. 创建 `.agents/skills/superpowers/` 符号链接
3. 注册 SKILL.md 文件供 Codex 的原生 skill 发现

---

## Repository 文件清单

```
obra/superpowers/
│
├── 📂 .claude-plugin/           # Claude Code 官方插件配置
│   └── manifest.json
│
├── 📂 .cursor-plugin/           # Cursor 插件配置
│   └── manifest.json
│
├── 📂 .codex/
│   └── INSTALL.md              # Codex 用户的手动安装脚本
│
├── 📂 .opencode/
│   └── INSTALL.md              # OpenCode 用户的手动安装脚本
│
├── 📂 .github/
│   ├── workflows/              # CI/CD pipeline
│   ├── ISSUE_TEMPLATE/         # Issue 模板
│   └── PULL_REQUEST_TEMPLATE/  # PR 模板
│
├── 📂 agents/                   # Subagent 配置（可选）
│   └── [agent-specific configs]
│
├── 📂 commands/                 # 全局命令脚本
│   └── initialize-skills.sh     # 核心初始化脚本
│
├── 📂 hooks/                    # Git 和平台 hooks
│   ├── pre-commit              # 验证测试通过（可选）
│   ├── post-commit             # 钩子集成
│   └── session-start           # 插件 session 启动
│
├── 📂 skills/                   # Core skills（仅用于本地开发/测试）
│   ├── testing/
│   ├── debugging/
│   ├── collaboration/
│   ├── meta/
│   ├── architecture/
│   └── [others]
│
├── 📂 docs/                     # 文档
│   ├── README.codex.md
│   ├── README.opencode.md
│   ├── architecture.md
│   └── [contributor guides]
│
├── 📂 tests/                    # Skill 功能测试
│   ├── brainstorming.test.md
│   ├── writing-plans.test.md
│   └── [skill tests]
│
├── README.md                    # 主入口文档
├── RELEASE-NOTES.md             # 版本与架构变更日志
├── CHANGELOG.md                 # 详细变更日志
├── CODE_OF_CONDUCT.md           # 社区行为准则
├── LICENSE                      # MIT License
│
├── package.json                 # 插件元数据（不执行 npm install）
├── gemini-extension.json        # Gemini 扩展清单
│
└── .gitignore, .gitattributes   # Git 配置
```

---

## 关键技术决策

### 为什么双仓库架构？

| 方面 | 单仓库（之前） | 双仓库（v2.0+） |
|------|---------------|-----------------|
| **版本同步** | 插件和 skills 一起发布 | 独立版本化，独立更新 |
| **贡献者体验** | 修改 skill 需要编译插件 | Fork skills repo，直接 PR |
| **用户自定义** | 覆盖需要本地插件编译 | Fork 和分支工作流，无编译 |
| **发布频率** | 低频（等待插件审核） | Skill 可快速迭代 |
| **社区规模** | 小（高准入门槛） | 大（标准 Git 工作流） |

### 为什么声明式而不是编程语言？

**Skills 使用 Markdown + YAML Frontmatter，不是代码**

原因：
1. **易于修改**：无需编译，编辑 SKILL.md 立即生效
2. **易于阅读**：Agent 和人类都能理解自然语言指令
3. **易于版本化**：标准 Git diff，无二进制
4. **易于社区贡献**：不需要编程经验

缺点（接受的）：
- 不能执行复杂计算（但 skill 不应该）
- Agent 必须理解自然语言（这正是 AI 擅长的）

---

## 开发工作流（贡献新 Skill）

### 步骤

1. **Fork** `obra/superpowers-skills`

2. **Clone & Branch**
   ```bash
   git clone https://github.com/<your-user>/superpowers-skills.git
   cd superpowers-skills
   git checkout -b add-performance-debugging
   ```

3. **创建 Skill 目录**
   ```bash
   mkdir -p skills/debugging/performance-profiling
   cd skills/debugging/performance-profiling
   touch SKILL.md
   ```

4. **编写 SKILL.md**
   ```markdown
   ---
   title: Performance Profiling
   description: Identify and fix performance bottlenecks using systematic profiling
   trigger: "profile|bottleneck|slow|performance issue"
   when: "When the agent is addressing performance complaints"
   next-skills:
     - "systematic-debugging"
     - "test-driven-development"
   ---
   
   # Performance Profiling
   ...
   ```

5. **测试**（使用 `writing-skills` skill）
   ```
   Claude: "Help me test this new performance profiling skill"
   → [Automatically invokes writing-skills, which validates the structure]
   ```

6. **提交 & PR**
   ```bash
   git add -A
   git commit -m "Add performance-profiling skill"
   git push origin add-performance-debugging
   ```
   → 打开 GitHub PR

7. **审查** → 合并 → 自动在下次 session 启动时提供给用户

---

## 性能与缓存

### Skills 缓存策略

**本地缓存**（~/.config/superpowers/skills/）

- Skills 在第一次 session 启动时克隆
- 每次 session 启动时自动拉取更新（快速）
- 如果远程有新提交，自动合并
- Git 状态检查防止冲突（如果本地前进，不警告）

**多工作区共享缓存**（VS Code）

```bash
~/.cache/superpowers/          # 共享克隆（所有工作区）
workspace1/.superpowers → ~/.cache/superpowers/
workspace2/.superpowers → ~/.cache/superpowers/
```

好处：
- 下载一次，所有项目使用
- 节省磁盘空间
- 自动同步

---

## 安全性与隔离

### 权限模型

**Plugin**：最小权限
- 读：skills 目录、Git 配置
- 写：仅限 ~/.config/superpowers/（用户配置空间）
- 执行：仅 initialize-skills.sh 和 Git 命令

**Subagents**：隔离的 Worktree
- 每个任务的代理在新 git worktree 中运行
- 在主分支上构建，但不修改主分支
- 完成后合并或丢弃（用户选择）

**用户 Fork**：标准 GitHub 权限
- 使用 GitHub OAuth 或 SSH key
- 强制推送保护（可选）
- PR 需要审查（仓库配置）

---

## 测试策略

### Skill 功能测试

**目录**：`tests/`

```
tests/
├── brainstorming.test.md
├── writing-plans.test.md
├── test-driven-development.test.md
├── systematic-debugging.test.md
└── [skill].test.md
```

**测试格式**：Markdown 工作流模拟

```markdown
# Test: brainstorming skill triggers correctly

## Given
- Fresh session, no project context
- User asks: "Help me design a payment API"

## When
- Agent receives the request
- Should automatically invoke brainstorming skill

## Then
- Skill asks design questions (5-10)
- Presents architecture in sections
- Requests user approval
- Saves spec to docs/superpowers/specs/YYYY-MM-DD-payment-design.md
- ✅ Continues to next-skills (writing-plans)
```

### CI/CD Pipeline

**`.github/workflows/`**

```yaml
name: Skill Validation

on: [push, pull_request]

jobs:
  validate-skills:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate SKILL.md format
        run: |
          for skill in skills/**/*.md; do
            # Check frontmatter (title, description, trigger, when, next-skills)
            # Validate Markdown syntax
            # Ensure no broken skill references in next-skills
          done
      - name: Run functional tests
        run: |
          # Simulate skill invocation with test data
          # Verify output structure
```

---

## 未来演进

### 已计划

1. **Skill 版本化**（v3.0）
   - `SKILL@1.2.3` 语法
   - 后向兼容性保证

2. **依赖解析**
   - `next-skills` 形成 DAG
   - 自动循环检测

3. **Skill 市场**
   - 评分与排名
   - 依赖关系可视化

4. **多语言支持**
   - Skills 翻译（保留英文原本作为规范）
   - 平台特定语言（如 Chinese instructions）

---

## 总结

Superpowers 架构的核心创新：

| 创新点 | 实现 | 效果 |
|--------|------|------|
| **Skills 独立化** | 双仓库 + Git 工作流 | 社区规模扩大 10 倍+ |
| **声明式触发** | Frontmatter + 自然语言 | 无需编程即可贡献 |
| **TDD 强制** | 工作流门控 | 所有输出都有测试覆盖 |
| **Subagent 驱动** | 任务级隔离 + 两阶段审查 | 自主工作 + 质量保证 |
| **跨平台** | 轻量插件 + 统一 skills | Claude Code/Cursor/VS Code 无缝支持 |

这个架构使 AI 编码代理从**一次性工具**演变为**可信赖的开发伙伴**。
