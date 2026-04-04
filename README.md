# AI Company

An AI-native software agency powered by Claude Code CLI. A human CEO provides direction, an AI Coordinator manages everything, and AI Workers execute development tasks autonomously.

**Cost:** $100-300/month depending on number of accounts.

**Capacity:** Up to 6 concurrent projects with 2 AI workers.

---

## Why This Exists

Even with a lot of AI tools and automation, I am facing constant context switching due to multiple projects, across clients and varying requirements and schedule. The bottleneck was never the code, it was the management overhead. Keeping track of what's in progress, what's blocked, what needs review, what the client said last Tuesday. Every time you switched projects, you would lose 20-30 minutes (or more) just rebuilding context.

I thought of building a middle layer, something that can hold all the project context, coordinate work, and let me stay at the high-level instead of drowning in individual task management. Not a project management tool with dashboards and notifications, but something that can actually *do the work* based on given instructions and context (milestones and tasks).

The Claude Code ecosystem made this viable. Claude Code CLI runs autonomously in the terminal, reads project context from `CLAUDE.md` files, executes multi-step tasks with subagents, and maintains state across sessions. The skills system, permission hooks, and `tmux` integration mean you can wire up a persistent AI team that operates on markdown files — no database, no custom framework, no infrastructure to maintain.

Yes, the Coordinator layer burns more tokens than just pointing Claude at a project and saying "build this." But it creates something valuable in return: a complete paper trail. Every task assignment, every code review, every escalation, every decision is captured in structured markdown files. When you come back to a project after a week, the context is *there*, in COMM.md, MILESTONES.md, REVIEW_LOG.md. The AI reads it and picks up exactly where it left off.

In the age of agentic AI, markdown files can become an effective company operating model. No web app, no workflow engine, just structured documents in a git repo that teach AI agents how to operate. This project takes that idea and applies it to running a software development team.

---

## Quick Start

### 1. Prerequisites

- macOS or Linux
- Claude Code CLI v2.1.89+ (`claude --version`)
- Authenticated Claude account (`claude` opens a session)
- `jq` installed (`brew install jq`)
- `git` configured with push access to your repos
- `tmux` for persistent sessions (`brew install tmux`)

### 2. Clone and Initialize

```bash
git clone https://github.com/AppGambitStudio/ai-company.git
cd ai-company

# Copy runtime files from templates
cp CEO_CONFIG.template.md CEO_CONFIG.md        # customize with your preferences
cp CEO_INBOX.template.md CEO_INBOX.md
cp coordinator/REGISTRY.template.md coordinator/REGISTRY.md
cp coordinator/DAILY_LOG.template.md coordinator/DAILY_LOG.md

# Create projects directory
mkdir -p projects

# Verify hook scripts are executable
chmod +x scripts/hooks/*.sh
```

### 3. Start the Coordinator

```bash
./scripts/start.sh          # default: 15m check-cycle interval
./scripts/start.sh 5        # or set custom interval in minutes
```

This automatically:
- Launches the Coordinator in a tmux session
- Sends the startup prompt (reads state, reports summary, waits for CEO)
- Starts the external check-cycle loop

To stop everything: `./scripts/stop.sh`

### 4. Onboard a Project

Once the Coordinator is running, give it a project brief:

```
New project: [describe what you want built — tech stack, requirements, constraints, deadline]
```

The Coordinator will:
1. Create project files (BRIEF.md, PROJECT.md, COMM.md, MILESTONES.md)
2. Ask you clarifying questions (discovery phase)
3. Once you approve, break down Milestone 1 into tasks
4. Launch a worker to start building

### 5. Monitor

```bash
# Check CEO inbox for updates
cat CEO_INBOX.md

# Check a project's status
cat projects/{project-name}/COMM.md

# Check worker registry
cat coordinator/REGISTRY.md

# Reattach to Coordinator
tmux attach -t coordinator
```

### 6. Detach / Resume

- **Detach Coordinator:** `Ctrl+B` then `D` (tmux detach)
- **Reattach:** `tmux attach -t coordinator`
- **If Coordinator crashes:** Run `./scripts/start.sh` again. It reads REGISTRY.md to rebuild state.

### 7. Slash Commands

Use these in the Coordinator session for quick operations:

**Monitoring:**

