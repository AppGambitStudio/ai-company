# APPGAMBIT AI Company — System Specification

> A $XXX/month AI-native software agency powered by Claude Code, Docker Sandboxes, and a Git-based coordination protocol.

---

## 1. Overview

APPGAMBIT AI Company is an autonomous AI workforce that manages software projects end-to-end. A human CEO provides high-level direction. An AI Coordinator handles all planning, assignment, review, and operational management. AI Workers execute development tasks inside isolated Docker sandboxes.

The entire system communicates through a single private Git repository — the **Management Repo**. There is no custom orchestration framework, no queue system, no database. Files and Git commits are the protocol.

---

## 2. Roles

### 2.1 Dhaval Nagar — Human CEO

**Responsibility:** Strategic direction, project intake, milestone approval, human-judgment decisions.

**Interactions:**
- Talks to APPGAMBIT AI (Coordinator) in natural language via one Claude Code session
- Reads CEO_INBOX.md for updates, escalations, and milestone reports
- Approves milestones, resolves escalations, reprioritizes projects
- Never touches operational files (COMM.md, REGISTRY.md) directly

**Decisions only the CEO makes:**
- "Start this new project"
- "Milestone approved / needs changes"
- "Reprioritize: project X is now urgent"
- "Add/remove a worker account"
- Ambiguous client requirements, budget decisions, scope changes

### 2.2 APPGAMBIT AI — AI Coordinator

**Account:** Anthropic Pro ($100/month), Account 1  
**Runtime:** Docker Sandbox, runs with `/loop` or equivalent persistent mode  
**Identity:** The CTO. Manages everything between CEO direction and worker execution.

**Responsibilities:**
- Convert CEO's verbal briefs into structured PROJECT.md
- Break milestones into sequenced, atomic tasks with acceptance criteria
- Maintain REGISTRY.md (single source of truth for all projects, workers, statuses)
- Assign tasks by writing COMM.md files
- Spin up / shut down / restart worker Docker sandboxes via bash
- Monitor worker progress (poll COMM.md files)
- Review completed work: read diffs, run tests, evaluate against acceptance criteria
- Approve or reject with specific feedback
- Manage rate limits and cooldown periods
- Escalate to CEO only when human judgment is required
- Write daily summaries and milestone reports to CEO_INBOX.md
- Handle worker reassignment when priorities change

**Standing loop (runs continuously):**
```
1. git pull (management repo)
2. For each active project:
   a. Read COMM.md
   b. If DONE_AWAITING_REVIEW → review code, run tests → APPROVED or REVISION_NEEDED
   c. If APPROVED → write next task → WAITING_FOR_WORKER
   d. If REVISION_NEEDED (3rd time) → ESCALATED_TO_CEO
   e. If RATE_LIMITED → note cooldown, reassign if urgent
   f. If STUCK (no progress >30min) → check sandbox health, restart if needed
   g. If WAITING_FOR_WORKER but sandbox not running → spin up sandbox
   h. If all milestone tasks APPROVED → compile milestone report → CEO_INBOX.md
   i. If CEO approves milestone:
      - Append completed milestone to MILESTONES_ARCHIVE.md (with code repo commit hash)
      - Remove completed milestone from MILESTONES.md
      - If next milestone not yet planned → break it down into tasks
      - Reset COMM.md with first task of new milestone → WAITING_FOR_WORKER
3. Check sandbox health: docker sandbox ls
4. Update REGISTRY.md
5. If escalations or milestone completions → update CEO_INBOX.md
6. git add, commit, push
7. Cooldown → repeat
```

### 2.3 Employee 1 & Employee 2 — AI Workers

**Accounts:** Anthropic Pro ($100/month each), Accounts 2 and 3  
**Runtime:** Docker Sandboxes, one per project assignment (max 3 per account)  
**Identity:** Full-stack developers. Execute tasks, write code, commit.

