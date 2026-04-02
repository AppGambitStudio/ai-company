# COMM — mrv-prototype

## Status
WAITING_FOR_WORKER

## Timestamps
- Created: 2026-04-02T12:15:00Z
- Last updated: 2026-04-02T13:15:00Z
- Task assigned: 2026-04-02T13:15:00Z

## Current Task
Task 3: Database Schema & Seed Data (moved ahead of Task 2 — SST infra blocked on AWS creds)

## Task Details
Define the complete database schema using Drizzle ORM in `packages/db`. This can be done locally without AWS credentials. Task 2 (SST infrastructure) will be done once credentials are available.

Work in `packages/db/src/`:

1. **Set up Drizzle config** — `drizzle.config.ts` in `packages/db/` (use placeholder connection string for now, actual connection via SST Resource bindings later)
2. **Define enums** in `packages/db/src/schema/enums.ts`:
   - `org_type`: WORLD_BANK, COUNTRY, AUDITOR
   - `user_status`: ACTIVE, INACTIVE
   - `user_role`: ADMIN, MEMBER
   - `template_status`: DRAFT, PUBLISHED, ARCHIVED
   - `editor_type`: RICH_TEXT, TABLE
   - `report_status`: DRAFT, SUBMITTED_TO_FMT, FMT_REVIEW_IN_PROGRESS, FMT_REVISION_REQUESTED, FMT_APPROVED, SUBMITTED_TO_AUDITOR, AUDITOR_REVIEW_IN_PROGRESS, AUDITOR_REVISION_REQUESTED, COMPLETED
   - `comment_status`: OPEN, RESOLVED
   - `notification_type`: REPORT_SUBMITTED, REVISION_REQUESTED, REPORT_RESUBMITTED, REPORT_COMPLETED, NEW_TEMPLATE_VERSION
3. **Define tables** in separate files under `packages/db/src/schema/`:
   - `organizations.ts` — organizations table (id uuid PK, name, type, status, timestamps)
   - `users.ts` — users table (id uuid PK, cognito_sub UQ, email UQ, first_name, last_name, organization_id FK, role, status, last_login_at, timestamps)
   - `countries.ts` — countries table (id uuid PK, name, iso_code UQ, organization_id FK UQ, auditor_organization_id FK nullable, timestamps)
   - `report-templates.ts` — report_templates (id, name, description, version, status, template_group_id, created_by FK, published_at, timestamps)
   - `template-sections.ts` — template_sections (id, template_id FK CASCADE, title, instructions jsonb, editor_type, editor_config jsonb, sample_data jsonb nullable, sort_order, timestamps)
   - `reports.ts` — reports (id, template_id FK, template_version, country_id FK, status, current_revision, created_by FK, submitted_at, completed_at, timestamps)
   - `report-sections.ts` — report_sections (id, report_id FK CASCADE, template_section_id FK, content jsonb, is_complete boolean, last_edited_by FK, last_edited_at, version int for optimistic locking, timestamps)
   - `report-revisions.ts` — report_revisions (id, report_id FK CASCADE, revision_number, content_snapshot jsonb, submitted_by FK, submitted_to varchar, submitted_at, timestamps)
   - `comments.ts` — comments (id, report_id FK CASCADE, section_id FK, revision_id FK, parent_comment_id FK nullable for threading, author_id FK, content text, status, resolved_by FK nullable, resolved_at, timestamps)
   - `change-records.ts` — change_records (id, report_id FK CASCADE, section_id FK, from_revision_id FK, to_revision_id FK, previous_content jsonb, new_content jsonb, created_at)
   - `notifications.ts` — notifications (id, user_id FK CASCADE, type, title, message, link nullable, is_read boolean, created_at)
   - `audit-log.ts` — audit_log (id, user_id FK, action, entity_type, entity_id, metadata jsonb nullable, created_at)
4. **Create barrel export** — `packages/db/src/schema/index.ts` re-exporting all tables and enums
5. **Define indexes** per DBSCHEMA.pdf:
   - users: idx_users_cognito_sub, idx_users_email, idx_users_organization_id
   - countries: idx_countries_organization_id, idx_countries_auditor_organization_id
   - report_templates: idx_templates_group_status_version, idx_templates_status
   - template_sections: idx_template_sections_template_order
   - reports: idx_reports_country_status, idx_reports_status, idx_reports_template_id
   - report_sections: idx_report_sections_report_id
   - report_revisions: idx_revisions_report_number
   - comments: idx_comments_report_section, idx_comments_report_status
   - change_records: idx_change_records_report_section
   - notifications: idx_notifications_user_unread
   - audit_log: idx_audit_entity, idx_audit_user
6. **Create seed script** — `packages/db/src/seed.ts`:
   - FMT Organization: ('org-fmt-001', 'World Bank FMT', 'WORLD_BANK')
   - FMT Admin User: ('usr-admin-001', 'admin@worldbank.org', 'FMT', 'Admin', org-fmt-001, 'ADMIN')
   - Country Orgs: Ethiopia Climate Authority, Colombia Environmental Agency
   - Countries: Ethiopia (ETH), Colombia (COL) linked to their orgs
   - Auditor Org: Global Audit Partners
   - Note: cognito_sub for admin will be 'cognito-sub-placeholder' until real Cognito user exists
7. **Generate initial migration** with Drizzle Kit: `pnpm --filter db run generate`
8. **Update packages/db/src/index.ts** to export schema and seed function

## Acceptance Criteria
- [ ] All 11 tables defined with correct columns, types, and constraints per DBSCHEMA.pdf
- [ ] All enums defined matching the specification exactly
- [ ] All foreign keys with correct ON DELETE behavior (CASCADE vs RESTRICT vs SET NULL)
- [ ] All indexes defined per DBSCHEMA.pdf
- [ ] Seed script exists with FMT org + admin + 2 countries + auditor org
- [ ] Drizzle config exists (even if connection string is placeholder)
- [ ] Migration files generated successfully via `pnpm --filter db run generate`
- [ ] `pnpm typecheck` passes from repo root
- [ ] `pnpm lint` passes from repo root
- [ ] All existing tests still pass

## Code Repo Branch
feature/task-3-database-schema

## Coordinator Notes
Priority: HIGH — unblocks Task 4 (API foundation) and all feature work.
Reference: `/Users/dhaval/Documents/work/antigravity/ai-company/projects/mrv-prototype/docs/DBSCHEMA.pdf` has the complete schema spec with ERD, table definitions, indexes, constraints, and seed data.
The DBSCHEMA.pdf is the authoritative source — match it exactly.
Branch from `feature/task-1-monorepo-scaffolding` (Task 1 approved, not yet merged to main).
No AWS credentials yet — use a placeholder DATABASE_URL in drizzle config. Drizzle Kit can generate migrations without a live DB.

## Worker Notes
(none yet)

## Revision History
(none)
