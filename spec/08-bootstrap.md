# 8. Getting Started — Bootstrap Steps

> Step-by-step guide to set up the APPGAMBIT AI Company system from scratch: accounts, repos, channels, and the first project run.

---

## Step 1: Accounts

- Create 3 Anthropic accounts with Pro plans ($100 each)
- Generate API keys for each
- Add to ~/.zshrc:
  ```bash
  export ANTHROPIC_API_KEY_COORD=sk-ant-...
  export ANTHROPIC_API_KEY_EMP1=sk-ant-...
  export ANTHROPIC_API_KEY_EMP2=sk-ant-...
  ```

## Step 2: Management Repo

- Create private repo: `appgambit/ai-company`
- Initialize with the directory structure from [03-repo-structure.md](./03-repo-structure.md)
- Write CLAUDE.md files for coordinator and workers
- Write hook scripts and settings.json files (see `scripts/hooks/` and `workers/hooks/`)

## Step 3: Install Channel Plugin

```bash
# In a Claude Code session
/plugin install telegram@claude-plugins-official
/telegram:configure <bot-token>
/telegram:access pair <code>
/telegram:access policy allowlist
```

## Step 4: First Run — Coordinator

```bash
# In a persistent terminal (tmux/screen)
claude --permission-mode auto \
  --channels plugin:telegram@claude-plugins-official
```

Coordinator reads `coordinator/CLAUDE.md`, starts `/loop 5m`, begins round-robin.

## Step 5: First Project

- Talk to Coordinator: give it a project brief
- Coordinator runs discovery flow, prepares worker context
- Coordinator launches worker via `claude -p` headless mode
- Verify the loop works end-to-end with a simple task

## Step 6: Scale

- Add second project, verify parallel execution
- Add second worker, verify multi-worker coordination
- Test edge cases: rate limits, escalations, priority changes

## Step 7: Docker (Optional)

If filesystem isolation is desired:
- Install Docker Desktop 4.58+
- Wrap worker `claude -p` launches in Docker sandbox commands
