#!/usr/bin/env bash
# Format converters: shared source -> a target's dialect.
#
# Every function writes into a staging directory. Nothing here touches $HOME;
# install-global.sh does that after rendering, so a render can always be
# inspected first with `port.sh <target> --out <dir>`.
#
# Sourced by port.sh. Assumes: set -euo pipefail, and SHARED_DIR exported.

# --- frontmatter helpers ---------------------------------------------------

# fm_field <file> <key> -> value of a top-level YAML frontmatter scalar
fm_field() {
    awk -v key="$2" '
        NR == 1 && $0 == "---" { infm = 1; next }
        infm && $0 == "---"    { exit }
        infm && index($0, key ":") == 1 {
            sub("^" key ":[ \t]*", "")
            gsub(/^["'"'"']|["'"'"']$/, "")
            print
            exit
        }
    ' "$1"
}

# fm_field_folded <file> <key> -> scalar, or a YAML folded block joined to one line
fm_field_folded() {
    local v
    v="$(fm_field "$1" "$2")"
    if [ "$v" = ">" ] || [ "$v" = "|" ] || [ "$v" = ">-" ] || [ "$v" = "|-" ]; then
        awk -v key="$2" '
            NR == 1 && $0 == "---" { infm = 1; next }
            infm && $0 == "---"    { exit }
            infm && index($0, key ":") == 1 { grab = 1; next }
            grab && /^[a-zA-Z_-]+:/ { exit }
            grab { sub(/^[ \t]+/, ""); printf "%s%s", (n++ ? " " : ""), $0 }
        ' "$1"
    else
        printf '%s' "$v"
    fi
}

# fm_strip <file> -> body with the frontmatter block removed and surrounding
# blank lines trimmed, so converted output has no stray padding.
fm_strip() {
    awk 'NR == 1 && $0 == "---" { infm = 1; next }
         infm && $0 == "---"    { infm = 0; next }
         !infm {
             if (!seen && $0 ~ /^[ \t]*$/) next   # drop leading blanks
             seen = 1
             if ($0 ~ /^[ \t]*$/) { pending++; next }
             while (pending-- > 0) print ""       # keep interior blanks
             pending = 0
             print
         }' "$1"
}

# --- instructions ----------------------------------------------------------

# render_instructions <src> <dest> <title> <skills_dir> [format]
# Substitutes {{SKILLS_DIR}} and retitles the H1 so each tool reads as its own.
render_instructions() {
    local src="$1" dest="$2" title="$3" skills_dir="$4" format="${5:-md}"
    mkdir -p "$(dirname "$dest")"

    local body
    body="$(subst < "$src" | sed -e "1s|^# .*|# ${title}|")"

    if [ "$format" = "mdc-always" ]; then
        {
            printf -- '---\ndescription: %s\nalwaysApply: true\n---\n\n' "$title"
            printf '%s\n' "$body"
        } > "$dest"
    else
        printf '%s\n' "$body" > "$dest"
    fi
}

# --- placeholders ----------------------------------------------------------
#
# Shared content is tool-neutral and refers to per-target paths through
# placeholders. Set by port.sh before rendering:
#   PH_SKILLS_DIR  the target's global skills directory
#   PH_CONFIG_DIR  the project config directory (.claude, .codex, .pi, .cursor)
#   PH_ENTRYPOINT  the project entry-point filename (CLAUDE.md / AGENTS.md)
#   PH_RULE_EXT    md, or mdc for Cursor

# subst [< stdin] -> stdout with every placeholder filled
subst() {
    sed -e "s#{{SKILLS_DIR}}#${PH_SKILLS_DIR:-}#g" \
        -e "s#{{CONFIG_DIR}}#${PH_CONFIG_DIR:-}#g" \
        -e "s#{{ENTRYPOINT}}#${PH_ENTRYPOINT:-}#g" \
        -e "s#{{RULE_EXT}}#${PH_RULE_EXT:-md}#g"
}

