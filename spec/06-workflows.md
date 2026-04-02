# 6. Workflows

> Step-by-step procedures for the major operational flows: onboarding new projects, the steady-state task cycle, handling escalations, rate limits, priority changes, session recovery, and context preparation.

---

## 6.1 New Project Onboarding (Discovery Flow)

```
CEO -> APPGAMBIT AI:
  "New project. [rough brief / notes / verbal description]"

APPGAMBIT AI (Discovery Phase):
  1. Create /projects/{name}/ directory
  2. Write BRIEF.md (raw capture of CEO's input, unstructured)
  3. Write draft PROJECT.md with:
     - Best interpretation of requirements
     - Assumptions made
     - Open questions (numbered list)
  4. Update REGISTRY.md: project status = DISCOVERY
  5. Write to CEO_INBOX.md: "Project {name} drafted. Open questions: [list]"
  6. git commit + push

CEO <-> Coordinator (N rounds):
  7. CEO answers questions, provides clarifications (live session or CEO_INBOX.md)
  8. Coordinator updates PROJECT.md, asks follow-up questions if needed
  9. Repeat until CEO approves the project plan

APPGAMBIT AI (Activation):
  10. Set project status -> ACTIVE in REGISTRY.md
  11. Break Milestone 1 into tasks -> write MILESTONES.md (3-5 milestones visible, ~4-5 tasks each)
  12. Prepare worker context in code repo:
      - Write/update CLAUDE.md (tech stack, conventions, current task context)
      - Write/update MEMORY.md (discovery decisions, CEO preferences, past feedback)
  13. Write COMM.md with Task 1 -> WAITING_FOR_WORKER
  14. Launch worker via headless mode:
      claude -p "{init prompt}" --permission-mode bypassPermissions \
        --settings /path/to/workers/hooks/settings.json --output-format json
  15. Record session ID in REGISTRY.md
  16. git commit + push
  17. Confirm to CEO (session + channel): "Project {name} is active. {Worker} assigned. ETA: {date}."
```

## 6.2 Task Cycle (steady state)

```
Coordinator:
  1. Write task to COMM.md -> WAITING_FOR_WORKER
  2. Push

Worker:
  3. Pull -> detect WAITING_FOR_WORKER
  4. Set IN_PROGRESS -> push
  5. Read task, create branch, implement
  6. Run tests
  7. Commit code (code repo) -> push
  8. Set DONE_AWAITING_REVIEW + worker notes -> push (management repo)

Coordinator:
  9. Pull -> detect DONE_AWAITING_REVIEW
  10. Read diff from code repo
  11. Run tests (by reading code repo diff)
  12. Evaluate against acceptance criteria
  13. If pass: APPROVED -> write next task -> WAITING_FOR_WORKER
  14. If fail: REVISION_NEEDED + specific feedback
  15. Push
  16. If milestone complete -> write report to CEO_INBOX.md
```

## 6.3 Escalation Flow

```
Worker sets BLOCKED:
  "Need Stripe webhook URL and signing secret. Not in PROJECT.md."

Coordinator reads BLOCKED:
  1. Can I resolve this myself? (check PROJECT.md, docs, code)
  2. If yes -> update COMM.md with answer -> WAITING_FOR_WORKER
  3. If no -> set ESCALATED_TO_CEO
  4. Write to CEO_INBOX.md:
     - What's blocked
     - Why
     - Options (if applicable)
     - Recommendation
  5. Push

CEO reads CEO_INBOX.md:
  6. Tells Coordinator the decision

Coordinator:
  7. Updates COMM.md with CEO's answer -> WAITING_FOR_WORKER
  8. Push
```

## 6.4 Rate Limit Handling

```
Worker detects rate limit:
  1. Set COMM.md -> RATE_LIMITED
  2. Add resume_after timestamp (30-60 min)
  3. Push

Coordinator reads RATE_LIMITED:
  4. Check: is this task urgent?
  5. If urgent + other worker has capacity -> reassign to other worker
  6. If not urgent -> wait for cooldown
  7. After cooldown -> check if worker session is alive
  8. If session died -> restart it
  9. Worker resumes -> reads COMM.md -> continues from last checkpoint
```

## 6.5 Priority Change

```
CEO -> Coordinator:
  "Drop IPOIQ. Client XYZ is priority."

Coordinator:
  1. Set IPOIQ COMM.md -> PAUSED
  2. Stop IPOIQ worker session
  3. Update REGISTRY.md: IPOIQ -> PAUSED, worker slot freed
  4. If client-xyz needs more workers -> assign freed slot
  5. Push
  6. Confirm to CEO
```

## 6.6 Worker Session Recovery

```
Coordinator (during round-robin loop):
  1. Check REGISTRY.md for active worker sessions
  2. For the current project in rotation:
     a. If COMM.md is IN_PROGRESS but last worker update >30min ago:
        - Attempt to resume session: claude -p "Resume work" --resume <session_id>
        - If resume fails -> launch fresh session, update session ID in REGISTRY.md
        - Worker reads COMM.md, sees IN_PROGRESS, continues from last git commit
  3. If repeated session failures (3+) -> ESCALATED_TO_CEO
```

## 6.7 Context Preparation

Before launching a worker session, the Coordinator prepares context files in the project's code repo so the worker has full situational awareness on startup.

```
Coordinator (before worker launch or new task assignment):
  1. cd into project code repo
  2. Write/update CLAUDE.md with:
     - Project name and overview
     - Tech stack (from PROJECT.md)
     - Coding conventions (linting rules, naming patterns, file structure)
     - Current milestone context (which milestone, progress so far)
     - Current task acceptance criteria (copied from COMM.md)
     - Reference to management repo COMM.md path for status updates
  3. Write/update MEMORY.md with:
     - Key decisions made during discovery phase
     - CEO preferences noted during discovery (e.g., "CEO prefers Tailwind over CSS modules")
     - Past revision feedback (summarized from REVIEW_LOG.md for this project)
     - Architecture decisions (e.g., "using app router not pages router", "SST v3 for infra")
  4. git add CLAUDE.md MEMORY.md
  5. git commit -m "chore: update worker context for [task name]"
  6. git push
  7. Return to management repo directory
```

**Why this matters:**
- Worker sessions are ephemeral — they have no memory of prior sessions
- CLAUDE.md gives the worker its "operating manual" for this specific project
- MEMORY.md gives the worker institutional knowledge that would otherwise be lost
- Both files are version-controlled, so the Coordinator can evolve them as the project progresses
