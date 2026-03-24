# Spring Boot Backend with JWT Security — Approach Document

This document describes a detailed approach to build a Spring Boot backend with JWT-based security that serves the APIs required by the VDF (Venture Debt Fund) React UI.

---

## 1. Scope: APIs the UI Requires

The UI currently uses an in-memory mock API (see `src/store/api.ts`). The following capabilities must be provided by the backend.

### 1.1 Authentication

| Capability | Current UI usage | Backend responsibility |
|------------|-------------------|-------------------------|
| **Login** | `POST`-like: `{ email, password }` → `AuthSession` | Validate credentials; issue JWT (access + optional refresh). |
| **Login as demo** | Optional: `{ email, userType, sidbiRole }` → session (no password) | Optional: demo-mode endpoint or seed users; same JWT response shape. |
| **Logout** | Client clears session | Client discards token; optional: refresh blacklist or short-lived tokens only. |
| **Get current session** | Used to show user/role | Decode JWT or `GET /auth/me` returning `{ email, userType, sidbiRole }`. |

**Auth session shape (align with UI):**

- `email: string`
- `userType: "applicant" | "sidbi" | "admin"`
- `sidbiRole?: "maker" | "checker" | "convenor" | "committee_member" | "approving_authority"` (when `userType === "sidbi"`)

### 1.2 Registrations

| Operation | Method | Request / behaviour | Response |
|-----------|--------|---------------------|----------|
| List registrations | GET | Query (optional filters) | `Registration[]` |
| Create registration | POST | Body: registration payload (no `id`, `status`, `submittedAt`) | `Registration` |
| Update status | PATCH/PUT | `{ id, status: "approved" \| "rejected" }` | 204 or updated `Registration` |

**Registration entity (align with UI):** `id`, `email`, `nameOfApplicant`, `registeredOffice`, `locationOfFacilities`, `dateOfIncorporation`, `dateOfCommencement`, `panNo`, `gstNo`, `msmeStatus`, `status`, `submittedAt`.

### 1.3 Applications (Venture Debt workflow)

| Operation | Method | Request / behaviour | Response |
|-----------|--------|---------------------|----------|
| List applications | GET | Query: `email` (applicant) or `role` (SIDBI) for filtering | `Application[]` |
| Get by ID | GET | Path: `id` | `Application` |
| Create prelim | POST | Body: `{ email, prelimData }` | `Application` |
| Update prelim data | PUT/PATCH | Body: `{ id, prelimData }` | 204 or updated |
| Submit detailed application | POST/PUT | Body: `{ appId, detailedData }` | 204 or updated |
| Apply workflow action | POST | Body: `{ id, action, actor, comment?, assignedChecker?, assignedConvenor?, assignedApprover?, recommendedOutcome?, meetingId? }` | `{ success, error? }` |
| Delete application | DELETE | Path: `id` | 204 |

**Application entity (align with UI):** `id`, `applicantEmail`, `status`, `stage`, `workflowStep`, assignments (`assignedMaker`, `assignedChecker`, `assignedConvenor`, `assignedApprover`), `recommendedOutcome`, `prelimData` (`PrelimApplicationData`), `detailedData` (`DetailedApplicationData`), `icvdNote` / `ccicNote` (`CommitteeNoteData`), `icvdMeetingId`, `ccicMeetingId`, `comments`, `auditTrail`, `submittedAt`, `updatedAt`. Enums: `AppStatus`, `AppStage`, `WorkflowStep`, `WorkflowAction` (as in `src/lib/applicationStore.ts`).

### 1.4 Committee meetings

| Operation | Method | Request / behaviour | Response |
|-----------|--------|---------------------|----------|
| List meetings | GET | Query: `type?: "icvd" \| "ccic"` | `CommitteeMeeting[]` |
| Get by ID | GET | Path: `id` | `CommitteeMeeting` |
| Create meeting | POST | Body: meeting payload (no `id`, `votes`, `createdAt`, `updatedAt`) | `CommitteeMeeting` |
| Update status | PATCH/PUT | Body: `{ id, status, outcome? }` | 204 or updated |
| Add vote | POST | Body: `{ meetingId, vote }` | 204 or updated meeting |

**CommitteeMeeting:** `id`, `type`, `subject`, `meetingNumber`, `dateTime`, `totalMembers`, `selectedMembers`, `makerEmail`, `checkerEmail`, `convenorEmail`, `approverEmail`, `applicationIds`, `status`, `votes`, `outcome`, `createdAt`, `updatedAt`.

### 1.5 Public data (optional)

The **Public Data** page (`/public/data`) currently reads all applications and registrations from local storage. For the backend you can either:

- Expose a **public** (unauthenticated) read-only API that returns aggregated/sanitized data (e.g. counts, status distribution, no PII), or
- Keep this page behind login and use the same authenticated list endpoints with appropriate role checks.

Recommendation: treat public data as a dedicated read-only endpoint with a fixed role or anonymous access and a limited DTO (no sensitive fields).

---

## 2. Spring Boot Project Structure

Suggested module layout:

