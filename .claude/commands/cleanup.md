Assign a maintenance/cleanup task to a worker for the specified project. The user will provide the project name and optionally specific cleanup areas (e.g., /cleanup mrv-prototype or /cleanup mrv-prototype dependency audit).

1. Read coordinator/REGISTRY.md to check project status and worker availability
2. If the project is PAUSED, unpause it first
3. Write a cleanup task to the project's COMM.md:
   - Task type: MAINTENANCE
   - Scope: user-specified areas, or if not specified, run the standard checklist:
     - Dependency audit (npm audit / pip audit)
     - Remove unused dependencies
     - Check for outdated packages
     - Clean up unused files, dead code, commented-out blocks
     - Verify all tests still pass after cleanup
     - If using SST/AWS: check for orphaned resources
   - Acceptance criteria:
     - Produce a summary of findings and actions taken in COMM.md worker notes
     - All existing tests must still pass
     - No functional changes — cleanup only
     - Commit changes on a cleanup branch (cleanup/maintenance-{date})
   - Status: WAITING_FOR_WORKER
4. Assign a worker using `prepare-worker` + `launch-worker-prompts` skills
5. Update REGISTRY.md
