# UI configuration to work with vdf-backend

This document describes the configuration and code changes needed in **vdf-ui** to use the real **vdf-backend** API instead of the in-memory mock.

---

## 1. Environment variable

Add the backend base URL so the UI can call the API.

**Create or edit `.env` (and optionally `.env.development`):**

```env
VITE_API_BASE_URL=http://localhost:8080
```

For production, set this in your build/deploy environment (e.g. `VITE_API_BASE_URL=https://api.yourdomain.com`).

**Note:** Vite only exposes env vars that start with `VITE_`. Use `import.meta.env.VITE_API_BASE_URL` in code.

---

## 2. Auth store: store and read the access token

The backend returns `{ accessToken, user }` on login and expects `Authorization: Bearer <token>` on protected requests. The UI currently only stores the session (user) in `authStore`.

**In `src/lib/authStore.ts`:**

- Add a key and helpers for the JWT:
  - `getToken(): string | null`
  - `setToken(token: string): void`
- In `clearSession()`, also remove the stored token so logout clears both session and token.

Example additions:

```ts
const TOKEN_KEY = "venture_debt_token";

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token);
}

export function clearSession(): void {
  localStorage.removeItem(AUTH_KEY);
  localStorage.removeItem(TOKEN_KEY);  // add this
}
```

---

## 3. API layer: use real HTTP and send the token

The UI currently uses RTK Query with `fakeBaseQuery()`. To use the backend:

- Replace `fakeBaseQuery()` with **`fetchBaseQuery`** from `@reduxjs/toolkit/query`.
- Set **base URL** from `import.meta.env.VITE_API_BASE_URL` (fallback to `""` for same-origin).
- In **`prepareHeaders`**, read the token (e.g. from `getToken()` in authStore) and set `Authorization: Bearer <token>` when present.
- On **401** responses, clear session and token and redirect to `/login` (e.g. in `prepareHeaders` you cannot redirect; handle 401 in a global way—see below).

**In `src/store/api.ts`:**

- Add: `import { fetchBaseQuery } from "@reduxjs/toolkit/query";`
- Add: `import { getToken } from "@/lib/authStore";`
- Replace the mock “DB” and `fakeBaseQuery()` with a single `baseQuery` that:
  - Uses `fetchBaseQuery({ baseUrl: import.meta.env.VITE_API_BASE_URL ?? "", ... })`
  - Uses `prepareHeaders: (headers, { getState }) => { const t = getToken(); if (t) headers.set("Authorization", `Bearer ${t}`); return headers; }`
- Optionally use **`baseQueryWithReauth`** or a wrapper: on `result.error?.status === 401`, call `clearSession()` (and `clearToken()` if you split it) and redirect to `/login` (e.g. `window.location.href = "/#/login"` or your router’s navigate), then return the error so the caller can stop.

Example shape (conceptual; you will remove the mock implementation and keep the same endpoint definitions):

```ts
const baseUrl = import.meta.env.VITE_API_BASE_URL ?? "";

const baseQuery = fetchBaseQuery({
  baseUrl,
  prepareHeaders: (headers, { getState }) => {
    const token = getToken();
    if (token) headers.set("Authorization", `Bearer ${token}`);
    return headers;
  },
});

// Optional: wrap to handle 401 globally
const baseQueryWithAuth = async (args: any, api: any, extraOptions: any) => {
  const result = await baseQuery(args, api, extraOptions);
  if (result.error?.status === 401) {
    clearSession();
    window.location.hash = "#/login";
  }
  return result;
};

export const api = createApi({
  reducerPath: "api",
  baseQuery: baseQueryWithAuth,  // or baseQuery if you handle 401 elsewhere
  tagTypes: ["Auth", "Applications", "Registrations", "Meetings"],
  endpoints: (builder) => ({ ... }),
});
```

Then **replace each mock endpoint** with a real one that uses the same URL and method as the backend (e.g. `POST /auth/login`, `GET /auth/me`, `GET /api/registrations`, etc.). Request/response shapes are listed in the approach doc and in the backend README.

---

## 4. Login response shape

The **backend** returns:

```json
{ "accessToken": "<jwt>", "user": { "email": "...", "userType": "...", "sidbiRole": "..." } }
```

The **mock** currently returns the session object directly (no `accessToken`, no `user` wrapper).

**In `src/pages/Login.tsx` (and anywhere that uses the login result):**

- After a successful login call, treat the result as `{ accessToken, user }` when using the real API:
  - Call `setToken(accessToken)` (or your new helper).
  - Call `setSession(user)` so the rest of the app still uses `getSession()` for email/userType/sidbiRole.