```
vdf-backend/
├── pom.xml
├── src/main/java/com/sidbi/vdf/
│   ├── VdfApplication.java
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   ├── CorsConfig.java
│   │   ├── JwtConfig.java / JwtProperties.java
│   │   └── OpenApiConfig.java          # OpenAPI 3 / Swagger UI (see §9)
│   ├── security/
│   │   ├── JwtTokenProvider.java
│   │   ├── JwtAuthenticationFilter.java
│   │   ├── JwtAuthenticationEntryPoint.java
│   │   ├── AuthService.java
│   │   ├── LoginRequest.java / LoginResponse.java
│   │   └── AuthController.java
│   ├── domain/
│   │   ├── User.java (or UserAccount)
│   │   ├── Registration.java
│   │   ├── Application.java
│   │   ├── CommitteeMeeting.java
│   │   ├── AuditEntry.java
│   │   └── enums/ (AppStatus, AppStage, WorkflowStep, WorkflowAction, UserType, SidbiRole, MeetingType, etc.)
│   ├── repository/
│   │   ├── UserRepository.java
│   │   ├── RegistrationRepository.java
│   │   ├── ApplicationRepository.java
│   │   └── CommitteeMeetingRepository.java
│   ├── service/
│   │   ├── RegistrationService.java
│   │   ├── ApplicationService.java
│   │   ├── WorkflowEngine.java
│   │   └── MeetingService.java
│   ├── web/
│   │   ├── RegistrationController.java
│   │   ├── ApplicationController.java
│   │   └── MeetingController.java
│   └── exception/
│       ├── GlobalExceptionHandler.java
│       └── ApiError.java
├── src/main/resources/
│   ├── application.yml
│   └── application-*.yml (dev, prod)
└── src/test/...
```

- **config**: Security, CORS, JWT settings.
- **security**: JWT creation/validation, filter, entry point, login API.
- **domain**: JPA entities and enums matching UI types.
- **repository**: Spring Data JPA repositories.
- **service**: Business logic; workflow transitions in `ApplicationService` + `WorkflowEngine`.
- **web**: REST controllers (auth already under `security`).
- **exception**: Central error handling and response shape.

---

## 3. Domain Class Attributes (for review)

The following attribute lists are derived from the UI types and should be mirrored in the backend domain/entities for contract alignment. Types are given in TypeScript/UI terms; Java equivalents: `string` → `String`, `number` → `Integer`/`Long`, dates → `Instant`/`OffsetDateTime` or `String` (ISO-8601), optional → `nullable` or `Optional`, collections → `List`/`Set`, JSON object → `Map` or JSON/JSONB column.

### 3.1 User / Auth (UserAccount)

| Attribute | Type | Notes |
|-----------|------|--------|
| `id` | string (UUID) | Primary key. |
| `email` | string | Unique; used for login. |
| `passwordHash` | string | BCrypt; not exposed in API. |
| `userType` | enum `UserType` | `applicant` \| `sidbi` \| `admin`. |
| `sidbiRole` | enum `SidbiRole` (optional) | `maker` \| `checker` \| `convenor` \| `committee_member` \| `approving_authority`; only when `userType === "sidbi"`. |
| `enabled` | boolean | For soft disable. |

**Enums:**

- **UserType:** `applicant`, `sidbi`, `admin`
- **SidbiRole:** `maker`, `checker`, `convenor`, `committee_member`, `approving_authority`

**AuthSession (API response / JWT claims):** `email`, `userType`, `sidbiRole?` — no password or internal id required in response.

---

### 3.2 Registration

| Attribute | Type | Notes |
|-----------|------|--------|
| `id` | string (UUID) | Primary key. |
| `email` | string | Applicant email. |
| `nameOfApplicant` | string | |
| `registeredOffice` | string | |
| `locationOfFacilities` | string | |
| `dateOfIncorporation` | string | Date (e.g. ISO-8601). |
| `dateOfCommencement` | string | Date. |
| `panNo` | string | |
| `gstNo` | string | |
| `msmeStatus` | enum | `micro` \| `small` \| `medium`. |
| `status` | enum | `pending` \| `approved` \| `rejected`. |
| `submittedAt` | string | ISO-8601 timestamp. |

**Enums:**

- **MsmeStatus:** `micro`, `small`, `medium`
- **RegistrationStatus:** `pending`, `approved`, `rejected`

---

### 3.3 Application (and nested types)

