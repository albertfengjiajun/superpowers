# Antigravity Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add zero-intrusion Antigravity support using flattened global skill installation and thin project workflows without modifying any existing Superpowers file.

**Architecture:** Create additive installer scripts that expose root `skills/*` as first-level global Antigravity skills, add four thin `.agent/workflows/superpowers-*.md` entrypoints, and document installation/troubleshooting in a new Antigravity-specific doc. Keep rules out of v1 unless manual validation proves they are required.

**Tech Stack:** PowerShell, POSIX shell, Markdown workflows, filesystem links/junctions

**Spec:** `docs/superpowers/specs/2026-04-02-antigravity-support-design.md`

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `scripts/antigravity/install-skills.ps1` | Windows flattened global skill install | Create |
| `scripts/antigravity/install-skills.sh` | Unix flattened global skill install | Create |
| `scripts/antigravity/remove-skills.ps1` | Windows cleanup of installed links | Create |
| `scripts/antigravity/remove-skills.sh` | Unix cleanup of installed links | Create |
| `.agent/workflows/superpowers-design.md` | Thin design entrypoint | Create |
| `.agent/workflows/superpowers-plan.md` | Thin planning entrypoint | Create |
| `.agent/workflows/superpowers-execute.md` | Thin execution entrypoint | Create |
| `.agent/workflows/superpowers-finish.md` | Thin finishing entrypoint | Create |
| `docs/README.antigravity.md` | Installation and troubleshooting guide | Create |

---

### Task 1: Create the Windows skill installer

**Files:**
- Create: `scripts/antigravity/install-skills.ps1`

- [ ] **Step 1: Create the target directory skeleton**

Create `scripts/antigravity/install-skills.ps1` with:

```powershell
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$skillsRoot = Join-Path $repoRoot 'skills'
$targetRoot = Join-Path $env:USERPROFILE '.agents\skills'

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
```

- [ ] **Step 2: Add dynamic skill discovery**

Append:

```powershell
$skillDirs = Get-ChildItem -Path $skillsRoot -Directory |
  Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }

if (-not $skillDirs) {
  throw "No installable skills found under $skillsRoot"
}
```

- [ ] **Step 3: Add safe flattened junction creation**

Append:

```powershell
foreach ($skillDir in $skillDirs) {
  $targetPath = Join-Path $targetRoot $skillDir.Name

  if (Test-Path $targetPath) {
    $existing = Get-Item $targetPath -Force
    if ($existing.LinkType -eq 'Junction' -or $existing.LinkType -eq 'SymbolicLink') {
      Remove-Item $targetPath -Force
    } else {
      throw "Refusing to overwrite non-link path: $targetPath"
    }
  }

  cmd /c mklink /J "$targetPath" "$($skillDir.FullName)" | Out-Null
  Write-Host "Installed skill: $($skillDir.Name)"
}
```

- [ ] **Step 4: Add final summary**

Append:

```powershell
Write-Host ""
Write-Host "Installed $($skillDirs.Count) Superpowers skills for Antigravity."
Write-Host "Target root: $targetRoot"
```

- [ ] **Step 5: Run the installer in dry environment**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\antigravity\install-skills.ps1
```

Expected: one `Installed skill:` line per root skill plus final summary.

---

### Task 2: Create the Unix skill installer

**Files:**
- Create: `scripts/antigravity/install-skills.sh`

- [ ] **Step 1: Create the script header**

Create `scripts/antigravity/install-skills.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"
TARGET_ROOT="${HOME}/.agents/skills"

mkdir -p "$TARGET_ROOT"
```

- [ ] **Step 2: Add dynamic skill discovery**

Append:

```bash
mapfile -t SKILL_DIRS < <(find "$SKILLS_ROOT" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
  if [[ -f "$dir/SKILL.md" ]]; then
    printf '%s\n' "$dir"
  fi
done)

if [[ "${#SKILL_DIRS[@]}" -eq 0 ]]; then
  echo "No installable skills found under $SKILLS_ROOT" >&2
  exit 1
fi
```

- [ ] **Step 3: Add symlink creation**

Append:

```bash
for skill_dir in "${SKILL_DIRS[@]}"; do
  skill_name="$(basename "$skill_dir")"
  target_path="$TARGET_ROOT/$skill_name"
  rm -rf "$target_path"
  ln -s "$skill_dir" "$target_path"
  echo "Installed skill: $skill_name"
