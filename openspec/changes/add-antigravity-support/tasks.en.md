## 1. Antigravity install layer

- [ ] 1.1 Add a Windows installer that creates flattened global Antigravity skill links from root `skills/*`
- [ ] 1.2 Add a Unix installer that creates flattened global Antigravity skill symlinks from root `skills/*`
- [ ] 1.3 Add matching uninstall scripts that remove only the Antigravity links created for Superpowers

## 2. Thin workflow entrypoints

- [ ] 2.1 Add `/superpowers-design` as a thin workflow entrypoint for `brainstorming`
- [ ] 2.2 Add `/superpowers-plan` as a thin workflow entrypoint for `writing-plans`
- [ ] 2.3 Add `/superpowers-execute` as a thin workflow entrypoint for execution skills
- [ ] 2.4 Add `/superpowers-finish` as a thin workflow entrypoint for branch completion

## 3. Documentation

- [ ] 3.1 Add a dedicated Antigravity installation guide that explains global skills plus project workflows
- [ ] 3.2 Document troubleshooting for nested-skill installs that Antigravity fails to discover
- [ ] 3.3 Document that rules are intentionally omitted in v1

## 4. Validation

- [ ] 4.1 Validate that Antigravity discovers flattened global skills like `brainstorming`
- [ ] 4.2 Validate that each `superpowers-*` workflow appears and routes to the expected skill
- [ ] 4.3 Validate that the support layer works without `.agent/rules`
