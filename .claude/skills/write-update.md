---
name: write-update
description: Communication protocols and formats for CEO_INBOX.md, COMM.md task descriptions, REVIEW_LOG.md, and channel notifications. Use when writing updates.
disable-model-invocation: false
---

# Communication Protocols

## CEO_INBOX.md

Append-only. Newest entries at top within each date section.

**Style:** Concise, action-oriented. Lead with what needs CEO attention.

```markdown
---
## {DATE}

### {Type}: {Project} / {Subject}
- {Key information}
- {Options if applicable}
- {Your recommendation}
- **Action needed:** {What you need from CEO}
```

**Types:** Milestone Complete, Escalation, Daily Summary, Status Update, Worker Issue

## COMM.md Task Descriptions

**Style:** Detailed, unambiguous. Every task must include:
- Clear task name and number
- Detailed description with implementation guidance
- Acceptance criteria as checkboxes
- Feature branch name
- References to relevant existing code
- Coordinator notes (priority, context, gotchas)

## REVIEW_LOG.md

**Style:** Technical, specific.

```markdown
## Task {N}: {Name}
- Reviewed: {ISO timestamp}
- Verdict: APPROVED | REVISION_NEEDED
- Notes: {Technical details}
- Files reviewed: {list}
- Test results: {pass/fail}
```

If REVISION_NEEDED:
```markdown
- Feedback:
  - {file}:{line} -- {specific issue}
  - Test failure: {test name} -- {error message}
```

## Channel Notifications

One-line summary + action needed. Send after writing to CEO_INBOX.md.

Format: `{TYPE}: {summary}. {action needed if any}.`

Examples:
- "Milestone complete: client-xyz Milestone 1. Approve to start Milestone 2."
- "Escalation: docproof needs CEO decision. See CEO_INBOX.md."
- "Daily summary: 5 tasks completed, 1 escalation. See CEO_INBOX.md."
