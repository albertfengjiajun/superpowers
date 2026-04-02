## 1. Antigravity install layer

- [x] 1.1 新增一个 Windows installer，从根目录 `skills/*` 创建扁平化的全局 Antigravity skill links
- [x] 1.2 新增一个 Unix installer，从根目录 `skills/*` 创建扁平化的全局 Antigravity skill symlinks
- [x] 1.3 新增配套的 uninstall scripts，只移除为 Superpowers 创建的 Antigravity links

## 2. 薄入口 workflow

- [x] 2.1 新增 `/superpowers-design`，作为 `brainstorming` 的薄入口 workflow
- [x] 2.2 新增 `/superpowers-plan`，作为 `writing-plans` 的薄入口 workflow
- [x] 2.3 新增 `/superpowers-execute`，作为 execution skills 的薄入口 workflow
- [x] 2.4 新增 `/superpowers-finish`，作为 branch completion 的薄入口 workflow

## 3. Documentation

- [x] 3.1 新增一个专用的 Antigravity installation guide，说明全局 skills 和项目 workflows 的组合方式
- [x] 3.2 记录 Antigravity 无法发现 nested-skill install 的 troubleshooting
- [x] 3.3 记录 v1 故意不引入 rules

## 4. Validation

- [x] 4.1 验证 Antigravity 能发现像 `brainstorming` 这样的扁平化全局 skills
- [x] 4.2 验证每个 `superpowers-*` workflow 都能出现，并路由到预期的 skill
- [x] 4.3 验证整个 support layer 可以在没有 `.agent/rules` 的情况下运行
