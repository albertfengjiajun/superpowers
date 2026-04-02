# Antigravity Support Design

## Summary

Add Antigravity support as an additive compatibility layer that reuses the existing root `skills/*` directory, installs those skills into Antigravity's global `.agents/skills` directory in a flattened shape, and provides project-local `superpowers-*` workflow entrypoints in `.agent/workflows`.

This design intentionally avoids modifying any existing file so the repository can continue to sync from upstream without merge conflicts.

## Constraints

- Existing repository files must remain unchanged.
- Root `skills/*` remains the only source of skill behavior.
- Antigravity did not discover skills when they were installed under `.agents/skills/superpowers/<skill-name>`.
- Antigravity supports project workflows in `.agent/workflows`.
- Rules are available but should be avoided unless workflow-only activation proves insufficient.

## Chosen Approach

1. Install each root skill as a first-level global Antigravity skill.
2. Add four thin project workflows:
   - `superpowers-design`
   - `superpowers-plan`
   - `superpowers-execute`
   - `superpowers-finish`
3. Keep workflows thin and route users into existing skills rather than copying process logic.
4. Add Antigravity-specific installation and troubleshooting documentation as a new file instead of modifying existing docs.

## Rejected Approaches

### Nested `superpowers/<skill>` global install

Rejected because Antigravity did not discover `brainstorming` from `C:\Users\Administrator\.agents\skills\superpowers\brainstorming\SKILL.md`. This shape is compatible with other hosts but not reliable for Antigravity.

### Copying skills into Antigravity directories

Rejected because it creates drift, undermines zero-intrusion upgrades, and makes troubleshooting harder.

### Rules-first bootstrap

Rejected for v1 because workflows give explicit entrypoints and the user prefers avoiding rules where possible. Rules remain a fallback if workflow-only validation fails.

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

- Antigravity can discover flattened skills such as `brainstorming`, `writing-plans`, and `using-superpowers`.
- `/superpowers-design` routes into the design phase without implementation leakage.
- `/superpowers-plan` routes into planning only when design context exists.
- `/superpowers-execute` routes into execution only when a plan exists.
- `/superpowers-finish` routes into finishing only when work is complete.
- No `.agent/rules` are required for the supported v1 workflow.
