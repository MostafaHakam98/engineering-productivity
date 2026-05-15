# AI Tools

AI assistant configuration, skills, and workflows for engineering productivity.

## What's Included

### [claude/](./claude/) - Claude Code Configuration
Reusable Claude Code config: global personal settings, slash commands, skills, agents, and project templates.

**Installation:**
```bash
./forge install claude
# or directly:
ai/claude/scripts/install-global.sh
```

**Documentation:** [claude/README.md](./claude/README.md) · [claude/USAGE.md](./claude/USAGE.md)

## Structure

This directory is organized by AI assistant:

- `claude/` - Claude Code productivity kit
  - `global/` - Personal config that installs to `~/.claude/`
  - `project-template/` - Starter `.claude/` for any project
  - `scripts/` - Install and sync scripts
  - `benchmark/` - Claude Code skill benchmarks

## Philosophy

- **Reduce repeated prompting**: Encode reusable workflows as skills and commands
- **Project-aware context**: Give Claude what it needs per project, not per session
- **Three-layer model**: global defaults → project template → project-specific overrides
- **Version-controlled**: Track AI configuration like any other engineering tool
