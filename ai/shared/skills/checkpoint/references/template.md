# Checkpoint output template

Follow this shape. Drop any section that has no content rather than writing
"none" — except **Right Now**, which is always present.

````markdown
# Checkpoint — <repo name>

`<YYYY-MM-DD HH:MM>` · <project path on GitLab> · on `<branch>` in `<worktree>`
<N> open threads · <N> need me · <N> waiting on others · <N> stale

## Right Now

The three things to touch next, most urgent first. One line each, with the
identifier and why it is first.

1. **<thread>** — <what to do>. <why now: blocking others / unbacked WIP / oldest wait>
2. **<thread>** — <what to do>.
3. **<thread>** — <what to do>.

> At risk: <uncommitted/unpushed work, in one line, or omit the line entirely>

## Since last checkpoint (<date of previous>)

- Moved: <thread> — <what changed>
- No movement: <thread> — unchanged for <N>d
- Closed: <thread> — <how it ended>
- New: <thread>

## Threads needing me

### <STATE> · <thread title>

| | |
|---|---|
| Issue | [#71](url) — <title> |
| MR | [!69](url) — <title> · `<src>` → `<tgt>` · <draft?> |
| Branch | `FT-foundation-integration-HA` |
| Worktree | `/path/to/worktree` — <clean / N dirty files / N unpushed commits> |
| Owner | <username> |
| Reviewers | <username> (<no response in Nd> / <approved> / <changes requested>) |
| Pipeline | <status> · <url or "unknown — check: glab ci status -b BRANCH"> |
| Acceptance | <c>/<t> boxes ticked |
| Age | opened <date> (<N>d) · last touched <date> (<N>d) |

**Where it stands.** Two or three sentences: what is done, what is not, and
what specifically stopped it.

**Timeline**
- `2026-07-30` issue #71 filed
- `2026-08-02` branch cut, worktree created
- `2026-08-31` MR !69 opened as draft, malak.kassem added as reviewer
- `2026-09-07` no movement since

**Next action.** <One imperative line.>

**Blockers / risks.** <Only if real.>

**Spawned.** <follow-up issues this thread created, as #N links>

## Threads waiting on others

Same block shape, condensed — the wait and the person are what matter.

### <STATE> · <thread title>
`!76` · owner joumana.elshoubashy · **I owe a review since 2026-09-06 (4d)** ·
pipeline success · mergeable
**Next action.** Review !76; the cancel-path change touches the UGE teardown I own.

## Backlog assigned to me

One line per issue, oldest first — no blocks. These are threads with no branch
and no MR yet.

- [#76](url) `RF` Make generated protocol keys importable — filed 2026-08-26 (15d) · `priority::low`
- [#73](url) `FIX` Remove clang-tidy exclusions — filed 2026-08-08 (33d) · follow-up to !66

## Landed recently

- [!79](url) FIX: Delegate job retries — merged 2026-09-03 · follow-ups: #76

## Cleanup candidates

Orphaned branches, stale worktrees, old stashes. Name the check before the
delete; never propose a destructive command as the next action.

- Worktree `/path/geodrive-mr79` on `FIX-executable-job-retry-JME` — its MR !79
  merged 2026-09-03. Confirm nothing local is unpushed, then it can go.
- `stash@{0}` from 2026-06-11 (91d) — <subject>

## People

| Person | Owns | Reviewing for me | Waiting on me |
|---|---|---|---|
| joumana.elshoubashy | !76, !74 | — | !76, !74 |
| malak.kassem | — | !69 (10d) | — |

## Coverage

What this checkpoint could and could not see — so a thin checkpoint is never
mistaken for a quiet project.

- Sources: GitLab `<host>` (authenticated as `<user>`), <N> worktrees, <N> local branches
- Window: last <N> days
- Unavailable: <section — reason, and the command to fix it>
````

## Style

- Dates as `YYYY-MM-DD`, ages as `(Nd)` computed from the bundle's `generated_at`.
- Identifiers as links wherever the bundle gives a URL.
- Never a status you cannot source from the bundle; write `unknown` and the
  command that would answer it.
- No advice paragraphs, no restating GitLab's UI. Every line either states a
  fact with a date or names an action.