| Attribute | Type | Notes |
|-----------|------|--------|
| `id` | string (UUID) | Primary key. |
| `applicantEmail` | string | |
| `status` | enum `AppStatus` | See below. |
| `stage` | enum `AppStage` | See below. |
| `workflowStep` | enum `WorkflowStep` | Current step in state machine. |
| `assignedMaker` | string (optional) | User id or email. |
| `assignedChecker` | string (optional) | |
| `assignedConvenor` | string (optional) | |
| `assignedApprover` | string (optional) | |
| `recommendedOutcome` | enum (optional) | `rejection` \| `pursual`. |
| `prelimData` | `PrelimApplicationData` \| null | Nested prelim form data (see below). |
| `detailedData` | `DetailedApplicationData` \| null | Nested detailed form data (see below). |
| `icvdNote` | `CommitteeNoteData` \| null | IC-VD note attached to the application. |
| `ccicNote` | `CommitteeNoteData` \| null | CCIC/CGM note attached to the application. |
| `icvdMeetingId` | string (optional) | FK or reference to IC-VD meeting. |
| `ccicMeetingId` | string (optional) | FK or reference to CCIC meeting. |
| `comments` | map string → `FieldComment` | Key = field key or `_global`; stored as records or JSON. |
| `auditTrail` | array of `AuditEntry` | Append-only audit entries. |
| `submittedAt` | string | ISO-8601. |
| `updatedAt` | string | ISO-8601. |

**FieldComment (value in `comments` map):**

| Attribute | Type |
|-----------|------|
| `needsChange` | boolean |
| `comment` | string |

**AuditEntry (element in `auditTrail`):**

| Attribute | Type |
|-----------|------|
| `actorRole` | string |
| `actorId` | string |
| `actionType` | string (WorkflowAction or legacy) |
| `remark` | string |
| `timestamp` | string (ISO-8601) |

**Enums:**

- **AppStatus:** `submitted`, `pending_review`, `reverted`, `approved`, `rejected`, `recommended_for_approval`, `recommended_for_rejection`, `recommend_pursual`, `recommend_rejection`, `sanctioned`
- **AppStage:** `prelim`, `detailed`, `icvd`, `ccic`, `final`, `post_sanction`
- **WorkflowStep:** `prelim_review`, `prelim_submitted`, `prelim_revision`, `prelim_rejected`, `detailed_form`, `detailed_form_open`, `detailed_revision`, `detailed_maker_review`, `detailed_checker_review`, `detailed_rejected`, `icvd_maker_review`, `icvd_checker_review`, `icvd_convenor_scheduling`, `icvd_committee_review`, `icvd_referred`, `icvd_note_preparation`, `ccic_maker_refine`, `ccic_checker_review`, `ccic_convenor_scheduling`, `ccic_committee_review`, `ccic_referred`, `ccic_note_preparation`, `final_approval`, `final_rejected`, `sanctioned`, `completed`
- **WorkflowAction:** (see `applicationStore.ts` for full list) e.g. `revert_prelim`, `reject_prelim`, `approve_prelim`, `revert_detailed`, `recommend_rejection`, `recommend_pursual`, `reject_final`, `recommend_icvd`, `recommend_ccic`, `icvd_maker_forward`, `icvd_checker_assign_convenor`, `icvd_schedule_meeting`, `icvd_committee_refer`, `submit_icvd_note`, `revert_icvd`, `approve_icvd`, `record_committee_decision`, `ccic_maker_upload`, `ccic_checker_assign_convenor`, `ccic_schedule_meeting`, `ccic_committee_refer`, `submit_ccic_note`, `revert_ccic`, `approve_ccic`, `approve_sanction`, `reject_sanction`
- **RecommendedOutcome:** `rejection`, `pursual`

**PrelimApplicationData (nested object on `Application.prelimData`):**

