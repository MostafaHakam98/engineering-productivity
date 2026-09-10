#!/usr/bin/env python3
"""Compact `glab mr view --comments --system-logs` output into a timeline.

GitLab's activity log is written for a browser: every push costs a bare
"added N commits" line, an HTML <ul> of commit subjects, a long diff-compare
URL, a full-precision timestamp, and blank lines between all of them. This
folds each push into one dated line and keeps human comments intact, which is
what a checkpoint timeline is built from.

Reads stdin, writes stdout. Never raises on odd input.
"""
import sys, re, html

TS = re.compile(r"(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}):\d{2}[\d.]*\s*[+\-]\d{4}\s*\w*")
ADDED = re.compile(r"added \d+ commits?$")


def strip_html(t):
    t = re.sub(r"</li>\s*<li>", " ; ", t)
    t = re.sub(r"<[^>]+>", "", t)
    return html.unescape(t).strip()


def shorten(ts_line):
    """Full-precision timestamps to `YYYY-MM-DD HH:MM`."""
    return TS.sub(r"\1 \2", ts_line)


def commits_summary(t, keep=3):
    parts = [p.strip() for p in t.split(" ; ") if p.strip()]
    if len(parts) <= keep:
        return " ; ".join(parts)
    return " ; ".join(parts[:keep]) + f" (+{len(parts) - keep} more)"


out, pending, commits = [], None, None

for raw in sys.stdin.read().splitlines():
    line = shorten(raw.rstrip())
    if not line.strip():
        continue

    # Long diff-compare URL: only its timestamp matters.
    if line.startswith("[Compare with previous version]") or line.startswith("pushed "):
        ts = TS.sub(r"\1 \2", line)
        ts = re.sub(r"^\[Compare with previous version\]\([^)]*\)\s*", "", ts)
        ts = re.sub(r"^pushed\s*", "", ts).strip()
        if pending:
            summary = f" — {commits}" if commits else ""
            out.append(f"{pending} [{ts}]{summary}")
            pending, commits = None, None
        else:
            out.append(f"pushed [{ts}]")
        continue

    if "<li>" in line or "<ul>" in line:
        commits = commits_summary(strip_html(line))
        continue

    if ADDED.search(line):
        if pending:
            out.append(pending)
        pending, commits = line, None
        continue

    if pending:
        out.append(pending)
        pending, commits = None, None
    out.append(strip_html(line) if "<" in line else line)

if pending:
    out.append(pending)

PUSH = re.compile(r"^(\S+) added \d+ commits? \[(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\](?: — (.*))?$")
CHECK = re.compile(
    r"^(\S+) marked the checklist item .*? as (completed|incomplete) "
    r"(\d{4}-\d{2}-\d{2} \d{2}:\d{2})$"
)


def collapse_checklist(lines, threshold=2):
    """Fold runs of checklist ticks into one counted line."""
    result, run = [], []

    def flush():
        if not run:
            return
        if len(run) < threshold:
            result.extend(l for _, _, _, l in run)
        else:
            who, state = run[0][0], run[0][1]
            verb = "ticked" if state == "completed" else "un-ticked"
            result.append(f"{who} {verb} {len(run)} acceptance-criteria boxes {run[-1][2]}")
        run.clear()

    for line in lines:
        m = CHECK.match(line)
        if m and (not run or (run[0][0], run[0][1]) == (m.group(1), m.group(2))):
            run.append((m.group(1), m.group(2), m.group(3), line))
            continue
        flush()
        if m:
            run.append((m.group(1), m.group(2), m.group(3), line))
        else:
            result.append(line)
    flush()
    return result


def collapse_pushes(lines, threshold=3):
    """Fold >=threshold consecutive pushes by the same author into one line."""
    result, run = [], []

    def flush():
        if not run:
            return
        if len(run) < threshold:
            result.extend(l for _, _, _, l in run)
        else:
            who = run[0][0]
            last_subject = next((s for _, _, s, _ in reversed(run) if s), "")
            tail = f" — last: {last_subject}" if last_subject else ""
            result.append(
                f"{who} pushed {len(run)}x between {run[0][1]} and {run[-1][1]}{tail}"
            )
        run.clear()

    for line in lines:
        m = PUSH.match(line)
        if m and (not run or run[0][0] == m.group(1)):
            run.append((m.group(1), m.group(2), m.group(3) or "", line))
            continue
        flush()
        if m:
            run.append((m.group(1), m.group(2), m.group(3) or "", line))
        else:
            result.append(line)
    flush()
    return result


print("\n".join(collapse_checklist(collapse_pushes(out))))
