# COMM — mrv-prototype

## Status
WAITING_FOR_WORKER

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
- [ ] All auth helpers implemented with correct RBAC logic per ARCHITECTURE.pdf Section 7
- [ ] All error classes match the API error response format in Section 11.1
- [ ] Pagination helper supports cursor-based pagination
- [ ] Zod validation wrapper returns field-level error details
- [ ] Report workflow state machine implements ALL valid transitions from Section 10.2
- [ ] State machine guard conditions implemented per Section 10.3
- [ ] Unit tests for report workflow: test every valid transition returns true, every invalid returns false
- [ ] Unit tests for RBAC helpers: test FMT/Country/Auditor access patterns
- [ ] Zod schemas exist for all major API request bodies
- [ ] `pnpm typecheck` passes
- [ ] `pnpm lint` passes
- [ ] `pnpm test` passes with all new tests green

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
(none yet)

## Revision History
(none)
