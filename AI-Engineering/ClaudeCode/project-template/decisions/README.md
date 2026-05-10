# Architecture Decisions Index

## Purpose

Use this directory to record important decisions that Claude should respect.

Each decision should be short and factual.

## File Naming

Use names like:

- `0001-use-cmake-presets.md`
- `0002-keep-runtime-api-separate.md`
- `0003-isolate-cuda-backends.md`

## Decision Template

Use this structure:

~~~md
# Decision Title

## Status

Accepted / Proposed / Deprecated

## Context

Why this decision exists.

## Decision

What we decided.

## Consequences

What this affects.

## Claude Guidance

How Claude should behave because of this decision.
~~~

## Rule

Claude should check this directory before proposing architecture-level changes.