**Responsibilities:**
- Pull management repo, read COMM.md
- When status is WAITING_FOR_WORKER → set to IN_PROGRESS, begin work
- Write code in the project's code repo (separate from management repo)
- Run tests, lint, validate
- Commit to a feature branch with descriptive messages
- Update COMM.md: set status to DONE_AWAITING_REVIEW, write worker notes
- Push both repos (management + code)
- If rate-limited → set COMM.md to RATE_LIMITED with resume timestamp
- If blocked on missing information → set COMM.md to BLOCKED with specific question

**Self-sufficiency before blocking:**
- Exhaust alternatives before setting BLOCKED:
  1. Can I skip this and do the next sub-task? Continue with the rest, note the gap.
  2. Can I use a placeholder? Use clearly marked placeholders (e.g., `PLACEHOLDER_STRIPE_KEY`) and flag in worker notes.
  3. Can I find the answer in the codebase or docs? Check PROJECT.md, existing code, README files.
  4. Can I make a reasonable assumption and flag it? Document in worker notes for Coordinator validation.
- Only set BLOCKED when genuinely stuck — missing information that cannot be reasonably assumed or worked around.

**Non-interactive execution:**
- Workers run in unattended sandboxes. All commands must execute without human input.
- Always use non-interactive flags: `npm init -y`, `npx create-next-app --yes`, `apt-get install -y`, `yes | command`
- Use token-based Git URLs, never SSH that may prompt for passphrases
- Never run commands that require stdin input (interactive installers, `read` prompts, `git add -i`)
- If a command unexpectedly prompts for input:
  1. Kill the process
  2. Note the issue in COMM.md worker notes
  3. Find a non-interactive alternative
  4. If no alternative exists, set BLOCKED with specifics

**Standing loop (runs per project sandbox):**
```
1. git pull (management repo)
2. Read COMM.md
3. If WAITING_FOR_WORKER:
   a. Set status → IN_PROGRESS
   b. git commit + push status change
   c. Read task details and acceptance criteria
   d. cd into code repo, git pull, create/checkout feature branch
   e. Execute task
   f. Run tests
   g. git add, commit, push (code repo)
   h. Update COMM.md → DONE_AWAITING_REVIEW with worker notes
   i. git commit + push (management repo)
4. If REVISION_NEEDED:
   a. Read coordinator feedback
   b. Set status → IN_PROGRESS
   c. Fix issues based on feedback
   d. Repeat from 3f
5. If APPROVED or no pending work → idle, wait, re-poll
6. Cooldown → repeat
```

---

## 3. Infrastructure

### 3.1 Accounts

| Role | Account | Plan | Cost | Max Sessions |
|------|---------|------|------|-------------|
| APPGAMBIT AI (Coordinator) | Account 1 | Pro $100 | $100/mo | 1 (coordinator) + 2 spare |
| Employee 1 | Account 2 | Pro $100 | $100/mo | Up to 3 projects |
| Employee 2 | Account 3 | Pro $100 | $100/mo | Up to 3 projects |
| **Total** | | | **$300/mo** | **Up to 6 projects** |

### 3.2 Docker Sandboxes

Each Claude Code session runs inside a Docker Sandbox on the host machine (Mac or Linux).

**Coordinator sandbox:**
```bash
# Set in ~/.zshrc
export ANTHROPIC_API_KEY_COORD=sk-ant-...

# Launch
docker sandbox run appgambit-ai ~/company-repo -- \
  "You are APPGAMBIT AI Coordinator. Read coordinator/CLAUDE.md for your operating manual. Begin your loop."
```

**Worker sandboxes (spun up by Coordinator via bash):**
```bash
# Coordinator executes this when assigning a project
docker sandbox run emp1-clientxyz ~/projects/client-xyz -- \
  "You are Employee 1 assigned to client-xyz. Read /company/workers/employee-1/CLAUDE.md for role instructions. Read /company/projects/client-xyz/COMM.md for your current task. Begin work."
```

