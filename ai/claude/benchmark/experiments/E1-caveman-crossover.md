# E1 — /caveman Crossover Point

**Question:** At what task complexity does `/caveman` start saving tokens vs default?

## Tasks

| ID         | Description                                                | Complexity                               |
|------------|------------------------------------------------------------|------------------------------------------|
| E1-simple  | Add one alias to docker/docker.sh                          | Trivial write, 1 file, 0 unknowns        |
| E1-medium  | Fix fkill's empty-pid case in optional/fzf.sh              | Targeted fix, 1 function, clear scope    |
| E1-complex | Refactor bat/batcat detection across 7 functions in fzf.sh | Multi-site refactor, unclear full extent |

## Results

| Task    | default $ | caveman $ | caveman-raw $ | caveman Δ         |
|---------|-----------|-----------|---------------|-------------------|
| simple  | $0.086    | $0.090    | $0.086        | **−5% (worse)**   |
| medium  | $0.099    | $0.136    | $0.088        | **−37% (worse)**  |
| complex | $0.230    | $0.106    | $0.184        | **+54% (better)** |

### Token detail

| Task    | variant | cache_read | out_tokens | cost   |
|---------|---------|------------|------------|--------|
| simple  | default | 63,445     | 322        | $0.086 |
| simple  | caveman | 64,631     | 404        | $0.090 |
| medium  | default | 61,918     | 1,387      | $0.099 |
| medium  | caveman | 161,021    | 1,580      | $0.136 |
| complex | default | 105,262    | 7,672      | $0.230 |
| complex | caveman | 92,208     | 1,163      | $0.106 |

## Findings

**1. Crossover is at complex tasks only.**
Caveman is neutral-to-negative on simple and medium tasks. It only pays off when the task scope is genuinely ambiguous
or multi-site.

**2. The medium task exposed a structural problem in the skill.**
Caveman loaded 99k more cache tokens than default on a task with clear, bounded scope (one function, one fix). Its "
observe everything first" phase read the full fzf.sh and surrounding context before acting. Default read only the target
function. Caveman's observation phase backfired because the scope was already known.

**3. Output token savings only appear at complex scale.**
On the complex refactor, default generated 7,672 output tokens (effectively rewrote the whole file with explanation).
Caveman generated 1,163 — it produced a targeted helper + callsite diff and stopped. That 85% reduction in output tokens
is where the money is.

**4. caveman-raw is neutral-to-mildly-useful on medium tasks.**
On medium, caveman-raw ($0.088) beat both default ($0.099) and caveman ($0.136). Terse prompt = fewer output tokens
without the observation overhead of the full skill.

## Root Cause

The `/caveman` skill had no scope-check gate. It entered broad observation mode regardless of whether the task scope was
already clear. This caused over-reading on bounded tasks.

## Fix Applied

Added a **Scope Check** section to `AI-Engineering/ClaudeCode/global/skills/caveman/SKILL.md`:

> Before entering full caveman mode: if the affected file is already known and the change is bounded, act directly.
> Caveman mode is for unclear or exploding scope only.

## When to Use /caveman

| Task type                             | Use caveman?                      |
|---------------------------------------|-----------------------------------|
| Add one alias, one-line fix           | No — default is cheaper           |
| Fix one known function                | No — default reads less           |
| Multi-file refactor, unclear scope    | Yes — saves 50%+                  |
| Debugging with no clear owner         | Yes — prevents wasted exploration |
| Task that has already gone wrong once | Yes — forces reset to facts       |
