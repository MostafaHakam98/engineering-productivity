# Tampermonkey scripts

Generate userscripts locally from templates, review them, then install them
manually in Tampermonkey.

| Script | Behavior |
|---|---|
| GitLab File Tree | Read-only repository tree, quick search, copy path, encoded navigation URLs |
| GitLab Issue → MR | Prepare a project-scoped description template and suggested branch; apply/copy on request |
| ActiTIME | Explicitly configured hour-grid autofill, confirmation before writes, summaries and CSV export |

## Setup

From the repository root:

```bash
cp .env.example .env
# Edit GITLAB_URL, COMPANY_NAME, AUTHOR_NAME, STORAGE_KEY_PREFIX.
bash browser/scripts/setup.sh
```

The `.env` parser accepts plain or fully quoted `KEY=value` lines and full-line
comments. It never sources the file, expands variables, or executes commands.
Existing generated scripts receive `.ep-backup-*` backups before replacement.
For isolated generation:

```bash
bash browser/scripts/setup.sh --env /path/to/test.env --out /tmp/my-userscripts
```

Open Tampermonkey's dashboard, create a new script for each generated `.js` file,
paste its contents, and save. Regeneration does not update Tampermonkey's installed
copy. Keep `.env` and generated scripts out of shared archives and commits.

## ActiTIME opt-in

Grid operations are disabled until `TIMESHEET_INPUT_SELECTOR` and
`FIRST_COLUMN_WEEKDAY` are configured in the installed userscript. Match only
editable hour inputs with exactly seven visible columns per row. Review and
customize the default Sun–Thu schedule. See the
[configuration example and recovery guide](../../docs/INSTALLATION.md).

Fill and clear actions ask for confirmation. The site may save input changes
automatically. Export first; there is no undo/redo feature. No Enter key is
synthesized and no nearest-element click is used for previous-week navigation.

GitLab's label widgets differ between releases, so select MR labels manually.
The helper fills a description; it does not submit an MR. Browser fixture tests
check these scenarios without contacting live services. Live instance versions,
permissions, and page markup still require recipient-side validation.
