# 2. Infrastructure

> Covers account setup, session management for the Coordinator and Workers, and the Git repository architecture that underpins the entire system.

---

## 2.1 Accounts

| Role | Account | Plan | Cost | Max Sessions |
|------|---------|------|------|-------------|
| APPGAMBIT AI (Coordinator) | Account 1 | Pro $100 | $100/mo | 1 (coordinator) + 2 spare |
| Employee 1 | Account 2 | Pro $100 | $100/mo | Up to 3 projects |
| Employee 2 | Account 3 | Pro $100 | $100/mo | Up to 3 projects |
| **Total** | | | **$300/mo** | **Up to 6 projects** |

## 2.2 Session Management

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

## 2.3 Git Repositories

**Management Repo** (`appgambit/ai-company` — private):
- Single source of truth for all coordination
- All roles read and write to this repo
- Every state change is a git commit → full audit trail

**Code Repos** (one per project, e.g., `appgambit/client-xyz`):
- Actual source code for each project
- Workers commit feature branches here
- Coordinator reads diffs/tests from here during review
- Completely separate from management repo
