# COMM — mrv-prototype

## Status
DONE_AWAITING_REVIEW

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
- [x] Tailwind CSS configured and working (or confirm already set up from Task 1)
- [x] Catalyst (or Headless UI fallback) installed and components rendering
- [x] Sidebar layout with role-based navigation items
- [x] Login page functional with Cognito auth (use `amazon-cognito-identity-js` or Amplify)
- [x] Forgot password + reset password pages functional
- [x] Auth context provides user/role/isAuthenticated across the app
- [x] Protected route wrapper redirects unauthenticated users to /login
- [x] API client attaches Bearer token and handles error responses
- [x] React Query provider configured in app layout
- [x] LoadingSkeleton, ErrorBoundary, EmptyState components exist and render
- [x] `/unauthorized` page exists
- [x] `pnpm typecheck` passes
- [x] `pnpm lint` passes
- [x] All existing tests still pass (134 tests)
- [x] No changes to backend packages (core, db, functions, infra)

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

### Decisions
- **Headless UI over Catalyst**: Catalyst (`@tailwindcss/catalyst`) is a paid Tailwind UI component kit requiring a private npm registry/license. Used `@headlessui/react` v2 + custom Tailwind styling as the fallback per coordinator instructions.
- **amazon-cognito-identity-js over Amplify**: Chose the lighter `amazon-cognito-identity-js` library instead of full AWS Amplify. It provides the exact Cognito methods needed (SRP auth, forgot/reset password, session management) without pulling in the entire Amplify SDK.
- **Role detection from Cognito groups**: Auth context reads `cognito:groups` from the ID token JWT payload to determine user role. Priority order: fmt > auditor > country.

### Files Created (all in `packages/web/src/`)
- `lib/cognito.ts` — Cognito auth wrapper (signIn, forgotPassword, resetPassword, getCurrentSession, signOut)
- `lib/api.ts` — Fetch wrapper with Bearer token, 401 auto-retry, error envelope parsing per Architecture Section 11.1
- `lib/query-client.ts` — React Query client factory (staleTime: 30s, retry: 1)
- `contexts/auth-context.tsx` — AuthProvider + useAuth hook (user, role, isAuthenticated, isLoading, signIn, signOut, forgotPassword, resetPassword)
- `components/providers.tsx` — Root providers wrapper (ErrorBoundary > QueryClientProvider > AuthProvider)
- `components/auth/protected-route.tsx` — ProtectedRoute component with role-based access control
- `components/layout/sidebar-layout.tsx` — Responsive sidebar with role-based nav, notification bell (hardcoded count=3), user menu with sign out
- `components/shared/loading-skeleton.tsx` — Configurable pulse animation (text/card/avatar shapes)
- `components/shared/error-boundary.tsx` — React error boundary with "Try Again" button
- `components/shared/empty-state.tsx` — Icon + message + optional action button
- `app/(auth)/layout.tsx` — Centered auth layout (no sidebar)
- `app/(auth)/login/page.tsx` — Email + password form with validation errors and loading state
- `app/(auth)/forgot-password/page.tsx` — Email form, success state with link to reset page
- `app/(auth)/reset-password/page.tsx` — Code + new password + confirm password form
- `app/(dashboard)/layout.tsx` — Protected + SidebarLayout wrapper
- `app/(dashboard)/dashboard/page.tsx` — Placeholder dashboard page
- `app/unauthorized/page.tsx` — 403 page with "Go to Dashboard" link
- `app/layout.tsx` — Updated to wrap children with Providers
- `app/page.tsx` — Redirects to /dashboard

### Dependencies Added
- `@headlessui/react` ^2.2.9
- `@heroicons/react` (for sidebar icons)
- `@tanstack/react-query` ^5.96.1
- `amazon-cognito-identity-js` ^6.3.16

### Route Structure (per Architecture Section 12.1)
```
app/
├── (auth)/          # No sidebar
│   ├── login/
│   ├── forgot-password/
│   └── reset-password/
├── (dashboard)/     # SidebarLayout + ProtectedRoute
│   └── dashboard/
├── unauthorized/
└── layout.tsx       # Root with Providers
```

### Env Vars Required (from Architecture Section 15.3)
- `NEXT_PUBLIC_API_URL` — API base URL
- `NEXT_PUBLIC_COGNITO_USER_POOL_ID` — Cognito User Pool ID
- `NEXT_PUBLIC_COGNITO_CLIENT_ID` — Cognito App Client ID

### Verification
- `pnpm typecheck` — passes
- `pnpm lint` — passes (0 errors)
- `pnpm test` — 134/134 tests pass (5 test files, all in packages/core)
- No changes to packages/core, packages/db, packages/functions, or infra/
- Commit: `c01eece` on branch `feature/task-5-frontend-foundation`

## Revision History
(none)
