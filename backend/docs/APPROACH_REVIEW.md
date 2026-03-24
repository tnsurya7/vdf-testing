# VDF Backend — Approach Document Review

This document records the review of `vdf-backend` against `vdf-ui/docs/spring-boot-jwt-backend-approach.md` and the fixes applied.

## Aligned with approach

- **API contract (§5):** Auth (login, me), Registrations (GET/POST/PATCH), Applications (list, get, prelim, detailed, workflow, delete), Meetings (list, get, create, PATCH, add vote), Public data. Paths and methods match.
- **Login response:** `{ accessToken, user: { email, userType, sidbiRole? } }`. No refresh token (optional per doc).
- **Auth session:** `AuthSessionDto` matches UI shape (email, userType, sidbiRole).
- **Domain & enums:** UserAccount, Registration, Application, CommitteeMeeting; all enums (UserType, SidbiRole, AppStatus, AppStage, WorkflowStep, WorkflowAction, etc.) match approach §3.
- **Workflow FSM (§6.1):** `WorkflowEngine` implements same transition tables and status/stage derivation as `applicationStore.ts`. Validation returns 409 for invalid transitions.
- **Security:** JWT filter, entry point (401 JSON), BCrypt, permit login + Swagger + public; authenticated for `/auth/**` and `/api/**`.
- **CORS & OpenAPI:** Configurable origins, Swagger UI with bearerAuth.
- **Error body:** `ApiError` with error, code, message; 401/403/404/400/409 used as specified.
- **Flyway:** V1 schema, V2 seed users (password: password).

## Fixes applied

1. **Login 401:** `AuthService.login()` now throws `BadCredentialsException` instead of `IllegalArgumentException`, so `GlobalExceptionHandler` returns 401 for invalid credentials.
2. **Security permit:** Removed `/auth/register` from `permitAll()` (no register endpoint yet); only `/auth/login` is public.
3. **Application list by role:** When query param `role` (SIDBI) is present, list is filtered by workflow steps for that role (convenor, checker) to match UI mock behaviour; added `ApplicationService.listByRole(SidbiRole)` and used it in `ApplicationController.list()`.
4. **Registration access (§4.3, §5):** `GET` and `PATCH /api/registrations` (and `GET /api/registrations/{id}`) now require admin: `@PreAuthorize("hasRole('ADMIN')")`.
5. **Workflow action access (§5):** `POST /api/applications/{id}/workflow` now requires SIDBI: `@PreAuthorize("hasRole('SIDBI')")`.
6. **Application DELETE (§5):** Delete allowed only for admin or applicant owner; controller checks `ROLE_ADMIN` or `app.getApplicantEmail().equals(principal)` and returns 403 otherwise.
7. **Add vote request body (§1.4):** UI sends `{ meetingId, vote }`. Added `AddVoteRequest` (meetingId optional, vote required); path `id` is the meeting id. Controller uses path id and `body.getVote()`.

## Optional / future

- **Registrations POST:** Doc says “JWT (applicant) or anon”. Currently any authenticated user can POST; could add `@PreAuthorize("hasRole('APPLICANT') or isAnonymous()")` and an anonymous permit for POST only if public registration is required.
- **Login as demo (§1.1):** Optional demo endpoint (no password). Not implemented; seed users with password “password” cover demo flows.
- **Refresh token (§4.1, §5):** Optional; not implemented.
- **Application list performance:** `listByRole` filters in memory after `findAll()`. For large data, add a repository method that filters by `workflowStep IN (...)`.
- **Meeting add vote:** If the UI sends only the vote object (no wrapper), body would not match `AddVoteRequest`. Document that body must be `{ "vote": { "memberId", "vote", "comment" } }` (and optionally `meetingId`).

## Reference

- Approach: `vdf-ui/docs/spring-boot-jwt-backend-approach.md`
- FSM source: `vdf-ui/src/lib/applicationStore.ts`
- UI API surface: `vdf-ui/src/store/api.ts`
