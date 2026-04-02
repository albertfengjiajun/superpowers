## Why

Antigravity 已经支持 Agent Skills 和本地 workflows，但目前还不能以 zero-intrusion 的方式直接消费 Superpowers。当前给其他宿主使用的 nested install 结构，会导致 Antigravity 无法发现 `brainstorming` 这样的核心 skill，而且项目里也没有 Antigravity 专用的 workflow 入口。

## What Changes

- 新增 Antigravity installer scripts，以扁平化方式把现有根目录 `skills/*` 映射为用户全局 `.agents/skills` 下的逐个 skill link。
- 在 `.agent/workflows` 下新增使用 `superpowers-*` 命名的薄入口 Antigravity workflows，把用户导向现有 Superpowers skills，而不是复制其中的逻辑。
- 新增独立的 Antigravity installation 和 troubleshooting 文档。
- v1 默认不引入 rules，除非手工验证证明 Antigravity 仅靠 skill discovery 和显式 workflows 仍无法稳定激活 `using-superpowers`。
- 通过不修改仓库中任何现有文件，保证 upstream 升级时不会产生 merge conflict。

## Capabilities

### New Capabilities
- `antigravity-support`：在不修改任何现有 Superpowers 文件的前提下，通过扁平化 skill discovery 和项目级薄入口 workflows，在 Antigravity 中安装并使用 Superpowers。

### Modified Capabilities

## Impact

- Affected code：仅新增 scripts、workflow markdown 文件和文档
- Affected systems：Antigravity 全局 skill discovery 与项目 workflow discovery
- Dependencies：现有根目录 `skills/*`，以及本地 shell 的 symlink/junction 创建能力
- Operational impact：需要在至少一个真实 Antigravity session 和一个受支持 OS 上做手工验证
