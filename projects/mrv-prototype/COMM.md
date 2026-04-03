# COMM — mrv-prototype

## Status
WAITING_FOR_WORKER

## Timestamps
- Created: 2026-04-02T12:15:00Z
- Last updated: 2026-04-03T07:30:00Z
- Milestone 2 started: 2026-04-03T07:30:00Z
- Task assigned: 2026-04-03T07:30:00Z

## Current Task
Task 7: Phase 1 Gap Closure — DB Client, Migrations, Logging, Email

## Task Description
Close the gaps identified in the Milestone 1 validation report before building Phase 2 features.

### Acceptance Criteria
1. **DB Client:** Wire up `packages/db/src/index.ts` with a proper Drizzle client. Create a `createDb()` function that accepts a connection string (for local dev/testing) and a version that reads from SST Resource binding (`Resource.Database`) for deployed environments. Export the client for use by Lambda handlers.
2. **Drizzle Config:** Add `drizzle.config.ts` at the `packages/db` level with correct schema path and output directory.
3. **Migrations:** Run `drizzle-kit generate` to produce the initial migration SQL from the existing schema. Verify the generated SQL creates all 11 tables, 8 enums, all indexes, and all foreign keys correctly.
4. **Structured JSON Logging:** Add a logging middleware/utility in `packages/core/src/api/logger.ts` that outputs structured JSON logs (timestamp, level, message, requestId, metadata). Include a `withLogging()` middleware wrapper for Lambda handlers.
5. **SES Email Infrastructure:** Add `infra/email.ts` with SES identity configuration. Wire it into `sst.config.ts`. This is needed for Cognito user invitation emails in Phase 2.
6. **Tests:** Unit tests for the logging utility. Verify migration SQL is syntactically valid.
7. **All existing tests still pass** (134 tests, zero regressions).

### Branch
`feature/task-7-phase1-gaps`

### Notes
- Codebase: `/Users/dhaval/Documents/work/antigravity/mrv-prototype`
- Reference docs: `/Users/dhaval/Documents/work/antigravity/worldbank-poc/docs/`
- The DB client should work both locally (direct connection string) and deployed (SST Resource linking). Use a factory pattern.
- For SES, just define the infrastructure — no email templates yet.
- Do NOT modify existing schema files — they passed validation.