| Attribute | Type | Notes |
|-----------|------|--------|
| `aifName` | string | Name of AIF / Investment Manager. |
| `businessModel` | string (optional) | Business model description. |
| `businessCompanyName` | string (optional) | Company name used in prelim form. |
| `otherParticulars` | string (optional) | Additional particulars. |
| `otherParticularsAmt` | string (optional) | Amount associated with other particulars. |
| `amountInvestedPast` | string | Amount invested in the past (₹ Cr) — stored as string in UI. |
| `investmentAsOnDate` | string | Investment as on date (₹ Cr). |
| `additionalInvestment` | string | Additional investment being considered (₹ Cr). |
| `companyName` | string (optional) | Display name of applicant (used in some views / public data). |
| `nameOfApplicant` | string (optional) | Alternative applicant name, when available. |
| (eligibility flags) | map `EligibilityKey` → `boolean \| string` | One key per eligibility parameter from `prelimConfig` (form stores boolean; mock data may use \"yes\"/\"no\"). |
| (eligibility remarks) | map `EligibilityRemarksKey` → string | `<key>Remarks` fields for each eligibility parameter. |
| (document slots) | map `DocSlotKey` → string | File names / storage refs for `docPitchDeck`, `docBalanceSheet1`, `docBalanceSheet2`, `docBalanceSheet3`, `docAuditorsNote`. |

**DetailedApplicationData (nested object on `Application.detailedData`):**

| Attribute | Type | Notes |
|-----------|------|--------|
| `id` | string (optional) | Client-side identifier for detailed payload. |
| `companyProfile` | string (optional) | Section A — company / founders / product / team profile. |
| `capitalTable` | `CapitalTableRow`[] (optional) | Fully diluted capital table rows (see below). |
| `financialPerformance` | `FinancialPerformanceGrid` (optional) | Row name → FY column key → value for financial metrics. |
| `revenueTrends` | `RevenueTrends` (optional) | Month label → revenue for last 12 months. |
| `arrears` | string (optional) | Arrears of statutory dues. |
| `enterpriseValue` | string (optional) | Enterprise value and basis of valuation. |
| `unitEconomics` | `UnitEconomicsSection` (optional) | Description + unit economics grid. |
| `cashBalance` | string (optional) | Cash & bank balance. |
| `cashRunway` | string (optional) | Cash runway. |
| `fundingWithdrawn` | `FundingWithdrawnSection` (optional) | Whether funding commitments were withdrawn/deferred and details. |
| `facilitiesAvailed` | `FacilitiesAvailedSection` (optional) | Whether facilities are availed and details. |
| `facilitiesApplicant` | `FacilityRow`[] (optional) | Facilities availed by the applicant. |
| `facilitiesAssociate` | `Concern`[] (optional) | Facilities availed by associate concerns. |
| `funding` | `FundingSection` (optional) | Total funding requirement, amount from SIDBI, balance sources, proposed use, repayment, moratorium, securities, rights. |
| `eligibility` | map string → `EligibilityItem` (optional) | Section D eligibility checklist keyed by serial number. |
| `pendingLitigations` | string (optional) | Pending litigations / contingencies. |
| `declarations` | boolean[] (optional) | Declaration checkboxes (all must be true on submit). |
| `detailedDocs` | string[] (optional) | Uploaded due diligence document names/refs. |
| `sanctionLetterFile` | string (optional) | Sanction letter file name/ref. |
| `signature` | `SignatureSection` (optional) | Applicant signature details. |
| `aifConfirmation` | `AifConfirmationSection` (optional) | AIF confirmation details. |
| `submittedAt` | string (optional) | ISO-8601 timestamp when detailed form was submitted. |
| `[key: string]` | unknown | Allows extra keys from drafts / legacy payloads. |

**CapitalTableRow:**

| Attribute | Type |
|-----------|------|
| `id` | string |
| `shareholders` | string |
| `shareholderType` | string |
| `shareholderTypeOther` | string |
| `typeOfShare` | string |
| `noOfShares` | string |
| `noOfEquityShares` | string |
| `noOfPrefShares` | string |
| `percentHolding` | string |
| `amountInvested` | string |

**FinancialPerformanceGrid / RevenueTrends / UnitEconomicsGrid:**

- `FinancialPerformanceGrid`: `Record<string, Record<string, string>>` — row name (e.g. \"Income / Revenue\") → FY key (e.g. `fy_minus3`, `fy_current`) → value.\n- `RevenueTrends`: `Record<string, string>` — month label (e.g. `Jan 2025`) → revenue.\n- `UnitEconomicsGrid`: `Record<string, Record<string, string>>` — unit economics row (e.g. `Net Revenue`, `EBITDA %`) → month column key → value.

**UnitEconomicsSection / FundingWithdrawnSection / FacilitiesAvailedSection:**

- `UnitEconomicsSection`: `{ description?: string; data?: UnitEconomicsGrid }`\n- `FundingWithdrawnSection`: `{ flag: boolean; details?: string }`\n- `FacilitiesAvailedSection`: `{ flag: boolean; details?: string }`

**FundingSection:**

| Attribute | Type |
|-----------|------|
| `totalFunding` | string (optional) |
| `amountFromSidbi` | string (optional) |
| `balanceSources` | string (optional) |
| `proposedUse` | string (optional) |
| `repaymentPeriod` | string (optional) |
| `moratorium` | string (optional) |
| `securitiesOffered` | string (optional) |
| `rightsDocument` | string (optional) |

**SignatureSection:**

| Attribute | Type |
|-----------|------|
| `place` | string (optional) |
| `date` | string (optional) |
| `name` | string (optional) |
| `designation` | string (optional) |
| `email` | string (optional) |
| `signFile` | string (optional) |

**AifConfirmationSection:**

| Attribute | Type |
|-----------|------|
| `name` | string (optional) |
| `place` | string (optional) |
| `date` | string (optional) |
| `signatory` | string (optional) |
| `signFile` | string (optional) |

**CommitteeNoteData (nested object on `Application.icvdNote` / `Application.ccicNote`):**

| Attribute | Type | Notes |
|-----------|------|--------|
| `summary` | string (optional) | Free-text note summary. |
| `recommendation` | enum (optional) | `rejection` \| `pursual` \| null. |
| `attachments` | string[] (optional) | File names / storage refs. |
| `[key: string]` | unknown | Allows extension of note schema over time. |

---

### 3.4 Committee meeting (and nested types)

| Attribute | Type | Notes |
|-----------|------|--------|
| `id` | string (UUID) | Primary key. |
| `type` | enum `MeetingType` | `icvd` \| `ccic`. |
| `subject` | string | |
| `meetingNumber` | number | Integer. |
| `dateTime` | string | ISO-8601. |
| `totalMembers` | array of `CommitteeMember` | Full pool. |
| `selectedMembers` | array of `CommitteeMember` | Selected for this meeting. |
| `makerEmail` | string | |
| `checkerEmail` | string | |
| `convenorEmail` | string | |
| `approverEmail` | string (optional) | For CCIC only. |
| `applicationIds` | array of string | Application UUIDs. |
| `status` | enum | `draft` \| `scheduled` \| `in_progress` \| `completed`. |
| `votes` | array of `MeetingVote` | |
| `outcome` | enum (optional) | `referred` \| `rejected`. |
| `createdAt` | string | ISO-8601. |
| `updatedAt` | string | ISO-8601. |

**CommitteeMember:**

| Attribute | Type |
|-----------|------|
| `id` | string |
| `name` | string |
| `email` | string |

**MeetingVote:**

| Attribute | Type |
|-----------|------|
| `memberId` | string |
| `vote` | enum `approve` \| `reject` \| `abstain` |
| `comment` | string |
| `timestamp` | string (ISO-8601) |

**Enums:**

- **MeetingType:** `icvd`, `ccic`
- **MeetingStatus:** `draft`, `scheduled`, `in_progress`, `completed`
- **MeetingOutcome:** `referred`, `rejected`
- **VoteType:** `approve`, `reject`, `abstain`

---

## 4. JWT-Based Security Design

### 4.1 Flow overview

1. **Login:** Client sends `POST /auth/login` with `{ "email": "...", "password": "..." }`. Backend validates credentials, loads user (including `userType`, `sidbiRole`), then issues:
   - **Access token (JWT):** short-lived (e.g. 15–60 minutes), signed with a secret or key pair. Claims: `sub` (e.g. user id or email), `email`, `userType`, `sidbiRole`, `exp`, `iat`.
   - **Refresh token (optional):** longer-lived, stored in DB or signed; used to get a new access token without re-entering password.
2. **Authenticated requests:** Client sends `Authorization: Bearer <access_token>` on every request. A filter validates the JWT, loads user/roles, and sets `SecurityContext`.
3. **Session endpoint:** `GET /auth/me` returns current user info (from `SecurityContext` or re-decoded token) in the same shape as the UI’s `AuthSession`.
4. **Logout:** Client deletes the token. If using refresh tokens, optional `POST /auth/logout` to invalidate the refresh token.

### 4.2 Technology choices

- **JWT library:** `jjwt` (io.jsonwebtoken) or `nimbus-jose-jwt`. Prefer one that supports:
  - HMAC (shared secret) or RSA (key pair).
  - Expiration and custom claims.
- **Password storage:** BCrypt (e.g. `BCryptPasswordEncoder`). Never store plain passwords.
- **User store:** DB table `user_account` (or similar) with at least: `id`, `email`, `password_hash`, `user_type`, `sidbi_role`, `enabled`. Optionally link to registration or application tables.

### 4.3 Security configuration (high level)

- **Permit all (no JWT):**
  - `POST /auth/login`, `POST /auth/register` (if registration creates an account).
  - Optional: `GET /public/data` (if you expose a public API).
  - Swagger/Actuator paths if needed (only in dev, or secured separately).
- **Authenticated (JWT required):**
  - `/auth/me`, `/auth/logout` (if implemented).
  - `/api/registrations/**`, `/api/applications/**`, `/api/meetings/**`.
- **Role-based rules (examples):**
  - `GET /api/applications` — applicant: filter by own email; sidbi: by role; admin: all.
  - `POST /api/applications/{id}/workflow` (apply action) — only SIDBI roles; optionally restrict by `workflowStep` and `sidbiRole` (maker/checker/convenor/committee_member/approving_authority).
  - `GET/PATCH /api/registrations` — admin only for listing and approving/rejecting; applicant for creating own registration.
  - Meetings: convenor/checker/committee_member as per business rules.

Use method security (`@PreAuthorize`) or a custom permission evaluator where role logic is non-trivial.

### 4.4 JWT filter chain position

1. `JwtAuthenticationFilter` runs once per request (e.g. `OncePerRequestFilter`).
2. Read `Authorization: Bearer <token>`. If missing, continue the chain (other filters or entry point will return 401 for protected URLs).
3. If present: validate token (signature, expiry), extract claims, build `UsernamePasswordAuthenticationToken` with user id/email and authorities (e.g. `ROLE_APPLICANT`, `ROLE_SIDBI`, `ROLE_ADMIN`, and optionally `SIDBI_MAKER`, etc.), set `SecurityContextHolder.getContext().setAuthentication(...)`.
4. On invalid/expired token: clear context and call `AuthenticationEntryPoint` to return 401 with a consistent JSON body.

### 4.5 CORS

Configure allowed origins (e.g. `http://localhost:5173` for Vite dev, and production UI origin), methods (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`), and headers (`Authorization`, `Content-Type`). Allow credentials if you use cookies in addition to JWT (optional).

---

## 5. API Contract Summary (REST)

Base path: `/api` (or no prefix for auth).

| Area | Method | Path | Auth | Description |
|------|--------|------|------|-------------|
| Auth | POST | `/auth/login` | No | `{ email, password }` → `{ accessToken, refreshToken?, user: { email, userType, sidbiRole? } }` |
| Auth | GET | `/auth/me` | JWT | → `{ email, userType, sidbiRole? }` |
| Auth | POST | `/auth/refresh` | Refresh | Optional; body/query refresh token → new access token |
| Registrations | GET | `/api/registrations` | JWT (admin) | List; optional query params |
| Registrations | POST | `/api/registrations` | JWT (applicant) or anon | Create |
| Registrations | PATCH | `/api/registrations/{id}` | JWT (admin) | Update status |
| Applications | GET | `/api/applications` | JWT | List (filter by user/role on server) |
| Applications | GET | `/api/applications/{id}` | JWT | Get one |
| Applications | POST | `/api/applications/prelim` | JWT (applicant) | Create prelim |
| Applications | PUT | `/api/applications/{id}/prelim` | JWT | Update prelim data |
| Applications | POST | `/api/applications/{id}/detailed` | JWT | Submit detailed |
| Applications | POST | `/api/applications/{id}/workflow` | JWT (SIDBI) | Apply workflow action |
| Applications | DELETE | `/api/applications/{id}` | JWT (admin or owner) | Delete |
| Meetings | GET | `/api/meetings` | JWT | List; optional `?type=icvd\|ccic` |
| Meetings | GET | `/api/meetings/{id}` | JWT | Get one |
| Meetings | POST | `/api/meetings` | JWT | Create |
| Meetings | PATCH | `/api/meetings/{id}` | JWT | Update status/outcome |
| Meetings | POST | `/api/meetings/{id}/votes` | JWT | Add vote |
| Public | GET | `/api/public/data` | No (or JWT) | Optional; read-only aggregated data |

Use consistent JSON error body (e.g. `{ "error": "...", "code": "..." }`) and HTTP status codes (401 Unauthorized, 403 Forbidden, 404 Not Found, 400 Bad Request, 409 Conflict for invalid workflow transitions).

---

## 6. Workflow Engine (Backend)

- **Single source of truth:** Move the transition tables from `applicationStore.ts` (`workflowTransitions`, `actionTransitions`) and status/stage derivation logic into the backend (e.g. `WorkflowEngine` + `ApplicationService`).
- **Validation:** Before updating an application, check `currentWorkflowStep` and `action` against the allowed transitions; return 409 or 400 with a clear message if invalid.
- **Persistence:** Update `workflowStep`, `status`, `stage`, assignments, meeting ids, `auditTrail`, and `comments` in one transactional method.
- **Audit:** Append to `auditTrail` with `actorId`/`actorRole` from the authenticated user (from JWT/SecurityContext), plus timestamp and action.

This keeps the UI as a thin client that only sends the chosen action and optional payload (comment, assignee ids, meeting id); the backend enforces rules and performs state transitions.

### 6.1 Application workflow finite state machine (FSM)

The application workflow is a **finite state machine** implemented in vdf-ui in `src/lib/applicationStore.ts`. The backend must replicate this FSM exactly so that workflow behaviour is consistent.

**Concepts:**

- **States** = `WorkflowStep` (the current step of the application in the pipeline).
- **Events** = `WorkflowAction` (the action the user/SIDBI performs).
- **Validation:** An action is allowed only if it is listed in `workflowTransitions[currentStep]`.
- **Transition:** When an allowed action is applied, the next state is `actionTransitions[action]`. The backend also updates `status` and `stage` from the action (see 6.1.3).

**Source of truth (TypeScript):** `vdf-ui/src/lib/applicationStore.ts` — types `WorkflowStep`, `WorkflowAction`, maps `workflowTransitions` and `actionTransitions`, and `applyWorkflowAction()` for status/stage derivation.

#### 6.1.1 Workflow steps (states)

| Step | Phase | Notes |
|------|--------|--------|
| `prelim_review`, `prelim_submitted` | Prelim | Applicant submitted prelim; SIDBI can revert/reject/approve. |
| `prelim_revision` | Prelim | Applicant revises; no workflow actions (resubmit via update prelim). |
| `prelim_rejected` | Prelim | Terminal. |
| `detailed_form`, `detailed_form_open`, `detailed_revision` | Detailed | Form open or under revision; no workflow actions from FSM (submit detailed moves to `detailed_maker_review`). |
| `detailed_maker_review` | Detailed | Maker can revert, recommend rejection, or recommend pursual. |
| `detailed_checker_review` | Detailed | Checker can reject, recommend IC-VD, or recommend CCIC. |
| `detailed_rejected` | Detailed | Terminal. |
| `icvd_maker_review` | IC-VD | Maker forwards. |
| `icvd_checker_review` | IC-VD | Checker assigns convenor. |
| `icvd_convenor_scheduling` | IC-VD | Convenor schedules meeting. |
| `icvd_committee_review` | IC-VD | Committee refers to CCIC (or records decision). |
| `icvd_referred` | IC-VD | Referred; no further IC-VD actions. |
| `icvd_note_preparation` | IC-VD | Legacy; submit note or forward. |
| `ccic_maker_refine` | CCIC | Maker uploads. |
| `ccic_checker_review` | CCIC | Checker assigns convenor. |
| `ccic_convenor_scheduling` | CCIC | Convenor schedules meeting. |
| `ccic_committee_review` | CCIC | Committee refers to final or records decision. |
| `ccic_referred` | CCIC | Referred. |
| `ccic_note_preparation` | CCIC | Legacy; submit note or upload. |
| `final_approval` | Final | Approving authority can approve or reject sanction. |
| `final_rejected` | Final | Terminal. |
| `sanctioned`, `completed` | Terminal | No further actions. |

#### 6.1.2 Transition map (state → allowed actions)

From each `WorkflowStep`, only the following `WorkflowAction` values are allowed. Any other action must be rejected (409/400).

| WorkflowStep | Allowed WorkflowActions |
|--------------|-------------------------|
| `prelim_review`, `prelim_submitted` | `revert_prelim`, `reject_prelim`, `approve_prelim` |
| `prelim_revision`, `prelim_rejected` | *(none)* |
| `detailed_form`, `detailed_form_open`, `detailed_revision` | *(none)* |
| `detailed_maker_review` | `revert_detailed`, `recommend_rejection`, `recommend_pursual` |
| `detailed_checker_review` | `reject_final`, `recommend_icvd`, `recommend_ccic` |
| `detailed_rejected` | *(none)* |
| `icvd_maker_review` | `icvd_maker_forward` |
| `icvd_checker_review` | `icvd_checker_assign_convenor` |
| `icvd_convenor_scheduling` | `icvd_schedule_meeting` |
| `icvd_committee_review` | `icvd_committee_refer` |
| `icvd_referred` | *(none)* |
| `icvd_note_preparation` | `submit_icvd_note`, `icvd_maker_forward` |
| `ccic_maker_refine` | `ccic_maker_upload` |
| `ccic_checker_review` | `ccic_checker_assign_convenor` |
| `ccic_convenor_scheduling` | `ccic_schedule_meeting` |
| `ccic_committee_review` | `ccic_committee_refer` |
| `ccic_referred` | *(none)* |
| `ccic_note_preparation` | `submit_ccic_note`, `ccic_maker_upload` |
| `final_approval` | `approve_sanction`, `reject_sanction` |
| `final_rejected`, `sanctioned`, `completed` | *(none)* |

#### 6.1.3 Action → next step map

When an allowed action is applied, the application’s `workflowStep` must be set to the following next step:

| WorkflowAction | Next WorkflowStep |
|----------------|-------------------|
| `revert_prelim` | `prelim_revision` |
| `reject_prelim` | `prelim_rejected` |
| `approve_prelim` | `detailed_form_open` |
| `revert_detailed` | `detailed_revision` |
| `recommend_rejection`, `recommend_pursual` | `detailed_checker_review` |
| `reject_final` | `detailed_rejected` |
| `recommend_icvd` | `icvd_maker_review` |
| `recommend_ccic` | `ccic_maker_refine` |
| `icvd_maker_forward`, `submit_icvd_note` | `icvd_checker_review` |
| `icvd_checker_assign_convenor`, `approve_icvd` | `icvd_convenor_scheduling` |
| `icvd_schedule_meeting` | `icvd_committee_review` |
| `icvd_committee_refer`, `record_committee_decision` | `ccic_maker_refine` |
| `ccic_maker_upload`, `submit_ccic_note` | `ccic_checker_review` |
| `ccic_checker_assign_convenor`, `approve_ccic` | `ccic_convenor_scheduling` |
| `ccic_schedule_meeting` | `ccic_committee_review` |
| `ccic_committee_refer` | `final_approval` |
| `approve_sanction` | `sanctioned` |
| `reject_sanction` | `final_rejected` |

#### 6.1.4 Status and stage derivation (from action)

When applying an action, the backend must also set `status` and optionally `stage` so the UI and reports stay consistent. Derivation rules (align with `applicationStore.ts` `applyWorkflowAction`):

- **Rejection actions:** `reject_prelim`, `reject_final`, `reject_sanction` → `status = "rejected"`.
- **Sanction:** `approve_sanction` → `status = "sanctioned"`, `stage = "post_sanction"`.
- **Prelim approved:** `approve_prelim` → `status = "approved"`, `stage = "detailed"`.
- **Checker recommendations:** `recommend_pursual` → `status = "recommend_pursual"`; `recommend_rejection` → `status = "recommend_rejection"`.
- **Reverts:** `revert_prelim`, `revert_detailed` → `status = "reverted"`.
- **To IC-VD:** `recommend_icvd` → `status = "submitted"`, `stage = "icvd"`.
- **To CCIC:** `recommend_ccic`, `icvd_committee_refer`, `record_committee_decision` → `status = "submitted"`, `stage = "ccic"` (or `"final"` for `ccic_committee_refer`).
- **IC-VD actions** (e.g. `icvd_maker_forward`, `icvd_checker_assign_convenor`, `approve_icvd`, `submit_icvd_note`) → keep `stage = "icvd"`; set `status` to `"submitted"` (or `"under_review"` for schedule meeting if the UI uses it).
- **CCIC actions** (e.g. `ccic_maker_upload`, `ccic_checker_assign_convenor`, `approve_ccic`, `submit_ccic_note`) → keep `stage = "ccic"`.
- **CCIC committee refer:** `ccic_committee_refer` → `stage = "final"`, `status = "submitted"`.

Implement these in the backend `WorkflowEngine` or `ApplicationService` so that a single “apply workflow action” call updates `workflowStep`, `status`, `stage`, assignments, meeting ids, and audit in one transaction.

---

## 7. Database and Entities

- **DB:** PostgreSQL or MySQL; use Spring Data JPA with Liquibase/Flyway for versioned migrations.
- **Entities:** Map the UI’s `Application`, `Registration`, `CommitteeMeeting`, and user account to tables. Use `@Enumerated(EnumType.STRING)` for enums; store JSON/JSONB for `prelimData`, `detailedData`, `comments`, and possibly `auditTrail` if you prefer not to normalize audit into a separate table initially.
- **Indexes:** On `applicant_email`, `workflow_step`, `status`, `meeting_id`, and foreign keys to support list and filter queries.

---

## 8. Configuration and Secrets

- **JWT:** Put signing key (or key pair path) in configuration (e.g. `application.yml`); in production use env vars or a secret manager, never commit secrets.
- **DB:** URL, username, password from env or profile-specific YAML.
- **CORS:** Origins from config so production UI URL can be set without code change.

---

## 9. Swagger / OpenAPI Documentation

Expose interactive API docs and a machine-readable OpenAPI 3 spec for the VDF API.

- **Dependency (MVC):** `org.springdoc:springdoc-openapi-starter-webmvc-ui` (version aligned with Spring Boot).
- **Config:** `config/OpenApiConfig.java` — define an `OpenAPI` bean with `info` (title, description, version) and a security scheme `bearerAuth` (type HTTP, scheme bearer, bearerFormat JWT). Add a global security requirement so Swagger UI sends `Authorization: Bearer <token>` for protected endpoints.
- **Security:** In `SecurityConfig`, permit `/swagger-ui/**`, `/swagger-ui.html`, and `/v3/api-docs/**` (e.g. `permitAll()` in dev; restrict or disable in production if desired).
- **Annotations:** Use `@Tag` on controllers (Auth, Registrations, Applications, Meetings, Public), `@Operation` and `@ApiResponse` on endpoints, and `@Schema` on DTOs where helpful. Document which operations require JWT via the global `bearerAuth` requirement.
- **application.yml:** e.g. `springdoc.api-docs.path: /v3/api-docs`, `springdoc.swagger-ui.path: /swagger-ui.html`, and `springdoc.swagger-ui.persist-authorization: true` so the "Authorize" token is retained. Disable in production with `springdoc.api-docs.enabled: false` and `springdoc.swagger-ui.enabled: false` if needed.
- **Usage:** Swagger UI at `/swagger-ui.html`; obtain a JWT via `POST /auth/login` and use "Authorize" to paste it for testing protected endpoints.

For a **reactive (WebFlux)** backend, use `springdoc-openapi-starter-webflux-ui` and the same concepts; see [spring-boot-webflux-jwt-backend-review.md](./spring-boot-webflux-jwt-backend-review.md) §7.

---

## 10. UI Integration (Migration Path)

1. **Environment:** Add a backend base URL (e.g. `VITE_API_BASE_URL`) and use it in the API client (e.g. Axios/fetch or RTK Query with `baseQuery` pointing to the real backend).
2. **Auth:** After login, store `accessToken` (e.g. in memory or secure storage); send it in `Authorization: Bearer <token>` on every request. Optionally implement refresh and redirect to login on 401.
3. **API client:** Replace RTK Query’s `fakeBaseQuery` with a real HTTP base query that uses the token and maps backend error responses to the same shape the UI expects (e.g. 401 → clear session and redirect to login).
4. **Contract:** Keep DTOs and enums aligned with the UI types (or generate client from OpenAPI). Ensure dates are ISO-8601 and enums match string values used in the frontend.

---

## 11. Testing and Security Checklist

- Unit tests for `WorkflowEngine` (all valid/invalid transitions) and for `ApplicationService` (apply action updates step, status, stage, audit).
- Integration tests: login → get token → call protected endpoints with and without token, and with wrong role.
- No secrets in repo; dependency scan (e.g. OWASP); HTTPS in production; short-lived access tokens and secure refresh token handling.

---

## 12. Document History and References

- **UI API surface:** `src/store/api.ts` (RTK Query endpoints and hooks).
- **Auth and user types:** `src/lib/authStore.ts`.
- **Application workflow FSM (WorkflowStep, WorkflowAction, workflowTransitions, actionTransitions, status/stage derivation):** `src/lib/applicationStore.ts` — see §6.1 for backend replication.
- **Registration and meeting types:** `src/lib/registrationStore.ts`, `src/lib/meetingStore.ts`.

This approach document should be updated when the UI adds or changes API usage or when backend API design is finalized.
