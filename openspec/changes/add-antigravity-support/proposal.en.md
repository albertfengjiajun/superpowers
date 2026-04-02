## Why

Antigravity already supports Agent Skills and local workflows, but Superpowers is not currently consumable there in a zero-intrusion way. The current nested install shape used for other hosts can leave Antigravity unable to discover core skills like `brainstorming`, and the project has no Antigravity-specific workflow entrypoints.

## What Changes

- Add additive Antigravity installer scripts that flatten the existing root `skills/*` into per-skill links under the user's global `.agents/skills` directory.
- Add thin Antigravity workflow entrypoints under `.agent/workflows` using `superpowers-*` names that point users into existing Superpowers skills without copying their logic.
- Add a dedicated Antigravity installation and troubleshooting document.
- Keep v1 rule-free unless manual validation proves Antigravity does not reliably activate `using-superpowers` through discovered skills and explicit workflows.
- Preserve upstream upgrade safety by avoiding changes to any existing file in the repository.

## Capabilities

### New Capabilities
- `antigravity-support`: Install and use Superpowers from Antigravity through flattened skill discovery and thin project workflows without modifying existing Superpowers files.

### Modified Capabilities

## Impact

- Affected code: new additive scripts, workflow markdown files, and documentation only
- Affected systems: Antigravity global skills discovery and project workflow discovery
- Dependencies: existing root `skills/*`, local shell tooling for symlink/junction creation
- Operational impact: manual validation required in a real Antigravity session on at least one supported OS