**Key properties:**
- `--dangerously-skip-permissions` is enabled by default in sandboxes (autonomous execution)
- Each sandbox is isolated — workers cannot interfere with each other
- Sandboxes are ephemeral — all persistent state lives in Git
- Host project directories are mounted into sandboxes

### 3.3 Git Repositories

**Management Repo** (`appgambit/ai-company` — private):
- Single source of truth for all coordination
- All roles read and write to this repo
- Every state change is a git commit → full audit trail

**Code Repos** (one per project, e.g., `appgambit/client-xyz`):
- Actual source code for each project
- Workers commit feature branches here
- Coordinator reads diffs/tests from here during review
- Completely separate from management repo

---

## 4. Management Repo Structure

```
ai-company/                          ← Private Git repo
│
├── README.md                         System overview
├── CEO_INBOX.md                      Coordinator → CEO communication
│
├── coordinator/
│   ├── CLAUDE.md                     Coordinator operating manual
│   ├── REGISTRY.md                   All projects, workers, statuses
│   └── DAILY_LOG.md                  Append-only daily summaries
│
├── workers/
│   ├── employee-1/
│   │   └── CLAUDE.md                 Worker 1 role instructions
│   └── employee-2/
│       └── CLAUDE.md                 Worker 2 role instructions
│
└── projects/
    ├── client-xyz/
    │   ├── PROJECT.md                 Project brief
    │   ├── BRIEF.md                   Original CEO brief (raw capture)
    │   ├── COMM.md                    Task protocol (Coordinator ↔ Worker)
    │   ├── MILESTONES.md              Task breakdown (active milestones only)
    │   ├── MILESTONES_ARCHIVE.md      Completed milestones log
    │   └── REVIEW_LOG.md              Review history
    └── docproof/
        ├── PROJECT.md
        ├── BRIEF.md
        ├── COMM.md
        ├── MILESTONES.md
        ├── MILESTONES_ARCHIVE.md
        └── REVIEW_LOG.md
```

---

## 5. File Protocols

### 5.1 CEO_INBOX.md

Written by Coordinator. Read by CEO. Append-only.

```markdown
---
## 2026-04-02

### Milestone Complete: client-xyz / Milestone 1 (Auth + SSO)
- 8 tasks completed, all tests passing
- Branch: milestone-1-auth (code repo)
- Deployed to: staging
- Summary: JWT auth with Azure AD OIDC integration, role-based middleware,
  refresh token rotation. 94% test coverage.
- **Action needed:** Review and approve to begin Milestone 2 (Dashboard).

### Escalation: docproof / Task 5 (Rule Builder export)
- Issue: Client wants PDF export but PROJECT.md only specifies CSV.
  Adding PDF requires a new dependency (puppeteer) and ~4 additional hours.
- Options: (A) CSV only as spec'd, (B) Add PDF export
- Recommendation: B — small effort, high client value
- **Action needed:** Your call.

### Daily Summary
- Employee 1: 3 tasks completed (client-xyz), 0 blocked
- Employee 2: 2 tasks completed (docproof), 1 escalated (above)
- Rate limits hit: Employee 1 at 14:30, resumed at 15:00
- Tomorrow's plan: client-xyz middleware tests, docproof rule builder UI
---
```

### 5.2 REGISTRY.md

Single source of truth maintained by Coordinator.

```markdown
# Company Registry

Last updated: 2026-04-02T16:30:00Z

## Workers

### Employee 1 (Account 2)
| Slot | Project | Status | Current Task | Sandbox |
|------|---------|--------|-------------|---------|
| 1 | client-xyz | IN_PROGRESS | Auth middleware tests | emp1-clientxyz |
| 2 | ipoiq | PAUSED | Agent 5 migration | emp1-ipoiq |
| 3 | — | AVAILABLE | — | — |

### Employee 2 (Account 3)
| Slot | Project | Status | Current Task | Sandbox |
|------|---------|--------|-------------|---------|
| 1 | docproof | ESCALATED_TO_CEO | Rule builder export | emp2-docproof |
| 2 | realestate-agent | WAITING_FOR_WORKER | RERA scraper tests | emp2-realestate |
| 3 | — | AVAILABLE | — | — |

## Project Priority (ordered)
1. client-xyz — HIGH (client deadline Friday)
2. docproof — HIGH (blocked on CEO decision)
3. realestate-agent — MEDIUM
4. ipoiq — LOW (paused)

## Queue (unassigned)
- cloudcorrect (milestone 3) — MEDIUM — needs 1 slot
```

