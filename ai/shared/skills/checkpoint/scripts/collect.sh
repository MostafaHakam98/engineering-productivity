#!/usr/bin/env bash
# Collect every open-thread signal available locally + from GitLab into one
# raw bundle. Read-only: never writes to the repo, never mutates GitLab.
#
# Usage: collect.sh [--days N] [--mr-detail N] [--out PATH]
#   --days N       history window for commits/activity (default 21)
#   --mr-detail N  how many of "my" MRs get full comment timelines (default 6)
#   --out PATH     raw bundle path (default .tmp/checkpoint-raw.txt)
#
# Exit 0 even when tools are missing or unauthenticated; each section reports
# its own degradation so the caller can still build a partial checkpoint.

set -uo pipefail

DAYS=21
MR_DETAIL=6
OUT=""
NET_TIMEOUT=30

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)      DAYS="$2"; shift 2 ;;
    --mr-detail) MR_DETAIL="$2"; shift 2 ;;
    --out)       OUT="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------- tool picking
# Honour the repo rule: prefer the safe-* wrappers when they exist.
if command -v safe-git >/dev/null 2>&1; then GIT=safe-git; else GIT=git; fi
if command -v safe-glab >/dev/null 2>&1; then GLAB=safe-glab
elif command -v glab >/dev/null 2>&1; then GLAB=glab
else GLAB=""; fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PY="$SCRIPT_DIR/project.py"
# Compact verbose glab JSON to one line per record. Without this a 50-MR
# listing is ~450KB of descriptions and avatar URLs.
proj() {
  if [[ -f "$PROJECT_PY" ]] && command -v python3 >/dev/null 2>&1; then
    python3 "$PROJECT_PY" "$@"
  else
    head -c 4000; echo; echo "(project.py or python3 missing — raw JSON truncated)"
  fi
}

# `glab mr view --comments` reprints the whole MR description, which the
# projected line already carries. Output is: header, "--", description, "--",
# then notes/activity. Keep the header and the activity, drop the middle.
strip_desc() {
  awk 'BEGIN{d=0}
       /^--$/{ d++; if (d==1) print "-- [description omitted: see the desc: line above] --"; next }
       d==0 || d>=2 { print }'
}

# GitLab's activity log is written for a browser: HTML commit lists, long diff
# URLs, blank lines. tidy_notes.py folds each push into one dated line.
TIDY_PY="$SCRIPT_DIR/tidy_notes.py"
tidy_activity() {
  if [[ -f "$TIDY_PY" ]] && command -v python3 >/dev/null 2>&1; then
    python3 "$TIDY_PY"
  else
    cat
  fi
}

# git for reads inside a chosen directory. safe-git execs git, so -C is safe.
g() { "$GIT" "$@" 2>/dev/null; }

# Network calls get a hard timeout: an unreachable GitLab host otherwise hangs
# the whole collection (seen with self-hosted hosts behind VPN).
gl() {
  [[ -z "$GLAB" ]] && { echo "(glab not installed)"; return 0; }
  timeout "$NET_TIMEOUT" "$GLAB" "$@" 2>&1 || echo "(unavailable: glab $* failed or timed out)"
}

sec() { printf '\n\n===== %s =====\n' "$1"; }
sub() { printf '\n--- %s ---\n' "$1"; }

# ------------------------------------------------------------------ repo roots
ROOT="$(g rev-parse --show-toplevel)"
IS_GIT=1
[[ -z "$ROOT" ]] && { IS_GIT=0; ROOT="$PWD"; }

# Remote name is NOT always "origin" (real repos use glab-base, upstream, ...).
# Resolve it once: current branch's upstream remote, else origin, else the first.
REMOTE="$(g config --get "branch.$(g rev-parse --abbrev-ref HEAD 2>/dev/null).remote")"
if [[ -z "$REMOTE" ]]; then
  if g remote | grep -qx origin; then REMOTE=origin; else REMOTE="$(g remote | head -1)"; fi
fi
[[ -z "$REMOTE" ]] && REMOTE=origin

