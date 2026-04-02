# PROJECT: World Bank MRV System

## Overview

Next Generation MRV (Monitoring, Reporting, and Verification) Prototype for the World Bank's Department for Climate Change. Enables online collaboration on ISFL Monitoring Reports between World Bank (FMT), Participating Countries, and Auditor Entities.

**Client:** World Bank — Department for Climate Change
**Type:** Prototype / MVP
**Code Repo:** `appgambit/worldbank-poc`

---

## Scope Constraints (from SOW)

- English-only, web-only (no mobile)
- MVP limited to maximum 2 participating countries
- AWS Consumer infrastructure (not GovCloud)
- No 3rd party integrations
- ISFL Monitoring Report template only

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Runtime | Node.js | 20 LTS |
| Frontend | Next.js (App Router) + React + TypeScript | Next.js 14+, React 18+ |
| UI Framework | Tailwind CSS + Catalyst (Tailwind UI premium kit) | Tailwind 3.4+ |
| Backend | AWS Lambda (Node.js) via SST v3 | SST Ion (v3) |
| Infrastructure as Code | SST v3 (Pulumi) | Latest |
| Database | Aurora Serverless v2 (PostgreSQL) | PostgreSQL 15 |
| ORM | Drizzle ORM | Latest |
| Authentication | Amazon Cognito | - |
| Storage | Amazon S3 | - |
| Rich Text Editor | TipTap | v2 |
| PDF Export | @react-pdf/renderer | - |
| Testing | Vitest (unit/integration), Playwright (E2E) | - |
| Package Manager | pnpm | 9+ |
| Monorepo | pnpm workspaces | - |

**Note on IaC:** SOW specifies "AWS CDK and/or Serverless." We use SST v3 (Pulumi-based), which provides higher-level serverless constructs on AWS. Deviation should be approved by client.

---

## AWS Services

Aurora Serverless v2, Lambda, API Gateway (HTTP API), Cognito, S3, CloudFront, Route 53, ACM, WAF, VPC, RDS Proxy, Secrets Manager, SES, CloudWatch, IAM

**Region:** us-east-1

---

## User Roles & Access Control

| Role | Cognito Group | Description |
|------|--------------|-------------|
| FMT Admin | `fmt` | Full system admin -- manage templates, orgs, users, review reports |
| Country User | `country` | Fill and submit reports, handle revisions |
| Auditor | `auditor` | Review assigned reports, mark complete |

Full RBAC authorization matrix defined in ARCHITECTURE.pdf Section 7.2.

**Data Isolation:**
- Country users: scoped to their `organization_id`
- Auditor users: scoped to countries where `auditor_organization_id = user.organization_id`
- FMT users: full admin scope

---

## Report Workflow State Machine

```
DRAFT -> SUBMITTED_TO_FMT -> FMT_REVIEW_IN_PROGRESS -> FMT_APPROVED -> SUBMITTED_TO_AUDITOR -> AUDITOR_REVIEW_IN_PROGRESS -> COMPLETED
                                    |                                          |
                                    v                                          v
                          FMT_REVISION_REQUESTED -> DRAFT            AUDITOR_REVISION_REQUESTED -> DRAFT
```

9 states, with revision cycles at both FMT and Auditor stages. Full transition rules with guard conditions in ARCHITECTURE.pdf Section 10.

---

## Database Schema

11 tables: `organizations`, `users`, `countries`, `report_templates`, `template_sections`, `reports`, `report_sections`, `report_revisions`, `comments`, `change_records`, `notifications`, `audit_log`

Full schema with columns, constraints, indexes, and seed data in DBSCHEMA.pdf. Also mirrored in ARCHITECTURE.pdf Section 9.

---

## Project Structure (Monorepo)

