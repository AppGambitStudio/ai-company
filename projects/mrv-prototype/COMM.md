# COMM — mrv-prototype

## Status
WAITING_FOR_WORKER

## Timestamps
- Created: 2026-04-02T12:15:00Z
- Last updated: 2026-04-02T12:45:00Z
- Task assigned: 2026-04-02T12:45:00Z

## Current Task
Task 1: Monorepo Scaffolding & Tooling

## Task Details
Set up the pnpm workspace monorepo with SST v3, TypeScript, and all four packages. This is the skeleton that everything else builds on.

Specific implementation:

1. **Initialize git repo** in `/Users/dhaval/Documents/work/antigravity/mrv-prototype`
2. **Initialize pnpm workspace** — create `pnpm-workspace.yaml` with packages: `packages/*`, `infra`
3. **Root package.json** — private, workspaces config, scripts: `lint`, `typecheck`, `test`, `build`
4. **Root tsconfig.json** — strict mode, ES2022 target, moduleResolution: bundler, composite project references
5. **ESLint** — flat config (`eslint.config.mjs`), TypeScript rules, import sorting
6. **Prettier** — `.prettierrc` with consistent style (semi, singleQuote, trailingComma)
7. **Initialize SST v3 project** — `sst.config.ts` targeting us-east-1, app name `worldbank-mrv`
8. **Create package structure:**
   - `packages/core/` — business logic & domain models (package.json, tsconfig.json, src/index.ts)
   - `packages/db/` — database layer with Drizzle ORM (package.json, tsconfig.json, src/index.ts)
   - `packages/functions/` — Lambda function handlers (package.json, tsconfig.json, src/index.ts)
   - `packages/web/` — Next.js 14+ app with App Router (initialize with `create-next-app` or manual setup)
   - `infra/` — SST infrastructure definitions (placeholder files: vpc.ts, database.ts, auth.ts, storage.ts, api.ts, web.ts)
9. **Set up Vitest** — root vitest config + per-package configs, test script in root
10. **Create .gitignore** — node_modules, .sst, .next, dist, *.env*, .turbo
11. **Create .nvmrc** — pin to Node 20

## Acceptance Criteria
- [ ] `pnpm install` runs without errors from repo root
- [ ] `pnpm typecheck` runs (may have no files yet, but command works)
- [ ] `pnpm lint` runs without errors
- [ ] `pnpm test` runs (0 tests, but Vitest initializes correctly)
- [ ] All 4 packages exist with valid package.json and tsconfig.json
- [ ] SST config file exists and is valid TypeScript
- [ ] `infra/` directory has placeholder infrastructure files
- [ ] Git repo initialized with clean first commit
- [ ] No `create-next-app` boilerplate cruft (remove default pages/styles if generated)

## Code Repo Branch
feature/task-1-monorepo-scaffolding

## Coordinator Notes
Priority: HIGH — this unblocks all subsequent tasks.
Code repo path: `/Users/dhaval/Documents/work/antigravity/mrv-prototype` (empty directory, no git yet)
No GitHub remote yet — work locally. Do NOT attempt `git push`.
No AWS credentials yet — SST config only, no `sst dev` or deploy.
Reference ARCHITECTURE.pdf and PHASES.pdf in management repo for tech stack details:
  `/Users/dhaval/Documents/work/antigravity/ai-company/projects/mrv-prototype/docs/ARCHITECTURE.pdf`
  `/Users/dhaval/Documents/work/antigravity/ai-company/projects/mrv-prototype/docs/PHASES.pdf`

## Worker Notes
(none yet)

## Revision History
(none)
