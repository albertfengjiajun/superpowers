# Superpowers 架构进化与集成指南

## 架构进化历史

### v1.x（单体架构）

```
plugin.json (编译的)
  ↓
skills/ (内嵌)
  ├── brainstorming.ts
  ├── test-driven.ts
  ├── code-review.ts
  └── ...
  ↓
用户 (使用内置 skills，不可自定义)
```

**问题**
- Skills 与 Plugin 一起发布，发布周期长
- 修改 skill 需要重新编译插件
- 用户无法贡献新 skills（需要编程经验）
- 覆盖 skills 需要本地开发环境
- 社区规模受限（高准入门槛）

---

### v2.0+（双仓库架构）✅ 当前

```
Plugin (轻量)                        Skills Repo (厚重)
├── manifest.json                   ├── skills/
├── initialize-skills.sh              │ ├── testing/
├── hooks/                            │ ├── debugging/
│   └── session-start                 │ ├── collaboration/
└── (≈200 行)                        │ └── meta/
                                     ├── README.md
                    ↓                ├── .github/
              自动克隆 & 更新          └── (可社区贡献)
                    ↓
         ~/.config/superpowers/
         (用户本地 fork)
                    ↓
              Skills 发现
              & 解析
                    ↓
              Agent 调用
```

**改进**
- ✅ Plugin 保持最小化（减少发布压力）
- ✅ Skills 独立版本化（快速迭代）
- ✅ 社区贡献简化（标准 Git 工作流）
- ✅ 用户自定义无需编译（fork & branch）
- ✅ 支持三级优先级（项目 > 个人 > 核心）

---

### v3.0（规划中的增强）

**考虑中的特性**

1. **Skill 版本化**
   ```yaml
   next-skills:
     - skill-name@1.2.3          # 指定版本
     - another-skill@latest      # 自动最新
   ```

2. **Skill 依赖图**
   ```mermaid
   brainstorming → writing-plans → executing-plans
                                      ↓
                            test-driven-development
   ```

3. **Skill 市场与评分**
   - 官方市场：obra/superpowers-skills
   - 第三方市场：community-maintained skills
   - 评分系统：质量指标（test coverage, 文档, 反馈）

4. **编译时验证**
   ```bash
   superpowers validate --check-deps --check-syntax
   ```

---

## 平台集成对比

### 集成矩阵

| 平台 | 官方支持 | 插件市场 | 自动更新 | Hook 支持 | 云缓存 | 自定义 Skills |
|------|---------|---------|---------|----------|--------|---------------|
| **Claude Code** | ✅ | ✅ 官方 | ✅ | ✅ session-start | ❌ | ✅ Fork + Branch |
| **Cursor** | ✅ | ✅ 官方 | ✅ | ✅ session-start | ❌ | ✅ Fork + Branch |
| **VS Code** | ⚠️ 包装器 | ✅ 社区 | ✅ | ⚠️ 受限 | ✅ 共享缓存 | ✅ 符号链接 |
| **Gemini** | ✅ | ✅ 官方 | ✅ | ✅ | ❌ | ✅ |
| **Codex** | ⚠️ 手动 | ❌ | ⚠️ 手动 | ✅ | ❌ | ✅ |
| **OpenCode** | ⚠️ 手动 | ❌ | ⚠️ 手动 | ✅ | ❌ | ✅ |

---

## 深入集成指南

### Claude Code（官方）

**安装**
```bash
# 方式 1：官方市场（推荐）
/plugin install superpowers@claude-plugins-official

# 方式 2：自定义市场
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**工作原理**

1. **Plugin 初始化**
   ```javascript
   // manifest.json
   {
     "name": "superpowers",
     "version": "5.0.6",
     "api_version": "0.2",
     "hooks": {
       "session-start": "commands/initialize-skills.sh"
     }
   }
   ```

2. **Session 启动流程**
   ```bash
   Session Start
   ↓
   [Claude Code 触发 session-start hook]
   ↓
   $ bash ~/.claude-plugin/superpowers/commands/initialize-skills.sh
   ↓
   检查 ~/.config/superpowers/skills/ 是否存在
     ├─ 不存在 → 克隆 obra/superpowers-skills
     ├─ 已存在 → git fetch upstream && git rebase
     └─ 已本地修改 → 警告用户（不强制更新）
   ↓
   扫描 skills/ 目录
   ↓
   解析所有 SKILL.md 的 frontmatter
   ↓
   注册到 Claude Code 的 skill 系统
   ```

3. **自动触发示例**
   ```
   用户：help me design this payment system
   ↓
   [Claude Code 匹配 trigger 模式]
   ↓
   brainstorming skill 的 trigger: "design.*|architecture|spec|plan"
   ↓
   自动加载 skills/collaboration/brainstorming/SKILL.md
   ↓
   Claude 按照 SKILL.md 的指令操作
   ```

---

### Cursor（Official Support）

**安装**
```bash
# 在 Cursor Agent Chat 中
/add-plugin superpowers
```

**差异点**

- Plugin API 略有不同（使用 `@plugin/superpowers` 语法）
- Hook 系统类似，但可能在特定点触发
- Skills 解析方式相同（frontmatter + Markdown）

**工作原理**（与 Claude Code 几乎相同）

```
Cursor Session Start
  ↓
