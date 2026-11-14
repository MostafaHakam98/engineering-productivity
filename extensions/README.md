# Editor Extensions

VS Code extensions that are built from source and installed as part of this
kit, together with the agent configuration they need.

## Why declarations, not sources

Each extension keeps its own repository and release cycle. Vendoring the source
here — or carrying it as a submodule — would mean bumping a commit in this repo
for every upstream change, and every clone paying for source it may not build.

So each extension is a **declaration**: `extensions/<name>/extension.json` says
where the source lives, at which ref, how to turn it into a `.vsix`, and which
AI target carries its agent config. The installer clones into a cache outside
the repo, builds, installs the artifact, and then installs the matching agent
config so the extension arrives configured rather than empty.

## Extensions

| Name | What it is | AI target |
|---|---|---|
| `metwally` | VS Code front-end for the `pi` coding agent, built for self-hosted models | `metwally` |

## Usage

```bash
ext-install                  # every declared extension
ext-install metwally         # just one
ext-install --update         # refetch the pinned revision, rebuild, reinstall
ext-install --build-only     # compile, test, and package; no editor or runtime required
ext-install --no-ai-config   # build and install the .vsix only
ext-install --editor codium  # target a different editor CLI
```

Or through the top-level CLI:

```bash
forge install ext
forge doctor                 # shows which extensions are installed
```

The installer picks the first available editor CLI from `code`,
`code-insiders`, `codium`, `cursor`. Missing build or runtime prerequisites are
reported as an installation failure. Normal installation requires an editor
and runtime; `--build-only` checks build prerequisites only. Source refs must be
40-character commit pins. Upstream build steps run trusted code with your user
permissions; test them in a disposable container first.

## Adding an extension

Create `extensions/<name>/extension.json`:

```json
{
  "name": "example",
  "displayName": "Example Agent",
  "description": "One line, shown in listings.",
  "publisher": "you",
  "extensionId": "you.example",

  "source": { "type": "git", "url": "https://github.com/you/example.git", "ref": "<40-character-reviewed-commit-sha>" },

  "build": {
    "requires": ["node", "npm"],
    "steps": ["npm ci", "npm run compile", "npx --yes @vscode/vsce package --out example.vsix"],
    "artifact": "example.vsix"
  },

  "runtime": {
    "requires": ["example-agent"],
    "install": "npm install -g example-agent",
    "note": "Shown when the runtime is missing."
  },

  "aiTarget": "example",

  "settings": {
    "example.someSetting": "Why it matters. Printed after install."
  }
}
```

- `extensionId` must match `<publisher>.<name>` from the extension's own
  `package.json` — it is how installed-state detection finds it.
- `requires` entries are checked with `command -v` before anything is built.
- `aiTarget` is optional. When set, it names a file in `ai/targets/` and the
  matching agent config is installed alongside the extension.
- `settings` is advisory: the keys are printed after install, never written.
