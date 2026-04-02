# 4. File Protocols

> Defines the format, ownership, and rules for each file type used in the management repo. These files are the communication protocol — there is no database or message queue.

---

## 4.1 CEO_INBOX.md

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

## 4.2 REGISTRY.md

Single source of truth maintained by Coordinator.

```markdown
# Company Registry

Last updated: 2026-04-02T16:30:00Z

## Rotation
Next check index: 2
Last checked: client-xyz at 2026-04-02T14:30:00Z

## Workers

### Employee 1 (Account 2)
| Slot | Project | Status | Current Task | Session ID |
|------|---------|--------|-------------|---------|
| 1 | client-xyz | IN_PROGRESS | Auth middleware tests | sess_abc123 |
| 2 | ipoiq | PAUSED | Agent 5 migration | — |
| 3 | — | AVAILABLE | — | — |

### Employee 2 (Account 3)
| Slot | Project | Status | Current Task | Session ID |
|------|---------|--------|-------------|---------|
| 1 | docproof | ESCALATED_TO_CEO | Rule builder export | sess_def456 |
| 2 | realestate-agent | WAITING_FOR_WORKER | RERA scraper tests | — |
| 3 | — | AVAILABLE | — | — |

## Project Priority (ordered)
1. client-xyz — HIGH (client deadline Friday)
2. docproof — HIGH (blocked on CEO decision)
3. realestate-agent — MEDIUM
4. ipoiq — LOW (paused)

## Queue (unassigned)
- cloudcorrect (milestone 3) — MEDIUM — needs 1 slot
```

## 4.3 PROJECT.md

Created by Coordinator from CEO's verbal brief.

```markdown
# Client XYZ — Customer Portal

## Overview
Customer-facing portal for XYZ Corp. Role-based dashboard with SSO.

## Client
XYZ Corp. Contact: [name]. Timezone: IST.

## Tech Stack
Next.js 15, TypeScript, Node.js, PostgreSQL, SST v3, AWS us-east-2 or us-west-2. 
As a note, always avoid us-east-1 as that's most congested region. 

## Code Repo
- Remote: git@github.com:appgambit/client-xyz.git
- Local path: /Users/dhaval/Documents/work/antigravity/client-xyz

## Constraints
- Azure AD SSO (OIDC)
- Deploy to us-east-2 or us-west-2. 
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

## 4.4 MILESTONES.md

Task breakdown created and maintained by Coordinator.

```markdown
# client-xyz — Milestones & Tasks

## Milestone 1: Auth + SSO (Target: April 3)

### Task 1: Project scaffolding ✅
- Setup Next.js 15, TypeScript strict, ESLint, Prettier
- SST v3 config for us-east-2
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

## 4.5 COMM.md — The Core Protocol

This is the active task communication between Coordinator and Worker. One per project.

```markdown
# COMM — client-xyz

## Status
IN_PROGRESS

## Assigned Worker
Employee 1

## Session ID
sess_abc123

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

## 4.6 REVIEW_LOG.md

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

## 4.7 MILESTONES_ARCHIVE.md

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

## 4.8 BRIEF.md

Written once by Coordinator during project discovery. Not updated after initial creation. Serves as the original source of truth for the CEO's input before interpretation.

```markdown
# client-xyz — Original Brief

Date: 2026-04-02
Source: Live session with CEO

## CEO's Input
We need a customer portal for XYZ Corp. They want SSO with their Azure AD,
role-based dashboards (admin, manager, viewer), and a report generation module.
Demo is Friday. They're on AWS us-east-2. Use Next.js + SST.
```
