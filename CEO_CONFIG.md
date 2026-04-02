# CEO Configuration

> Baseline defaults. Customize to match your management style.
> The Coordinator reads this file on startup and defers to these preferences over its built-in defaults.

---

## Identity

- **CEO Name:** Dhaval Nagar
- **Company:** APPGAMBIT AI Company
- **Timezone:** IST (Asia/Kolkata)

---

## Communication Preferences

- **Primary channel:** Telegram (or Discord — configure during bootstrap)
- **Update frequency:** Per-event (milestone complete, escalation, daily summary)
- **Escalation style:** Give me options + your recommendation. I'll pick.
- **Daily summary:** Yes, end of day. Include: tasks completed, blockers, tomorrow's plan.
- **Notification urgency:**
  - Milestone complete → immediate
  - Escalation → immediate
  - Daily summary → end of day
  - Rate limit hit → no notification (handle silently)

---

## Decision Authority

### Coordinator CAN decide (no escalation needed):
- Tech stack choices within PROJECT.md constraints
- Implementation approach when multiple options are equivalent
- Minor requirement clarifications findable in docs/code
- Task sequencing within a milestone
- Worker assignment and load balancing
- Git conflict resolution in management repo
- Restarting crashed worker sessions
- Choosing date/time formats, naming conventions, code style within project norms

### Coordinator MUST escalate:
- Any scope change (feature not in PROJECT.md)
- Any new paid dependency or service ($0+ cost)
- Deadline risk (milestone will miss target date)
- Missing credentials, API keys, third-party access
- Ambiguous requirements with multiple valid interpretations
- Worker failing same task 3+ times
- Priority conflicts between projects
- New project intake
- Milestone approval (always CEO)
- Budget decisions of any kind

---

## Code Review Standards

- **Test coverage:** Required for all new functionality. No exceptions.
- **Review depth:** Coordinator reviews all code. CEO does not review code unless escalated.
- **Acceptance criteria:** Must be 100% met. Partial completion = REVISION_NEEDED.
- **Code quality bar:** No debug code, no commented-out blocks, proper error handling.
- **Max revisions before escalation:** 2 (3rd failure → escalate to CEO)
- **Regression tolerance:** Zero. All existing tests must pass.

---

## Working Rules

- **Cooldown between tasks:** 30 minutes (coordinator delays next assignment)
- **Loop interval:** 5 minutes (`/loop 5m`)
- **Worker parallelism:** Subagents encouraged for independent sub-tasks within a session
- **Branch strategy:** Feature branches per task (`feature/task-{N}-{description}`)
- **Commit style:** Conventional commits (`feat:`, `fix:`, `test:`, `refactor:`)
- **Milestone size:** 4-5 tasks per milestone (guideline)
- **Rolling window:** 3-5 milestones visible at a time

---

## Project Onboarding

- **Discovery depth:** Thorough. Coordinator should ask clarifying questions until PROJECT.md is complete. Don't rush to implementation.
- **Tech stack preferences:**
  - Frontend: Next.js, React, TypeScript
  - Backend: Node.js, Python (project-dependent)
  - Infrastructure: SST v3, AWS
  - Database: PostgreSQL (default), project-dependent
- **Default deployment region:** ap-south-1 (Mumbai)
- **Code repo hosting:** GitHub (private repos under `appgambit/`)

---

## Dos and Don'ts

### Do:
- Ask questions during discovery. Better to clarify upfront than fix later.
- Write detailed acceptance criteria. Workers need unambiguous instructions.
- Update CEO_INBOX.md before sending channel notifications (audit trail first).
- Keep COMM.md focused on the current task only.
- Log everything in DAILY_LOG.md — it's the system's memory.
- Treat worker context preparation (CLAUDE.md, MEMORY.md) as critical — a well-briefed worker produces better code.

### Don't:
- Don't deploy to production without CEO approval.
- Don't skip code review, even for simple tasks.
- Don't let workers run for >2 hours without a COMM.md update.
- Don't assign more than 2 active projects per worker (leave a buffer slot).
- Don't make assumptions about client requirements — escalate.
- Don't modify CEO_INBOX.md entries after they're written.
- Don't push directly to main/master in code repos.

---

## Guardrails

- **Blocked commands:** See `scripts/hooks/block-dangerous-commands.sh`
- **Interactive commands:** See `scripts/hooks/block-interactive-commands.sh`
- **Custom blocks:** Add patterns to the hook scripts as needed. No code changes required — just append to the BLOCKED_PATTERNS array.
- **Permission mode — Coordinator:** `acceptEdits` (Pro plan) or `auto` (Team/Enterprise)
- **Permission mode — Workers:** `bypassPermissions` (hooks provide guardrails)

---

## Scaling

- **Current setup:** 1 account, Coordinator + Employee 1 (shared)
- **Next step:** Add Account 2 ($100/mo) for dedicated Employee 1
- **Full capacity:** 3 accounts ($300/mo), 2 workers, up to 6 projects
- **Future:** Separate machines via SSH, specialized workers (frontend/backend/infra)

---

*Last updated: 2026-04-02*
*Customize this file to match your management style. The Coordinator reads it on startup.*
