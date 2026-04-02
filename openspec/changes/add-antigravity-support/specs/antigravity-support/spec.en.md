## ADDED Requirements

### Requirement: Flattened global skill installation
The Antigravity support layer SHALL expose each core Superpowers skill as a first-level directory under the Antigravity-compatible global `.agents/skills` root, with each directory resolving to the existing repository `skills/<skill-name>` source rather than a copied duplicate.

#### Scenario: Install core skills for Antigravity discovery
- **WHEN** the Antigravity installer runs against a Superpowers repository clone
- **THEN** it creates one global skill entry per root `skills/*` directory that contains `SKILL.md`

#### Scenario: Preserve upstream as source of truth
- **WHEN** a user updates the upstream Superpowers repository
- **THEN** the installed Antigravity skill entries continue resolving to the updated upstream skill content without requiring copied skill files to be synchronized

### Requirement: Thin project workflow entrypoints
The Antigravity support layer SHALL provide project workflows under `.agent/workflows` that serve as thin entrypoints into existing Superpowers skills without duplicating the skill instructions.

#### Scenario: Start design phase through Antigravity
- **WHEN** a user runs `/superpowers-design`
- **THEN** the workflow directs Antigravity to use the existing `brainstorming` skill and not to begin implementation work

#### Scenario: Start planning phase through Antigravity
- **WHEN** a user runs `/superpowers-plan`
- **THEN** the workflow directs Antigravity to use the existing `writing-plans` skill only when a design or approved requirements context exists

#### Scenario: Start execution phase through Antigravity
- **WHEN** a user runs `/superpowers-execute`
- **THEN** the workflow directs Antigravity to use `subagent-driven-development` by default and to fall back to `executing-plans` only when inline execution is explicitly requested

#### Scenario: Start finish phase through Antigravity
- **WHEN** a user runs `/superpowers-finish`
- **THEN** the workflow directs Antigravity to use `finishing-a-development-branch` only after implementation and verification are complete

### Requirement: Zero-intrusion repository support
The Antigravity support layer SHALL be implemented only through newly added files and SHALL NOT require modifications to existing repository files.

#### Scenario: Add support without merge-risking existing integrations
- **WHEN** Antigravity support is added to the repository
- **THEN** no existing file under `skills/`, `.codex/`, `.opencode/`, `.gemini/`, `.claude/`, or current documentation is modified

#### Scenario: Remove Antigravity support cleanly
- **WHEN** the additive Antigravity support files and installed global links are removed
- **THEN** the repository returns to its prior behavior without requiring restoration of modified upstream files

### Requirement: Rules remain optional in v1
The Antigravity support layer SHALL NOT require project-level Antigravity rules for its initial supported flow.

#### Scenario: Operate with skills and workflows only
- **WHEN** Antigravity support is installed according to the documented v1 process
- **THEN** users can discover core skills and invoke the `superpowers-*` workflows without requiring `.agent/rules`
