# Claude Code Features Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Amend SPEC.md v1.1 → v1.2 with Claude Code native features (loop, channels, headless mode, hooks, permission modes, subagents) and create the hook scripts.

**Architecture:** SPEC.md section edits + two new bash scripts for worker guardrails. All changes are additive or replacements of existing sections.

**Tech Stack:** Markdown, Bash, JSON

**Design Doc:** `docs/superpowers/specs/2026-04-02-claude-code-features-integration-design.md`

---

### Task 1: Update Overview and Coordinator Runtime (Sections 1, 2.2)

**Files:**
- Modify: `SPEC.md:2` (subtitle)
- Modify: `SPEC.md:9` (overview paragraph)
- Modify: `SPEC.md:37` (coordinator runtime)
- Modify: `SPEC.md:44-45` (coordinator responsibilities)
- Modify: `SPEC.md:54-76` (coordinator standing loop)

- [ ] **Step 1: Update the subtitle**

Replace line 2:
```
> A $XXX/month AI-native software agency powered by Claude Code, Docker Sandboxes, and a Git-based coordination protocol.
```
With:
```
> A $300/month AI-native software agency powered by Claude Code CLI, headless workers, and a Git-based coordination protocol.
```

- [ ] **Step 2: Update the overview paragraph**

Replace line 9:
```
APPGAMBIT AI Company is an autonomous AI workforce that manages software projects end-to-end. A human CEO provides high-level direction. An AI Coordinator handles all planning, assignment, review, and operational management. AI Workers execute development tasks inside isolated Docker sandboxes.
```
With:
```
APPGAMBIT AI Company is an autonomous AI workforce that manages software projects end-to-end. A human CEO provides high-level direction. An AI Coordinator handles all planning, assignment, review, and operational management. AI Workers execute development tasks as headless Claude Code CLI processes, each scoped to its own project directory.
```

- [ ] **Step 3: Update Coordinator runtime**

Replace line 37:
```
**Runtime:** Docker Sandbox, runs with `/loop` or equivalent persistent mode  
```
With:
```
**Runtime:** Claude Code CLI session in persistent terminal (tmux/screen), uses `/loop` for scheduling  
```

- [ ] **Step 4: Update Coordinator responsibilities**

Replace lines 44-45:
```
- Assign tasks by writing COMM.md files
- Spin up / shut down / restart worker Docker sandboxes via bash
```
With:
```
- Assign tasks by writing COMM.md files
- Prepare worker context (CLAUDE.md, MEMORY.md in code repo) before launch
- Launch / resume / restart worker sessions via `claude -p` headless mode
- Send real-time updates to CEO via Channels (Telegram/Discord)
```

- [ ] **Step 5: Replace the Coordinator standing loop**

Replace lines 54-76 (the entire standing loop block) with:

```markdown
**Standing loop (via `/loop`, round-robin):**

On startup, Coordinator runs:
```
/loop 5m coordinator-check-cycle
```

Each iteration processes ONE project in round-robin order:
```
1. git pull (management repo)
2. Read REGISTRY.md → identify next project in rotation (by index)
3. Read COMM.md for that project
4. Process state change:
   a. If DONE_AWAITING_REVIEW → review code, run tests → APPROVED or REVISION_NEEDED
   b. If APPROVED → write next task → WAITING_FOR_WORKER
   c. If REVISION_NEEDED (3rd time) → ESCALATED_TO_CEO
   d. If RATE_LIMITED → note cooldown, reassign if urgent
   e. If STUCK (no progress >30min) → check worker session health, restart if needed
   f. If WAITING_FOR_WORKER but worker session not running → launch worker
   g. If all milestone tasks APPROVED → compile milestone report → CEO_INBOX.md + Channel notification
   h. If CEO approves milestone:
      - Append completed milestone to MILESTONES_ARCHIVE.md (with code repo commit hash)
      - Remove completed milestone from MILESTONES.md
      - If next milestone not yet planned → break it down into tasks
      - Reset COMM.md with first task of new milestone → WAITING_FOR_WORKER
5. Update REGISTRY.md (project status + increment rotation index)
6. git add, commit, push
```
```

- [ ] **Step 6: Commit**

```bash
git add SPEC.md
git commit -m "spec: update overview and coordinator loop to use /loop with round-robin (v1.2)"
```

---

### Task 2: Update Worker Runtime and Launch (Section 2.3)

**Files:**
- Modify: `SPEC.md:80-82` (worker runtime description)

- [ ] **Step 1: Update worker runtime**

