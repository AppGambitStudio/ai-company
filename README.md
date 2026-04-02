# APPGAMBIT AI Company

An AI-native software agency powered by Claude Code CLI. A human CEO provides direction, an AI Coordinator manages everything, and AI Workers execute development tasks autonomously.

**Cost:** $100-300/month depending on number of accounts.

**Capacity:** Up to 6 concurrent projects with 2 AI workers.

---

## Quick Start

### 1. Prerequisites

- macOS or Linux
- Claude Code CLI v2.1.72+ (`claude --version`)
- Authenticated Claude account (`claude` opens a session)
- `jq` installed (`brew install jq`)
- `git` configured with push access to your repos
- `tmux` for persistent sessions (`brew install tmux`)

### 2. Initialize (first time only)

```bash
cd /path/to/ai-company

# Verify hook scripts are executable
chmod +x scripts/hooks/*.sh

# Verify runtime files exist (CEO_INBOX.md, REGISTRY.md, DAILY_LOG.md)
# If missing, see docs/SETUP.md for templates
```

### 3. Start the Coordinator

```bash
# Open a persistent terminal session
tmux new-session -s coordinator

# Navigate to the management repo
cd /path/to/ai-company

# Launch Claude Code
claude --permission-mode acceptEdits
```

Paste this as your first message to the Coordinator:

```
You are APPGAMBIT AI Coordinator. Read coordinator/CLAUDE.md for your operating manual. Read CEO_CONFIG.md for CEO preferences. Read coordinator/REGISTRY.md to check current state. Begin your startup sequence.
```

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
- **If Coordinator crashes:** Restart with Step 3. It reads REGISTRY.md to rebuild state.

---

## How It Works

```
CEO (you)
  │
  ├── Gives direction via live session or Channel (Telegram/Discord)
  ├── Reads CEO_INBOX.md for updates and escalations
  ├── Approves milestones, resolves escalations
  │
  ▼
Coordinator (AI — runs as Claude Code session)
  │
  ├── Converts briefs into PROJECT.md
  ├── Breaks milestones into tasks (MILESTONES.md)
  ├── Assigns tasks via COMM.md
  ├── Reviews code, approves or rejects
  ├── Launches workers via `claude -p` headless mode
  ├── Reports to CEO via CEO_INBOX.md + Channel
  │
  ▼
Workers (AI — run as headless `claude -p` processes)
  │
  ├── Read COMM.md for task assignment
  ├── Write code in the project's code repo
  ├── Run tests, commit to feature branch
  ├── Update COMM.md when done
  └── One session per project, subagents for parallelism
```

**Communication protocol:** Git commits on a private management repo. Every state change is a commit. No database, no queue, no custom framework.

---

## Repo Structure

```
ai-company/
├── README.md                 ← You are here
├── SPEC.md                   ← System spec index
├── CEO_CONFIG.md             ← Your management preferences (customize this)
├── CEO_INBOX.md              ← Coordinator → CEO communication
│
├── spec/                     ← System specification (the engine)
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
├── coordinator/              ← Coordinator operating files
│   ├── CLAUDE.md             ← Coordinator's operating manual
│   ├── REGISTRY.md           ← Worker/project status registry
│   ├── DAILY_LOG.md          ← Daily summaries
│   └── hooks/settings.json
│
├── workers/                  ← Worker operating files
│   ├── employee-1/CLAUDE.md
│   ├── employee-2/CLAUDE.md
│   └── hooks/settings.json
│
├── scripts/hooks/            ← Guardrail scripts
│   ├── block-dangerous-commands.sh
│   ├── block-interactive-commands.sh
│   └── validate-comm-update.sh
│
├── projects/                 ← One subdirectory per project
│   └── {project-name}/
│       ├── PROJECT.md
│       ├── BRIEF.md
│       ├── COMM.md
│       ├── MILESTONES.md
│       ├── MILESTONES_ARCHIVE.md
│       └── REVIEW_LOG.md
│
└── docs/
    ├── SETUP.md              ← Detailed setup guide
    └── superpowers/          ← Design docs and plans
```

---

## Customization

Edit `CEO_CONFIG.md` to customize:
- **Communication:** notification frequency, channel preference, escalation style
- **Decision authority:** what the Coordinator can decide vs must escalate
- **Code review standards:** test requirements, quality bar, max revisions
- **Working rules:** cooldown, loop interval, branch strategy, commit style
- **Dos and Don'ts:** your specific rules for how the team operates

The Coordinator reads CEO_CONFIG.md on every startup and adjusts its behavior. No code changes needed.

---

## Documentation

| Document | Purpose |
|----------|---------|
| `SPEC.md` | System specification index (links to `spec/` files) |
| `CEO_CONFIG.md` | Your management preferences |
| `coordinator/CLAUDE.md` | Coordinator's full operating manual |
| `workers/employee-*/CLAUDE.md` | Worker operating manuals |
| `docs/SETUP.md` | Detailed first-time setup guide |
| `spec/06-workflows.md` | All workflows (onboarding, task cycle, escalation, etc.) |
| `spec/07-rules.md` | All rules and edge cases |

---

*Version: 1.2 | Last updated: 2026-04-02*
