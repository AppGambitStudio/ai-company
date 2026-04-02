Onboard a new project into the AI Company. The user will provide a project name and brief description.

Follow the full discovery flow from coordinator/CLAUDE.md Section 5.1:

1. Create `/projects/{name}/` directory in management repo
2. Create `/projects/{name}/docs/` directory for reference materials
3. Ask CEO: "Do you have reference documents (SOW, requirements, wireframes) to add to `projects/{name}/docs/`? If so, copy them there and let me know."
4. Write `BRIEF.md` — raw capture of CEO's input
5. Write draft `PROJECT.md` with:
   - Best interpretation of requirements
   - Tech stack recommendation
   - Assumptions made (numbered)
   - Open questions (numbered) — MUST include:
     - Where is the code repo on this machine? (absolute path)
     - What is the GitHub remote URL?
     - Does the repo already exist or should we create it?
     - AWS profile name for deployments (if applicable)
   - Proposed milestones (3-5)
6. If CEO provides reference docs, read them and incorporate into PROJECT.md
7. Update REGISTRY.md: add project with status = DISCOVERY
8. Write to CEO_INBOX.md: "Project {name} drafted. Open questions: [list]"
9. git commit
10. Present the open questions to the CEO and wait for answers

Continue iterating until CEO approves the project plan. Then activate per Section 5.1.

Usage: /new-project mrv-prototype World Bank MRV platform for carbon credit monitoring