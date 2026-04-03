Check on a worker's live session. The user will provide the project name (e.g., /worker-log mrv-prototype).

1. Read coordinator/REGISTRY.md to find which employee and tmux session is assigned to this project
2. If no worker is assigned, say so and stop
3. Check if the tmux session exists: `tmux has-session -t {session-name}`
4. If session exists, capture the last 50 lines of output: `tmux capture-pane -t {session-name} -p -S -50`
5. Read the project's COMM.md for the "Last worker update" timestamp
6. Present a summary:
   - Worker: Employee N
   - Session: {session-name} (alive/dead)
   - Last COMM.md heartbeat: {timestamp} ({X minutes ago})
   - Recent session output: (last 10-15 meaningful lines, skip blank lines)
7. If the session is dead or heartbeat is >60 minutes old, flag it as potentially stuck

Keep the response concise. Do NOT take any action — this is read-only.
