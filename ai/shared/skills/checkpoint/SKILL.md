---
name: checkpoint
description: Build a "where am I" checkpoint at .tmp/CHECKPOINT.md that reconstructs every open thread of work in the current project — GitLab issues and MRs, branches, worktrees, uncommitted WIP, pipelines, who owns and who reviews what, each thread's timeline, and the single next action per thread. Use when the user says checkpoint, "where am I", "where did I leave off", "what's open", "what am I working on", "I lost track", "catch me up", "status of my work", "what's waiting on me", "what's blocked", "open threads", or resumes a project after time away.
---

# Checkpoint

Reconstructs the state of every in-flight thread in a project and writes it to
`.tmp/CHECKPOINT.md`. The point is not a data dump: it is to answer, in the
first ten lines, *what should I touch next and what is waiting on someone else*.

## Run it

```bash
bash {{SKILLS_DIR}}/checkpoint/scripts/collect.sh
```

Writes a raw signal bundle to `.tmp/checkpoint-raw.txt` (~100KB on a busy
repo, ~45s when GitLab is reachable). Read that bundle, then write the
checkpoint. Options:

| Flag | Default | Use |
|---|---|---|
| `--days N` | 21 | history window for commits and "stale" judgements |
| `--mr-detail N` | 6 | how many of *my* MRs get full comment timelines |
| `--out PATH` | `.tmp/checkpoint-raw.txt` | bundle location |

The script is read-only against the repo and GitLab. It adds `.tmp/` to
`.git/info/exclude` (local-only, no tracked-file diff) if `.tmp` isn't already
ignored. It degrades section by section: a missing `glab`, an unauthenticated
or unreachable host, or a non-git directory each narrow the checkpoint instead
of failing it. Say so in the output when a section is unavailable — a silently
thin checkpoint is worse than a flagged one.

## Steps

1. **Collect.** Run the script. If the user passed a window (`checkpoint last
   two months`), pass `--days`.
2. **Read the bundle** in full. It is already projected down to one line per
   record; do not re-fetch what it contains.
3. **Group signals into threads** (see below). This is the whole job.
4. **Write** `.tmp/CHECKPOINT.md`, following
   [references/template.md](references/template.md). Copy it to
   `.tmp/checkpoints/<YYYY-MM-DD-HHMM>.md` so the history is browsable.
5. **Reply in the terminal with the Right Now block only** (5–8 lines) plus the
   file path. Do not paste the whole checkpoint back — it is a file to open.

## What a thread is

A thread is one unit of work a person is carrying, not one GitLab object. Fuse
into a single thread anything that shares an identity:

- **branch name** — links a local branch, a remote branch, a worktree
  directory, and an MR's `source_branch`. This is the strongest key.
- **`Closes #N` / `refs=` in the bundle** — links an MR to its issue and to
  follow-up issues. The projector already mined these from titles and
  descriptions.
- **branch-name suffix** — the author's initials (`-HA`, `-JME`, `-OOM`, `-AHN`)
  say who owns the thread even when GitLab metadata is thin.
- **subject matter** — a backlog issue that is plainly the follow-up to a
  merged MR belongs in that thread's "spawned" list, not as its own top-level
  entry.

A worktree with no MR is still a thread. A backlog issue with no branch is
still a thread. Uncommitted changes with no branch of their own are still a
thread — usually the most urgent one, because they exist nowhere but that disk.

## Thread state

Assign exactly one state per thread, from this vocabulary, and derive it
mechanically from the bundle:

| State | Derived from |
|---|---|
| `REVIEW-OWED-BY-ME` | open MR, `reviewers=` includes me, author is someone else |
| `BLOCKED-CONFLICTS` | MR flagged `CONFLICTS` / `merge=conflict` |
| `BLOCKED-PIPELINE` | MR's or branch's latest pipeline `failed` |
| `BLOCKED-DISCUSSIONS` | MR flagged `UNRESOLVED-THREADS` |
| `WAITING-ON-OTHERS` | my MR, open, non-draft, reviewer assigned, no conflicts |
| `DRAFT-MINE` | my MR, `DRAFT` — the ball is with me |
| `DIRTY` | worktree with uncommitted files |
| `UNPUSHED` | commits ahead of upstream, or no upstream at all |
| `LOCAL-ONLY` | branch/worktree with commits and no MR |
| `BACKLOG` | issue assigned to me, no branch, no MR |
| `LANDED` | MR merged inside the window, follow-ups may remain |
| `ORPHANED` | branch or worktree matching no issue, MR, or recent commit |

Add `STALE` as a modifier when nothing moved in more than 14 days — flag it,
because stale threads are exactly the ones that get lost.

## Ordering

Sort so the top of the file is actionable. Within the thread sections, order by:

1. Threads where **I am the blocker** (`REVIEW-OWED-BY-ME`, `DRAFT-MINE`,
   `BLOCKED-*` on my own MRs, `DIRTY`, `UNPUSHED`).
2. Threads **blocked on someone else** — name the person and the wait duration.
3. Backlog and landed-with-follow-ups.
4. Orphans and cleanup candidates.

## Rules that keep this useful

- **Every thread gets a Next action**: one imperative line, concrete enough to
  start without rereading anything (`rebase !65 onto devel, conflicts in
  .clang-format`, not `address conflicts`).
- **Name people and durations.** "waiting on malak.kassem since 2026-08-31
  (10d)" beats "in review". Compute ages from the bundle's `generated_at`.
- **Timelines are dated bullets, newest last**, built from `created=`/`updated=`
  fields, commit dates, and the MR comment/system-activity logs. Three to six
  bullets per thread — enough to remember the shape of it, not a transcript.
- **Uncommitted and unpushed work is the highest-risk item** in any checkpoint:
  it is the only state with no backup. Call it out in Right Now even when it
  looks trivial.
- **Do not invent status.** If the bundle cannot tell you whether a pipeline
  passed, write `unknown` and name the command to check it.
- **Quote real identifiers** — `!69`, `#71`, `FT-foundation-integration-HA`,
  worktree paths, URLs — so every line is clickable or greppable.
- Keep the whole file scannable. Budget roughly 20–30 lines per active thread,
  so a quiet repo lands near 80 lines and a busy one near 300. Push detail into
  the per-thread blocks and keep the top summary tight — Right Now must stay
  readable without scrolling.

## Diffing against the last checkpoint

The bundle embeds the previous `.tmp/CHECKPOINT.md` when one exists. Use it to
fill the **Since last checkpoint** section: threads that moved, threads that
did not move at all (name them — repeated no-movement is the real signal),
threads that closed, and threads that are new. On the first run, write
`First checkpoint — no baseline.`

## Modes

- `checkpoint` — full run.
- `checkpoint quick` — pass `--mr-detail 0`; skips per-MR timelines. Use when
  the user wants a fast look or GitLab is slow.
- `checkpoint mine` — collect everything, but write only threads where I am
  author, assignee, or reviewer. Keep a one-line count of what was omitted.
- `checkpoint <topic>` — full collection, and lead with the threads matching
  that topic; keep the rest as a compact list.

## Notes on the tooling

`glab api` is blocked by the `safe-glab` wrapper, so the collector uses only
typed subcommands. Two quirks it already handles, worth remembering if you
extend it: `glab issue list` spells JSON as `--output json` while `glab mr
list` uses `-F/--output`, and the remote is not always named `origin`.
See [references/signals.md](references/signals.md) for what each bundle
section contains and which commands produced it.