Replace lines 80-82:
```
**Accounts:** Anthropic Pro ($100/month each), Accounts 2 and 3  
**Runtime:** Docker Sandboxes, one per project assignment (max 3 per account)  
**Identity:** Full-stack developers. Execute tasks, write code, commit.
```
With:
```
**Accounts:** Anthropic Pro ($100/month each), Accounts 2 and 3  
**Runtime:** Headless Claude Code CLI (`claude -p`), one session per project assignment (max 3 per account)  
**Identity:** Full-stack developers. Execute tasks, write code, commit.
**Permission mode:** `bypassPermissions` — fully autonomous. Hooks provide guardrails.
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: update worker runtime to headless CLI mode"
```

---

### Task 3: Replace Docker Sandboxes Section (Section 3.2)

**Files:**
- Modify: `SPEC.md:150-175` (Section 3.2 Docker Sandboxes)

- [ ] **Step 1: Replace Section 3.2**

Replace the entire Section 3.2 (lines 150-175) with:

```markdown
### 3.2 Session Management

**Coordinator session:**
```bash
# Set in ~/.zshrc
export ANTHROPIC_API_KEY_COORD=sk-ant-...

# Launch in persistent terminal (tmux/screen)
claude --permission-mode auto \
  --channels plugin:telegram@claude-plugins-official
```

The Coordinator reads `coordinator/CLAUDE.md` on startup and begins its `/loop`.

**Worker sessions (launched by Coordinator via headless mode):**
```bash
# Coordinator executes this when assigning a project
cd /path/to/projects/client-xyz/code-repo

claude -p "You are Employee 1 assigned to client-xyz. \
  Read /path/to/ai-company/projects/client-xyz/COMM.md for your current task. \
  Read CLAUDE.md for project context. Begin work." \
  --permission-mode bypassPermissions \
  --settings /path/to/ai-company/workers/hooks/settings.json \
  --output-format json
```

**Key properties:**
- Workers run as headless CLI processes, each in its own project code repo directory
- `--permission-mode bypassPermissions` enables fully autonomous execution
- `--settings` loads hook-based guardrails (block dangerous/interactive commands)
- `--output-format json` gives Coordinator structured results including session ID
- Each worker is isolated by working directory — no cross-project access
- All persistent state lives in Git — worker sessions are ephemeral
- Docker sandboxes remain an optional layer for filesystem isolation

**Session recovery:**
```bash
# Resume a crashed worker session
claude -p "Resume work on client-xyz. Read COMM.md for current status." \
  --resume <session_id> \
  --permission-mode bypassPermissions \
  --output-format json
```

If `--resume` fails (session expired), Coordinator launches a fresh session. Worker reads COMM.md and code repo to pick up from last git commit.
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: replace Docker sandboxes with headless CLI session management"
```

---

### Task 4: Update Repo Structure (Section 4)

**Files:**
- Modify: `SPEC.md:194-226` (Management Repo Structure)

- [ ] **Step 1: Update the directory tree**

Replace the directory tree (lines 194-226) with:

```markdown
```
ai-company/                          ← Private Git repo
│
├── README.md                         System overview
├── CEO_INBOX.md                      Coordinator → CEO communication
│
├── coordinator/
│   ├── CLAUDE.md                     Coordinator operating manual
│   ├── REGISTRY.md                   All projects, workers, statuses, rotation index
│   ├── DAILY_LOG.md                  Append-only daily summaries
│   └── hooks/
│       └── settings.json             Coordinator hook configuration
│
├── workers/
│   ├── employee-1/
│   │   └── CLAUDE.md                 Worker 1 role instructions
│   ├── employee-2/
│   │   └── CLAUDE.md                 Worker 2 role instructions
│   └── hooks/
│       ├── settings.json             Worker hook configuration
│       ├── block-dangerous-commands.sh
│       └── block-interactive-commands.sh
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
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: add hooks directories to repo structure"
```

---

### Task 5: Update REGISTRY.md Format (Section 5.2)

**Files:**
- Modify: `SPEC.md:267-296` (REGISTRY.md example)

- [ ] **Step 1: Update the REGISTRY.md example**

Replace the REGISTRY.md example (lines 267-296) with:

```markdown
```markdown
# Company Registry

Last updated: 2026-04-02T16:30:00Z

## Rotation
Next check index: 2
Last checked: client-xyz at 2026-04-02T14:30:00Z

## Workers

### Employee 1 (Account 2)
| Slot | Project | Status | Current Task | Session ID |
|------|---------|--------|-------------|------------|
| 1 | client-xyz | IN_PROGRESS | Auth middleware tests | sess_abc123 |
| 2 | ipoiq | PAUSED | Agent 5 migration | — |
| 3 | — | AVAILABLE | — | — |

### Employee 2 (Account 3)
| Slot | Project | Status | Current Task | Session ID |
|------|---------|--------|-------------|------------|
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
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: add rotation tracking and session IDs to REGISTRY.md format"
```

