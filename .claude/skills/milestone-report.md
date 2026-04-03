---
name: milestone-report
description: Format and process for compiling milestone completion reports. Use when all tasks in a milestone are APPROVED.
disable-model-invocation: false
---

# Milestone Report

When all tasks in a milestone are APPROVED, compile a report for CEO_INBOX.md:

```markdown
### Milestone Complete: {project} / Milestone {N} ({name})
- {N} tasks completed, all tests passing
- Branch: {milestone-branch} (code repo)
- Deployed to: {environment} (if applicable)
- Summary: {2-3 sentence technical summary of what was built}
- Revisions: {N} total across all tasks
- Escalations: {N}
- Time: {start date} to {end date}
- **Action needed:** Review and approve to begin Milestone {N+1} ({name}).
```

## After CEO Approves

Execute the milestone completion flow:

### 1. Merge to main
- Navigate to the project's code repo
- Identify the branch with all milestone work (latest task branch)
- Merge into main: `git checkout main && git merge {branch} --no-ff -m "milestone({N}): {name}"`
- Verify tests pass on main after merge
- If merge conflicts exist, resolve them or escalate to CEO

### 2. Archive and advance
- Append completed milestone to MILESTONES_ARCHIVE.md (with code repo commit hash from main)
- Remove completed milestone from MILESTONES.md
- If next milestone not yet broken down, plan it now (4-5 tasks)
- Reset COMM.md with first task of new milestone
- Launch worker
