---
name: prepare-worker
description: Prepare worker context (CLAUDE.md in code repo, MEMORY.md in management repo) before launching a worker. Use before every worker launch.
disable-model-invocation: false
---

# Worker Context Preparation

Before launching a worker on a project, prepare its working context.

## 1. Write/Update CLAUDE.md in Code Repo

```markdown
# {Project Name} -- Worker Instructions

## Project
{One-line description from PROJECT.md}

## Tech Stack
{From PROJECT.md}

## Current Task
{Task name and number from COMM.md}

## Acceptance Criteria
{Copied from COMM.md}

## Conventions
- {Language-specific conventions}
- {Framework-specific patterns}
- Commit messages: "feat:", "fix:", "test:", "refactor:" prefixes
- Branch naming: feature/task-{N}-{short-description}

## Management Repo
- COMM.md: {absolute path to management repo}/projects/{project-name}/COMM.md
- PROJECT.md: {absolute path to management repo}/projects/{project-name}/PROJECT.md

## Important
- Update COMM.md worker notes as you make progress
- Push both code repo and management repo when done
- Run all tests before marking DONE_AWAITING_REVIEW
- Use subagents for parallel sub-tasks when beneficial
```

## 2. Write/Update MEMORY.md in Management Repo

MEMORY.md lives at `projects/{name}/MEMORY.md` (NOT in the code repo).

```markdown
# {Project Name} -- Context Memory

## Discovery Decisions
{Key decisions made during discovery phase}

## CEO Preferences
{Any preferences expressed by CEO}

## Past Revision Feedback
{Summary of what was rejected in previous tasks and why}

## Architecture Notes
{Key architecture decisions and trade-offs}
```

Update MEMORY.md after each task cycle with relevant new context.
