# What the bundle contains

`collect.sh` emits `===== SECTION =====` blocks. Each is the output of the
commands listed here, so you can re-run or extend one in isolation.

## Local git

| Section | Command | Reads as |
|---|---|---|
| REPO IDENTITY | `remote -v`, `rev-parse`, `symbolic-ref`, `config user.*` | which project, which remote name, which integration branch, who I am |
| WORKTREES | `worktree list --porcelain`, then per directory: `rev-parse`, `log -1`, `rev-list --left-right --count HEAD...@{upstream}`, `status --porcelain`, `diff --stat HEAD`, `log @{upstream}..HEAD` | one block per worktree: branch, upstream, ahead/behind, dirty files, unpushed commits, WIP markers in changed files |
| LOCAL BRANCHES | `for-each-ref refs/heads` sorted by committerdate | every branch with upstream, track state, author, subject |
| MY REMOTE BRANCHES | `for-each-ref refs/remotes` filtered to my email | what I pushed and may have forgotten |
| STASHES | `stash list` | uncommitted work parked and forgotten |
| MY RECENT COMMITS | `log --all --author=<me> --since=<days>` | what I actually did in the window |
| IN-PROGRESS GIT OPERATIONS | presence of `MERGE_HEAD`, `rebase-merge`, `BISECT_LOG`, … | an interrupted rebase/merge is a thread nobody remembers |

`ahead/behind` prints as two numbers, `ahead behind`, relative to upstream.

## GitLab

All read-only, all through `safe-glab`, each wrapped in `timeout 30` so an
unreachable self-hosted host cannot hang the run.

| Section | Command |
|---|---|
| GITLAB PROJECT | `repo view --output json` |
| MRs — MINE | `mr list --author=@me --output json` |
| MRs — ASSIGNED TO ME | `mr list --assignee=@me --output json` |
| MRs — I AM REVIEWER | `mr list --reviewer=@me --output json` |
| MRs — ALL STATES | `mr list --all --per-page 50 --output json` |
| ISSUES — ASSIGNED TO ME | `issue list --assignee=@me --output json` |
| ISSUES — ALL OPEN | `issue list --per-page 50 --output json` |
| MR DETAIL + TIMELINES | `mr view <iid> --output json`, `mr view <iid> --comments --system-logs` |
| PIPELINES | `ci list --per-page 15 --output json`, `ci status --compact` |

`mr list --all` means *all states*, so merged and closed MRs appear there —
that section is the "what just landed" view, not an open-MR list.

### Projected fields

`project.py` collapses each JSON record to one line. MR lines carry: `!iid`,
state, title, `author=`, `assignees=`, `reviewers=`, `src -> tgt`, `labels=`,
`milestone=`, `notes=` (comment count), `tasks=c/t` (acceptance-criteria boxes
ticked), `created=`, `updated=`, `refs=` (`#N`/`!N` mined from title and
description — this is what links a thread together), flags, and the URL.
Flags are `DRAFT`, `CONFLICTS`, `UNRESOLVED-THREADS`, `pipeline=<status>`,
`merge=<detailed_merge_status>`.

Issue lines carry: `#iid`, state, title, `author=`, `assignees=`, `labels=`,
`milestone=`, `mrs=` (linked MR count), `tasks=c/t`, `notes=`, `created=`,
`updated=`, `due=`, `refs=`, URL.

`tasks=` is unusually informative here: the issue and MR templates in use are
checklists, so `5/7` is real progress on stated acceptance criteria.

## Tool quirks this already handles

- `glab api` is blocked by `safe-glab` — only typed subcommands are used.
- `glab issue list` takes `--output json` (`-O`); `glab mr list` takes `-F`.
  Spelling `--output json` works for both; the short flags do not.
- The remote is not always `origin` (real repos use `glab-base`, `upstream`).
  `REMOTE` is resolved from the current branch's upstream, then `origin`, then
  the first remote.
- Byte-truncating (`head -c`) GitLab text splits UTF-8 mid-character; truncation
  happens inside `project.py` on decoded text instead.
- `mr view --comments` reprints the full description; `strip_desc()` drops it
  because the projected line already carries a summary.
