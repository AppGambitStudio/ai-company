# COMM — mrv-prototype

## Status
IN_PROGRESS

## Timestamps
- Created: 2026-04-02T12:15:00Z
- Last updated: 2026-04-02T15:58:00Z
- Task assigned: 2026-04-02T15:58:00Z

## Current Task
Task 5: Frontend Foundation & Auth Pages

## Task Details
Initialize the Next.js frontend in `packages/web` with authentication, layout, and shared components. This builds the shell that all future UI work slots into.

Work in `packages/web/`:

1. **Tailwind CSS + Catalyst component library:**
   - Install Tailwind CSS (should already be in Next.js setup from Task 1)
   - Install and configure Catalyst (Tailwind UI React component library)
   - If Catalyst requires a license/private npm registry, use Headless UI + Tailwind as fallback and note it in worker notes

2. **App layout with sidebar (Catalyst `SidebarLayout` or equivalent):**
   - Sidebar navigation with items visible per role:
     - All roles: Dashboard, Reports, Notifications
     - `fmt` role: Organizations, Countries, Templates, Users
     - `country` role: My Organization
     - `auditor` role: Assigned Countries
   - Header with user menu dropdown (name, role, sign out)
   - Notification bell placeholder (badge with unread count — hardcoded for now)
   - Responsive: sidebar collapses on mobile

3. **Auth pages:**
   - `/login` — email + password form, calls Cognito via Amplify Auth (or `amazon-cognito-identity-js`)
   - `/forgot-password` — email form, triggers Cognito forgot-password flow
   - `/reset-password` — code + new password form, completes the reset flow
   - All forms use Catalyst/Headless UI components, show validation errors, loading states
   - On successful login, redirect to `/dashboard`

4. **Auth context provider:**
   - React context wrapping Amplify Auth (or cognito-identity-js)
   - Provides: `user`, `role`, `isAuthenticated`, `isLoading`, `signIn`, `signOut`, `forgotPassword`, `resetPassword`
   - Reads Cognito groups from the ID token to determine role
   - Persists session across page refreshes

5. **Protected route wrapper:**
   - `withAuth(Component, { roles?: string[] })` HOC or `<ProtectedRoute roles={[...]}>` wrapper
   - Redirects to `/login` if unauthenticated
   - Redirects to `/unauthorized` if role doesn't match
   - Shows loading skeleton while auth state is resolving

6. **API client:**
   - Fetch wrapper in `packages/web/src/lib/api.ts`
   - Automatically attaches `Authorization: Bearer <token>` header
   - Handles 401 (redirect to login), 403 (show error), 4xx/5xx (parse error envelope from Section 11.1)
   - Auto-retry on token refresh (if token expired, refresh and retry once)
   - Base URL from `NEXT_PUBLIC_API_URL` env var

7. **React Query (TanStack Query) setup:**
   - QueryClientProvider in app layout
   - Default staleTime: 30 seconds
   - Default retry: 1

8. **Shared UI components:**
   - `LoadingSkeleton` — pulse animation placeholder, configurable rows/shape
   - `ErrorBoundary` — catches React errors, shows friendly error page with "Try Again" button
   - `EmptyState` — icon + message + optional action button, used when lists have no data
   - `/unauthorized` page — "You don't have permission" message with "Go to Dashboard" link

## Acceptance Criteria
- [ ] Tailwind CSS configured and working (or confirm already set up from Task 1)
- [ ] Catalyst (or Headless UI fallback) installed and components rendering
- [ ] Sidebar layout with role-based navigation items
- [ ] Login page functional with Cognito auth (use `amazon-cognito-identity-js` or Amplify)
- [ ] Forgot password + reset password pages functional
- [ ] Auth context provides user/role/isAuthenticated across the app
- [ ] Protected route wrapper redirects unauthenticated users to /login
- [ ] API client attaches Bearer token and handles error responses
- [ ] React Query provider configured in app layout
- [ ] LoadingSkeleton, ErrorBoundary, EmptyState components exist and render
- [ ] `/unauthorized` page exists
- [ ] `pnpm typecheck` passes
- [ ] `pnpm lint` passes
- [ ] All existing tests still pass (134 tests)
- [ ] No changes to backend packages (core, db, functions, infra)

## Code Repo Branch
feature/task-5-frontend-foundation

## Coordinator Notes
Priority: HIGH — this completes Milestone 1 and the April 16 demo depends on it.
Branch from `feature/task-2-sst-infrastructure` (latest approved task).
**Catalyst:** If the Catalyst npm package requires a paid license or private registry access, fall back to Headless UI (@headlessui/react) + custom Tailwind styling. Note the decision in worker notes.
**Cognito:** No real Cognito pool exists yet (no AWS deploy). Wire up the auth library with config from env vars (`NEXT_PUBLIC_COGNITO_USER_POOL_ID`, `NEXT_PUBLIC_COGNITO_CLIENT_ID`). The login flow won't work end-to-end until SST deploys, but the code structure should be correct.
**Don't over-engineer:** Focus on the auth shell and layout. Dashboard content is Milestone 2.
Reference: ARCHITECTURE.pdf Sections 7 (Frontend Architecture), 8 (Authentication), 9 (Role-Based Access).

## Worker Notes
(none yet)

## Revision History
(none)