done
```

- [ ] **Step 4: Add final summary and executable bit**

Append:

```bash
echo
echo "Installed ${#SKILL_DIRS[@]} Superpowers skills for Antigravity."
echo "Target root: $TARGET_ROOT"
```

Run:

```bash
chmod +x scripts/antigravity/install-skills.sh
```

- [ ] **Step 5: Run the installer**

Run:

```bash
./scripts/antigravity/install-skills.sh
```

Expected: one `Installed skill:` line per root skill plus final summary.

---

### Task 3: Create cleanup scripts

**Files:**
- Create: `scripts/antigravity/remove-skills.ps1`
- Create: `scripts/antigravity/remove-skills.sh`

- [ ] **Step 1: Create PowerShell cleanup**

Create `scripts/antigravity/remove-skills.ps1`:

```powershell
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$skillsRoot = Join-Path $repoRoot 'skills'
$targetRoot = Join-Path $env:USERPROFILE '.agents\skills'

$skillDirs = Get-ChildItem -Path $skillsRoot -Directory |
  Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }

foreach ($skillDir in $skillDirs) {
  $targetPath = Join-Path $targetRoot $skillDir.Name
  if (Test-Path $targetPath) {
    $item = Get-Item $targetPath -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
      Remove-Item $targetPath -Force
      Write-Host "Removed skill link: $($skillDir.Name)"
    }
  }
}
```

- [ ] **Step 2: Create Unix cleanup**

Create `scripts/antigravity/remove-skills.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"
TARGET_ROOT="${HOME}/.agents/skills"

find "$SKILLS_ROOT" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
  if [[ -f "$dir/SKILL.md" ]]; then
    skill_name="$(basename "$dir")"
    target_path="$TARGET_ROOT/$skill_name"
    if [[ -L "$target_path" ]]; then
      rm "$target_path"
      echo "Removed skill link: $skill_name"
    fi
  fi
done
```

- [ ] **Step 3: Make Unix cleanup executable**

Run:

```bash
chmod +x scripts/antigravity/remove-skills.sh
```

- [ ] **Step 4: Verify cleanup scripts parse**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content .\scripts\antigravity\remove-skills.ps1 | Out-Null"
```

Run:

```bash
bash -n scripts/antigravity/remove-skills.sh
```

Expected: no parse errors.

---

### Task 4: Add `/superpowers-design`

**Files:**
- Create: `.agent/workflows/superpowers-design.md`

- [ ] **Step 1: Create the workflow**

Create `.agent/workflows/superpowers-design.md`:

```markdown
---
description: Start Superpowers design flow in Antigravity
---

Use the `brainstorming` skill for this task.

This workflow is a thin Antigravity entrypoint only. Do not duplicate the skill content. Follow `skills/brainstorming/SKILL.md` fully, including its approval gates before any implementation action.

If the user already has an approved design or explicitly asks for an implementation plan, stop and tell them to run `/superpowers-plan`.
```

- [ ] **Step 2: Verify formatting**

Read the file and confirm:
- frontmatter exists
- description is one line
- the body names `brainstorming`

---

### Task 5: Add `/superpowers-plan`

**Files:**
- Create: `.agent/workflows/superpowers-plan.md`

- [ ] **Step 1: Create the workflow**

Create `.agent/workflows/superpowers-plan.md`:

```markdown
---
description: Start Superpowers planning flow in Antigravity
---

Use the `writing-plans` skill for this task.

This workflow is a thin Antigravity entrypoint only. Do not restate the plan-writing process. Follow `skills/writing-plans/SKILL.md` fully.

Only continue when the user already has an approved design, spec, or equivalent requirements artifact. If they do not, stop and tell them to run `/superpowers-design`.
```

- [ ] **Step 2: Verify formatting**

Read the file and confirm it names `writing-plans` and redirects missing design context to `/superpowers-design`.

---

### Task 6: Add `/superpowers-execute`

**Files:**
- Create: `.agent/workflows/superpowers-execute.md`

- [ ] **Step 1: Create the workflow**

Create `.agent/workflows/superpowers-execute.md`:

