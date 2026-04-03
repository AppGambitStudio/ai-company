# MILESTONES — mrv-prototype

## Milestone 1: Project Foundation & Infrastructure (Phase 1)

**Target:** 2026-04-16 (First DEMO)
**Demo goal:** Login works, role-based dashboard visible, authenticated API call (`GET /auth/me`) returns user profile, infrastructure deployed to dev.

### Task 1: Monorepo Scaffolding & Tooling
- Initialize pnpm workspace monorepo (`pnpm-workspace.yaml`)
- Initialize SST v3 project (`sst.config.ts`) targeting us-east-1
- Set up TypeScript configuration (root `tsconfig.json` + per-package configs)
- Configure ESLint (flat config) + Prettier
- Create package structure: `core`, `db`, `functions`, `web`
- Set up Vitest for unit/integration testing (config in root + per-package)
- Add `lint`, `typecheck`, `test` scripts to root `package.json`
- **Branch:** `feature/task-1-monorepo-scaffolding`

### Task 2: SST Infrastructure — VPC, Database, Auth, Storage
- VPC: 2 public subnets (NAT Gateway), 2 private app subnets, 2 private DB subnets
- Security groups: Lambda SG, RDS Proxy SG, Aurora SG (per ARCHITECTURE.pdf Section 6)
- VPC endpoints: S3 (gateway), Secrets Manager (interface)
- Aurora Serverless v2 PostgreSQL cluster (dev: 0.5-2 ACU)
- RDS Proxy for Lambda connection pooling
- Cognito User Pool with groups: `fmt`, `country`, `auditor`
- Cognito App Client (SRP auth flow)
- S3 bucket for file storage (block public access, SSE-S3 encryption)
- API Gateway HTTP API with JWT authorizer (Cognito)
- Next.js site deployment via SST `Nextjs` construct
- Secrets Manager for database credentials
- **Branch:** `feature/task-2-sst-infrastructure`

### Task 3: Database Schema & Seed Data
- Set up Drizzle ORM with `postgres` driver in `packages/db`
- Define all enums (org_type, user_status, template_status, report_status, etc.)
- Define schema: `organizations`, `users`, `countries`
- Define schema: `report_templates`, `template_sections`
- Define schema: `reports`, `report_sections`, `report_revisions`
- Define schema: `comments`, `change_records`
- Define schema: `notifications`, `audit_log`
- Generate initial migration with Drizzle Kit
- Create seed script: FMT organization + admin user + 2 sample countries + auditor org
- Verify seed runs successfully in dev
- **Branch:** `feature/task-3-database-schema`

### Task 4: API Foundation & Auth
- Lambda middleware: extract user context from JWT claims (sub, groups, organization_id)
- Lambda middleware: Zod request body validation
- Lambda middleware: structured JSON error responses (per ARCHITECTURE.pdf Section 11.1)
- Lambda middleware: structured JSON logging (CloudWatch)
- RBAC helper in `packages/core/src/auth/`: `requireRole()`, `requireOwnership()`
- Data isolation helper: `scopeByOrganization(userId)` for query scoping
- Audit log helper: `logAction(userId, action, entityType, entityId, metadata)`
- Health check endpoint: `GET /health`
- CORS configuration on API Gateway
- Cognito User Pool integration via SST (linked to API)
- API Gateway JWT authorizer configured
- `GET /auth/me` endpoint (returns user profile from DB, matched by `cognito_sub`)
- Post-confirmation Lambda trigger: create user record in DB when Cognito user is confirmed
- Unit tests for RBAC helpers and auth middleware
- **Branch:** `feature/task-4-api-foundation`

### Task 5: Frontend Foundation & Auth Pages
- Initialize Next.js app with App Router in `packages/web`
- Install and configure Tailwind CSS + Catalyst component library
- Set up app layout with Catalyst `SidebarLayout`:
  - Sidebar with navigation items (per-role visibility)
  - Header with user menu dropdown
  - Notification bell placeholder (wired in Phase 5)
