Launch a worker session for the specified project. The project must have a COMM.md with status WAITING_FOR_WORKER.

Steps:
1. Read the project's COMM.md — verify status is WAITING_FOR_WORKER
2. Read the project's PROJECT.md to get the code repo local path
3. Prepare worker context if not already done (CLAUDE.md, MEMORY.md in code repo)
4. Launch worker using the appropriate prompt from coordinator/CLAUDE.md Section 8:
   - New task: use Section 8.2 prompt
   - Resume: use Section 8.3 prompt  
   - Revision: use Section 8.4 prompt
5. Capture the session ID from the JSON output
6. Update REGISTRY.md with session ID and status IN_PROGRESS
7. git commit
8. Confirm to CEO: worker launched for {project}, session {id}

Usage: /launch-worker mrv-prototype