[Cursor 触发自定义 hook]
  ↓
initialize-skills.sh
  ↓
~/.config/superpowers/skills/ 同步
  ↓
Cursor 的原生 skill 系统加载
```

---

### VS Code + Copilot CLI（社区支持）

**项目**：`earchibald/vsc-superpowers`（包装器）

**安装**
```bash
copilot plugin add https://github.com/earchibald/vsc-superpowers
```

**架构（两层）**

```
Layer 1: earchibald/vsc-superpowers (包装器)
  ├── 自动克隆 obra/superpowers 到 ~/.cache/superpowers
  ├── 创建符号链接 ./.superpowers → ~/.cache/superpowers
  ├── 生成 .github/copilot-instructions.md
  └── 复制 skills 到 .github/prompts/

Layer 2: Copilot CLI
  ├── 读取 .github/copilot-instructions.md
  ├── 扫描 .github/prompts/ 中的 SKILL.md
  └── 通过自然语言匹配触发
```

**多工作区共享缓存**

```bash
~/.cache/superpowers/               # 全局共享缓存
├── skills/
├── commands/
└── hooks/

workspace1/
├── .superpowers → ~/.cache/superpowers  # 符号链接
├── .github/
│   └── copilot-instructions.md
└── src/

workspace2/
├── .superpowers → ~/.cache/superpowers  # 同一缓存
├── .github/
│   └── copilot-instructions.md
└── src/
```

**优势**
- 磁盘效率高（只克隆一次）
- 自动同步（所有工作区共享最新版本）
- 无权限提示（相对路径）

---

### Codex / OpenCode（手动安装）

**安装流程（用户指导）**

```bash
# 用户在 Codex 中输入
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md

# 系统自动执行以下步骤
1. 下载 .codex/INSTALL.md
2. 解析脚本指令
3. 克隆 https://github.com/obra/superpowers-skills
4. 创建符号链接（Unix）或接合点（Windows）
5. 注册到 Codex 的原生 skill 发现系统
```

**Codex 原生 Skill 发现**

```bash
# Codex 在启动时扫描
~/.agents/skills/

# 链接到 Superpowers
~/.agents/skills/superpowers → ~/.codex/superpowers/skills/

# Codex 的发现过程
1. 遍历 ~/.agents/skills/
2. 找到每个 SKILL.md
3. 解析 frontmatter (title, description, trigger)
4. 加载到内存索引
5. 在 Agent 执行时按需匹配触发

# 使用方法
User: "Let's design a system"
  ↓
[Codex matches against index]
  ↓
"design" matches brainstorming trigger
  ↓
Codex 加载并执行 ~/.agents/skills/superpowers/collaboration/brainstorming/SKILL.md
```

**Windows 注意事项**

```batch
# .codex/INSTALL.md 包含 PowerShell 脚本
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"

# 创建符号链接/接合点（需要管理员权限）
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\superpowers" `
  "$env:USERPROFILE\.codex\superpowers\skills"

# 验证
ls "$env:USERPROFILE\.agents\skills\superpowers"
```

---

## 架构关键组件详解

### 1. initialize-skills.sh（核心引导脚本）

**位置**：`commands/initialize-skills.sh`

**责任**
```bash
#!/bin/bash

# 1. 确定 skills 目录
if [ -z "$SUPERPOWERS_SKILLS_DIR" ]; then
  if [ -n "$XDG_CONFIG_HOME" ]; then
    SKILLS_DIR="$XDG_CONFIG_HOME/superpowers/skills"
  else
    SKILLS_DIR="$HOME/.config/superpowers/skills"
  fi
fi

# 2. 克隆或更新
if [ ! -d "$SKILLS_DIR" ]; then
  git clone https://github.com/obra/superpowers-skills "$SKILLS_DIR"
else
  cd "$SKILLS_DIR"
  
  # 检查本地状态
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u})
  BASE=$(git merge-base @ @{u})
  
  if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Skills 已是最新"
  elif [ "$LOCAL" = "$BASE" ]; then
    echo "本地落后，更新中..."
    git pull --rebase
  elif [ "$REMOTE" = "$BASE" ]; then
    echo "本地领先，保留本地修改"
  else
    echo "❌ 分叉状态，请手动解决"
  fi
fi