### 5.3 PROJECT.md

Created by Coordinator from CEO's verbal brief.

```markdown
# Client XYZ — Customer Portal

## Overview
Customer-facing portal for XYZ Corp. Role-based dashboard with SSO.

## Client
XYZ Corp. Contact: [name]. Timezone: IST.

## Tech Stack
Next.js 15, TypeScript, Node.js, PostgreSQL, SST v3, AWS ap-south-1

## Code Repo
git@github.com:appgambit/client-xyz.git

## Constraints
- Azure AD SSO (OIDC)
- Deploy to ap-south-1
- Budget: ~40 hours equivalent
- Client demo: Friday April 4

## Milestones
1. Auth + SSO integration (deadline: April 3)
2. Dashboard with role-based views (deadline: April 7)
3. Report generation module (deadline: April 11)
4. UAT and handoff (deadline: April 14)

## Current State
Greenfield — repo initialized with Next.js starter.

## References
- Client requirements: /docs/requirements.pdf
- Wireframes: /docs/wireframes.pdf
- Similar project: /projects/abc-portal/
```

### 5.4 MILESTONES.md

Task breakdown created and maintained by Coordinator.

```markdown
# client-xyz — Milestones & Tasks

## Milestone 1: Auth + SSO (Target: April 3)

### Task 1: Project scaffolding ✅
- Setup Next.js 15, TypeScript strict, ESLint, Prettier
- SST v3 config for ap-south-1
- Acceptance: `npm run build` passes, deploys to dev
- Assigned: Employee 1 | Completed: April 2 09:30

### Task 2: Azure AD OIDC integration ✅
- NextAuth.js with Azure AD provider
- Token storage, session management
- Acceptance: Login flow works with test Azure AD tenant
- Assigned: Employee 1 | Completed: April 2 11:15

### Task 3: Auth middleware 🔄
- Role-based route protection
- Acceptance: Unauthenticated requests return 401, role mismatch returns 403, tests pass
- Assigned: Employee 1 | Status: IN_PROGRESS

### Task 4: Token refresh + error handling ⬜
- Silent refresh, expired session redirect
- Acceptance: Token refresh works, graceful error UI
- Assigned: — | Status: PENDING

...

## Milestone 2: Dashboard (Target: April 7)
(Not yet broken down — will be planned after Milestone 1 approval)
```

### 5.5 COMM.md — The Core Protocol

This is the active task communication between Coordinator and Worker. One per project.

```markdown
# COMM — client-xyz

## Status
IN_PROGRESS

## Assigned Worker
Employee 1

## Assigned Sandbox
emp1-clientxyz

## Current Task
Task 3: Auth middleware — role-based route protection

## Task Details
Implement middleware for Next.js API routes and pages:
- Read user role from session (admin, manager, viewer)
- Protect /api/* routes: return 401 if unauthenticated, 403 if role mismatch
- Protect pages: redirect to /unauthorized if role mismatch
- Use decorator pattern: withAuth(handler, { roles: ['admin'] })

## Acceptance Criteria
- [ ] withAuth wrapper works for API routes
- [ ] withAuth wrapper works for pages
- [ ] Tests: 401 for unauth, 403 for wrong role, 200 for correct role
- [ ] No changes to existing auth flow from Task 2
- [ ] All existing tests still pass

## Code Repo Branch
feature/task-3-auth-middleware

## Coordinator Notes
Priority: HIGH. Client demo Friday.
Reference Task 2 implementation for session structure.

## Worker Notes
Started 14:00. Reading Task 2 session structure.
withAuth API wrapper done, working on page-level protection now.

## Revision History
(none)

## Timestamps
- Task assigned: 2026-04-02T13:45:00Z
- Worker picked up: 2026-04-02T14:00:00Z
- Last worker update: 2026-04-02T14:35:00Z
```

