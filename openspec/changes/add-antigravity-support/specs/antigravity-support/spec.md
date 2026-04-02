## ADDED Requirements

### Requirement: 扁平化的全局 skill 安装
Antigravity support layer SHALL 将每个核心 Superpowers skill 暴露为 Antigravity 兼容的全局 `.agents/skills` 根目录下的一级目录，并且每个目录都指向现有仓库 `skills/<skill-name>` 的 source，而不是复制出的副本。

#### Scenario: 为 Antigravity discovery 安装核心 skills
- **WHEN** Antigravity installer 针对一个 Superpowers repository clone 运行
- **THEN** 它会为每一个包含 `SKILL.md` 的根目录 `skills/*` 创建一个全局 skill entry

#### Scenario: 保持 upstream 作为 source of truth
- **WHEN** 用户更新 upstream Superpowers repository
- **THEN** 已安装的 Antigravity skill entries 会继续解析到更新后的 upstream skill 内容，而不需要同步任何复制出来的 skill 文件

### Requirement: 薄入口的 project workflows
Antigravity support layer SHALL 在 `.agent/workflows` 下提供 project workflows，并将其作为进入现有 Superpowers skills 的薄入口，而不复制 skill instructions。

#### Scenario: 通过 Antigravity 启动 design phase
- **WHEN** 用户运行 `/superpowers-design`
- **THEN** 该 workflow 会指示 Antigravity 使用现有 `brainstorming` skill，并且不会开始 implementation work

#### Scenario: 通过 Antigravity 启动 planning phase
- **WHEN** 用户运行 `/superpowers-plan`
- **THEN** 该 workflow 会指示 Antigravity 仅在已有 design 或已批准 requirements context 的前提下使用现有 `writing-plans` skill

#### Scenario: 通过 Antigravity 启动 execution phase
- **WHEN** 用户运行 `/superpowers-execute`
- **THEN** 该 workflow 会默认指示 Antigravity 使用 `subagent-driven-development`，只有在用户明确要求 inline execution 时才回退到 `executing-plans`

#### Scenario: 通过 Antigravity 启动 finish phase
- **WHEN** 用户运行 `/superpowers-finish`
- **THEN** 该 workflow 会仅在 implementation 和 verification 已完成后，指示 Antigravity 使用 `finishing-a-development-branch`

### Requirement: zero-intrusion 的 repository support
Antigravity support layer SHALL 仅通过新增文件实现，并且 SHALL NOT 需要修改任何现有 repository 文件。

#### Scenario: 在不引发 merge 风险的情况下增加 support
- **WHEN** Antigravity support 被加入到 repository
- **THEN** `skills/`、`.codex/`、`.opencode/`、`.gemini/`、`.claude/` 以及现有文档下的任何现有文件都不会被修改

#### Scenario: 干净移除 Antigravity support
- **WHEN** 删除新增的 Antigravity support 文件，以及已安装的全局 links
- **THEN** repository 会恢复到原有行为，而不需要还原任何被修改过的 upstream 文件

### Requirement: v1 中 rules 保持可选
Antigravity support layer SHALL NOT 在其初始支持流程中强制要求 project-level 的 Antigravity rules。

#### Scenario: 仅通过 skills 和 workflows 运行
- **WHEN** 按照文档中的 v1 流程安装 Antigravity support
- **THEN** 用户无需 `.agent/rules`，也能发现核心 skills，并调用 `superpowers-*` workflows
