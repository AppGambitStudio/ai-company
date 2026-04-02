# 5. COMM.md State Machine

> Defines the valid states, transitions, and lifecycle for task communication (COMM.md) and overall project progression. The state machine is the heartbeat of the system — every action by Coordinator or Worker is a state transition.

---

## 5.1 Task State Diagram

```
                         Coordinator
                         writes task
                              |
                              v
                    +-------------------+
                    | WAITING_FOR_WORKER |
                    +--------+----------+
                             |
                    Worker picks up
                             |
                             v
                    +-------------------+
              +----+    IN_PROGRESS     +----+
              |    +-------------------+    |
              |                             |
         completes                     hits rate limit
              |                             |
              v                             v
   +---------------------+      +------------------+
   | DONE_AWAITING_REVIEW |      |   RATE_LIMITED    |
   +----------+----------+      | (auto-resumes)    |
              |                  +------------------+
     Coordinator reviews
        |       |        |
        v       v        v
   APPROVED  REVISION  BLOCKED
        |    _NEEDED      |
        |       |         |
        v       v         v
   Next task  Worker   Coordinator
   assigned   fixes    decides:
        |       |     escalate or
        |       |     unblock
        v       |         |
   WAITING_     |    ESCALATED_
   FOR_WORKER   |    TO_CEO
                |         |
                |    CEO resolves
                |         |
                +---------+

   Special states:
   - PAUSED: Coordinator paused work (priority change)
   - CANCELLED: Task cancelled by CEO or Coordinator
   - MILESTONE_COMPLETE: All tasks in milestone approved
```

## 5.2 Valid Transitions

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

## 5.3 Project Lifecycle

Tracked in REGISTRY.md, separate from the task states above:

```
DISCOVERY -> ACTIVE -> COMPLETED
```

- **DISCOVERY:** Requirements gathering, no worker assigned. CEO and Coordinator iterate on PROJECT.md.
- **ACTIVE:** Implementation in progress. Tasks follow the COMM.md state machine above.
- **COMPLETED:** All milestones approved and archived.
- **PAUSED / CANCELLED:** Can apply at any point after DISCOVERY.