### 5.6 REVIEW_LOG.md

Append-only history of all Coordinator reviews for the project.

```markdown
# Review Log — client-xyz

## Task 1: Project scaffolding
- Reviewed: 2026-04-02T09:45:00Z
- Verdict: APPROVED
- Notes: Clean setup. ESLint and Prettier configured correctly. Build passes.

## Task 2: Azure AD OIDC integration
- Reviewed: 2026-04-02T11:30:00Z
- Verdict: REVISION_NEEDED
- Feedback: Session callback doesn't persist user role from Azure AD claims.
  Need to map `roles` claim from ID token to session object in [...nextauth].ts.
- Re-reviewed: 2026-04-02T12:15:00Z
- Verdict: APPROVED
- Notes: Role mapping implemented correctly. Login flow verified.
```

### 5.7 MILESTONES_ARCHIVE.md

Written by Coordinator after CEO approves a milestone. Append-only.

```markdown
# client-xyz — Completed Milestones

## Milestone 1: Auth + SSO
Completed: 2026-04-03 | Approved by CEO: 2026-04-03
Code commit: abc1234 (branch: milestone-1-auth)
Tasks: 8 | Revisions: 2 | Escalations: 0

### Tasks
1. Project scaffolding — Completed April 2
2. Azure AD OIDC integration — Completed April 2 (1 revision)
3. Auth middleware — Completed April 2
4. Token refresh + error handling — Completed April 3

## Milestone 2: Dashboard
Completed: 2026-04-07 | Approved by CEO: 2026-04-08
Code commit: f7e2a91 (branch: milestone-2-dashboard)
Tasks: 5 | Revisions: 1 | Escalations: 0

### Tasks
1. Dashboard layout — Completed April 5
2. Admin view — Completed April 6
3. Manager view — Completed April 6
4. Viewer view — Completed April 7
5. Role-based sidebar — Completed April 7
```

### 5.8 BRIEF.md

Written once by Coordinator during project discovery. Not updated after initial creation. Serves as the original source of truth for the CEO's input before interpretation.

```markdown
# client-xyz — Original Brief

Date: 2026-04-02
Source: Live session with CEO

## CEO's Input
We need a customer portal for XYZ Corp. They want SSO with their Azure AD,
role-based dashboards (admin, manager, viewer), and a report generation module.
Demo is Friday. They're on AWS ap-south-1. Use Next.js + SST.
```

---

## 6. COMM.md State Machine

```
                         Coordinator
                         writes task
                              │
                              ▼
                    ┌───────────────────┐
                    │ WAITING_FOR_WORKER │
                    └────────┬──────────┘
                             │
                    Worker picks up
                             │
                             ▼
                    ┌───────────────────┐
              ┌────│    IN_PROGRESS     │────┐
              │    └───────────────────┘    │
              │                             │
         completes                     hits rate limit
              │                             │
              ▼                             ▼
   ┌─────────────────────┐      ┌──────────────────┐
   │ DONE_AWAITING_REVIEW │      │   RATE_LIMITED    │
   └──────────┬──────────┘      │ (auto-resumes)    │
              │                  └──────────────────┘
     Coordinator reviews
        │       │        │
        ▼       ▼        ▼
   APPROVED  REVISION  BLOCKED
        │    _NEEDED      │
        │       │         │
        ▼       ▼         ▼
   Next task  Worker   Coordinator
   assigned   fixes    decides:
        │       │     escalate or
        │       │     unblock
        ▼       │         │
   WAITING_     │    ESCALATED_
   FOR_WORKER   │    TO_CEO
                │         │
                │    CEO resolves
                │         │
                └─────────┘

   Special states:
   - PAUSED: Coordinator paused work (priority change)
   - CANCELLED: Task cancelled by CEO or Coordinator
   - MILESTONE_COMPLETE: All tasks in milestone approved
```

