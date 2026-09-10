#!/usr/bin/env python3
"""Project verbose glab JSON into compact one-line-per-record text.

Raw `glab ... --output json` carries full descriptions and avatar URLs; a
50-MR listing is ~450KB, which is useless to read. This keeps only the fields
that answer "what is this thread, who owns it, what is it waiting on".

Usage:  <json on stdin> | project.py {mr|issue|pipeline} [--desc N]

Never fails hard: bad or non-JSON input (an error string from glab, an empty
body) is echoed back with a marker so the bundle still shows what happened.
"""
import sys, json, re

MODE = sys.argv[1] if len(sys.argv) > 1 else "mr"
DESC = 240
if "--desc" in sys.argv:
    DESC = int(sys.argv[sys.argv.index("--desc") + 1])

raw = sys.stdin.read().strip()


def bail(msg):
    print(f"(no parseable JSON: {msg})")
    if raw:
        print(raw[:600])
    sys.exit(0)


if not raw:
    bail("empty output")
# glab sometimes prefixes warnings before the JSON body.
start = min([i for i in (raw.find("["), raw.find("{")) if i != -1], default=-1)
if start == -1:
    bail("no JSON found")
try:
    data = json.loads(raw[start:])
except Exception as e:
    bail(str(e))

records = data if isinstance(data, list) else [data]
if not records:
    print("(none)")
    sys.exit(0)


def users(v):
    if not v:
        return "-"
    if isinstance(v, dict):
        v = [v]
    return ",".join(u.get("username", "?") for u in v) or "-"


def day(v):
    return (v or "")[:10] or "-"


def clean(v, n=DESC):
    """Collapse a description to one line; keeps template headings readable."""
    if not v:
        return ""
    t = re.sub(r"\s+", " ", v).strip()
    return t[:n] + ("…" if len(t) > n else "")


def xrefs(r):
    """Cross-references (#12, !30) mined from title+description: these are what
    actually stitch an issue, its MR and its follow-ups into one thread."""
    blob = f"{r.get('title','')} {r.get('description','')}"
    found = re.findall(r"(?<![\w/])([#!]\d+)", blob)
    seen = list(dict.fromkeys(found))[:8]
    return ",".join(seen) or "-"


def tasks(r):
    t = r.get("task_completion_status") or {}
    return f"{t.get('completed_count', 0)}/{t.get('count', 0)}"


for r in records:
    if MODE == "mr":
        flags = []
        if r.get("draft") or r.get("work_in_progress"):
            flags.append("DRAFT")
        if r.get("has_conflicts"):
            flags.append("CONFLICTS")
        if r.get("blocking_discussions_resolved") is False:
            flags.append("UNRESOLVED-THREADS")
        hp = r.get("head_pipeline") or {}
        if hp.get("status"):
            flags.append("pipeline=" + hp["status"])
        dms = r.get("detailed_merge_status") or r.get("merge_status")
        if dms:
            flags.append("merge=" + str(dms))
        print(
            " | ".join(
                [
                    "!%s" % r.get("iid"),
                    str(r.get("state")),
                    clean(r.get("title"), 120),
                    "author=" + users(r.get("author")),
                    "assignees=" + users(r.get("assignees")),
                    "reviewers=" + users(r.get("reviewers")),
                    "%s -> %s" % (r.get("source_branch"), r.get("target_branch")),
                    "labels=" + (",".join(r.get("labels") or []) or "-"),
                    "milestone=" + ((r.get("milestone") or {}).get("title") or "-"),
                    "notes=%s" % r.get("user_notes_count", 0),
                    "tasks=" + tasks(r),
                    "created=" + day(r.get("created_at")),
                    "updated=" + day(r.get("updated_at")),
                    "refs=" + xrefs(r),
                    " ".join(flags) or "-",
                    str(r.get("web_url") or "-"),
                ]
            )
        )
        if DESC:
            print("      desc: " + clean(r.get("description")))

    elif MODE == "issue":
        print(
            " | ".join(
                [
                    "#%s" % r.get("iid"),
                    str(r.get("state")),
                    clean(r.get("title"), 120),
                    "author=" + users(r.get("author")),
                    "assignees=" + users(r.get("assignees")),
                    "labels=" + (",".join(r.get("labels") or []) or "-"),
                    "milestone=" + ((r.get("milestone") or {}).get("title") or "-"),
                    "mrs=%s" % r.get("merge_requests_count", 0),
                    "tasks=" + tasks(r),
                    "notes=%s" % r.get("user_notes_count", 0),
                    "created=" + day(r.get("created_at")),
                    "updated=" + day(r.get("updated_at")),
                    "due=" + (r.get("due_date") or "-"),
                    "refs=" + xrefs(r),
                    str(r.get("web_url") or "-"),
                ]
            )
        )
        if DESC:
            print("      desc: " + clean(r.get("description")))

    elif MODE == "pipeline":
        print(
            " | ".join(
                [
                    "pipeline=%s" % r.get("id"),
                    str(r.get("status")),
                    "ref=%s" % r.get("ref"),
                    "source=%s" % r.get("source"),
                    "sha=%s" % (r.get("sha") or "")[:8],
                    "created=" + day(r.get("created_at")),
                    "updated=" + day(r.get("updated_at")),
                    str(r.get("web_url") or "-"),
                ]
            )
        )

    else:  # project / fallback: a small hand-picked slice
        print(
            json.dumps(
                {
                    k: r.get(k)
                    for k in (
                        "path_with_namespace",
                        "default_branch",
                        "web_url",
                        "open_issues_count",
                        "last_activity_at",
                        "visibility",
                    )
                    if k in r
                }
            )
        )
