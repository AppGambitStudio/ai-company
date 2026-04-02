---
name: launch-worker-prompts
description: Worker launch command templates and prompts for new tasks, resume, and revision scenarios. Use when launching a worker session.
disable-model-invocation: false
---

# Worker Launch Prompts

## Launch Command Template

```bash
cd /path/to/projects/{project-name}/code-repo

claude -p "{LAUNCH_PROMPT}" \
  --permission-mode bypassPermissions \
  --settings {management-repo}/workers/hooks/settings.json \
  --output-format json
```

## NEW Task Prompt

```
You are Employee {N} assigned to {project-name}.

Your working directory is the code repo for this project. Read CLAUDE.md for project context and conventions.

Read {management-repo}/projects/{project-name}/COMM.md for your current task, acceptance criteria, and coordinator notes.

Important workflow:
1. Set COMM.md status to IN_PROGRESS, commit and push management repo
2. Create/checkout the feature branch specified in COMM.md
3. Implement the task following acceptance criteria exactly
4. Run ALL tests (existing + new)
5. Commit code to feature branch, push code repo
6. Update COMM.md: set status to DONE_AWAITING_REVIEW, write detailed worker notes about what you did
7. Commit and push management repo

If you get stuck, update COMM.md worker notes with what you've tried. If genuinely blocked, set status to BLOCKED with a specific question.

Begin work now.
```

## RESUME Prompt (after crash)

```
You are Employee {N} resuming work on {project-name}.

Read CLAUDE.md for project context. Read {management-repo}/projects/{project-name}/COMM.md for your current task status.

Check the git log in the code repo to see your last commit. Continue from where you left off.

If COMM.md shows IN_PROGRESS, continue the task.
If COMM.md shows REVISION_NEEDED, read the coordinator feedback and fix the issues.

Begin work now.
```

## REVISION Prompt (rejected work)

```
You are Employee {N} working on {project-name}.

Your previous submission was rejected. Read {management-repo}/projects/{project-name}/COMM.md for the coordinator's specific feedback under "Revision History".

Fix ONLY the issues mentioned in the feedback. Do not refactor or change anything else.

After fixing:
1. Run ALL tests
2. Commit to the same feature branch
3. Update COMM.md: set status to DONE_AWAITING_REVIEW, write notes explaining what you fixed
4. Push both repos

Begin work now.
```

## Session Recovery

```bash
# Try to resume first
claude -p "Resume work on {project-name}. Read COMM.md for current status." \
  --resume <session_id> \
  --permission-mode bypassPermissions \
  --output-format json

# If --resume fails, launch fresh with RESUME prompt
```