---

### Task 6: Update COMM.md Example (Section 5.5)

**Files:**
- Modify: `SPEC.md:388-389` (Assigned Sandbox field in COMM.md example)

- [ ] **Step 1: Update the Assigned Sandbox field**

Replace:
```
## Assigned Sandbox
emp1-clientxyz
```
With:
```
## Session ID
sess_abc123
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: replace sandbox name with session ID in COMM.md format"
```

---

### Task 7: Update Onboarding Workflow (Section 7.1)

**Files:**
- Modify: `SPEC.md:604-611` (Activation steps in onboarding)

- [ ] **Step 1: Replace activation steps**

Replace lines 604-611:
```
APPGAMBIT AI (Activation):
  10. Set project status → ACTIVE in REGISTRY.md
  11. Break Milestone 1 into tasks → write MILESTONES.md (3-5 milestones visible, ~4-5 tasks each)
  12. Write COMM.md with Task 1 → WAITING_FOR_WORKER
  13. Spin up worker sandbox:
      docker sandbox run {sandbox-name} ~/projects/{name} -- "{init prompt}"
  14. git commit + push
  15. Confirm to CEO: "Project {name} is active. {Worker} assigned. ETA: {date}."
```
With:
```
APPGAMBIT AI (Activation):
  10. Set project status → ACTIVE in REGISTRY.md
  11. Break Milestone 1 into tasks → write MILESTONES.md (3-5 milestones visible, ~4-5 tasks each)
  12. Prepare worker context in code repo:
      - Write/update CLAUDE.md (tech stack, conventions, current task context)
      - Write/update MEMORY.md (discovery decisions, CEO preferences, past feedback)
  13. Write COMM.md with Task 1 → WAITING_FOR_WORKER
  14. Launch worker via headless mode:
      claude -p "{init prompt}" --permission-mode bypassPermissions \
        --settings /path/to/workers/hooks/settings.json --output-format json
  15. Record session ID in REGISTRY.md
  16. git commit + push
  17. Confirm to CEO (session + channel): "Project {name} is active. {Worker} assigned. ETA: {date}."
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: update onboarding with context prep and headless worker launch"
```

---

### Task 8: Update Sandbox Health Recovery (Section 7.6)

**Files:**
- Modify: `SPEC.md:697-709` (Section 7.6)

- [ ] **Step 1: Replace Section 7.6**

Replace the entire Section 7.6 content with:

```markdown
### 7.6 Worker Session Recovery

```
Coordinator (during round-robin loop):
  1. Check REGISTRY.md for active worker sessions
  2. For the current project in rotation:
     a. If COMM.md is IN_PROGRESS but last worker update >30min ago:
        - Attempt to resume session: claude -p "Resume work" --resume <session_id>
        - If resume fails → launch fresh session, update session ID in REGISTRY.md
        - Worker reads COMM.md, sees IN_PROGRESS, continues from last git commit
  3. If repeated session failures (3+) → ESCALATED_TO_CEO
```
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: replace sandbox health recovery with session recovery"
```

---

### Task 9: Add Permission Modes Section (new Section 8.8)

**Files:**
- Modify: `SPEC.md` (after Section 8.7, around line 772)

- [ ] **Step 1: Add Section 8.8 after Non-Interactive Execution**

Insert after Section 8.7:

```markdown
### 8.8 Permission Modes

Each role uses a different Claude Code permission mode:

| Role | Permission Mode | Rationale |
|------|----------------|-----------|
| Coordinator | `auto` (preferred) or `acceptEdits` (fallback) | `auto` requires Team/Enterprise/API plan. On Pro plan, use `acceptEdits` — auto-accepts file edits, prompts for bash commands. Hooks provide additional guardrails. |
| Workers | `bypassPermissions` | Fully autonomous within their project directory. Hooks provide guardrails instead of permission prompts. No human available to respond to prompts. |
| CEO session | `default` | Human reviews and approves everything. Full oversight. |
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: add permission modes per role (Section 8.8)"
```