TMP="$ROOT/.tmp"
mkdir -p "$TMP/checkpoints"
[[ -z "$OUT" ]] && OUT="$TMP/checkpoint-raw.txt"

# Keep .tmp out of version control without dirtying a tracked .gitignore:
# .git/info/exclude is local-only and produces no diff.
IGNORE_STATE="n/a (not a git repo)"
if [[ "$IS_GIT" -eq 1 ]]; then
  if g check-ignore -q .tmp; then
    IGNORE_STATE="already ignored"
  else
    EXCL="$(g rev-parse --git-path info/exclude)"
    if [[ -n "$EXCL" ]]; then
      mkdir -p "$(dirname "$EXCL")"
      grep -qxF '.tmp/' "$EXCL" 2>/dev/null || printf '.tmp/\n' >> "$EXCL"
      IGNORE_STATE="added '.tmp/' to .git/info/exclude (local-only, no repo diff)"
    fi
  fi
fi

exec > "$OUT" 2>&1

echo "checkpoint raw bundle"
echo "generated_at: $(date -Iseconds)"
echo "cwd: $PWD"
echo "repo_root: $ROOT"
echo "is_git_repo: $IS_GIT"
echo "history_window_days: $DAYS"
echo "tmp_ignore: $IGNORE_STATE"
echo "git_tool: $GIT   glab_tool: ${GLAB:-none}"

if [[ "$IS_GIT" -eq 0 ]]; then
  sec "NOT A GIT REPO"
  echo "Local-only checkpoint. Directory listing (2 levels, no dotdirs):"
  find "$ROOT" -maxdepth 2 -not -path '*/.*' -printf '%y %TY-%Tm-%Td %p\n' 2>/dev/null | sort -k3 | tail -60
  sub "recently modified files (7d)"
  find "$ROOT" -type f -mtime -7 -not -path '*/.git/*' -not -path '*/.tmp/*' \
    -printf '%TY-%Tm-%Td %p\n' 2>/dev/null | sort -r | head -40
  sub "notes in .tmp"
  ls -lt "$TMP" 2>/dev/null | head -20
  exit 0
fi

# ------------------------------------------------------------------- identity
sec "REPO IDENTITY"
sub "remotes"; g remote -v
sub "current branch"; g rev-parse --abbrev-ref HEAD
sub "HEAD"; g log -1 --format='%h %an %ar %s'
sub "resolved remote"; echo "$REMOTE"
sub "default branch (remote HEAD)"
g symbolic-ref --quiet "refs/remotes/$REMOTE/HEAD" || echo "($REMOTE/HEAD unset; run: git remote set-head $REMOTE -a)"
sub "candidate integration branches present"
for b in devel develop main master staging production; do
  g rev-parse --verify --quiet "refs/remotes/$REMOTE/$b" >/dev/null && echo "$REMOTE/$b"
done
sub "git user"; g config user.name; g config user.email

# ------------------------------------------------------------------ worktrees
sec "WORKTREES"
g worktree list --porcelain

WT_DIRS=()
while IFS= read -r line; do
  [[ "$line" == worktree\ * ]] && WT_DIRS+=("${line#worktree }")
