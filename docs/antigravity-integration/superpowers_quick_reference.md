# Superpowers 架构快速参考指南

## 目录结构概览

```
obra/superpowers/
├── .claude-plugin/              # Claude Code 配置
│   └── manifest.json
├── .cursor-plugin/              # Cursor 配置
├── .codex/                      # Codex 安装脚本
├── .opencode/                   # OpenCode 安装脚本
├── .github/                     # CI/CD 和模板
├── commands/                    # 脚本
│   └── initialize-skills.sh     # ⭐ 核心初始化脚本
├── hooks/                       # Git & 平台 hooks
├── skills/                      # 核心 skills（供测试）
│   ├── testing/
│   ├── debugging/
│   ├── collaboration/
│   ├── meta/
│   └── architecture/
├── docs/                        # 文档
├── tests/                       # 功能测试
├── README.md                    # 主入口
├── RELEASE-NOTES.md             # 架构变更日志
└── LICENSE
```

---

## 关键文件速查

| 文件 | 用途 | 关键内容 |
|------|------|--------|
| `commands/initialize-skills.sh` | 核心初始化 | 克隆/更新 skills，Git 状态检查 |
| `hooks/session-start` | Session 启动 | 触发 initialize-skills.sh |
| `.claude-plugin/manifest.json` | Claude Code 配置 | hook 注册，版本信息 |
| `README.md` | 主文档 | 安装说明，工作流概述 |
| `RELEASE-NOTES.md` | 架构文档 | v2.0 双仓库设计说明 |
| `skills/*/SKILL.md` | Skill 定义 | frontmatter + 指令 |

---

## 核心概念速查

### 1. 双仓库架构

```
Plugin (obra/superpowers)           Skills (obra/superpowers-skills)
├── 轻量级（<1MB）                  ├── 所有 skills 定义
├── 平台配置                        ├── 用户可 fork
├── Hook 注册                       ├── 社区贡献
└── 生命周期管理                    └── 独立版本化
```

### 2. Skills 文件格式

```markdown
---
title: Skill Name
description: One-line summary
trigger: "regex|patterns|to|match"
when: "Describe when this activates"
next-skills: ["skill-1", "skill-2"]
---

# Skill Title

## When to use
Explanation and examples.

## Steps
1. **Step title**: Instructions
2. **Next step**: More instructions

## Anti-patterns
Things NOT to do.
```

### 3. 三级优先级（从高到低）

```
1️⃣ 项目级    .superpowers/skills/{name}/SKILL.md
2️⃣ 个人级    ~/.superpowers/personal-skills/{name}/SKILL.md
3️⃣ 核心级    ~/.config/superpowers/skills/{name}/SKILL.md
```

**使用场景**
- 项目 A 需要定制化 TDD 流程 → 创建项目级 override
- 个人偏好 → ~/.superpowers/personal-skills
- 默认最佳实践 → 核心库（社区维护）

### 4. 自动触发流程

```
User Input
  ↓
[Pattern Matching]
  skill.trigger regex vs input
  ↓
[Priority Resolution]
  project > personal > core
  ↓
[Load SKILL.md]
  读取 frontmatter + 内容
  ↓
[Execute]
  Agent 遵循指令
  ↓
[Chain]
  next-skills 触发下一个 skill
```

---

## 工作流速查

### 完整的特性开发

```
1. brainstorming       ← User: "Build X"
   ↓ (设计文档)
   ↓
2. using-git-worktrees ← 创建隔离分支
   ↓ (clean setup)
   ↓
3. writing-plans       ← 分解为微任务
   ↓ (任务列表)
   ↓
4. subagent-driven-development  ← 自主执行
   ├─ test-driven-development (per task)
   ├─ requesting-code-review (per task)
   └─ (2 阶段审查 + 自动合并)
   ↓
5. finishing-a-development-branch ← PR/merge
```

### 快速调试

```
User: "Something is broken"
  ↓
systematic-debugging (自动)
  1. 重现问题
  2. 形成假设
  3. 隔离变量
  4. 验证修复
  ↓
test-driven-development (修复时)
  RED → GREEN → REFACTOR
  ↓
verification-before-completion
  确保实际修复了
```

