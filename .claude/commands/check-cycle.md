Run one coordinator check cycle. Be MINIMAL with token usage.

Steps:
1. Read coordinator/REGISTRY.md — get the rotation index and next project name
2. If no active projects, respond "No active projects." and stop
3. Read that project's COMM.md — ONLY the Status and Timestamps sections (first 20 lines)
4. Based on status:
   - WAITING_FOR_WORKER or IN_PROGRESS or PAUSED: respond "Project {name}: {status}. No action needed." and stop
   - DONE_AWAITING_REVIEW: respond "Project {name}: ready for review. Run /project-status {name} to review."
   - BLOCKED: respond "Project {name}: BLOCKED. Run /project-status {name} for details."
   - RATE_LIMITED: respond "Project {name}: rate limited. No action."
5. Increment rotation index in REGISTRY.md
6. Do NOT read PROJECT.md, MILESTONES.md, REVIEW_LOG.md, or any other files
7. Do NOT run git pull or git push — unnecessary for local-only operation
8. Keep response under 3 lines