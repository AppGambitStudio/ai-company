Pause a project temporarily. The user will provide the project name.

Steps:
1. Read the project's COMM.md for current status
2. If a worker session is running, note the session ID for potential resume later
3. Set COMM.md status to PAUSED
4. Update REGISTRY.md:
   - Set project status to PAUSED
   - Free the worker slot (set to AVAILABLE)
   - Keep the project in the priority list but mark as PAUSED
5. Write to CEO_INBOX.md: "Project {name} paused. Last task: [task name and status]"
6. git commit
7. Confirm to CEO

To resume later, CEO can say "Resume project {name}" or use /assign-task.

Usage: /pause-project mrv-prototype