- Auth pages: login, forgot password, reset password (using Amplify Auth + Catalyst forms)
- Auth context provider (wraps Amplify, provides user/role to components)
- Protected route wrapper (redirect to /login if unauthenticated)
- API client: fetch wrapper with `Authorization: Bearer` header, error handling, auto-retry on token refresh
- React Query (TanStack Query) provider configured
- Loading skeleton component (reusable)
- Error boundary with Catalyst-styled error page
- Empty state component (reusable)
- **Branch:** `feature/task-5-frontend-foundation`

---

## Milestone 2: Organization & User Management (Phase 2)

**Target:** 2026-04-16 (First DEMO)
**Demo goal:** FMT admin can create organizations, invite users (Cognito email sent), manage countries, assign auditors. RBAC enforced — non-FMT users get 403 on admin pages.

### Task 7: Phase 1 Gap Closure — DB Client, Migrations, Logging
- Wire up `packages/db/src/index.ts` with a proper Drizzle client using SST Resource binding (`Resource.Database`)
- Generate initial Drizzle migration with `drizzle-kit generate`
- Add `drizzle.config.ts` for migration tooling
- Add structured JSON logging middleware to `packages/core/src/api/`
- Add `infra/email.ts` (SES configuration) — needed for Cognito invite emails in Phase 2
- Unit tests for logging middleware
- **Branch:** `feature/task-7-phase1-gaps`

### Task 8: Backend — Organizations API
- Implement `GET /organizations` — list with cursor pagination, filter by `type`
- Implement `POST /organizations` — create (FMT only, validate with Zod)
- Implement `PUT /organizations/:id` — update name/status (FMT only)
- RBAC: only FMT group can access all org endpoints
- Organization service layer in `packages/core/src/services/`
- Unit tests for organization service
- Integration tests for organization endpoints (mock DB or test helpers)
- **Branch:** `feature/task-8-organizations-api`

### Task 9: Backend — User & Country Management API
- Implement `GET /organizations/:id/users` — list users in org
- Implement `POST /organizations/:id/users` — invite user (create Cognito user with temp password, assign to correct group, create DB record, Cognito sends invite email)
- Implement `PUT /users/:id` — update profile/role/status (FMT or self)
- Deactivate user: set status to INACTIVE, disable Cognito user
- Implement `GET /countries` — list with org and auditor info
- Implement `POST /countries` — create (link to existing COUNTRY org)
- Implement `PUT /countries/:id` — update name
- Implement `POST /countries/:id/assign-auditor` — assign/reassign auditor org (validate auditor org type)
- RBAC: FMT manages all users; users can update own profile
- Unit tests for user and country services
- **Branch:** `feature/task-9-users-countries-api`

### Task 10: Frontend — Admin Pages
- Organizations list page — table with type badges, search, cursor pagination
- Create organization — dialog/modal with form (name, type dropdown)
- Organization detail page — org info + user list table
- Invite user — dialog with form (email, first name, last name, role)
- User status toggle (activate/deactivate) with confirmation
- Countries list page — table with assigned auditor column
- Create country — dialog with form (name, ISO code, link to org)
- Assign auditor — dropdown of auditor organizations
- Loading skeletons for all list pages
- Empty states for no organizations / no users / no countries
- All pages use React Query for data fetching + cache invalidation
- **Branch:** `feature/task-10-admin-frontend`

### Task 11: Milestone 2 Integration & Testing
- Wire frontend pages to backend APIs end-to-end
- Verify RBAC: Country/Auditor users cannot access admin pages (403 redirect)
- Verify pagination works on all list pages
- Verify invite user flow: Cognito user created, email sent, DB record exists
- Fix any integration issues found
- **Branch:** `feature/task-11-integration-testing`

## Milestone 3: Report Template Management (Phase 3)
(Not yet broken down)

## Milestone 4: Report Creation & Filling (Phase 4)
(Not yet broken down)

## Milestone 5: Submission & FMT Review (Phase 5)
(Not yet broken down)