# 3. 索引 skills（平台特定）
# 由平台的 skill 发现系统接管
```

**关键特性**
- 跨平台：Windows/Linux/macOS 路径处理
- 安全：仅更新，不强制重置
- 智能：检测本地修改并提醒

### 2. Skill 发现与解析流程

**流程图**

```
initialize-skills.sh 完成
  ↓
[平台特定的发现器]
  ├─ Claude Code: find skills/ -name "SKILL.md" | parse frontmatter
  ├─ Cursor: 相同
  ├─ Codex: 原生 skill discovery + frontmatter parsing
  └─ VS Code: 复制到 .github/prompts/
  ↓
生成 skill 索引（内存或缓存）
{
  "brainstorming": {
    path: "~/.config/superpowers/skills/collaboration/brainstorming",
    trigger: "design.*|architecture|spec|plan",
    when: "Before writing code",
    next_skills: ["writing-plans", "using-git-worktrees"]
  },
  ...
}
  ↓
[Agent 请求到达]
  ↓
运行时匹配
User Input: "Help me design a payment API"
  ↓
[正则匹配 trigger patterns]
  ↓
brainstorming 的 trigger 匹配成功
  ↓
加载 SKILL.md 内容
  ↓
Agent 遵循指令执行
```

### 3. 三级优先级解析

**查找算法**

```javascript
function resolveSkill(skillName, context = {}) {
  const searchPaths = [
    // 级别 1：项目特定
    `${context.projectRoot}/.superpowers/skills/${skillName}/SKILL.md`,
    
    // 级别 2：个人
    `${os.homedir()}/.superpowers/personal-skills/${skillName}/SKILL.md`,
    
    // 级别 3：核心（来自克隆的仓库）
    `${os.homedir()}/.config/superpowers/skills/${skillName}/SKILL.md`
  ];
  
  for (const path of searchPaths) {
    if (fs.existsSync(path)) {
      return fs.readFileSync(path, 'utf8');
    }
  }
  
  throw new Error(`Skill not found: ${skillName}`);
}
```

**使用场景**

```markdown
# 默认使用核心版本
trigger: "write tests"
→ 加载 ~/.config/superpowers/skills/testing/test-driven-development/SKILL.md

# 项目覆盖
项目 A 创建：.superpowers/skills/test-driven-development/SKILL.md
→ 加载项目版本（不使用核心版本）
→ 其他项目继续使用核心版本

# 显式引用
使用 `superpowers:test-driven-development` 强制使用核心版本
（即使项目或个人有覆盖）

# 个人全局覆盖
~/.superpowers/personal-skills/test-driven-development/SKILL.md
→ 所有项目都使用个人版本（除非项目明确覆盖）
```

---

## 工作流协调示例

### 完整的特性开发工作流

```
用户请求：
"I want to build a user authentication system using OAuth 2.0"

├─────────────────────────────────────────┤ Session Start
│ initialize-skills.sh 运行
│ skills 索引完成
└─────────────────────────────────────────┘

Agent 处理请求
  ↓
[匹配 trigger: "build|feature|system"]
  ↓
brainstorming 自动触发
  ├─ 提问：What are the core requirements?
  ├─ 提问：Who are the users?
  ├─ 提问：What security concerns?
  ├─ 问题：Should we support social login providers?
  ├─ 展示架构草案（分段展示）
  ├─ 保存至：docs/superpowers/specs/2026-04-02-oauth-auth-design.md
  └─ next-skills → [writing-plans, using-git-worktrees]
  
用户审批设计

  ↓
using-git-worktrees 自动触发
  ├─ 创建新 worktree：auth-feature-2026-04-02
  ├─ 切换到新分支
  ├─ 运行 npm install / make setup
  ├─ 验证 npm test 通过（clean baseline）
  └─ next-skills → [writing-plans]

用户点击 "开始实现"

  ↓
writing-plans 自动触发
  ├─ 解析设计文档
  ├─ 分解为 15 个微任务：
  │   ├─ Task 1 (3min): Create OAuth provider interface
  │   ├─ Task 2 (5min): Implement GitHub OAuth strategy
  │   ├─ Task 3 (4min): Add token refresh logic
  │   └─ ... (12 more)
  ├─ 每个任务包含：
  │   ├─ 文件路径：src/oauth/providers/github.ts
  │   ├─ 完整代码
  │   └─ 验证步骤：npm test -- oauth.github
  ├─ 展示任务列表，等待批准
  └─ next-skills → [subagent-driven-development]

用户批准计划

  ↓
