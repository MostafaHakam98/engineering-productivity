---
name: caveman
description: Use when a task is confusing, too broad, failing repeatedly, token-heavy, or when the user asks for the caveman approach. Reduces work to observable facts, tiny steps, and one safe next action.
---

# Caveman Skill

## Purpose

Use the caveman approach to reduce complexity.

The goal is not to be dumb. The goal is to avoid hallucination, over-engineering, and context explosion.

## Core Principle

Big problem bad.  
Small fact good.  
One next action good.  
Guessing bad.

## Scope Check (do this first)

Before entering full caveman mode, answer these:

- Is the affected file already known and the change clearly bounded? → Read only that file, make the edit. Do not broaden.
- Is this a single-function fix with an obvious target? → Read only that function. Do not survey the repo.
- Is the task scope unclear, multi-file, or failing without an obvious cause? → Enter full caveman mode below.

Caveman mode is for **unclear or exploding scope**. Do not apply broad observation to clearly bounded tasks — it loads more context than a direct approach and costs more.

## Operating Mode

When this skill is active:

1. Run the scope check above. If scope is clear, act directly.
2. Stop broad exploration.
3. State only the facts already observed.
4. State the smallest unknown blocking progress.
5. Choose one safe command, one file read, or one edit.
6. Verify after every meaningful step.
7. Do not continue expanding scope unless the evidence requires it.

## Response Format

Use this structure:

~~~md
## Facts

- ...

## Unknowns

- ...

## Smallest Next Step

...

## Expected Signal

...

## Stop Condition

...
~~~

## Rules

- Prefer one command over five.
- Prefer one file read over a directory scan.
- Prefer one failing target over a full build.
- Prefer one minimal patch over a refactor.
- Do not infer architecture from filenames alone.
- Do not fix multiple problems in one patch unless they are inseparable.

## Debugging Flow

For failures:

1. What command failed?
2. What is the first real error?
3. Is it configure, compile, link, test, runtime, permission, environment, or network?
4. What file most likely owns that error?
5. What is the smallest proof?

## Build Failure Caveman Flow

~~~text
failed command
-> failing phase
-> failing target
-> first real error
-> owner CMake/source file
-> one patch
-> rebuild same target
~~~

## CI Failure Caveman Flow

~~~text
failed job
-> failed command
-> first real error
-> local reproduction command
-> smallest config/code fix
-> rerun same job/stage
~~~

## Output Constraints

- Be brief.
- Do not produce a full design unless requested.
- Do not scan the whole repo.
- Do not make speculative changes.
