## Context

Superpowers 已经通过不同宿主的 install layer 支持多个 agent host，同时保持根目录 `skills/*` 作为行为的唯一来源。Antigravity 兼容 Agent Skills，并且有稳定的 workflow 目录；但实测表明，像 `.agents/skills/superpowers/brainstorming/SKILL.md` 这样的 nested install 结构，并不会被 Antigravity 识别为 `brainstorming` skill。同时，用户要求这次方案必须是 zero-intrusion：不能修改任何现有 upstream 文件，不能重写 platform runtime，也不能在从 `obra/superpowers` 同步时制造 merge conflict。

Antigravity 还有项目级 workflows（`.agent/workflows`）和可选的项目级 rules（`.agent/rules`）。用户已经明确表示，如果 workflows 和 discovered skills 足够，就尽量不要引入 rules。

## Goals / Non-Goals

**Goals:**
- 通过仅新增文件的方式提供 zero-intrusion 的 Antigravity support layer。
- 复用现有根目录 `skills/*`，保持它作为唯一 source of truth。
- 通过扁平化的全局安装形态，让 Antigravity 能发现核心 Superpowers skills。
- 提供使用 `superpowers-*` 命名的项目级薄入口 workflows，覆盖常见的 Superpowers phases。
- 不修改任何现有文件，从而保证 upstream 升级过程无摩擦。

**Non-Goals:**
- 不实现 Antigravity plugin 或 runtime integration layer。
- 不做 Artifact / Manager / Subagent 级别的平台集成。
- 不修改 `README.md`、已有 skill 文件或已有平台适配文件。
- v1 不引入项目级 rules，除非手工验证证明必须使用。
- 不把项目专用的 `openspec-*` skills 纳入 Antigravity bridge。

## Decisions

### Decision 1: 使用扁平化的逐 skill 全局安装

Antigravity support 将把每个根 skill 安装到用户全局 `.agents/skills/<skill-name>` 路径下，并将其作为指向 `<repo>/skills/<skill-name>` 的独立 link。

相对于其他方案，这样选择的原因是：
- `.agents/skills/superpowers/<skill-name>` 这种单一 wrapper 目录，在 Antigravity 中不能稳定暴露子 skills。
- 复制 skill folder 会造成 drift，破坏 zero-intrusion 升级。
- 逐 skill link 同时满足单一 source of truth 和 Antigravity 的实际 discovery 模型。

### Decision 2: v1 使用薄入口 project workflows，而不是 rules

项目将新增以下 `.agent/workflows` 文件：
- `superpowers-design`
- `superpowers-plan`
- `superpowers-execute`
- `superpowers-finish`

每个 workflow 都是一个薄入口，只告诉 Antigravity 应该使用哪个现有 skill，以及什么时候停止或跳转到下一阶段。

相对于其他方案，这样选择的原因是：
- 薄入口 workflows 给了用户显式、稳定的入口，但不会复制 skill body。
- 复用现有 `opsx-*` 名称会混淆 OpenSpec 和 Antigravity support 的边界。
- rules 是可选项，只有 workflows 不足时才应该引入。

### Decision 3: 保持 workflow layer 足够薄

新的 workflows 不会复述完整的 Superpowers 逻辑。它们只负责：
- 指定目标 skill
- 说明使用该 skill 的前置条件
- 当前置条件不满足时，把用户重定向到正确的下一个 workflow

相对于其他方案，这样选择的原因是：
- 厚 workflows 会复制 `skills/*`，并最终和 upstream 演进脱节。
- 薄 workflows 只做 routing，不做重定义，因此更能承受 upstream skill 演化。

### Decision 4: 新增独立的 Antigravity 文档

Antigravity 的 installation 和 troubleshooting 说明将写入新文档，而不是修改现有 README。

相对于其他方案，这样选择的原因是：
- 保持变更完全 additive。
- 避免与 upstream 文档合并时产生冲突。
- 将 Antigravity 特定的 host knowledge 聚合到一个地方。

## Risks / Trade-offs

- [Risk] Antigravity 仅靠 discovered skills 仍可能无法稳定自动激活 `using-superpowers`。 -> Mitigation：先用显式 workflow 入口验证；只有手工测试证明不够时，才增加 `.agent/rules`。
- [Risk] Windows 环境里 link 创建可能在受限环境下失败。 -> Mitigation：Windows 默认使用 junction，并提供清晰的失败提示和手工 fallback 步骤。
- [Risk] 如果 installer 使用硬编码列表，upstream 未来新增根 skills 时可能漏装。 -> Mitigation：通过扫描 `skills/*/SKILL.md` 动态发现 install candidates。
- [Risk] 薄 workflows 的自动化感受可能弱于宿主特定的 bootstrap integration。 -> Mitigation：保持 workflow 命名清晰，并让每个 workflow 承担明确的 handoff 语义。
- [Risk] 全局 skill 安装意味着 Antigravity support 是 host-user 级别，而 workflows 是 project 级别。 -> Mitigation：文档中明确说明这种 split，并把它定义为 v1 的支持模型。

## Migration Plan

1. 以新增文件的方式加入 installer scripts、workflow 文件和 Antigravity 文档。
2. 从仓库根目录 `skills/*` 安装扁平化的全局 skills。
3. 在真实 Antigravity session 中验证四个 project workflows。
4. 如果验证成功，继续保持 rules 不在 v1 范围内。
5. 回滚也只需要删除新增的 workflow 文件，以及 installer 创建的全局 links。

## Open Questions

- v1 设计层面没有未决问题。剩余的仅是 operational validation：确认显式 workflows 加扁平化 skill install，足以在不使用 project rules 的前提下稳定工作。
