# COMM — mrv-prototype

## Status
DONE_AWAITING_REVIEW

## Timestamps
- Created: 2026-04-02T12:15:00Z
- Last updated: 2026-04-02T13:50:00Z
- Task assigned: 2026-04-02T13:50:00Z

## Current Task
Task 4a: Core Business Logic & API Utilities (no AWS required)

## Task Details
Build the shared business logic layer in `packages/core` that all Lambda handlers will use. This can be written and unit-tested without AWS credentials. The actual Lambda handlers and SST wiring come in Task 2 + Task 4b.

Work in `packages/core/src/`:

1. **Auth types & helpers** — `packages/core/src/auth/`:
   - `types.ts` — define `UserContext` type: `{ userId: string; cognitoSub: string; email: string; organizationId: string; role: 'ADMIN' | 'MEMBER'; groups: ('fmt' | 'country' | 'auditor')[]; orgType: 'WORLD_BANK' | 'COUNTRY' | 'AUDITOR' }`
   - `rbac.ts` — RBAC helper functions:
     - `requireRole(context: UserContext, ...roles: string[]): void` — throws 403 if user not in role
     - `requireGroup(context: UserContext, ...groups: string[]): void` — throws 403 if user not in group
     - `isFmt(context: UserContext): boolean`
     - `isCountry(context: UserContext): boolean`
     - `isAuditor(context: UserContext): boolean`
   - `scope.ts` — Data isolation helpers:
     - `scopeByOrganization(context: UserContext): { organizationId: string }` — returns org filter for queries
     - `canAccessReport(context: UserContext, report: { countryId: string; country: { organizationId: string; auditorOrganizationId?: string } }): boolean`
   - `index.ts` — barrel export

2. **API utilities** — `packages/core/src/api/`:
   - `errors.ts` — structured error classes matching ARCHITECTURE.pdf Section 11.1:
     - `AppError` base class with `code`, `message`, `statusCode`, `details`
     - `ValidationError` (400), `UnauthorizedError` (401), `ForbiddenError` (403), `NotFoundError` (404), `ConflictError` (409), `InternalError` (500)
     - `formatErrorResponse(error: AppError): { error: { code: string; message: string; details?: any } }`
   - `pagination.ts` — cursor pagination helper:
     - `parsePaginationParams(query: { limit?: string; cursor?: string }): { limit: number; cursor?: string }`
     - `buildPaginatedResponse<T>(data: T[], limit: number, cursorField: string): { data: T[]; meta: { pageSize: number; total?: number; nextCursor?: string } }`
   - `validation.ts` — Zod validation wrapper:
     - `validateBody<T>(schema: ZodSchema<T>, body: unknown): T` — throws ValidationError with field-level details on failure
     - `validateQuery<T>(schema: ZodSchema<T>, query: unknown): T`
   - `index.ts` — barrel export

3. **Audit log helper** — `packages/core/src/audit/`:
   - `audit.ts` — `logAction(db: any, userId: string, action: string, entityType: string, entityId: string, metadata?: Record<string, unknown>): Promise<void>`
   - Types for common actions: `report.submit`, `report.revision`, `template.publish`, `comment.create`, `user.invite`
   - `index.ts` — barrel export

4. **Report workflow state machine** — `packages/core/src/services/`:
   - `report-workflow.ts` — implements the state machine from ARCHITECTURE.pdf Section 10:
     - Define valid transitions map
     - `canTransition(currentStatus: ReportStatus, targetStatus: ReportStatus): boolean`
     - `getValidTransitions(currentStatus: ReportStatus): ReportStatus[]`
     - `validateTransition(currentStatus: ReportStatus, targetStatus: ReportStatus, context: { allSectionsComplete?: boolean; hasOpenComments?: boolean; hasAssignedAuditor?: boolean }): { valid: boolean; reason?: string }`
     - Guard conditions per ARCHITECTURE.pdf Section 10.3
   - Unit tests in `report-workflow.test.ts` — test every valid transition AND every invalid transition

5. **Zod domain schemas** — `packages/core/src/domain/`:
   - `schemas.ts` — Zod schemas for API request validation:
     - `createOrganizationSchema`, `updateOrganizationSchema`
     - `inviteUserSchema`, `updateUserSchema`
     - `createCountrySchema`, `updateCountrySchema`, `assignAuditorSchema`
     - `createTemplateSchema`, `updateTemplateSchema`
     - `createSectionSchema`, `updateSectionSchema`, `reorderSectionsSchema`
     - `saveReportSectionSchema` (content jsonb, is_complete boolean)
     - `createCommentSchema`, `updateCommentSchema`
   - `index.ts` — barrel export

6. **Update root barrel** — `packages/core/src/index.ts` exporting all modules