- You can either:
  - Change the login mutation’s return type to a union or a type that has `user` and optional `accessToken`, and in Login.tsx branch on “has accessToken” (real API) vs “direct session” (mock), or
  - When using only the real backend, always do:  
    `const res = await login({ email, password }).unwrap();`  
    `if (res.accessToken) { setToken(res.accessToken); setSession(res.user); } else { setSession(res); }`  
    so both shapes work.

---

## 5. Demo login (login without password)

The backend has **no** “login as demo” endpoint; it only supports `POST /auth/login` with email and password. Demo users are seeded with password **`password`**.

**Options:**

- **Recommended:** When using the real backend, make the “Demo Accounts” buttons call the normal login with a fixed password:
  - `login({ email: account.email, password: "password" })` for each demo account.
- Or hide the “Demo Accounts” section when `VITE_API_BASE_URL` is set.
- Or add a separate “demo login” endpoint to the backend (optional per approach doc) and keep the current `loginAsDemo` mutation for that.

---

## 6. Session on load (optional)

Currently the UI uses only localStorage for session and does not call the backend to “restore” session.

- **Minimal:** Keep that: after login you store token + user; on reload you use stored session; if a request returns 401, you clear and redirect to login.
- **Optional:** On app init (e.g. in a layout or root component), if there is a stored token, call `GET /auth/me` to validate it and refresh the session (and redirect to login if 401). That way session stays in sync with the backend.

---

## 7. Request/response shapes and endpoints

Align with the backend and approach doc:

| Area           | Method | Path (backend)              | Notes |
|----------------|--------|-----------------------------|--------|
| Login          | POST   | `/auth/login`               | Body: `{ email, password }`. Response: `{ accessToken, user }`. |
| Session        | GET    | `/auth/me`                  | Header: `Authorization: Bearer <token>`. Response: `{ email, userType, sidbiRole? }`. |
| Registrations  | GET    | `/api/registrations`        | Admin only. |
| Registrations  | POST   | `/api/registrations`        | Body: registration payload (no id/status/submittedAt). |
| Registrations  | PATCH  | `/api/registrations/:id`    | Body: `{ status: "approved" \| "rejected" }`. |
| Applications   | GET    | `/api/applications`          | Query: `email` or `role` (SIDBI). |
| Applications   | GET    | `/api/applications/:id`     | |
| Applications   | POST   | `/api/applications/prelim`  | Body: `{ email?, prelimData }`. |
| Applications   | PUT    | `/api/applications/:id/prelim` | Body: `{ prelimData }`. |
| Applications   | POST   | `/api/applications/:id/detailed` | Body: `{ appId?, detailedData }`. |
| Applications   | POST   | `/api/applications/:id/workflow` | Body: `{ action, actor?, comment?, assignedChecker?, ... }`. Response: `{ success, error? }`. |
| Applications   | DELETE | `/api/applications/:id`      | |
| Meetings       | GET    | `/api/meetings`             | Query: `type=icvd|ccic`. |
| Meetings       | GET    | `/api/meetings/:id`         | |
| Meetings       | POST   | `/api/meetings`             | |
| Meetings       | PATCH  | `/api/meetings/:id`         | Body: `{ status, outcome? }`. |
| Meetings       | POST   | `/api/meetings/:id/votes`   | Body: `{ meetingId?, vote }` (vote: `{ memberId, vote, comment }`). |
| Public         | GET    | `/api/public/data`         | |

IDs in the path are UUIDs (strings). Backend returns JSON with string IDs and ISO-8601 dates; enums match the UI (e.g. `userType`, `sidbiRole`, `status`, `workflowStep`).

---

## 8. CORS

The backend is configured to allow origins from `vdf.cors.allowed-origins` (default includes `http://localhost:5173` and `http://localhost:3000`). If the UI runs on another port or host, add it to the backend config or set `VDF_CORS_ORIGINS` when running the backend.

---

## 9. Checklist

- [ ] Add `VITE_API_BASE_URL` to `.env` (e.g. `http://localhost:8080`).
- [ ] In `authStore`: add `getToken` / `setToken`; clear token in `clearSession()`.
- [ ] In `api.ts`: switch to `fetchBaseQuery` with base URL and `Authorization: Bearer <token>`; handle 401 (clear session + redirect to login).
- [ ] In `Login.tsx`: after login, set both token and session from `{ accessToken, user }` when present.
- [ ] Demo login: use `login({ email, password: "password" })` for demo accounts when using real API, or hide demo section.
- [ ] Replace all mock endpoint implementations with real HTTP calls to the paths above (same endpoints and shapes as in the approach doc / backend).

After these changes, the UI will use the vdf-backend API with JWT and match the backend contract.