# subst_tree <dir> — rewrite placeholders in every text file under <dir>,
# preserving permissions (skill scripts must stay executable).
subst_tree() {
    local f tmp
    while IFS= read -r f; do
        grep -q '{{' "$f" 2>/dev/null || continue
        tmp="$f.subst.$$"
        subst < "$f" > "$tmp" && cat "$tmp" > "$f" && rm -f "$tmp"
    done < <(find "$1" -type f)
}

# --- skills ----------------------------------------------------------------

# render_skills <src_root> <dest_root> <format>
render_skills() {
    local src="$1" dest="$2" format="$3"
    mkdir -p "$dest"

    case "$format" in
        skill-dir)
            # Native SKILL.md consumers (Claude Code, Codex, pi/Metwally):
            # copy the tree verbatim so references/ and scripts/ come along.
            local d name
            for d in "$src"/*/; do
                [ -d "$d" ] || continue
                name="$(basename "$d")"
                rm -rf "${dest:?}/$name"
                cp -R "$d" "$dest/$name"
                subst_tree "$dest/$name"
            done
            ;;
        mdc)
            # Cursor: one .mdc rule per skill. Cursor loads a single file, so
            # bundled references/ and scripts/ cannot travel — they are listed
            # as repo-relative pointers instead of being silently dropped.
            local d name desc extras rel
            for d in "$src"/*/; do
                [ -d "$d" ] || continue
                name="$(basename "$d")"
                [ -f "$d/SKILL.md" ] || continue
                desc="$(fm_field_folded "$d/SKILL.md" description)"
                {
                    printf -- '---\ndescription: %s\nalwaysApply: false\n---\n\n' "$(printf '%s' "$desc" | subst)"
                    fm_strip "$d/SKILL.md" | subst
                    extras="$(cd "$d" && find . -type f ! -name SKILL.md | sed 's|^\./||' | sort)"
                    if [ -n "$extras" ]; then
                        printf '\n## Bundled Resources\n\n'
                        printf 'Not inlined into this rule. Read them from the kit when needed:\n\n'
                        while IFS= read -r rel; do
                            printf -- '- `ai/shared/skills/%s/%s`\n' "$name" "$rel"
                        done <<< "$extras"
                    fi
                } > "$dest/$name.mdc"
            done
            ;;
        "")  : ;;
        *)   echo "render_skills: unknown format '$format'" >&2; return 1 ;;
    esac
}

# --- commands / prompt templates -------------------------------------------

