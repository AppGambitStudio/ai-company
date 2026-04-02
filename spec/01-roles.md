# 1. Roles

> Defines the three roles in the APPGAMBIT AI Company system: the human CEO, the AI Coordinator, and the AI Workers. Each role has distinct responsibilities, permissions, and operating patterns.

---

## 1.1 Dhaval Nagar — Human CEO

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

## 1.2 APPGAMBIT AI — AI Coordinator

**Account:** Anthropic Pro ($100/month), Account 1  
**Runtime:** Claude Code CLI session in persistent terminal (tmux/screen), uses `/loop` for scheduling  
**Identity:** The CTO. Manages everything between CEO direction and worker execution.

**Responsibilities:**
- Convert CEO's verbal briefs into structured PROJECT.md
- Break milestones into sequenced, atomic tasks with acceptance criteria
- Maintain REGISTRY.md (single source of truth for all projects, workers, statuses)
- Assign tasks by writing COMM.md files
- Prepare worker context (CLAUDE.md, MEMORY.md in code repo) before launch
- Launch / resume / restart worker sessions via `claude -p` headless mode
- Send real-time updates to CEO via Channels (Telegram/Discord/Slack)
- Monitor worker progress (poll COMM.md files via round-robin)
- Review completed work: read diffs, run tests, evaluate against acceptance criteria
- Approve or reject with specific feedback
- Manage rate limits and cooldown periods
- Escalate to CEO only when human judgment is required
- Write daily summaries and milestone reports to CEO_INBOX.md
- Handle worker reassignment when priorities change

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

## 1.3 Employee 1 & Employee 2 — AI Workers

**Accounts:** Anthropic Pro ($100/month each), Accounts 2 and 3  
**Runtime:** Headless Claude Code CLI (`claude -p`), one session per project assignment (max 3 per account)  
**Identity:** Full-stack developers. Execute tasks, write code, commit.  
**Permission mode:** `bypassPermissions` — fully autonomous. Hooks provide guardrails.

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
- Workers run in unattended sessions. All commands must execute without human input.
- Always use non-interactive flags: `npm init -y`, `npx create-next-app --yes`, `apt-get install -y`, `yes | command`
- Use token-based Git URLs, never SSH that may prompt for passphrases
- Never run commands that require stdin input (interactive installers, `read` prompts, `git add -i`)
- If a command unexpectedly prompts for input:
  1. Kill the process
  2. Note the issue in COMM.md worker notes
  3. Find a non-interactive alternative
  4. If no alternative exists, set BLOCKED with specifics

**Standing loop (runs per project session):**
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