subagent-driven-development 自动触发
  ├─ Task 1 执行 (Subagent #1)
  │   ├─ 创建 src/oauth/providers/index.ts
  │   ├─ 写入接口定义
  │   └─ 【审查门 1】规格合规检查
  │       └─ 批准 → 进行
  │
  ├─ Task 1 内 test-driven-development
  │   ├─ 【RED】创建失败的测试 (src/oauth/providers/__tests__/index.test.ts)
  │   ├─ 【GREEN】写最小代码使测试通过
  │   ├─ 【REFACTOR】改进代码质量
  │   └─ git commit -m "Implement OAuth provider interface"
  │
  ├─ 【审查门 2】代码质量审查
  │   ├─ 检查 lint 通过
  │   ├─ 检查 test coverage > 80%
  │   ├─ 检查模块化设计
  │   └─ 批准 → 进行
  │
  ├─ Task 2 执行 (Subagent #2)
  │   ├─ 创建 src/oauth/providers/github.ts
  │   ├─ 实现 GitHub OAuth 策略
  │   └─ 【两阶段审查】
  │       ├─ 规格合规 ✅
  │       └─ 代码质量 ✅
  │
  └─ ... (重复所有任务)

所有任务完成

  ↓
finishing-a-development-branch 自动触发
  ├─ 运行完整测试套件：npm test
  ├─ 生成覆盖率报告：npm coverage
  ├─ 展示选项：
  │   a) 合并到 main: git checkout main && git merge auth-feature-*
  │   b) 创建 PR: gh pr create --base main
  │   c) 保留 worktree 进行额外工作
  │   d) 丢弃（未合并）：git worktree remove auth-feature-*
  └─ 用户选择 → b（创建 PR）

GitHub PR 创建
  ├─ PR #123: OAuth 2.0 Authentication System
  ├─ 包含：
  │   ├─ 所有 commit（分离的任务 commit）
  │   ├─ 设计文档链接
  │   └─ 测试覆盖报告
  └─ [准备好社区审查]

完成！
```

---

## 常见问题与故障排除

### Q1: Skills 更新后导致 agent 行为改变

**症状**：修改 skill 后，agent 仍使用旧版本

**解决**
```bash
# 方式 1：重启 session
# （自动运行 initialize-skills.sh，触发 git fetch）

# 方式 2：手动更新
cd ~/.config/superpowers/skills/
git pull --rebase

# 方式 3：检查缓存（VS Code）
rm -rf ~/.cache/superpowers/
# 下次 session 会重新克隆
```

### Q2: 项目特定 skill 不生效

**症状**：创建了 `.superpowers/skills/custom-skill/SKILL.md`，但 agent 使用核心版本

**检查清单**
```bash
# 1. 路径正确？
ls -la .superpowers/skills/custom-skill/SKILL.md

# 2. Frontmatter 有效？
head -20 .superpowers/skills/custom-skill/SKILL.md
# 应该看到 YAML frontmatter

# 3. skill 名称与加载名称匹配？
# SKILL.md 中 trigger pattern 必须与 skill 名称匹配或包含

# 4. 重启 session？
# 某些平台需要重启才能重新索引
```

### Q3: 本地修改被覆盖

**症状**：运行 initialize-skills.sh 后，自定义修改消失

**原因**：本地分叉，脚本自动 rebase

**预防**
```bash
# 使用 branch 开发，不在 main 上修改
cd ~/.config/superpowers/skills/
git checkout -b my-improvements
# 修改 SKILL.md
git commit -m "Improve test-driven skill"

# 设置上游
git branch -u origin/main

# 现在 initialize-skills.sh 会检测本地领先，不会覆盖
```

### Q4: 符号链接权限问题（Windows）

**症状**：创建接合点时出现 "Access Denied"

**解决**
```powershell
# 以管理员身份运行 PowerShell
Run-As Administrator

# 重新运行安装脚本
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md
```

---

## 性能优化建议

### 对于大型项目（100+ skills）

1. **分层目录**
   ```
   skills/
   ├── core/              # 基础 skills（10)
   ├── domain/            # 领域特定（30）
   ├── optimizations/     # 性能优化（20）
   └── advanced/          # 高级技巧（40）
   ```

2. **按需加载**
   ```yaml
   # SKILL.md
   lazy: true           # 仅在匹配 trigger 时加载
   category: "advanced" # 便于索引过滤
   ```

3. **缓存策略**
   ```bash
   # 索引缓存（1 小时）
   ~/.config/superpowers/.skill-index.json
   
   # 修改时间戳检查
   if [[ $(stat -f%m ~/.config/superpowers/skills) -gt CACHE_TIME ]]; then
     rebuild_index
   fi
   ```

---

## 总结

Superpowers 的架构设计实现了：

✅ **轻量级插件** → 减少发布负担  
✅ **独立 skills 库** → 快速社区迭代  
✅ **声明式工作流** → 易于理解和贡献  
✅ **多平台支持** → 统一的开发体验  
✅ **自动化更新** → 用户始终获得最新的最佳实践  

这使得 AI 编码代理从**实验性工具**演变为**生产级开发伙伴**。
