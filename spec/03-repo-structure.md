# 3. Management Repo Structure

> Defines the directory layout of the `ai-company` management repository — the single private Git repo through which all roles coordinate.

---

```
ai-company/                          <- Private Git repo
|
├── README.md                         System overview
├── SPEC.md                           Index to specification files
├── CEO_INBOX.md                      Coordinator -> CEO communication
|
├── spec/                             Specification documents
│   ├── 01-roles.md
│   ├── 02-infrastructure.md
│   ├── 03-repo-structure.md
│   ├── 04-file-protocols.md
│   ├── 05-state-machine.md
│   ├── 06-workflows.md
│   ├── 07-rules.md
│   ├── 08-bootstrap.md
│   └── 09-cost-and-future.md
|
├── coordinator/
│   ├── CLAUDE.md                     Coordinator operating manual
│   ├── REGISTRY.md                   All projects, workers, statuses, rotation
│   ├── DAILY_LOG.md                  Append-only daily summaries
│   └── hooks/
│       └── settings.json             Coordinator hook configuration
|
├── workers/
│   ├── employee-1/
│   │   └── CLAUDE.md                 Worker 1 role instructions
│   ├── employee-2/
│   │   └── CLAUDE.md                 Worker 2 role instructions
│   └── hooks/
│       └── settings.json             Worker hook configuration
|
├── scripts/
│   └── hooks/
│       ├── block-dangerous-commands.sh
│       └── block-interactive-commands.sh
|
├── docs/                             Supporting documentation
|
└── projects/
    ├── client-xyz/
    │   ├── PROJECT.md                 Project brief
    │   ├── BRIEF.md                   Original CEO brief (raw capture)
    │   ├── COMM.md                    Task protocol (Coordinator <-> Worker)
    │   ├── MILESTONES.md              Task breakdown (active milestones only)
    │   ├── MILESTONES_ARCHIVE.md      Completed milestones log
    │   ├── REVIEW_LOG.md              Review history
    │   ├── MEMORY.md                  Internal context (decisions, feedback, preferences)
    │   └── docs/                      Reference materials (SOW, requirements, wireframes)
    └── docproof/
        ├── PROJECT.md
        ├── BRIEF.md
        ├── COMM.md
        ├── MILESTONES.md
        ├── MILESTONES_ARCHIVE.md
        ├── REVIEW_LOG.md
        ├── MEMORY.md
        └── docs/
```
