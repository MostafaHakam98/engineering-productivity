# Claude Code Kit

Claude Code is one **target** of the shared AI kit. The content it installs —
instructions, skills, commands, agents, permissions, project template — lives
in [`ai/shared/`](../shared/), not here. See [`ai/README.md`](../README.md) for
the porting model.

This directory holds what is Claude-specific: the benchmarks, and thin script
shims kept so existing aliases keep working.

## Install

```bash
ai-install claude          # canonical
claude-install-global      # alias for the same thing
forge install claude
```

Renders `ai/shared/` into Claude Code's dialect and installs it:

| Kit artifact | Lands at |
|---|---|
| `instructions.md` | `~/.claude/CLAUDE.md` |
| `skills/<n>/` | `~/.claude/skills/<n>/` (SKILL.md, references/, scripts/) |
| `commands/<n>.md` | `~/.claude/commands/<n>.md` |
| `agents/<n>.md` | `~/.claude/agents/<n>.md` |
| `permissions.json` | merged into `~/.claude/settings.json` |

Permissions are merged, so your model choice, theme and machine-local allow
rules survive a re-install.

Set `CLAUDE_CONFIG_DIR` to install somewhere other than `~/.claude`.

## Project config

```bash
ai-install-project claude   # writes .claude/ here
```

Then run `/repo-profile` inside a Claude Code session to fill in the
project-specific rules and maps.

## Benchmarks

`benchmark/` measures skill effectiveness against Claude Code specifically.

```bash
./bench <task>              # from the repo root
```

Tasks live in `benchmark/tasks/`, experiments in `benchmark/experiments/`.
Run outputs land in `benchmark/results/` and are gitignored.
