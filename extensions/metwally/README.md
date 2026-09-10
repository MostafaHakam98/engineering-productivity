# Metwally Coding Agent

A VS Code front-end for the [`pi`](https://www.npmjs.com/package/@earendil-works/pi-coding-agent)
coding agent, built for self-hosted models — vLLM, Ollama, llama.cpp, LM Studio,
LiteLLM. Point it at an OpenAI-compatible URL; no hosted API account required.

Source: <https://github.com/MostafaHakam98/metwally-vscode>

## Install

```bash
ext-install metwally
```

This clones the extension, builds a `.vsix`, installs it, and then installs the
`metwally` AI target so `pi` starts with this kit's instructions, skills and
prompt templates already in place.

Prerequisites: `node`, `npm`, and the `pi` binary.

```bash
npm install -g @earendil-works/pi-coding-agent
```

The extension probes nvm, `/usr/local/bin` and `~/.local/bin` for `pi`, or set
`piVscode.piPath` to an absolute path.

## What the AI target installs

`pi` reads its resources from `~/.pi/agent` (override with `PI_CODING_AGENT_DIR`):

| Kit artifact | Lands at | Shows up as |
|---|---|---|
| `ai/shared/instructions.md` | `~/.pi/agent/APPEND_SYSTEM.md` | appended to every session's system prompt |
| `ai/shared/skills/<n>/` | `~/.pi/agent/skills/<n>/SKILL.md` | auto-loaded on match, or `/skill:<n>` |
| `ai/shared/commands/<n>.md` | `~/.pi/agent/prompts/<n>.md` | `/<n>` in the composer |

`APPEND_SYSTEM.md` is deliberate: `SYSTEM.md` would *replace* pi's coding-assistant
prompt rather than extend it.

Subagents and permission rules are not installed — `pi` has neither concept.
`Ctrl+Alt+K` in the extension lists everything pi currently knows about.

## Project-level config

```bash
ai-install-project metwally
```

Writes `AGENTS.md` at the repository root (pi discovers it from the working
directory) and the rules, maps and workflows under `.pi/`.

> Project resources need `piVscode.trustProject` enabled. In RPC mode pi never
> prompts about trust, so without it everything under a project's `.pi/` is
> silently ignored. Enable it only for repositories you trust — it also lets pi
> load project settings and run project-local extensions.

## Updating

```bash
ext-install metwally --update
```

Pulls upstream, rebuilds, reinstalls, and re-syncs the agent config. Reload the
editor window afterwards.