---

## 平台安装命令速查

| 平台 | 命令 |
|------|------|
| Claude Code | `/plugin install superpowers@claude-plugins-official` |
| Cursor | `/add-plugin superpowers` |
| VS Code | `copilot plugin add https://github.com/earchibald/vsc-superpowers` |
| Gemini | `gemini extensions install https://github.com/obra/superpowers` |
| Codex | Fetch `.codex/INSTALL.md` 并执行 |
| OpenCode | Fetch `.opencode/INSTALL.md` 并执行 |

---

## 常用操作

### 更新 Skills

```bash
# 自动（session 启动时）
# 手动重新索引
cd ~/.config/superpowers/skills/
git pull --rebase
```

### 创建项目特定 Skill

```bash
# 在项目根目录
mkdir -p .superpowers/skills/my-custom-skill
cat > .superpowers/skills/my-custom-skill/SKILL.md << 'EOF'
---
title: My Custom Skill
description: Project-specific best practice
trigger: "my.*project.*context"
when: "When working on this project"
next-skills: []
---

# My Custom Skill
...
EOF
```

### 创建个人全局 Skill

```bash
mkdir -p ~/.superpowers/personal-skills/my-workflow
cat > ~/.superpowers/personal-skills/my-workflow/SKILL.md << 'EOF'
---
title: My Personal Workflow
description: How I like to work
trigger: "my preferred pattern"
when: "All my projects"
next-skills: []
---

# My Personal Workflow
...
EOF
```

### 贡献 Skill 到社区

```bash
# 1. Fork obra/superpowers-skills
git clone https://github.com/<you>/superpowers-skills.git
cd superpowers-skills

# 2. 创建 branch
git checkout -b add-performance-profiling

# 3. 创建 skill
mkdir -p skills/debugging/performance-profiling
cat > skills/debugging/performance-profiling/SKILL.md << 'EOF'
---
title: Performance Profiling
description: Find and fix bottlenecks
trigger: "profile|performance|slow|bottleneck"
when: "When addressing performance issues"
next-skills: ["test-driven-development", "systematic-debugging"]
---

# Performance Profiling
...
EOF

# 4. Commit & Push
git add -A
git commit -m "Add performance-profiling skill"
git push origin add-performance-profiling

# 5. 打开 PR in GitHub
```

---

## 架构决策速查

### 为什么双仓库？

| 问题 | 单仓库❌ | 双仓库✅ |
|------|--------|--------|
| 发布周期 | 长（等插件审核） | 短（skills 独立） |
| 贡献门槛 | 高（需编译） | 低（Git fork） |
| 版本化 | 紧耦合 | 独立 |
| 社区规模 | 小 | 大 |

### 为什么声明式 Markdown？

✅ 无需编译  
✅ 易于 diff（Git）  
✅ 人类可读  
✅ AI 易理解  
❌ 不能执行复杂逻辑（但不需要）

---

## 性能指标

| 操作 | 耗时 | 说明 |
|------|------|------|
| Session 启动 | ~1s | 克隆 skills（首次），更新（后续） |
| Skills 索引 | ~100ms | 扫描 50+ skills，解析 frontmatter |
| Skill 加载 | ~10ms | 读取单个 SKILL.md |
| 自动触发匹配 | ~5ms | 正则匹配 input vs all triggers |

**优化**
- 本地缓存（`.skill-index.json`）
- 分层加载（按需）
- VS Code 缓存共享（多工作区）

---

## 故障排除速查表

| 症状 | 原因 | 解决 |
|------|------|------|
| Skill 内容过期 | 缓存未清 | 重启 session 或 `git pull` |
| 项目覆盖不生效 | 索引未更新 | 重启 session |
| 符号链接失败（Windows） | 权限不足 | 管理员运行 PowerShell |
| 本地修改被覆盖 | 在 main 分支编辑 | 使用 `git checkout -b` 创建分支 |
| Skill 不触发 | trigger 不匹配 | 检查 regex，手动 `/skills skill-name` |
| 多个 skills 冲突 | trigger 重叠 | 检查优先级顺序，调整 regex |

