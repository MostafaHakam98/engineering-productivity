# AI Agent Kit

One source of truth for agent configuration, rendered into every coding agent's
own dialect.

## Why it is shaped this way

Every agent wants the same substance — behavioral rules, skills, slash commands,
subagents — and each one spells it differently. Maintaining a parallel copy per
tool guarantees drift. So the content lives once, in `shared/`, and each tool is
described by a small **target** file that says where its pieces go and in what
format.

```
ai/
├── shared/                  # written once, tool-neutral
│   ├── instructions.md      # global behavior, style, token discipline
│   ├── skills/<name>/       # SKILL.md (+ references/, scripts/)
│   ├── commands/<name>.md   # slash commands / prompt templates
│   ├── agents/<name>.md     # subagent definitions
│   ├── permissions.json     # tool allow/deny rules
│   ├── external-skills.json # third-party skills: declared, not vendored
│   └── project-template/    # per-repository rules, maps, workflows
│
├── targets/<tool>.target    # where each artifact goes, in what format
│
└── scripts/
    ├── port.sh                    # render a target into a staging dir
    ├── install-global.sh          # render, then install into the agent's home
    ├── install-project.sh         # bootstrap a project template here
    ├── install-external-skills.sh # fetch and link declared third-party skills
    └── lib/render.sh              # the format converters
```

## Supported targets

| Target | Tool | Instructions | Skills | Commands | Subagents | Permissions |
|---|---|---|---|---|---|---|
| `claude` | Claude Code | `~/.claude/CLAUDE.md` | `skills/<n>/SKILL.md` | `commands/<n>.md` | `agents/<n>.md` | `settings.json` |
| `codex` | Codex CLI | `~/.codex/AGENTS.md` | `skills/<n>/SKILL.md` | `prompts/<n>.md` | `agents/<n>.toml` | — |
| `cursor` | Cursor | `rules/working-style.mdc` | `rules/<n>.mdc` | `commands/<n>.md` | — | — |
| `metwally` | Metwally / pi | `~/.pi/agent/APPEND_SYSTEM.md` | `~/.pi/agent/skills/<n>/SKILL.md` | `~/.pi/agent/prompts/<n>.md` | — | — |

Claude Code, Codex and pi all consume `SKILL.md` directories natively, so skills
copy across verbatim, bundled `references/` and `scripts/` included. Cursor has
no skill loader, so each skill is converted to one agent-requestable `.mdc` rule
and its bundled files are listed as pointers rather than silently dropped.

## Usage

```bash
ai-targets                      # what can I install into?
ai-install claude               # one target
ai-install all                  # every target
ai-install codex --dry-run      # show what would change, write nothing
ai-port cursor --out /tmp/x     # render only, to inspect or diff

ai-install-project codex        # bootstrap this repo's agent config
ai-external-skills              # fetch the declared third-party skills
```

Or through the top-level CLI:

```bash
forge install ai                # pick a target interactively
forge doctor                    # per-target install state and counts
```

### What installing does, and does not, touch

- **Instructions, skills, commands, agents** are written into the target's
  config directory.
- **Permissions** are *merged* into the target's existing settings file. Your
  model choice, theme, and machine-local allow-rules survive.
- **Pruning is manifest-tracked**, not `rsync --delete`. Each install records
  what it wrote to `<target home>/.engineering-productivity.manifest`; the next
  install removes only paths that this kit previously installed and no longer
  ships. Hand-written rules and external skill symlinks living in the same
  directory are left alone.

## Adding a new agent

Write one file. No script changes are needed if the agent uses a format that is
already supported.

1. Create `ai/targets/<name>.target`:

   ```bash
   TARGET_LABEL="My Agent"
   TARGET_HOME="${MYAGENT_HOME:-$HOME/.myagent}"

   INSTRUCTIONS_DEST="$TARGET_HOME/AGENTS.md"
   INSTRUCTIONS_TITLE="Global My Agent Preferences"

   SKILLS_DEST="$TARGET_HOME/skills"
   SKILLS_FORMAT="skill-dir"      # or "mdc"

   COMMANDS_DEST="$TARGET_HOME/prompts"
   COMMANDS_FORMAT="md"

   AGENTS_DEST=""                 # empty = unsupported, silently skipped
   AGENTS_FORMAT=""

   PERMISSIONS_DEST=""
   PERMISSIONS_FORMAT=""

   PROJECT_DEST=".myagent"
   PROJECT_FORMAT="agents-md"
   ```

2. Check it: `ai-port myagent --out /tmp/check && find /tmp/check`
3. Install it: `ai-install myagent`

`forge`, `ai-targets`, `forge doctor` and `install-external-skills.sh` all
discover targets by globbing `ai/targets/*.target`, so the new agent appears
everywhere automatically.

If the agent needs a format that does not exist yet, add a case to the relevant
`render_*` function in `scripts/lib/render.sh`. Current formats:

| Artifact | Formats |
|---|---|
| instructions | `md`, `mdc-always` |
| skills | `skill-dir`, `mdc` |
| commands | `md` |
| agents | `md`, `toml` |
| permissions | `claude-settings` |
| project | `claude-project`, `agents-md`, `pi-project`, `mdc-project` |

### Placeholders

Shared content is tool-neutral, so it uses placeholders the renderer fills in:

| Placeholder | Becomes |
|---|---|
| `{{SKILLS_DIR}}` | the target's global skills directory |
| `{{CONFIG_DIR}}` | the project config directory (`.claude`, `.codex`, `.pi`, `.cursor`) |
| `{{ENTRYPOINT}}` | the project entry-point file (`CLAUDE.md`, `AGENTS.md`, `rules/project.mdc`) |
| `{{RULE_EXT}}` | `md`, or `mdc` for Cursor |

They are filled in instructions, skills (including bundled `references/` and
`scripts/`), commands, subagents and the project template. A skill that names a
config path must use them — `repo-profile` writes `.claude/` under Claude Code
and `.codex/` under Codex from the same source.

## Third-party skills

Skills written by other people are **declared, not vendored**:
`shared/external-skills.json` records each source repository, a pinned revision,
and the path to each skill at that revision. `ai-external-skills` clones them
into `~/.agents/skills` and symlinks them into every target that loads
`SKILL.md` directories.

Upstream renames skills between revisions, so paths are only valid for the
pinned ref. Bump `ref` deliberately and re-verify the paths.

> **Name collisions.** A third-party skill with the same name as one of ours
> would shadow it. `install-external-skills.sh` refuses to replace a real
> directory with a symlink and says so. This kit's own `caveman` collides with
> the upstream one and is deliberately excluded from the manifest.

## Benchmarks

`claude/benchmark/` holds skill benchmarks and the `bench` runner. They measure
Claude Code specifically and are not part of the porting layer.