## Acceptance Criteria
- [x] All auth helpers implemented with correct RBAC logic per ARCHITECTURE.pdf Section 7
- [x] All error classes match the API error response format in Section 11.1
- [x] Pagination helper supports cursor-based pagination
- [x] Zod validation wrapper returns field-level error details
- [x] Report workflow state machine implements ALL valid transitions from Section 10.2
- [x] State machine guard conditions implemented per Section 10.3
- [x] Unit tests for report workflow: test every valid transition returns true, every invalid returns false
- [x] Unit tests for RBAC helpers: test FMT/Country/Auditor access patterns
- [x] Zod schemas exist for all major API request bodies
- [x] `pnpm typecheck` passes
- [x] `pnpm lint` passes
- [x] `pnpm test` passes with all new tests green

## Code Repo Branch
feature/task-4a-core-business-logic

## Coordinator Notes
Priority: HIGH — this is the logic layer that all API handlers will import.
Branch from `feature/task-3-database-schema` (Task 3 approved).
Reference: ARCHITECTURE.pdf Sections 7 (RBAC), 10 (State Machine), 11 (API Spec).
Read the ARCHITECTURE.pdf for the RBAC matrix, state transitions, and error format.
Add `zod` as a dependency to `packages/core`.
Write real unit tests — this is critical business logic. Use Vitest.
No AWS needed — pure TypeScript logic + tests.

## Worker Notes
- 2026-04-02: Started work on Task 4a. Read ARCHITECTURE.pdf sections 7, 10, 11 for RBAC, state machine, and API error format.
- 2026-04-02: COMPLETED. All modules implemented and tested. Summary:

### What was built (22 files, 1203 lines added)

**Auth module** (`packages/core/src/auth/`):
- `types.ts` — `UserContext` type with userId, cognitoSub, email, organizationId, role, groups, orgType
- `rbac.ts` — `requireRole()`, `requireGroup()` (throw ForbiddenError), `isFmt()`, `isCountry()`, `isAuditor()`
- `scope.ts` — `scopeByOrganization()`, `canAccessReport()` with data isolation per Section 7.3 (FMT=all, Country=own org, Auditor=assigned countries)
- 19 unit tests covering all RBAC patterns

**API utilities** (`packages/core/src/api/`):
- `errors.ts` — `AppError` base + `ValidationError`(400), `UnauthorizedError`(401), `ForbiddenError`(403), `NotFoundError`(404), `ConflictError`(409), `InternalError`(500) + `formatErrorResponse()` matching Section 11.1 envelope
- `pagination.ts` — `parsePaginationParams()` (default 20, max 100) + `buildPaginatedResponse()` with cursor
- `validation.ts` — `validateBody()`, `validateQuery()` wrapping Zod with field-level error details
- 22 unit tests for errors, pagination, and validation

**Audit module** (`packages/core/src/audit/`):
- `audit.ts` — `logAction()` + `AuditAction` type for common actions (report.submit, report.revision, template.publish, etc.)

**Report workflow state machine** (`packages/core/src/services/`):
- `report-workflow.ts` — All 10 valid transitions from Section 10.2, all 6 guard conditions from Section 10.3
- Guard: DRAFT→SUBMITTED_TO_FMT requires allSectionsComplete
- Guard: FMT_REVIEW→FMT_REVISION_REQUESTED requires hasOpenComments
- Guard: FMT_REVIEW→FMT_APPROVED requires !hasOpenComments
- Guard: FMT_APPROVED→SUBMITTED_TO_AUDITOR requires hasAssignedAuditor
- Guard: AUDITOR_REVIEW→AUDITOR_REVISION_REQUESTED requires hasOpenComments
- Guard: AUDITOR_REVIEW→COMPLETED requires !hasOpenComments
- 93 unit tests: every valid transition returns true, every invalid pair returns false, all guards tested

**Domain schemas** (`packages/core/src/domain/`):
- 15 Zod schemas for all API request bodies: organizations, users, countries, templates, sections, reports, comments

**Root barrel** (`packages/core/src/index.ts`): re-exports all modules

### Verification
- `pnpm typecheck` — passes
- `pnpm lint` — passes (0 errors)
- `pnpm test` — 134 tests, 5 test files, all passing

### Dependencies added
- `zod` added to `packages/core`

### Design decisions
- RBAC helpers throw `ForbiddenError` directly (consistent with API error classes)
- `canAccessReport()` implements Section 7.3 data isolation: FMT sees all, Country sees own org, Auditor sees assigned countries
- Pagination uses "fetch limit+1" pattern to detect hasMore without separate count query
- Audit `logAction()` accepts a generic db interface to avoid coupling to drizzle schema (will be wired in Task 4b)
- State machine uses string-based transition key (`from->to`) for clean guard condition dispatch

## Revision History
(none)