---

## 最佳实践清单

### 编写新 Skill 时

- ✅ 使用清晰的命令式语言
- ✅ 为每个步骤提供清晰的成功标准
- ✅ 链接到相关 skills（`next-skills`）
- ✅ 包含反面例子（anti-patterns）
- ✅ 测试 YAML frontmatter 有效性
- ❌ 不要嵌套超过 2 级子步骤
- ❌ 不要写代码片段（引用或链接代替）

### 使用 Superpowers 时

- ✅ 信任工作流（设计 → 计划 → 执行 → 审查）
- ✅ 在每个门控点审批
- ✅ 查看生成的设计文档和任务列表
- ✅ 监视 subagent 的进度
- ❌ 不要跳过 brainstorming（设计错误代价高）
- ❌ 不要禁用代码审查（质量保证）

### 贡献到社区时

- ✅ 在自己的 fork 上开发
- ✅ 为新 skill 编写测试（`.test.md`）
- ✅ 在 PR 描述中说明为什么有用
- ✅ 等待维护者反馈
- ❌ 不要直接推送到 obra/superpowers-skills
- ❌ 不要修改核心工作流 skills（除非修复 bug）

---

## 文件权限参考

```bash
# 典型的 skills 目录权限
~/.config/superpowers/
├── skills/              (755, 用户可读写执行)
│   └── */
│       └── SKILL.md     (644, 用户可读)
├── .git/                (700, 私有)
└── .skill-index.json    (644, 缓存)

# 项目级 override
.superpowers/
├── skills/              (755)
│   └── */
│       └── SKILL.md     (644)
└── .git/                (755)
```

---

## 深入阅读

| 主题 | 文档位置 | 说明 |
|------|---------|------|
| 安装 | `README.md` | 所有平台安装说明 |
| 工作流 | `RELEASE-NOTES.md` | v2.0+ 架构详解 |
| Skill 编写 | `skills/meta/writing-skills/SKILL.md` | 如何创建新 skill |
| 贡献指南 | `README.md` (Contributing 段落) | PR 流程 |
| Codex 支持 | `docs/README.codex.md` | 特定于 Codex 的说明 |
| OpenCode 支持 | `docs/README.opencode.md` | 特定于 OpenCode 的说明 |

---

## 核心团队与社区

**维护者**：Jesse Vincent (@obra) 和 Prime Radiant 团队  
**Discord**：https://discord.gg/Jd8Vphy9jq  
**GitHub Issues**：https://github.com/obra/superpowers/issues  
**Marketplace**：https://github.com/obra/superpowers-marketplace  

---

## 版本历史

| 版本 | 时间 | 关键变化 |
|------|------|--------|
| **v2.0.0** | 2025-10 | ✨ 双仓库架构，skills 独立化 |
| **v1.x** | 2025-08 前 | 单体架构，skills 内嵌于插件 |
| **v3.0** | 规划中 | Skill 版本化，市场化，依赖图 |

---

## 一页纸总结

**Superpowers** 是一个 AI 编码代理的完整软件开发工作流框架。

**架构**：
- Plugin（轻，<1MB）+ Skills Repo（厚，社区维护）
- Skill = Markdown + YAML frontmatter，无需编译
- 三级优先级覆盖（项目 > 个人 > 核心）

**工作流**：设计 → 计划 → 自主执行 → 审查 → 完成

**支持平台**：Claude Code、Cursor、VS Code、Gemini、Codex、OpenCode

**关键特性**：
- 自动触发（基于用户输入和 context）
- Subagent 驱动开发（任务级隔离 + 两阶段审查）
- TDD 强制（RED-GREEN-REFACTOR）
- Git worktree 隔离

**社区**：GitHub fork/PR 贡献，标准开源工作流

---

**快速开始**：
```bash
# Claude Code
/plugin install superpowers@claude-plugins-official

# 然后只需说...
"Help me build a payment system"
# 框架会自动处理设计、计划和实现！
```
