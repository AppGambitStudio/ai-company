Onboard an existing project that already has code and history. The user will provide the project name and the local path to the code repo.

This is NOT a greenfield project — code already exists and is working. The goal is to bring it under AI Company management so new tasks can be assigned.

Steps:

1. Create `/projects/{name}/` and `/projects/{name}/docs/` in management repo
2. Ask CEO: "Do you have reference documents (SOW, architecture docs) to add to `projects/{name}/docs/`?"

3. **Assess the existing codebase:**
   - cd into the code repo at the path CEO provided
   - Run `git log --oneline --since="30 days ago"` to understand recent activity
   - Run `git log --oneline --since="30 days ago" --stat` for file-level changes
   - Read README.md, package.json (or equivalent) for tech stack
   - Read the project structure (`ls -la`, key directories)
   - Read any existing documentation in the repo
   - Identify: tech stack, architecture patterns, test setup, deployment config

4. **Write BRIEF.md** — capture what CEO said about the project + what you learned from the code

5. **Write PROJECT.md** with:
   - Project overview (from code assessment + CEO input)
   - Tech stack (from actual package.json/config, not assumptions)
   - Code repo paths (local + remote from `git remote -v`)
   - Current state: "Existing project with active codebase. Last 30 days: [N] commits, [summary of recent work]"
   - What's already built (from code assessment)
   - Open questions for CEO:
     - What are the next priorities for this project?
     - Any known bugs or tech debt to address first?
     - Any upcoming deadlines or milestones?
     - Are there areas of the code that need refactoring?
     - Who has been working on this? Any context to capture?

6. **Write MEMORY.md** with:
   - Architecture assessment from code review
   - Key patterns observed (state management, API structure, auth approach, etc.)
   - Recent commit themes (what's been worked on in last 30 days)
   - Any code quality observations (test coverage, linting, type safety)

7. **Write initial MILESTONES.md** — leave empty until CEO provides priorities:
   ```
   # {project-name} — Milestones & Tasks
   
   (Awaiting CEO input on priorities. Project assessed and ready for task assignment.)
   ```

8. **Write COMM.md** with status DISCOVERY:
   ```
   # COMM — {project-name}
   
   ## Status
   DISCOVERY
   
   ## Notes
   Existing project onboarded. Codebase assessed. Awaiting CEO priorities.
   ```

9. Create REVIEW_LOG.md and MILESTONES_ARCHIVE.md (empty)

10. Update REGISTRY.md: add project with status = DISCOVERY

11. Write to CEO_INBOX.md:
    - "Existing project {name} assessed and onboarded."
    - Summary of codebase: tech stack, size, recent activity, code quality observations
    - "Ready for task assignment once you provide priorities."

12. **Write CLAUDE.md in the code repo** with project context learned from assessment (tech stack, conventions observed, test commands, build commands)

13. git commit management repo

14. Present the assessment to CEO and ask for priorities

Usage: /onboard-existing myproject /Users/dhaval/Documents/work/antigravity/myproject