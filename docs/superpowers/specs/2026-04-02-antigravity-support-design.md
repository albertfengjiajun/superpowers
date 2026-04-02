# Antigravity Support Design

## Summary

通过一个 additive compatibility layer 为 Antigravity 增加支持：复用现有根目录 `skills/*`，将这些 skills 以扁平化形态安装到 Antigravity 的全局 `.agents/skills` 目录，并在 `.agent/workflows` 中提供项目级 `superpowers-*` workflow 入口。

这个 design 明确避免修改任何现有文件，因此 repository 继续从 upstream 同步时不会产生 merge conflict。

## Constraints

- 任何现有 repository 文件都不能被修改。
- 根目录 `skills/*` 仍然是 skill behavior 的唯一来源。
- 当 skills 安装在 `.agents/skills/superpowers/<skill-name>` 下时，Antigravity 无法发现这些 skills。
- Antigravity 支持 `.agent/workflows` 下的项目级 workflows。
- rules 虽然可用，但除非 workflow-only activation 不足，否则不应引入。

## Chosen Approach

1. 把每个根 skill 安装成一级的全局 Antigravity skill。
2. 新增四个薄入口的项目级 workflows：
   - `superpowers-design`
   - `superpowers-plan`
   - `superpowers-execute`
   - `superpowers-finish`
3. 保持 workflows 足够薄，只做 routing，不复制 skill 内部流程。
4. 把 Antigravity 专用的 installation 和 troubleshooting 写入新文档，而不是改已有 docs。

## Rejected Approaches

### 嵌套式的 `superpowers/<skill>` 全局安装

拒绝原因：Antigravity 不能从 `C:\Users\Administrator\.agents\skills\superpowers\brainstorming\SKILL.md` 中发现 `brainstorming`。这种形态对其他 hosts 可用，但对 Antigravity 不可靠。

### 复制 skills 到 Antigravity 目录

拒绝原因：它会产生 drift，破坏 zero-intrusion 升级，并让 troubleshooting 更困难。

### rules-first bootstrap

拒绝原因：v1 中 workflows 已经能提供显式入口，而且用户明确偏好尽量不用 rules。只有当 workflow-only validation 失败时，rules 才作为 fallback。

## File Additions

- `scripts/antigravity/install-skills.ps1`
- `scripts/antigravity/install-skills.sh`
- `scripts/antigravity/remove-skills.ps1`
- `scripts/antigravity/remove-skills.sh`
- `.agent/workflows/superpowers-design.md`
- `.agent/workflows/superpowers-plan.md`
- `.agent/workflows/superpowers-execute.md`
- `.agent/workflows/superpowers-finish.md`
- `docs/README.antigravity.md`

## Validation Targets

- Antigravity 能发现扁平化后的 `brainstorming`、`writing-plans` 和 `using-superpowers` 等 skills。
- `/superpowers-design` 能正确进入 design phase，且不会泄漏到 implementation。
- `/superpowers-plan` 仅在存在 design context 时进入 planning。
- `/superpowers-execute` 仅在存在 plan 时进入 execution。
- `/superpowers-finish` 仅在工作完成后进入 finishing。
- 支持的 v1 流程不依赖 `.agent/rules`。