| Command | What it does |
|---------|-------------|
| `/status` | Overall system summary |
| `/employees` | Worker assignment table |
| `/inbox` | CEO inbox with pending actions |
| `/projects` | All projects with status |
| `/project-status {name}` | Specific project's current task and COMM.md |
| `/milestones {name}` | Milestone progress for a project |
| `/review-log {name}` | Review history for a project |
| `/daily-log` | Latest daily summary |

**Project Management:**

| Command | What it does |
|---------|-------------|
| `/new-project {name} {brief}` | Onboard a new greenfield project (discovery flow) |
| `/onboard-existing {name} {path}` | Onboard an existing project with code history |
| `/assign-task {project} {task}` | Write task to COMM.md and launch worker |
| `/launch-worker {project}` | Launch worker for a project with pending task |
| `/pause-project {name}` | Temporarily pause, free worker slot |
| `/close-project {name}` | Archive and remove from active management |

**System Operations:**

| Command | What it does |
|---------|-------------|
| `/check-cycle` | Force one round-robin check now (don't wait for timer) |
| `/check-loop` | Verify loop is running, restart if dead |
| `/check-usage` | Check rate limit history and capacity |
| `/sync-registry` | Reconcile REGISTRY.md against actual project state |

### 8. Example Conversations

Here's what a typical day looks like in the Coordinator session:

**Starting up and checking status:**
```
> /status

Coordinator online.
- mrv-prototype: ACTIVE, Milestone 2 in progress, Task 7 assigned to Employee 1
- presentify: PAUSED, awaiting CEO priorities
- Employee 1: working on mrv-prototype (Task 7)
- Employee 2: AVAILABLE
Waiting for CEO instructions.

> /milestones mrv-prototype

Milestone 2: Core MRV Pipeline (5 tasks)
  Task 6: API endpoints         — APPROVED
  Task 7: Phase 1 Gap Closure   — IN_PROGRESS
  Task 8: Data validation       — NOT_STARTED
  Task 9: Report generation     — NOT_STARTED
  Task 10: Integration tests    — NOT_STARTED
```

**Onboarding a new project:**
```
> /new-project client-portal A client-facing portal for viewing project status and invoices.
  Tech stack: Next.js, PostgreSQL, SST on AWS.

Starting discovery for client-portal...
I have a few questions before we proceed:
1. Authentication — SSO, magic link, or password-based?
2. Invoice data — coming from an existing system or built from scratch?
3. Target users — how many concurrent users expected?

> SSO with Google, invoices from QuickBooks API, ~50 users

Got it. Creating project files...
- projects/client-portal/PROJECT.md ✓
- projects/client-portal/MILESTONES.md ✓ (3 milestones planned)
- projects/client-portal/COMM.md ✓

Milestone 1: Auth + Dashboard Shell (4 tasks)
Ready to assign Task 1 to a worker. Proceed?

> yes

Launching Employee 2 on client-portal, Task 1: Google SSO integration...
```

**Onboarding from an existing SOW or spec:**
```
> /new-project analytics-dashboard Real-time analytics dashboard for a client.
  I've dropped the SOW and wireframes in projects/analytics-dashboard/docs/

Reading docs/...
- SOW.pdf: 12 requirements across 3 phases
- wireframes.pdf: 8 screens
- api-spec.yaml: 15 endpoints

Phase 1 maps to Milestone 1 (5 tasks), Phase 2 to Milestone 2 (4 tasks), Phase 3 to Milestone 3 (3 tasks).

A few gaps I noticed in the SOW:
1. No mention of auth — should this sit behind the client's existing SSO?
2. "Real-time" — WebSocket push or polling interval?

> Behind their SSO, and WebSocket for real-time updates

Updated PROJECT.md. Ready to start Milestone 1?
```

**Onboarding a pre-existing project:**
```
> /onboard-existing mobile-app /Users/dhaval/projects/mobile-app

Scanning existing codebase...
- React Native + Expo, TypeScript
- 47 components, 12 screens, REST API layer
- 68% test coverage, last commit 2 weeks ago
- No CLAUDE.md found — I'll create one

Project files created. Based on the code and git history, here's what I see:
- Auth and core navigation are complete
- Payment integration is half-done (Stripe SDK imported but not wired up)
- No push notifications yet

Want me to plan milestones from here, or do you have specific priorities?

> Focus on finishing payments first, then push notifications

Milestone 1: Complete Payment Integration (4 tasks)
Milestone 2: Push Notifications (3 tasks)
Ready to assign Task 1?
```

**Reviewing completed work:**
```
> /inbox

### Task Complete: mrv-prototype / Task 7
- All acceptance criteria met, tests passing
- Branch: feature/task-7-phase1-gaps
- Action needed: Review the code review results below, or I can proceed to Task 8.

> proceed to Task 8

Assigning Task 8 (Data validation) to Employee 1...
Task written to COMM.md, worker launched.
```

**Handling escalations:**
```
> /inbox

### Escalation: client-portal / Task 2
- Worker failed 3 times on QuickBooks API integration
- Error: OAuth token refresh not working with sandbox credentials
- Action needed: Verify QuickBooks sandbox API keys are correct

> The sandbox keys expired. Here are the new ones: [keys].
  Update the .env in the client-portal repo and retry.

Updating .env and relaunching worker on Task 2...
```

**End of day:**
```
> /daily-log

Daily Summary — 2026-04-03
- mrv-prototype: Tasks 7-8 completed, Task 9 in progress
- client-portal: Task 1 approved, Task 2 in progress (was blocked, now resolved)
- Revisions: 1 (mrv-prototype Task 8, missing edge case test)
- Escalations: 1 (client-portal QuickBooks keys)
- Tomorrow: Task 9 + Task 2 should complete, queue Task 10 and Task 3

> Looks good. Pause client-portal for the weekend, keep mrv-prototype running.

/pause-project client-portal
Paused. Employee 2 freed. mrv-prototype continues with Employee 1.
```

---

## Architecture

```
+-----------------------------------------------------------------------------------+
|                              HOST MACHINE (Mac/Linux)                             |
|                                                                                   |
|  +------------------+    CEO_CONFIG.md     +----------------------------------+   |
|  |    HUMAN CEO     |    CEO_INBOX.md      |        AI COORDINATOR            |   |
|  |                  |<-------------------->|     (Claude Code CLI session)    |   |
|  |  - Direction     |                      |                                  |   |
|  |  - Approvals     |                      |  - Runs in tmux (persistent)     |   |
|  |  - Escalations   |                      |  - External check-cycle loop     |   |
|  +------------------+                      |  - Reads coordinator/CLAUDE.md   |   |
|                                            |  - Reads CEO_CONFIG.md           |   |
|                                            +--+----------+-------------------+    |
|                                               |          |                        |
|                              launches via     |          |  launches via          |
|                              claude -p        |          |  claude -p             |
|                                               |          |                        |
|                   +---------------------------+          +-------------------+    |
|                   |                                                          |    |
|                   v                                                          v    |
|  +-------------------------------+              +-------------------------------+ |
|  |        AI WORKER 1            |              |        AI WORKER 2            | |
|  |   (headless claude -p)        |              |   (headless claude -p)        | |
|  |                               |              |                               | |
|  |  - bypassPermissions mode     |              |  - bypassPermissions mode     | |
|  |  - hooks for guardrails       |              |  - hooks for guardrails       | |
|  |  - one session per project    |              |  - one session per project    | |
|  |  - subagents for parallelism  |              |  - subagents for parallelism  | |
|  +-------+---+-------------------+              +-------+---+-------------------+ |
|          |   |                                          |   |                     |
|          |   |  reads/writes                            |   |  reads/writes       |
|          |   |                                          |   |                     |
+----------|---|------------------------------------------|---|---------------------+
           |   |                                          |   |
           v   v                                          v   v
+-------------------+  +-------------------+  +-------------------+
| MANAGEMENT REPO   |  |  CODE REPO A      |  |  CODE REPO B      |
| (ai-company/)     |  |  (project-a/)     |  |  (project-b/)     |
|                   |  |                   |  |                   |
| - COMM.md (x N)   |  | - Source code     |  | - Source code     |
| - REGISTRY.md     |  | - Tests           |  | - Tests           |
| - CEO_INBOX.md    |  | - Feature branches|  | - Feature branches|
| - MILESTONES.md   |  | - CLAUDE.md       |  | - CLAUDE.md       |
| - PROJECT.md      |  | - MEMORY.md       |  | - MEMORY.md       |
| - REVIEW_LOG.md   |  |                   |  |                   |
+-------------------+  +-------------------+  +-------------------+
        |                       |                       |
        +---------- all repos on Git (public/private) ------+
```

### Communication Flow

```
CEO -----> Coordinator -----> Worker
     brief      COMM.md         code
     approve    (task)          (feature branch)
     escalate
                                    |
CEO <----- Coordinator <----- Worker
     CEO_INBOX   REVIEW_LOG    COMM.md
     (md file)   (verdict)     (DONE_AWAITING_REVIEW)
```

### State Machine (per task)

```
WAITING_FOR_WORKER --> IN_PROGRESS --> DONE_AWAITING_REVIEW --> APPROVED --> next task
                           |                                       |
                           +--> RATE_LIMITED (auto-resumes)         +--> REVISION_NEEDED
                           |                                              (worker fixes)
                           +--> BLOCKED --> ESCALATED_TO_CEO
```

### Round-Robin Loop (External)

The check-cycle loop runs as a separate process (`scripts/coordinator-loop.sh`), not inside the Coordinator session:

```
Every N minutes (default 15):
  Is Coordinator idle? --> Send /check-cycle --> REGISTRY.md --> pick project --> read COMM.md --> process
                                                                     |
                                                                rotate to next
```

Can be paused (`touch /tmp/coordinator-loop-pause`) and resumed (`rm /tmp/coordinator-loop-pause`).

### Merge Strategy

- Workers develop on feature branches (`feature/task-{N}-{description}`)
- Feature branches are merged to main on **CEO approval** (typically at milestone completion)
- Coordinator never merges to main without CEO say-so

**Protocol:** Markdown files on a management repo. Every state change is a file update. No database, no queue, no custom framework.

---

## Repo Structure

```
ai-company/
├── README.md                 ← You are here
├── LICENSE
├── SPEC.md                   ← System spec index
├── CEO_CONFIG.md             ← Your management preferences (gitignored, from template)
├── CEO_CONFIG.template.md    ← Template for CEO preferences
├── CEO_INBOX.md              ← Coordinator → CEO communication (gitignored)
├── CEO_INBOX.template.md     ← Template for CEO inbox
│
├── .claude/
│   ├── commands/             ← Slash commands (18 commands: /status, /inbox, etc.)
│   ├── skills/               ← Coordinator skills (review-code, launch-worker-prompts, etc.)
│   └── settings.local.json   ← Claude Code settings and hooks
│
├── coordinator/              ← Coordinator operating files
│   ├── CLAUDE.md             ← Coordinator's operating manual
│   ├── REGISTRY.md           ← Worker/project status registry (gitignored)
│   ├── REGISTRY.template.md
│   ├── DAILY_LOG.md          ← Daily summaries (gitignored)
│   ├── DAILY_LOG.template.md
│   └── hooks/settings.json
│
├── workers/                  ← Worker operating files
│   ├── employee-1/CLAUDE.md
│   ├── employee-2/CLAUDE.md
│   └── hooks/settings.json
│
├── scripts/
│   ├── start.sh              ← Start Coordinator + check-cycle loop
│   ├── stop.sh               ← Stop all sessions
│   ├── coordinator-loop.sh   ← External check-cycle loop
│   └── hooks/                ← Guardrail scripts
│       ├── block-dangerous-commands.sh
│       ├── block-interactive-commands.sh
│       └── validate-comm-update.sh
│
├── projects/                 ← One subdirectory per project (gitignored)
│   └── {project-name}/
│       ├── PROJECT.md        ← Full project spec
│       ├── BRIEF.md          ← Initial project brief
│       ├── COMM.md           ← Current task communication
│       ├── MILESTONES.md     ← Active milestones and tasks
│       ├── MILESTONES_ARCHIVE.md
│       ├── REVIEW_LOG.md     ← Code review history
│       ├── MEMORY.md         ← Project-specific context for workers
│       └── docs/             ← SOWs, wireframes, specs from CEO
│
├── spec/                     ← System specification
│   ├── 01-roles.md
│   ├── 02-infrastructure.md
│   ├── 03-repo-structure.md
│   ├── 04-file-protocols.md
│   ├── 05-state-machine.md
│   ├── 06-workflows.md
│   ├── 07-rules.md
│   ├── 08-bootstrap.md
│   └── 09-cost-and-future.md
│
└── docs/
    └── SETUP.md              ← Detailed setup guide
```

---

## Customization

Edit `CEO_CONFIG.md` to customize:
- **Communication:** notification frequency, channel preference, escalation style
- **Decision authority:** what the Coordinator can decide vs must escalate
- **Code review standards:** test requirements, quality bar, max revisions
- **Working rules:** cooldown, loop interval, branch strategy, commit style
- **Dos and Don'ts:** your specific rules for how the team operates

The Coordinator reads CEO_CONFIG.md when it needs to check preferences. No code changes needed.

---

## Current Caveats

- **Single machine only** — Coordinator and all workers run on the same machine, sharing CPU and Claude API rate limits. True parallelism is limited.
- **Shared account** — Currently testing with 1 Claude account for both Coordinator and workers. Workers and Coordinator share the same rate limit.
- **No dashboard** — Monitoring requires `tmux attach` or slash commands. No web UI or push notifications yet.
- **No cross-project dependencies** — Projects are fully independent. No way to express "Project B depends on Project A's API."

## Future Plans

- **Multi-machine workers** — Launch workers on separate machines via SSH, each with its own Claude account and rate limits
- **Dedicated worker accounts** — Separate Claude accounts ($100/mo each) for true parallel execution
- **Status dashboard** — Web UI or Slack/Telegram notifications for real-time visibility without terminal access
- **Cross-project dependencies** — Coordinator tracks inter-project blockers and sequences work accordingly

---

## FAQ

**How does this help if I can already use Claude Code directly on my projects?**

You can — and for a single project, that works fine. The problem starts when you're managing 3-6 projects simultaneously. Each time you switch projects, you lose context. What was the last task? What's the current branch? What did the code review say? With AI Company, the Coordinator holds all of that context in structured markdown files. You give high-level direction ("finish the payment integration, then start on notifications") and the system handles task breakdown, worker assignment, code review, and progress tracking. You stay at the strategic level instead of manually managing each session.

**Why use Claude Pro/Max login sessions instead of the API?**

Three reasons:

1. **Cost predictability.** A Claude Pro account is $20/month (Max is $100 or $200) with generous usage. API costs for the same workload — multiple long-running coding sessions with large context windows — would be significantly higher and unpredictable. For an always-on dev team running multiple projects, flat-rate billing is far more practical.

2. **Claude Code CLI features.** The CLI provides tools that the raw API doesn't — persistent sessions, `tmux` integration, `CLAUDE.md` auto-loading, slash commands, skills, permission hooks, and subagent orchestration. These are the building blocks that make the Coordinator and Worker system possible without custom infrastructure.

**Can I use this with other AI models or tools?**

The architecture (markdown files, git-based state, coordinator/worker pattern) is model-agnostic. But the implementation relies heavily on Claude Code CLI features — `CLAUDE.md` auto-loading, skills, permission modes, `tmux send-keys` for session management. Adapting it to another tool would require replacing the CLI integration layer.

**How many projects can this handle?**

It depends on the volume of work. With a single Claude account (shared Coordinator + Worker), couple of projects with one active at a time.

**What happens if the Coordinator or a Worker crashes?**

The system is crash-resilient by design. All state lives in markdown files on disk, not in memory. Run `./scripts/start.sh` to restart the Coordinator — it reads `REGISTRY.md` and picks up where it left off. Workers can be relaunched with a RESUME prompt that checks git history and COMM.md to continue from the last checkpoint.

---

## Documentation

| Document | Purpose |
|----------|---------|
| `CEO_CONFIG.md` | Your management preferences (copy from template) |
| `coordinator/CLAUDE.md` | Coordinator's operating manual |
| `workers/employee-*/CLAUDE.md` | Worker operating manuals |
| `.claude/commands/` | All slash commands available in the Coordinator session |
| `.claude/skills/` | Coordinator skills (code review, worker launch, etc.) |
| `docs/SETUP.md` | Detailed first-time setup guide |
| `SPEC.md` → `spec/` | Full system specification (architecture, workflows, rules) |

---

*Version: 1.5 | Last updated: 2026-04-04*
