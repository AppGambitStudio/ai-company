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

### Task 8a: Database Migration & Seed Data (First User)
- Run Drizzle migration against the deployed Aurora database to create all tables and enums
- Create Cognito user groups (`fmt`, `country`, `auditor`) via AWS SDK or CLI
- Create the first FMT admin user in Cognito (assign to `fmt` group)
- Run the seed script to populate: FMT org, 2 country orgs, 1 auditor org, 2 countries (Ethiopia, Colombia)
- Create the FMT admin user record in the `users` table (linked to Cognito sub)
- Verify: user can log in via the deployed frontend, sees the dashboard
- **This is a deployment/ops task** — can be done by Coordinator or Worker
- **Branch:** `feature/task-8a-seed-data`

### Task 9: Organizations — Full Vertical Slice (Backend + Frontend)
**Backend:**
- Organization service in `packages/core/src/services/organization-service.ts`
- Implement `GET /organizations` — list with cursor pagination, filter by `type`
- Implement `POST /organizations` — create (FMT only, Zod validation)
- Implement `PUT /organizations/:id` — update name/status (FMT only)
- RBAC: only FMT group can access org endpoints
- Unit tests for organization service

**Frontend:**
- Organizations list page (`/admin/organizations`) — table with type badges (WORLD_BANK, COUNTRY, AUDITOR), search, pagination
- Create organization — dialog/modal with form (name, type dropdown)
- Organization detail page (`/admin/organizations/[id]`) — org info header
- Loading skeletons + empty states
- React Query hooks for data fetching + cache invalidation

**Deploy & verify end-to-end**
- **Branch:** `feature/task-9-organizations`

### Task 10: Users & Invites — Full Vertical Slice (Backend + Frontend)
**Backend:**
- User service in `packages/core/src/services/user-service.ts`
- Implement `GET /organizations/:id/users` — list users in org
- Implement `POST /organizations/:id/users` — invite user (create Cognito user with temp password, assign to correct group based on org type, create DB record)
- Implement `PUT /users/:id` — update profile/role/status (FMT or self)
- Deactivate user: set status to INACTIVE, disable Cognito user
- RBAC: FMT manages all users; users can update own profile
- Unit tests for user service

**Frontend:**
- Organization detail page — add user list table below org info
- Invite user — dialog with form (email, first name, last name, role)
- User status toggle (activate/deactivate) with confirmation dialog
- Loading skeletons + empty states for user list

**Deploy & verify:** invite a user, check Cognito + DB, verify they can log in
- **Branch:** `feature/task-10-users-invites`

### Task 11: Countries & Auditors — Full Vertical Slice (Backend + Frontend)
**Backend:**
- Country service in `packages/core/src/services/country-service.ts`
- Implement `GET /countries` — list with org and auditor info (joined)
- Implement `POST /countries` — create (link to existing COUNTRY org)
- Implement `PUT /countries/:id` — update name
- Implement `POST /countries/:id/assign-auditor` — assign/reassign auditor org (validate org type is AUDITOR)
- Unit tests for country service

**Frontend:**
- Countries list page (`/admin/countries`) — table with country name, ISO code, organization, assigned auditor
- Create country — dialog with form (name, ISO code, link to org)
- Assign auditor — dropdown of auditor organizations on country row
- Loading skeletons + empty states

**Deploy & verify end-to-end**
- **Branch:** `feature/task-11-countries-auditors`

### Task 12: Notifications & Polish — Full Vertical Slice (Backend + Frontend)
**Backend:**
- Implement `GET /notifications` — list user's notifications with pagination
- Implement `PUT /notifications/:id/read` — mark single as read
- Implement `POST /notifications/read-all` — mark all as read
- Implement `GET /notifications/unread-count` — return count for bell badge

**Frontend:**
- Notifications page (`/notifications`) — list with read/unread styling, mark-as-read button
- Wire notification bell in sidebar header to real unread count (replace hardcoded `3`)
- "Mark all as read" button
- Loading skeletons + empty state

**Deploy & verify end-to-end**
- **Branch:** `feature/task-12-notifications`

## Milestone 3: Report Template Management (Phase 3)
(Not yet broken down)

## Milestone 4: Report Creation & Filling (Phase 4)
(Not yet broken down)

## Milestone 5: Submission & FMT Review (Phase 5)
(Not yet broken down)