```
worldbank-poc/
├── sst.config.ts              # SST v3 configuration
├── infra/                     # SST infrastructure definitions
│   ├── vpc.ts, database.ts, auth.ts, storage.ts, api.ts, email.ts, monitoring.ts, web.ts
├── packages/
│   ├── core/                  # Business logic & domain models
│   │   └── src/ (domain/, services/, auth/, utils/)
│   ├── db/                    # Database layer (Drizzle schema, migrations, seed)
│   ├── functions/             # Lambda function handlers
│   │   └── src/ (middleware/, auth/, templates/, reports/, comments/, organizations/, notifications/, exports/)
│   └── web/                   # Next.js frontend
│       └── src/ (app/, components/, hooks/, lib/, styles/)
├── docs/
├── .github/workflows/deploy.yml
├── pnpm-workspace.yaml
├── package.json
└── tsconfig.json
```

---

## Implementation Phases

| Phase | Name | Duration | Risk | Dependencies |
|-------|------|----------|------|-------------|
| 0 | Design & Technical Spikes | 1 sprint | MEDIUM | None |
| 1 | Foundation & Infrastructure | 2 sprints | MEDIUM | Phase 0 |
| 2 | Organization & User Management | 1.5 sprints | LOW | Phase 1 |
| 3 | Report Template Management | 2 sprints | MEDIUM-HIGH | Phase 1 (can parallel Phase 2 backend) |
| 4 | Report Creation & Filling | 1.5 sprints | MEDIUM | Phase 3 |
| 5 | Submission & FMT Review | 2.5 sprints | HIGH | Phase 4 |
| 6 | Auditor Review & Completion | 1 sprint | LOW-MEDIUM | Phase 5 |
| 7 | PDF Export & Email Notifications | 1.5 sprints | MEDIUM | Phase 6 |
| 8 | Polish, Security Hardening & UAT | 1.5 sprints | LOW | Phase 7 |

**Total estimated: ~14.5 sprints**

**Parallelization opportunities:**
- Phase 2 backend and Phase 3 backend can run in parallel (different domains, both depend only on Phase 1)
- PDF export (Phase 7) can begin during Phase 6 using mock data
- In-app notifications infrastructure starts in Phase 5

Detailed task breakdowns with acceptance criteria in PHASES.pdf.

---

## API Specification

~40+ endpoints across 7 groups: Auth, Templates, Reports, Comments, Organizations/Users, Countries, Notifications. Full spec in ARCHITECTURE.pdf Section 11.

---

## Assumptions

1. Catalyst (Tailwind UI premium kit) license is available for the project
2. AWS account with appropriate permissions will be provided
3. Custom domain and Route 53 hosted zone will be configured
4. SES will be moved out of sandbox for production email sending
5. Client will provide World Bank logo asset for PDF cover page
6. "Sprint" duration not yet defined -- assuming 2-week sprints (total ~29 weeks / ~7 months)

---

## Open Questions

1. **Region discrepancy:** Architecture doc specifies `us-east-1`. CEO default region is `ap-south-1` (Mumbai). Which region should we use? World Bank may have data residency preferences.

2. **Code repo:** Does `appgambit/worldbank-poc` already exist on GitHub, or should we create it?

3. **AWS account:** Which AWS account/profile should workers use for `sst dev` and deployments? Are credentials configured?

4. **Catalyst license:** Do we have access to the Tailwind UI / Catalyst premium component kit?

5. **Phase 0 scope:** The wireframes/Figma deliverable in Phase 0 requires design tooling. Should we skip Phase 0 (spikes + wireframes) and go straight to Phase 1 (code), treating the architecture docs as the approved design? Or do you want wireframes produced first?

6. **Sprint duration:** Assuming 2-week sprints. Confirm?

7. **Target delivery date:** Is there a deadline from the World Bank?

---

## Reference Documents

All in `projects/mrv-prototype/docs/`:
- `ARCHITECTURE.pdf` — 20-page technical architecture & API specification
- `DBSCHEMA.pdf` — 10-page database schema with ERD, table definitions, seed data
- `PHASES.pdf` — 16-page implementation phases with detailed task breakdowns
- `architecture-diagram.drawio (2).png` — AWS architecture diagram

---

*Status: DISCOVERY*
*Created: 2026-04-02*
