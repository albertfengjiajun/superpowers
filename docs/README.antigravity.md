# Antigravity Support for Superpowers

Superpowers supports the Antigravity system via a "zero-intrusion" flat installation approach. Instead of complex `.agent/rules` logic (which is intentionally omitted in v1), this mechanism creates global shortcuts to your local Superpowers skills, making them accessible directly in your AI agent interface.

## Installation Instructions

### Windows

Run the PowerShell installer to create directory junctions (links) into your `~/.gemini/antigravity/skills` directory:

```powershell
.\scripts\antigravity\install-skills.ps1
```

### macOS / Linux

Run the Unix installer to create symlinks:

```bash
./scripts/antigravity/install-skills.sh
```

## How It Works

Antigravity expects flat global skills. Since Superpowers skills exist inside the `skills/` directory of the project, these installer scripts simply loop over `skills/*` and create links in your global `~/.gemini/antigravity/skills` directory, prefixing them with `superpowers-` (e.g., `superpowers-brainstorming`).

Then, use the provided thin entry workflows:
- `/superpowers-design`
- `/superpowers-plan`
- `/superpowers-execute`
- `/superpowers-finish`

## Troubleshooting

### Issue: Nested installs are not discovered

If you simply copy or symlink the `skills/` directory as a whole (a nested install), Antigravity cannot discover the `SKILL.md` files because it does not recursively scan subdirectories of skills.

**Solution:** Ensure you are using the official install scripts, which flatten the skills out (e.g., creating `~/.gemini/antigravity/skills/superpowers-brainstorming` instead of just pointing to `skills/`).

### Why are there no `.agent/rules`?

In v1 of the Antigravity support, `.agent/rules` are deliberately omitted to maintain zero intrusion. The global skill linking combined with thin workflow files is enough for the agent to know how to trigger Superpowers logic.

## Cleanup

To remove the Antigravity skills linking specifically for Superpowers, run the appropriate removal script:

**Windows:**
```powershell
.\scripts\antigravity\remove-skills.ps1
```

**macOS / Linux:**
```bash
./scripts/antigravity/remove-skills.sh
```
