Assign a research task to a worker for the specified project. The user will provide the project name and research topic (e.g., /research mrv-prototype Upgrade to Next.js 15).

This is NOT a coding task. The worker should investigate and produce a RESEARCH.md file in the project's management directory (projects/{name}/RESEARCH.md).

1. Read coordinator/REGISTRY.md to check project status and worker availability
2. If the project is PAUSED, unpause it first
3. Write a research task to the project's COMM.md:
   - Task type: RESEARCH (not implementation)
   - Topic: the user's research question
   - Acceptance criteria:
     - Produce projects/{name}/RESEARCH.md with:
       - Summary of findings
       - Pros and cons
       - Recommended approach with justification
       - Implementation plan (if applicable)
       - Links to relevant documentation
     - Do NOT write any code or make any changes to the code repo
   - Status: WAITING_FOR_WORKER
4. Assign a worker using `prepare-worker` + `launch-worker-prompts` skills
5. Update REGISTRY.md