**Valid transitions:**

| From | To | Who |
|------|----|-----|
| WAITING_FOR_WORKER | IN_PROGRESS | Worker |
| IN_PROGRESS | DONE_AWAITING_REVIEW | Worker |
| IN_PROGRESS | RATE_LIMITED | Worker |
| IN_PROGRESS | BLOCKED | Worker |
| RATE_LIMITED | IN_PROGRESS | Worker (after cooldown) |
| DONE_AWAITING_REVIEW | APPROVED | Coordinator |
| DONE_AWAITING_REVIEW | REVISION_NEEDED | Coordinator |
| APPROVED | WAITING_FOR_WORKER | Coordinator (next task) |
| REVISION_NEEDED | IN_PROGRESS | Worker |
| BLOCKED | ESCALATED_TO_CEO | Coordinator |
| BLOCKED | WAITING_FOR_WORKER | Coordinator (if can resolve) |
| ESCALATED_TO_CEO | WAITING_FOR_WORKER | Coordinator (after CEO resolves) |
| Any active state | PAUSED | Coordinator |
| PAUSED | WAITING_FOR_WORKER | Coordinator |
| Any state | CANCELLED | Coordinator or CEO |

**Project Lifecycle (tracked in REGISTRY.md, separate from task states above):**

DISCOVERY → ACTIVE → COMPLETED

- DISCOVERY: Requirements gathering, no worker assigned. CEO ↔ Coordinator iterate on PROJECT.md.
- ACTIVE: Implementation in progress. Tasks follow the COMM.md state machine above.
- COMPLETED: All milestones approved and archived.
- PAUSED / CANCELLED: Can apply at any point after DISCOVERY.

---

## 7. Workflows

### 7.1 New Project Onboarding (Discovery Flow)

```
CEO → APPGAMBIT AI:
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

CEO ↔ Coordinator (N rounds):
  7. CEO answers questions, provides clarifications (live session or CEO_INBOX.md)
  8. Coordinator updates PROJECT.md, asks follow-up questions if needed
  9. Repeat until CEO approves the project plan

APPGAMBIT AI (Activation):
  10. Set project status → ACTIVE in REGISTRY.md
  11. Break Milestone 1 into tasks → write MILESTONES.md (3-5 milestones visible, ~4-5 tasks each)
  12. Write COMM.md with Task 1 → WAITING_FOR_WORKER
  13. Spin up worker sandbox:
      docker sandbox run {sandbox-name} ~/projects/{name} -- "{init prompt}"
  14. git commit + push
  15. Confirm to CEO: "Project {name} is active. {Worker} assigned. ETA: {date}."
```

### 7.2 Task Cycle (steady state)

```
Coordinator:
  1. Write task to COMM.md → WAITING_FOR_WORKER
  2. Push

Worker:
  3. Pull → detect WAITING_FOR_WORKER
  4. Set IN_PROGRESS → push
  5. Read task, create branch, implement
  6. Run tests
  7. Commit code (code repo) → push
  8. Set DONE_AWAITING_REVIEW + worker notes → push (management repo)

Coordinator:
  9. Pull → detect DONE_AWAITING_REVIEW
  10. Read diff from code repo
  11. Run tests (via bash into worker sandbox or fresh checkout)
  12. Evaluate against acceptance criteria
  13. If pass: APPROVED → write next task → WAITING_FOR_WORKER
  14. If fail: REVISION_NEEDED + specific feedback
  15. Push
  16. If milestone complete → write report to CEO_INBOX.md
```

### 7.3 Escalation Flow

