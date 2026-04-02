Assign a new task to a project. The user will provide the project name and task description.

Steps:
1. Read the project's MILESTONES.md to determine the next task number
2. Read the project's COMM.md to check current status — if a task is already IN_PROGRESS, warn the CEO and ask whether to queue this or replace the current task
3. Write the new task to COMM.md with status WAITING_FOR_WORKER, including:
   - Task number and name
   - Detailed task description from the user's input
   - Acceptance criteria (ask the CEO if not provided)
   - Feature branch name
   - Coordinator notes (mark as URGENT if specified)
4. Update MILESTONES.md with the new task
5. Update REGISTRY.md
6. Prepare worker context (update CLAUDE.md in code repo with new task details)
7. Launch worker via `claude -p` headless mode using the launch prompt from coordinator/CLAUDE.md Section 8
8. Record session ID in REGISTRY.md
9. git commit
10. Confirm to CEO what was assigned and to which worker

Usage: /assign-task mrv-prototype Set up the database schema using Drizzle ORM based on DBSCHEMA.pdf