done < <(g worktree list --porcelain)
[[ ${#WT_DIRS[@]} -eq 0 ]] && WT_DIRS=("$ROOT")

for wt in "${WT_DIRS[@]}"; do
  [[ -d "$wt" ]] || { sub "WORKTREE $wt"; echo "(directory missing — stale worktree; prune candidate)"; continue; }
  sub "WORKTREE $wt"
  echo "branch: $(g -C "$wt" rev-parse --abbrev-ref HEAD)"
  echo "head: $(g -C "$wt" log -1 --format='%h %ad %an %s' --date=short)"
  # `rev-parse --abbrev-ref @{upstream}` echoes the literal "@{upstream}" when
  # the upstream branch is gone, so verify the ref resolves before trusting it.
  if g -C "$wt" rev-parse --verify --quiet '@{upstream}' >/dev/null; then
    up="$(g -C "$wt" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')"
  else
    up=""
  fi
  track="$(g -C "$wt" for-each-ref --format='%(upstream:short) %(upstream:track)' "$(g -C "$wt" symbolic-ref -q HEAD)")"
  echo "upstream: ${up:-<none or deleted on remote>}   track: ${track:-<n/a>}"
  if [[ -n "$up" ]]; then
    echo "ahead/behind vs upstream (ahead behind): $(g -C "$wt" rev-list --left-right --count 'HEAD...@{upstream}' | tr '\t' ' ')"
  fi
  echo "-- dirty files (porcelain, capped 40) --"
  g -C "$wt" status --porcelain=v1 | head -40
  echo "-- dirty count: $(g -C "$wt" status --porcelain=v1 | wc -l)"
  echo "-- diffstat vs HEAD --"
  g -C "$wt" diff --stat HEAD | tail -15
  echo "-- unpushed commits --"
  if [[ -n "$up" ]]; then
    g -C "$wt" log --oneline '@{upstream}..HEAD' | head -20
  else
    for base in "$REMOTE/devel" "$REMOTE/develop" "$REMOTE/main" "$REMOTE/master"; do
      if g -C "$wt" rev-parse --verify --quiet "$base" >/dev/null; then
        n="$(g -C "$wt" rev-list --count "$base..HEAD")"
        echo "(no upstream; $n commits not in $base — newest 8)"
        g -C "$wt" log --oneline "$base..HEAD" | head -8
        break
      fi
    done
  fi
  echo "-- in-tree WIP markers touched in last ${DAYS}d --"
  g -C "$wt" diff --name-only HEAD | head -40 | while read -r f; do
    [[ -f "$wt/$f" ]] && grep -nEH 'TODO|FIXME|XXX|WIP|HACK' "$wt/$f" 2>/dev/null | head -3
  done
done

# ------------------------------------------------------------------- branches
sec "LOCAL BRANCHES — RECENT (newest 25 by last commit)"
g for-each-ref --sort=-committerdate refs/heads \
  --format='%(committerdate:short) | %(refname:short) | up=%(upstream:short) | track=%(upstream:track) | %(authorname) | %(contents:subject)' \
  | head -25

sec "LOCAL BRANCHES — CLEANUP CANDIDATES"
echo "total local branches: $(g for-each-ref --format='%(refname:short)' refs/heads | wc -l)"
sub "upstream deleted on remote ([gone]) — merged or abandoned"
g for-each-ref --sort=-committerdate refs/heads \
  --format='%(committerdate:short) | %(refname:short) | %(upstream:track)' \
  | grep -F '[gone]' | head -40
sub "no upstream at all — never pushed"
g for-each-ref --sort=-committerdate refs/heads \
  --format='%(committerdate:short) | %(refname:short) | up=%(upstream:short)' \
  | grep -E 'up=$' | head -25

sec "MY REMOTE BRANCHES (authored, last ${DAYS}d)"
ME_EMAIL="$(g config user.email)"
g for-each-ref --sort=-committerdate refs/remotes \
  --format='%(committerdate:short) | %(refname:short) | %(authoremail) | %(contents:subject)' \
  | grep -F "$ME_EMAIL" | head -40

sec "STASHES"
g stash list --format='%gd | %ci | %s'

sec "MY RECENT COMMITS (all refs, last ${DAYS}d)"
g log --all --author="$ME_EMAIL" --since="${DAYS}.days" \
  --format='%ad | %h | %d | %s' --date=short | head -60

sec "IN-PROGRESS GIT OPERATIONS"
GITDIR="$(g rev-parse --git-dir)"
for m in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_LOG rebase-merge rebase-apply; do
  [[ -e "$GITDIR/$m" ]] && echo "IN PROGRESS: $m"
done
echo "(none listed above means the tree is in a clean operational state)"

# --------------------------------------------------------------------- gitlab
sec "GITLAB PROJECT"
gl repo view --output json | proj project

# Cache the three "mine" listings: they feed both the sections below and the
# per-MR detail pass, and each glab call costs a network round trip.
CACHE="$(mktemp -d)"
trap 'rm -rf "$CACHE"' EXIT
gl mr list --author=@me   --output json > "$CACHE/mine.json"
gl mr list --assignee=@me --output json > "$CACHE/assigned.json"
gl mr list --reviewer=@me --output json > "$CACHE/review.json"

sec "GITLAB MRs — MINE (author=@me, open)"
proj mr < "$CACHE/mine.json"

sec "GITLAB MRs — ASSIGNED TO ME (open)"
proj mr < "$CACHE/assigned.json"

sec "GITLAB MRs — I AM REVIEWER (open)"
proj mr < "$CACHE/review.json"

sec "GITLAB MRs — ALL STATES, RECENT 50 (team context: who owns/reviews what, what just landed)"
gl mr list --all --per-page 50 --output json | proj mr --desc 0

sec "GITLAB ISSUES — ASSIGNED TO ME (open)"
# NOTE: `issue list` spells JSON as -O/--output; `mr list` uses -F/--output.
gl issue list --assignee=@me --output json | proj issue

sec "GITLAB ISSUES — ALL OPEN (per-page 50)"
gl issue list --per-page 50 --output json | proj issue --desc 0

# Per-MR detail: comment timeline is where review state actually lives.
sec "GITLAB MR DETAIL + COMMENT TIMELINES"
MY_IIDS="$(cat "$CACHE"/mine.json "$CACHE"/assigned.json "$CACHE"/review.json \
            | grep -oE '"iid":[0-9]+' | grep -oE '[0-9]+' | sort -unr | head -"$MR_DETAIL")"
if [[ "$MR_DETAIL" -eq 0 ]]; then
  echo "(skipped: --mr-detail 0)"
elif [[ -z "$MY_IIDS" ]]; then
  echo "(no open MRs authored by / assigned to / reviewed by me, or GitLab unreachable)"
else
  for iid in $MY_IIDS; do
    sub "MR !$iid json"
    gl mr view "$iid" --output json | proj mr
    sub "MR !$iid comments + system activity"
    gl mr view "$iid" --comments --system-logs --per-page 40 | strip_desc | tidy_activity | head -70
  done
fi

sec "GITLAB PIPELINES (recent 15)"
gl ci list --per-page 15 --output json | proj pipeline

sec "GITLAB PIPELINE — CURRENT BRANCH"
gl ci status --compact

# `ci list` is ordered by pipeline id, so one branch mid-push-storm can fill
# the whole page and hide every other branch's state. Probe the refs that
# actually matter: worktree branches plus the source branches of my MRs.
sec "GITLAB PIPELINE — LATEST PER ACTIVE REF"
ACTIVE_REFS="$( { for wt in "${WT_DIRS[@]}"; do
                    [[ -d "$wt" ]] && g -C "$wt" rev-parse --abbrev-ref HEAD
                  done
                  cat "$CACHE"/mine.json "$CACHE"/assigned.json "$CACHE"/review.json 2>/dev/null \
                    | grep -oE '"source_branch":"[^"]+"' | cut -d'"' -f4
                } | sort -u | head -10 )"
for ref in $ACTIVE_REFS; do
  printf '%s: ' "$ref"
  gl ci list --ref "$ref" --per-page 1 --output json | proj pipeline
done

# ------------------------------------------------------------- prior context
sec "PREVIOUS CHECKPOINT (for what-changed-since)"
if [[ -f "$TMP/CHECKPOINT.md" ]]; then
  echo "path: $TMP/CHECKPOINT.md"
  echo "mtime: $(date -Iseconds -r "$TMP/CHECKPOINT.md")"
  cat "$TMP/CHECKPOINT.md"
else
  echo "(no previous checkpoint — this is the first one)"
fi

sec "OTHER LOCAL NOTES"
ls -lt "$TMP" 2>/dev/null | head -25
sub "project guidance files present"
for f in CLAUDE.md AGENTS.md .claude/CLAUDE.md .codex/AGENTS.md CONTEXT.md README.md docs/adr; do
  [[ -e "$ROOT/$f" ]] && echo "$f"
done

echo
echo "===== END OF BUNDLE ====="