```markdown
---
description: Start Superpowers execution flow in Antigravity
---

Use `subagent-driven-development` for this task unless the user explicitly asks for inline execution, in which case use `executing-plans`.

This workflow is a thin Antigravity entrypoint only. Do not restate the execution system. Follow the selected skill exactly.

Only continue when an implementation plan already exists. If no plan exists, stop and tell the user to run `/superpowers-plan`.
```

- [ ] **Step 2: Verify formatting**

Read the file and confirm it prefers `subagent-driven-development`, mentions `executing-plans` as the inline fallback, and redirects missing plan context.

---

### Task 7: Add `/superpowers-finish`

**Files:**
- Create: `.agent/workflows/superpowers-finish.md`

- [ ] **Step 1: Create the workflow**

Create `.agent/workflows/superpowers-finish.md`:

```markdown
---
description: Finish a completed Superpowers implementation in Antigravity
---

Use the `finishing-a-development-branch` skill for this task.

This workflow is a thin Antigravity entrypoint only. Follow `skills/finishing-a-development-branch/SKILL.md` fully.

Only continue when implementation is complete and verification has already run. If the work is not yet complete, stop and direct the user back to `/superpowers-execute`.
```

- [ ] **Step 2: Verify formatting**

Read the file and confirm it names `finishing-a-development-branch` and redirects unfinished work to `/superpowers-execute`.

---

### Task 8: Add Antigravity documentation

**Files:**
- Create: `docs/README.antigravity.md`

- [ ] **Step 1: Create the document header and install model**

Create `docs/README.antigravity.md` with:

```markdown
# Superpowers for Antigravity

Use Superpowers in Antigravity through:

1. Global flattened skills in `~/.agents/skills/`
2. Project workflows in `.agent/workflows/`

This integration is additive only. It does not modify existing Superpowers files.
```

- [ ] **Step 2: Add installation instructions**

Append:

```markdown
## Installation

### Windows

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\antigravity\install-skills.ps1
```

### macOS / Linux

```bash
./scripts/antigravity/install-skills.sh
```

## Workflow Entry Points

- `/superpowers-design`
- `/superpowers-plan`
- `/superpowers-execute`
- `/superpowers-finish`
```

- [ ] **Step 3: Add troubleshooting**

Append:

```markdown
## Troubleshooting

### Antigravity cannot find `brainstorming`

If your skills are installed under a nested path like:

```text
~/.agents/skills/superpowers/brainstorming/SKILL.md
```

Antigravity may not discover them as first-level skills. Reinstall using the provided Antigravity installer so the resulting shape is:

```text
~/.agents/skills/brainstorming/SKILL.md
```

### Do I need `.agent/rules`?

Not for the supported v1 flow. Start with the workflows above. Add project rules only if validation shows the workflow-only model is insufficient.
```

- [ ] **Step 4: Verify markdown rendering**

Read the full file and confirm all code fences are balanced and the troubleshooting section reflects the flattened install requirement.

---

### Task 9: Validate the generated files and installed behavior

**Files:**
- Read: `scripts/antigravity/*.ps1`
- Read: `scripts/antigravity/*.sh`
- Read: `.agent/workflows/superpowers-*.md`
- Read: `docs/README.antigravity.md`

- [ ] **Step 1: Validate Antigravity workflow file presence**

Run:

```powershell
Get-ChildItem .agent\workflows\superpowers-*.md
```

Expected: four files listed.

- [ ] **Step 2: Validate Windows installer result shape**

Run:

```powershell
Get-ChildItem "$env:USERPROFILE\.agents\skills" | Where-Object { $_.Name -in @('brainstorming','writing-plans','using-superpowers') }
```

Expected: first-level entries for `brainstorming`, `writing-plans`, and `using-superpowers`.

- [ ] **Step 3: Validate no project rules were introduced**

Run:

```powershell
if (Test-Path .agent\rules) { Get-ChildItem .agent\rules } else { 'NO_RULES_DIR' }
```

Expected: `NO_RULES_DIR` or no Antigravity rules added for this feature.

- [ ] **Step 4: Validate no existing files were modified**

Run:

```bash
git diff --name-only --diff-filter=M
```

Expected: empty output or no pre-existing tracked file modified by this feature; only new files should belong to the Antigravity support layer.