---

### Task 10: Add Channels Section (new Section 8.9)

**Files:**
- Modify: `SPEC.md` (after new Section 8.8)

- [ ] **Step 1: Add Section 8.9 after Permission Modes**

Insert after Section 8.8:

```markdown
### 8.9 CEO Channels (Real-Time Notifications)

CEO_INBOX.md remains the append-only audit log. Channels add a real-time notification layer.

**Setup:** Coordinator session starts with `--channels plugin:telegram@claude-plugins-official` (or Discord).

**When the Coordinator writes to CEO_INBOX.md, it also sends a channel message:**
- Milestone complete → summary + "approve to continue"
- Escalation → options + recommendation
- Daily summary → highlights

**CEO replies via channel** (phone) → message arrives in Coordinator session as `<channel source="...">` event → Coordinator processes the reply.

**Platform options:**
- Telegram and Discord available now via official plugins
- Slack integration planned (channel tool already built)
- CEO picks platform during bootstrap

**What stays the same:**
- CEO_INBOX.md is still written — it's the historical record
- CEO can still use live Claude Code session for complex discussions
- Channels are a convenience layer, not a replacement for Git-based protocol
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: add CEO channels for real-time notifications (Section 8.9)"
```

---

### Task 11: Add Within-Project Parallelism Section (new Section 8.10)

**Files:**
- Modify: `SPEC.md` (after new Section 8.9)

- [ ] **Step 1: Add Section 8.10 after Channels**

Insert after Section 8.9:

```markdown
### 8.10 Within-Project Parallelism (Subagents)

Workers can use subagents within their single session for parallel sub-tasks:
- One subagent writes the API route, another writes the tests
- One subagent researches existing patterns, another scaffolds the component

**Rules:**
- One session per project — workers do NOT spawn additional full sessions
- Subagents run inside the worker's session with isolated context
- Subagent results return as summaries to the worker's main context
- Encouraged in worker CLAUDE.md but not enforced — worker uses judgment
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: add within-project parallelism via subagents (Section 8.10)"
```

---

### Task 12: Update Bootstrap Steps (Section 9)

**Files:**
- Modify: `SPEC.md:776-811` (Section 9)

- [ ] **Step 1: Replace Section 9**

Replace the entire Section 9 content with:

```markdown
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
- Write CLAUDE.md files for coordinator and workers
- Write hook scripts and settings.json files (see `workers/hooks/`)

### Step 3: Install Channel Plugin
```bash
# In a Claude Code session
/plugin install telegram@claude-plugins-official
/telegram:configure <bot-token>
/telegram:access pair <code>
/telegram:access policy allowlist
```

### Step 4: First Run — Coordinator
```bash
# In a persistent terminal (tmux/screen)
claude --permission-mode auto \
  --channels plugin:telegram@claude-plugins-official
```
Coordinator reads `coordinator/CLAUDE.md`, starts `/loop 5m`, begins round-robin.

### Step 5: First Project
- Talk to Coordinator: give it a project brief
- Coordinator runs discovery flow, prepares worker context
- Coordinator launches worker via `claude -p` headless mode
- Verify the loop works end-to-end with a simple task

### Step 6: Scale
- Add second project, verify parallel execution
- Add second worker, verify multi-worker coordination
- Test edge cases: rate limits, escalations, priority changes

### Step 7: Docker (Optional)
If filesystem isolation is desired:
- Install Docker Desktop 4.58+
- Wrap worker `claude -p` launches in Docker sandbox commands
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: update bootstrap steps for headless mode and channels"
```

---

### Task 13: Update Future Extensions (Section 11)

**Files:**
- Modify: `SPEC.md:833-843` (Section 11)

- [ ] **Step 1: Update the future extensions list**

Replace the Slack Integration and GitHub Webhooks bullets:
```
- **GitHub Webhooks:** Trigger coordinator loop on push events (event-driven instead of polling)
- **Slack Integration:** CEO_INBOX.md updates → Slack webhook for mobile notifications
```
With:
```
- **GitHub Webhooks:** Trigger coordinator loop on push events (event-driven instead of polling)
- **Slack Channel:** Integrate existing Slack channel tool for CEO notifications (replacing Telegram/Discord)
- **Priority-First Polling:** Replace round-robin with priority-based scanning — quick status scan of all projects, then process the most urgent one per iteration
```

- [ ] **Step 2: Commit**

```bash
git add SPEC.md
git commit -m "spec: update future extensions with Slack channel and priority polling"
```

