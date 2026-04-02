Close/complete a project and remove it from active management. The user will provide the project name.

Steps:
1. Read the project's COMM.md and MILESTONES.md — verify all tasks are APPROVED or confirm with CEO that it's OK to close with pending work
2. If any active worker session exists for this project, stop it
3. Archive final state:
   - Ensure all completed milestones are in MILESTONES_ARCHIVE.md
   - If there are remaining milestones in MILESTONES.md, append them to archive with status CANCELLED or COMPLETED as appropriate
4. Set COMM.md status to PROJECT_CLOSED
5. Update REGISTRY.md:
   - Set project status to COMPLETED
   - Free the worker slot (set to AVAILABLE, clear session ID)
   - Remove project from the priority list
6. Write to CEO_INBOX.md: "Project {name} closed. Summary: [milestones completed, total tasks, total revisions]"
7. git commit
8. Confirm to CEO with a final project summary

Usage: /close-project mrv-prototype