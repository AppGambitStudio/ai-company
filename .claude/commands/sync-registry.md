REGISTRY.md may be stale. Reconcile it against the actual state of all projects.

For each project in REGISTRY.md:
1. Read its COMM.md — get the actual current status, task, and worker assignment
2. Read its REVIEW_LOG.md — check if the latest task was already reviewed/approved
3. Compare against what REGISTRY.md says

If any mismatches found:
- Update REGISTRY.md to match the actual state from COMM.md and REVIEW_LOG.md
- List every correction made
- git commit with message "coord: sync REGISTRY.md — [summary of corrections]"

If everything matches, confirm "REGISTRY.md is in sync."

This command should be run after any manual interventions or when the CEO reports stale data.