---

### Task 14: Create Worker Hook Scripts

**Files:**
- Create: `workers/hooks/block-dangerous-commands.sh`
- Create: `workers/hooks/block-interactive-commands.sh`
- Create: `workers/hooks/settings.json`

- [ ] **Step 1: Create the dangerous commands blocker**

Create `workers/hooks/block-dangerous-commands.sh`:

```bash
#!/bin/bash
# block-dangerous-commands.sh
# PreToolUse hook: blocks destructive bash commands
# Exit 2 = block the action, stderr = feedback to Claude

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Patterns to block
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \."
  "git push --force"
  "git push -f"
  "DROP TABLE"
  "DROP DATABASE"
  "truncate table"
  "> /dev/sda"
  "mkfs\."
  "dd if="
  ":(){:|:&};:"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    echo "BLOCKED: Command matches dangerous pattern '$pattern'. This command is not allowed." >&2
    exit 2
  fi
done

exit 0
```

- [ ] **Step 2: Create the interactive commands blocker**

Create `workers/hooks/block-interactive-commands.sh`:

```bash
#!/bin/bash
# block-interactive-commands.sh
# PreToolUse hook: blocks commands that require stdin input
# Exit 2 = block the action, stderr = feedback to Claude

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Commands that require interactive input
INTERACTIVE_PATTERNS=(
  "git add -i"
  "git add --interactive"
  "git rebase -i"
  "git rebase --interactive"
  "^read "
  "^select "
  "npm init$"
  "npx create-.*[^-][^y][^e][^s]$"
  "ssh-keygen"
  "passwd"
  "sudo -S"
)

for pattern in "${INTERACTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "BLOCKED: Command '$COMMAND' requires interactive input. Use non-interactive flags (e.g., npm init -y, git add .) or find an alternative." >&2
    exit 2
  fi
done

exit 0
```

- [ ] **Step 3: Create the worker hooks settings.json**

Create `workers/hooks/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/ai-company/workers/hooks/block-dangerous-commands.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/ai-company/workers/hooks/block-interactive-commands.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' >> /tmp/claude-changed-files.txt"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "cat \"$CLAUDE_PROJECT_DIR\"/CLAUDE.md"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 4: Make hook scripts executable**

```bash
chmod +x workers/hooks/block-dangerous-commands.sh
chmod +x workers/hooks/block-interactive-commands.sh
```

- [ ] **Step 5: Commit**

```bash
git add workers/hooks/
git commit -m "feat: add worker hook scripts and settings.json"
```

---

### Task 15: Create Coordinator Hook Settings

**Files:**
- Create: `coordinator/hooks/settings.json`

- [ ] **Step 1: Create the coordinator hooks settings.json**

Create `coordinator/hooks/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"APPGAMBIT AI Coordinator needs attention\" with title \"AI Company\"'"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) git: $(cat | jq -r '.tool_input.command')\" >> /tmp/coordinator-git-audit.log"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add coordinator/hooks/
git commit -m "feat: add coordinator hook settings"
```

---

### Task 16: Update Spec Version and Final Verification

**Files:**
- Modify: `SPEC.md:846-850` (version footer)
- Read: `SPEC.md` (full file for verification)

- [ ] **Step 1: Update the spec version**

Replace the footer:
```
*Spec version: 1.1*
*Last updated: 2026-04-02*
*Author: Dhaval Nagar + Claude (APPGAMBIT AI Company design session)*
*Amendment: Rolling window protocol, discovery phase, worker autonomy (v1.1)*
```
With:
```
*Spec version: 1.2*
*Last updated: 2026-04-02*
*Author: Dhaval Nagar + Claude (APPGAMBIT AI Company design session)*
*v1.1: Rolling window protocol, discovery phase, worker autonomy*
*v1.2: Claude Code CLI features — /loop, Channels, headless mode, hooks, permission modes, subagents*
```

- [ ] **Step 2: Read the full updated SPEC.md and verify**

Check:
- All sections updated/added correctly
- Section numbers are sequential (8.8, 8.9, 8.10)
- No remaining references to "Docker sandbox" as required (should say optional)
- REGISTRY.md example has rotation index and session IDs
- COMM.md example has session ID instead of sandbox name
- Bootstrap steps reference headless mode and channels
- No markdown formatting issues

- [ ] **Step 3: Fix any issues found**

- [ ] **Step 4: Final commit**

```bash
git add SPEC.md
git commit -m "spec: bump to v1.2 — Claude Code features integration complete"
```