# render_commands <src_root> <dest_root> <format>
render_commands() {
    local src="$1" dest="$2" format="$3"
    [ -n "$format" ] || return 0
    mkdir -p "$dest"
    case "$format" in
        md)
            local f
            for f in "$src"/*.md; do
                [ -f "$f" ] || continue
                subst < "$f" > "$dest/$(basename "$f")"
            done
            ;;
        *)   echo "render_commands: unknown format '$format'" >&2; return 1 ;;
    esac
}

# --- subagents -------------------------------------------------------------

# render_agents <src_root> <dest_root> <format>
render_agents() {
    local src="$1" dest="$2" format="$3"
    [ -n "$format" ] || return 0
    mkdir -p "$dest"

    case "$format" in
        md)
            local f
            for f in "$src"/*.md; do
                [ -f "$f" ] || continue
                subst < "$f" > "$dest/$(basename "$f")"
            done
            ;;
        toml)
            # Codex agents are TOML with the body as developer_instructions.
            local f name desc
            for f in "$src"/*.md; do
                [ -f "$f" ] || continue
                name="$(fm_field "$f" name)"
                desc="$(fm_field_folded "$f" description)"
                {
                    printf 'name = "%s"\n' "$name"
                    printf 'description = "%s"\n' "${desc//\"/\\\"}"
                    # TOML trims the newline right after the opening delimiter.
                    # The body is emitted via %s so its trailing newline is
                    # dropped and the value carries no trailing blank line.
                    # Any literal triple-quote is escaped so the block cannot
                    # break out of the string.
                    printf 'developer_instructions = """\n%s"""\n' \
                        "$(fm_strip "$f" | subst | sed 's|"""|\\"\\"\\"|g')"
                } > "$dest/$(basename "$f" .md).toml"
            done
            ;;
        *)   echo "render_agents: unknown format '$format'" >&2; return 1 ;;
    esac
}

# --- permissions -----------------------------------------------------------

# render_permissions <src> <dest> <format>
# Merges the kit's allow/deny into an existing settings file rather than
# replacing it, so machine-local rules and personal prefs survive.
render_permissions() {
    local src="$1" dest="$2" format="$3"
    [ -n "$format" ] || return 0
    mkdir -p "$(dirname "$dest")"

    case "$format" in
        claude-settings)
            SRC="$src" DEST="$dest" python3 - <<'PY'
import json, os, pathlib

src, dest = os.environ["SRC"], pathlib.Path(os.environ["DEST"])
kit = json.load(open(src))["permissions"]
cur = json.loads(dest.read_text()) if dest.exists() else {}

perms = cur.setdefault("permissions", {})
for bucket in ("allow", "deny"):
    existing = perms.setdefault(bucket, [])
    for rule in kit.get(bucket, []):
        if rule not in existing:
            existing.append(rule)

dest.write_text(json.dumps(cur, indent=2) + "\n")
PY
            ;;
        *)   echo "render_permissions: unknown format '$format'" >&2; return 1 ;;
    esac
}

# --- project template ------------------------------------------------------

# render_project <src_root> <dest_root> <format> <skills_dir>
render_project() {
    local src="$1" dest="$2" format="$3" skills_dir="$4"
    [ -n "$format" ] || return 0
    mkdir -p "$dest"

    # entrypoint.md is the guide that points at rules/ and maps/. Where it
    # lands, what it is named, and how it spells those paths differ per tool,
    # so the template carries {{CONFIG_DIR}}, {{RULE_EXT}} and {{SKILLS_DIR}}
    # placeholders instead of hard-coded ones.
    local project_root dot
    project_root="$(dirname "$dest")"
    dot="$(basename "$dest")"

    # Inside a project template, CONFIG_DIR is the dot directory being written.
    # fill <config_dir> <rule_ext> [< stdin]
    fill() { PH_CONFIG_DIR="$1" PH_RULE_EXT="$2" PH_SKILLS_DIR="$skills_dir" subst; }

    case "$format" in
        claude-project)
            # Claude Code reads .claude/CLAUDE.md.
            cp -R "$src"/. "$dest"/
            fill "$dot" md < "$src/entrypoint.md" > "$dest/CLAUDE.md"
            rm -f "$dest/entrypoint.md"
            ;;
        agents-md|pi-project)
            # Codex and pi both discover AGENTS.md from the project ROOT, not
            # from inside a dot directory. The rules/ and maps/ it references
            # stay in the dot directory.
            cp -R "$src"/. "$dest"/
            fill "$dot" md < "$src/entrypoint.md" > "$project_root/AGENTS.md"
            rm -f "$dest/entrypoint.md"
            ;;
        mdc-project)
            # Cursor has one flat rules/ directory of .mdc files and no
            # entry-point file, so the guide becomes an always-applied rule and
            # every cross-reference is flattened to match.
            local f name rel desc apply
            mkdir -p "$dest/rules"
            while IFS= read -r f; do
                rel="${f#"$src"/}"
                name="$(basename "$rel" .md)"
                desc="$(sed -n 's/^# \(.*\)$/\1/p' "$f" | head -1)"
                [ -n "$desc" ] || desc="$name"
                apply=false
                if [ "$rel" = "entrypoint.md" ]; then name="project"; apply=true; fi
                printf -- '---\ndescription: %s\nalwaysApply: %s\n---\n\n' "$desc" "$apply" \
                    > "$dest/rules/$name.mdc"
                fill "$dot" mdc < "$f" \
                    | sed -E 's#`\.cursor/(rules|maps|workflows)/#`.cursor/rules/#g' \
                    >> "$dest/rules/$name.mdc"
            done < <(find "$src" -name '*.md' | sort)
            ;;
        *)   echo "render_project: unknown format '$format'" >&2; return 1 ;;
    esac
}
