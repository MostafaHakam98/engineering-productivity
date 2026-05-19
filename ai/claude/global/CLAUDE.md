# Global Claude Preferences

## Working Style

- Be direct, technical, and specific.
- Prefer targeted reads over broad repository scans.
- Before large edits, explain the files that need to change.
- Prefer small, reviewable patches.
- Avoid touching unrelated files.
- Separate facts, assumptions, and recommendations.

## Code Review Style

- Focus on correctness, maintainability, architecture, and CI impact.
- Separate blockers from suggestions.
- Prefer concrete replacement snippets over vague advice.

## Debugging Style

- Identify the exact failing command.
- Find the first meaningful error.
- Classify the failure before proposing fixes.
- Prefer one minimal fix followed by one targeted verification.

## Output Style

- Prefer commands, diffs, examples, and checklists.
- Avoid over-explaining basic concepts unless asked.
- When unsure, say what is unknown and what to inspect next.

## GitLab Rules

Always use `safe-git` instead of `git` and `safe-glab` instead of `glab`.

### Allowed

- Create feature branches.
- Commit changes on feature branches.
- Push feature branches.
- Create merge requests.
- Edit MR descriptions.
- List MRs.
- View pipelines.
- View issues.
- Create issues.

### Not Allowed

- Do not push to `main`, `master`, `devel`, `develop`, `staging`, or `production`.
- Do not force-push.
- Do not merge MRs.
- Do not delete branches.
- Do not delete tags.
- Do not modify CI/CD variables.
- Do not modify repository/project settings.
- Do not modify protected branches.
- Do not use raw `glab api`.
- Do not use destructive Git commands.

### Before Pushing

1. Show `safe-git status`.
2. Show `safe-git diff --stat`.
3. Show current branch name.
4. Ask for confirmation before pushing.

### Branch Naming

- Features: `FT-description-HA`
- Fixes: `FIX-description-HA`
- Refactors: `RF-description-HA`

All branches must end with `-HA` (short for Hakam).

### Issue + MR Workflow

When asked to create an issue OR an MR, always create BOTH — an issue first, then a linked Draft MR. Never create one without the other unless explicitly told to skip one.

#### Step-by-step sequence

1. Run `safe-glab label list` to fetch available labels for the project.
2. Select all labels that match the work type (e.g. `feature`, `bug`, `refactor`, `documentation`, `test`).
3. Create the issue using the Issue Template below. Assign to `moustafa.hakam` and apply the selected labels.
4. Note the issue number returned (e.g. `#42`).
5. Create the Draft MR using the MR Template below. Link it to the issue. Assign to `moustafa.hakam` and apply the same labels.

#### Example command sequence

```bash
# 1. Fetch labels
safe-glab label list

# 2. Create issue
safe-glab issue create \
  --title "FT: Add login validation" \
  --description "..." \
  --assignee moustafa.hakam \
  --label "feature,backend"

# 3. Create MR (after noting issue number, e.g. #42)
safe-git checkout -b FT-login-validation-HA
safe-git push -u origin FT-login-validation-HA

safe-glab mr create \
  --draft \
  --source-branch FT-login-validation-HA \
  --target-branch devel \
  --title "Draft: FT: Add login validation" \
  --description "..." \
  --assignee moustafa.hakam \
  --label "feature,backend"
```

### MR Rules

- Default target branch is `devel` unless explicitly told otherwise.
- Always create MRs as Draft unless told otherwise.
- MR title mirrors the issue title, prefixed with `Draft: `.
- Always assign to `moustafa.hakam`.
- Always apply the same labels as the linked issue.
- Always link the related issue in the MR description under `### Related Issues`.

### Issue Template

```
### Summary
Briefly describe what the feature should do and why it's needed.

---

### Detailed Description
Explain how the feature should work, including any relevant:
- Algorithms or data structures
- APIs or endpoints
- Design patterns or flow diagrams

_Add mockups, screenshots, or UML diagrams if helpful._

---

### Acceptance Criteria
- [ ] **Functional:** The feature performs as expected and meets all requirements.
- [ ] **Tests:** Unit/integration tests cover new and updated code.
- [ ] **Documentation:** Usage instructions and examples are included.
- [ ] **Pipelines Passing:** All CI/CD pipelines succeed.
- [ ] **Performance:** No significant performance regressions.
- [ ] **UML (if applicable):** Diagrams included for complex multi-module features.
- [ ] **Code Review:** Meets coding standards and passes peer review.

---

### Additional Information
_Add any relevant research, previous implementations, or external references._

---

### Related Issues
_Link to subsidiary or dependent issues here._

---

### Target Branches
- **Branch Out From:** `<source_branch>`
- **Merge Into:** `<target_branch>`
```

### MR Template

Use this template strictly. Do not invent or substitute sections.

```
### Issue
Closes #<issue_number>

---

### Authored By
@moustafa.hakam

---

### Summary
Briefly describe what the feature should do and why it's needed.

---

### Detailed Description
Explain how the feature should work, including any relevant:
- Algorithms or data structures
- APIs or endpoints
- Design patterns or flow diagrams

_Add mockups, screenshots, or UML diagrams if helpful._

---

### Acceptance Criteria
- [ ] **Functional:** The feature performs as expected and meets all requirements.
- [ ] **Tests:** Unit/integration tests cover new and updated code.
- [ ] **Documentation:** Usage instructions and examples are included.
- [ ] **Pipelines Passing:** All CI/CD pipelines succeed.
- [ ] **Performance:** No significant performance regressions.
- [ ] **UML (if applicable):** Diagrams included for complex multi-module features.
- [ ] **Code Review:** Meets coding standards and passes peer review.

---

### Additional Information
_Add any relevant research, previous implementations, or external references._

---

### Related Issues
_Link to subsidiary or dependent issues here._

---

### Target Branches
- **Branch Out From:** `<source_branch>`
- **Merge Into:** `<target_branch>`
```
