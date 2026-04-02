## Context

Superpowers already supports multiple agent hosts through host-specific install layers while keeping the root `skills/*` directory as the primary source of behavior. Antigravity is compatible with Agent Skills and has stable workflow directories, but practical testing showed that a nested install shape like `.agents/skills/superpowers/brainstorming/SKILL.md` is not discovered as the `brainstorming` skill in Antigravity. At the same time, the user wants a zero-intrusion approach: no edits to existing upstream files, no platform-runtime rewrite, and no merge conflicts when syncing from `obra/superpowers`.

Antigravity also has project workflows in `.agent/workflows` and optional project rules in `.agent/rules`. The user explicitly prefers avoiding rules if workflows and discovered skills are sufficient.

## Goals / Non-Goals

**Goals:**
- Provide a zero-intrusion Antigravity support layer using additive files only.
- Reuse the existing root `skills/*` as the single source of truth.
- Make core Superpowers skills discoverable in Antigravity through a flattened global install shape.
- Provide thin project workflow entrypoints with `superpowers-*` names for common Superpowers phases.
- Keep upstream upgrades frictionless by avoiding modifications to existing files.

**Non-Goals:**
- No Antigravity plugin or runtime integration layer.
- No Artifact/Manager/Subagent platform integration work.
- No edits to `README.md`, existing skill files, or existing platform-specific integration files.
- No project rules in v1 unless manual validation proves they are required.
- No support for project-specific `openspec-*` skills as part of the Antigravity bridge.

## Decisions

### Decision 1: Use flattened per-skill global installation

Antigravity support will install each root skill into the user's global `.agents/skills/<skill-name>` path as an individual link to `<repo>/skills/<skill-name>`.

Why this over alternatives:
- A single wrapper directory such as `.agents/skills/superpowers/<skill-name>` does not reliably surface child skills in Antigravity.
- Copying skill folders would create drift and undermine zero-intrusion upgrades.
- Per-skill links preserve one source of truth while matching Antigravity's observed discovery model.

### Decision 2: Use thin project workflows instead of rules for v1

The project will add new workflow files in `.agent/workflows` named:
- `superpowers-design`
- `superpowers-plan`
- `superpowers-execute`
- `superpowers-finish`

Each workflow will be a thin entrypoint that tells Antigravity which existing skill to use and when to stop or redirect to the next phase.

Why this over alternatives:
- Thin workflows give users explicit, stable entrypoints without duplicating skill bodies.
- Reusing existing `opsx-*` names would blur OpenSpec and Antigravity support concerns.
- Rules are optional and should not be introduced until workflows prove insufficient.

### Decision 3: Keep the workflow layer intentionally thin

The new workflows will not restate full Superpowers logic. They will:
- name the target skill
- state the gating condition for using it
- redirect users to the correct next workflow when the precondition is not met

Why this over alternatives:
- Fat workflows would duplicate and eventually diverge from `skills/*`.
- Thin workflows survive upstream skill evolution because they only route, not redefine.

### Decision 4: Add a dedicated Antigravity documentation file

Antigravity installation and troubleshooting guidance will live in a new document rather than modifying existing README content.

Why this over alternatives:
- It keeps the change additive only.
- It avoids merge conflicts against upstream documentation.
- It localizes Antigravity-specific host knowledge in one place.

## Risks / Trade-offs

- [Risk] Antigravity may still not auto-activate `using-superpowers` reliably from discovered skills alone. -> Mitigation: validate with explicit workflow entrypoints first; add `.agent/rules` only if manual testing proves necessary.
- [Risk] Windows link creation may fail in restricted environments. -> Mitigation: use junctions by default on Windows and provide a clean failure message plus manual fallback steps.
- [Risk] Future root skills added upstream might be missed if the installer uses a hardcoded list. -> Mitigation: discover install candidates dynamically by scanning `skills/*/SKILL.md`.
- [Risk] Thin workflows may feel less automated than host-specific bootstrap integrations. -> Mitigation: keep workflow names obvious and make each workflow responsible for the correct handoff language.
- [Risk] Global skill installation means Antigravity support is host-user level while workflows are project level. -> Mitigation: document the split explicitly and treat it as the supported operating model for v1.

## Migration Plan

1. Add the new installer scripts, workflow files, and Antigravity documentation as additive files.
2. Install flattened global skills from the repo's root `skills/*`.
3. Validate the four project workflows in a real Antigravity session.
4. If validation succeeds, keep rules out of scope for v1.
5. Rollback is additive-only: remove the new workflow files from the repo clone and remove the global links created by the installer.

## Open Questions

- None required for v1 design closure. The only follow-up validation is operational: confirm that explicit workflows plus flattened skill install are sufficient without project rules.