```
Worker sets BLOCKED:
  "Need Stripe webhook URL and signing secret. Not in PROJECT.md."

Coordinator reads BLOCKED:
  1. Can I resolve this myself? (check PROJECT.md, docs, code)
  2. If yes → update COMM.md with answer → WAITING_FOR_WORKER
  3. If no → set ESCALATED_TO_CEO
  4. Write to CEO_INBOX.md:
     - What's blocked
     - Why
     - Options (if applicable)
     - Recommendation
  5. Push

CEO reads CEO_INBOX.md:
  6. Tells Coordinator the decision

Coordinator:
  7. Updates COMM.md with CEO's answer → WAITING_FOR_WORKER
  8. Push
```

### 7.4 Rate Limit Handling

```
Worker detects rate limit:
  1. Set COMM.md → RATE_LIMITED
  2. Add resume_after timestamp (30-60 min)
  3. Push

Coordinator reads RATE_LIMITED:
  4. Check: is this task urgent?
  5. If urgent + other worker has capacity → reassign to other worker
  6. If not urgent → wait for cooldown
  7. After cooldown → check if worker sandbox is alive
  8. If sandbox died → restart it
  9. Worker resumes → reads COMM.md → continues from last checkpoint
```

### 7.5 Priority Change

```
CEO → Coordinator:
  "Drop IPOIQ. Client XYZ is priority."

Coordinator:
  1. Set IPOIQ COMM.md → PAUSED
  2. Stop IPOIQ sandbox (docker sandbox stop)
  3. Update REGISTRY.md: IPOIQ → PAUSED, worker slot freed
  4. If client-xyz needs more workers → assign freed slot
  5. Push
  6. Confirm to CEO
```

### 7.6 Sandbox Health Recovery

```
Coordinator (during loop):
  1. Run: docker sandbox ls
  2. Compare against REGISTRY.md expected sandboxes
  3. If sandbox missing/crashed:
     a. Check COMM.md — was it IN_PROGRESS?
     b. Restart sandbox:
        docker sandbox run {name} ~/projects/{project} -- "{resume prompt}"
     c. Worker reads COMM.md, sees IN_PROGRESS, continues from last git commit
  4. If repeated crashes (3+) → ESCALATED_TO_CEO
```

---

## 8. Edge Cases & Rules

### 8.1 Quality Gate
- Coordinator rejects max 2 times with REVISION_NEEDED
- On 3rd failure → ESCALATED_TO_CEO with context:
  "Employee X failed task Y three times. Issue: [specific problem]. Worker may lack context or task may need re-scoping."

### 8.2 Conflict Resolution
- If both workers need to commit to management repo simultaneously, standard git conflict resolution applies
- Workers should pull before push, rebase if needed
- COMM.md files are per-project so conflicts are rare

### 8.3 Worker Capacity
- Each account supports max 3 concurrent sandbox sessions
- Coordinator never assigns more than 3 projects per worker
- If all slots full and new project arrives → queue it in REGISTRY.md, notify CEO

### 8.4 Context Loss
- Sandboxes are ephemeral. Workers lose in-memory context on restart.
- All state is in Git. Worker reads COMM.md and code repo on every restart.
- Feature branches in code repo serve as work checkpoints.
- COMM.md worker notes serve as context breadcrumbs.

### 8.5 Cooldown Strategy
- After each feature/task completion, 30-60 minute cooldown before next heavy task
- Coordinator manages cooldown by delaying next task assignment
- During cooldown, worker sandbox can be stopped to avoid accidental usage

### 8.6 Rolling Window Protocol

Working files must stay small enough for AI agents to parse reliably within context windows.

**MILESTONES.md:**
- Holds at most 3-5 milestones at any time (current + upcoming)
- Each milestone contains ~4-5 tasks (guideline, not hard limit)
- Milestones beyond the visible window are not yet broken down — Coordinator plans them when they enter the window
- Deciding whether to split a large project into separate projects is a CEO decision

**COMM.md:**
- Scoped to the current task only — when Coordinator writes a new task, previous task content is replaced
- Fully resets when a new milestone begins (after CEO approval)
- Historical task details live in REVIEW_LOG.md and git history

