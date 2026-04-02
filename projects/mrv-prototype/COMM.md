# COMM — mrv-prototype

## Status
IN_PROGRESS

## Timestamps
- Created: 2026-04-02T12:15:00Z
- Last updated: 2026-04-02T14:15:00Z
- Task assigned: 2026-04-02T14:15:00Z

## Current Task
Task 2: SST v4 Infrastructure Definitions (code only, no deploy)

## Task Details
Write all SST v4 (Ion/Pulumi) infrastructure definitions in the `infra/` directory. This is CODE ONLY — do NOT run `sst dev` or `sst deploy`. No AWS credentials are available. All code must pass `pnpm typecheck` and `pnpm lint`.

**IMPORTANT:** SST v4 uses Ion (Pulumi-based). Use the `sst` v4 APIs — `new sst.aws.*` components. Check the installed SST version in the project and upgrade to v4 if needed (`pnpm add sst@latest --save-dev` at root). SST v4 docs: the `$config` export, `sst.aws.Vpc`, `sst.aws.Postgres`, `sst.aws.Cognito`, `sst.aws.ApiGatewayV2`, `sst.aws.Nextjs`, `sst.aws.Bucket`, etc.

Work in `infra/` and `sst.config.ts`:

1. **Update sst.config.ts** for SST v4:
   - Ensure correct v4 config format
   - Import and call all infra modules in the `run()` function
   - App name: `worldbank-mrv`, region: `us-east-1`
   - Stages: `dev`, `staging`, `prod` with appropriate settings

2. **infra/vpc.ts** — VPC:
   - 2 public subnets (NAT Gateway), 2 private app subnets, 2 private DB subnets
   - Export VPC for use by other infra modules
   - Use SST v4's VPC component or raw AWS provider if SST doesn't wrap VPC

3. **infra/database.ts** — Aurora Serverless v2 + RDS Proxy:
   - Aurora Serverless v2 PostgreSQL 15 cluster
   - Dev: 0.5-2 ACU, Prod: 2-16 ACU (use `$app.stage` to switch)
   - RDS Proxy for Lambda connection pooling
   - Secrets Manager for credentials
   - Place in private DB subnets
   - Export database connection info for Lambda functions

4. **infra/auth.ts** — Cognito:
   - Cognito User Pool with groups: `fmt`, `country`, `auditor`
   - App Client with SRP auth flow
   - Post-confirmation Lambda trigger (reference, don't implement handler yet)
   - Export User Pool ID and Client ID for frontend

5. **infra/storage.ts** — S3:
   - Bucket for file storage (PDF exports)
   - Block all public access
   - SSE-S3 encryption
   - Versioning enabled
   - Naming: `{stage}-worldbank-mrv-storage`

6. **infra/api.ts** — API Gateway + Lambda functions:
   - HTTP API (API Gateway v2) with JWT authorizer (Cognito)
   - CORS config: allow frontend domain, GET/POST/PUT/DELETE, Authorization/Content-Type headers
   - Route definitions for ALL endpoints from ARCHITECTURE.pdf Section 11:
     - Auth: POST /auth/callback, GET /auth/me, POST /auth/change-password
     - Templates: GET/POST /templates, GET/PUT/DELETE /templates/:id, POST /templates/:id/publish, POST /templates/:id/clone, POST /templates/:id/sections, PUT/DELETE /templates/:id/sections/:sectionId, PUT /templates/:id/sections/reorder
     - Reports: GET/POST /reports, GET/DELETE /reports/:id, PUT /reports/:id/sections/:sectionId, POST /reports/:id/validate, POST /reports/:id/submit, POST /reports/:id/request-revision, POST /reports/:id/approve, POST /reports/:id/forward-to-auditor, POST /reports/:id/complete, GET /reports/:id/revisions, GET /reports/:id/revisions/:revisionId, GET /reports/:id/revisions/:revisionId/diff, GET /reports/:id/export/pdf
     - Comments: GET/POST /reports/:id/comments, PUT /comments/:id, POST /comments/:id/resolve, POST /comments/:id/reopen
     - Organizations: GET/POST /organizations, PUT /organizations/:id, GET /organizations/:id/users, POST /organizations/:id/users, PUT /users/:id
     - Countries: GET/POST /countries, PUT /countries/:id, POST /countries/:id/assign-auditor
     - Notifications: GET /notifications, PUT /notifications/:id/read, POST /notifications/read-all, GET /notifications/unread-count
     - Health: GET /health
   - Each route points to a Lambda handler file in `packages/functions/src/` (create placeholder handler files)
   - Lambda config per ARCHITECTURE.pdf Section 13.2:
     - API handlers: 256 MB, 15s timeout
     - PDF export: 1024 MB, 60s timeout
     - Auth handlers: 256 MB, 10s timeout
     - DB migrations: 512 MB, 120s timeout
   - Link database, auth, and storage to functions that need them

7. **infra/web.ts** — Next.js frontend:
   - SST v4 `Nextjs` component
   - Environment variables: API URL, Cognito User Pool ID, Cognito Client ID, AWS region
   - CloudFront distribution (managed by SST)

8. **Create placeholder Lambda handlers** in `packages/functions/src/`:
   - One file per API group: `auth.ts`, `templates.ts`, `reports.ts`, `comments.ts`, `organizations.ts`, `countries.ts`, `notifications.ts`, `health.ts`, `exports.ts`
   - Each exports named handler functions matching the route definitions (stub implementations that return 501 Not Implemented)
   - Use the pattern: `export async function handler(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2>`

## Acceptance Criteria
- [ ] `sst.config.ts` updated for SST v4 format with all infra imports
- [ ] All 6 infra files implemented: vpc.ts, database.ts, auth.ts, storage.ts, api.ts, web.ts
- [ ] API routes cover ALL endpoints from ARCHITECTURE.pdf Section 11
- [ ] Lambda handler placeholder files exist for all API groups
- [ ] Lambda memory/timeout configs match Section 13.2
- [ ] Cognito User Pool has 3 groups (fmt, country, auditor)
- [ ] S3 bucket configured with no public access + encryption
- [ ] `pnpm typecheck` passes
- [ ] `pnpm lint` passes
- [ ] All existing tests still pass (134 tests)
- [ ] NO `sst dev` or `sst deploy` commands executed

## Code Repo Branch
feature/task-2-sst-infrastructure

## Coordinator Notes
Priority: HIGH — this wires everything together.
Branch from `feature/task-4a-core-business-logic` (latest approved task).
**SST v4 (Ion)** — NOT v3. Upgrade the sst package if needed.
Reference: ARCHITECTURE.pdf Sections 6 (VPC/Security Groups), 8 (Cognito), 11 (API endpoints), 13 (Infrastructure config).
CODE ONLY — no deployments. No AWS credentials available.
The `.sst/` types won't fully resolve without `sst dev`, but the code should be structurally correct TypeScript.
If SST v4 types aren't available without running sst, use type assertions or `any` casts sparingly — prefer structural correctness over perfect types.

## Worker Notes
(none yet)

## Revision History
(none)