**Milestone Archive Flow (triggered after CEO approves a completed milestone):**
1. Coordinator appends completed milestone to MILESTONES_ARCHIVE.md (with code repo commit hash and branch)
2. Coordinator removes completed milestone from MILESTONES.md
3. If next milestone not yet broken down, Coordinator plans it now
4. Coordinator resets COMM.md with first task of new milestone → WAITING_FOR_WORKER
5. git commit + push

### 8.7 Non-Interactive Execution

Worker sandboxes run unattended. No human is available to provide stdin input.

**Rules:**
- All commands must use non-interactive flags (`-y`, `--yes`, `--non-interactive`)
- Git operations use token-based HTTPS URLs, not SSH
- Never run interactive commands (`git add -i`, `npm init` without `-y`, `read` prompts)
- If a command unexpectedly blocks for input: kill it, log in COMM.md, find non-interactive alternative
- If no non-interactive alternative exists: set COMM.md to BLOCKED with specifics

---

## 9. Getting Started — Bootstrap Steps

### Step 1: Accounts
- Create 3 Anthropic accounts with Pro plans ($100 each)
- Generate API keys for each
- Add to ~/.zshrc:
  ```bash
  export ANTHROPIC_API_KEY_COORD=sk-ant-...
  export ANTHROPIC_API_KEY_EMP1=sk-ant-...
  export ANTHROPIC_API_KEY_EMP2=sk-ant-...
  ```

### Step 2: Management Repo
- Create private repo: `appgambit/ai-company`
- Initialize with the directory structure from Section 4
- Write CLAUDE.md files for coordinator and workers (see companion files)

### Step 3: Docker Desktop
- Install Docker Desktop 4.58+
- Verify sandbox support: `docker sandbox --help`

### Step 4: First Run — Coordinator
```bash
docker sandbox run appgambit-ai ~/ai-company -- \
  "You are APPGAMBIT AI. Read coordinator/CLAUDE.md. Begin your coordination loop."
```

### Step 5: First Project
- Talk to Coordinator: give it a project brief
- Coordinator sets everything up, spins up first worker sandbox
- Verify the loop works end-to-end with a simple task

### Step 6: Scale
- Add second project, verify parallel execution
- Add second worker, verify multi-worker coordination
- Test edge cases: rate limits, escalations, priority changes

---

## 10. Cost Analysis

| Item | Monthly Cost |
|------|-------------|
| Anthropic Account 1 (Coordinator) | $100 |
| Anthropic Account 2 (Worker) | $100 |
| Anthropic Account 3 (Worker) | $100 |
| Docker Desktop | $0 (included) |
| GitHub Private Repo | $0 (free tier) |
| Host Machine | $0 (existing Mac/Linux) |
| **Total** | **$300/month** |

**Capacity:** Up to 6 concurrent projects, with autonomous task execution, code review, and progress reporting.

**Comparison:** A single junior developer costs $1,500-3,000/month in India. This system provides 2 full-time AI workers with a coordinator for 10-20% of that cost, running 24/7 with breaks only for rate limit cooldowns.

---

## 11. Future Extensions

- **GitHub Webhooks:** Trigger coordinator loop on push events (event-driven instead of polling)
- **Slack Integration:** CEO_INBOX.md updates → Slack webhook for mobile notifications
- **PR-based Milestones:** Coordinator creates GitHub PRs for milestone reviews. CEO approves via PR merge.
- **GitHub Issues for Escalations:** Coordinator creates issues. CEO responds in issue. Coordinator reads response.
- **Notion Dashboard:** Secondary sync for visual project board (git remains source of truth)
- **4th Account:** Scale to 3 workers (9 projects) for $400/month
- **Specialized Workers:** Instead of full-stack, assign workers by specialty (frontend, backend, infra)
- **Inter-project Dependencies:** Coordinator manages cross-project blocking (project A needs API from project B)

---

*Spec version: 1.1*
*Last updated: 2026-04-02*
*Author: Dhaval Nagar + Claude (APPGAMBIT AI Company design session)*
*Amendment: Rolling window protocol, discovery phase, worker autonomy (v1.1)*
