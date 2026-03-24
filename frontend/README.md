# VDF UI

React frontend for the **Venture Debt Fund (VDF)** application. Works with the [vdf-backend](../vdf-backend) REST API for authentication, registrations, applications, and committee meetings.

---

## Prerequisites

- **Node.js 18+** (recommend [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) for installation)
- **npm** (comes with Node.js)

---

## Quick start

```bash
# Clone the repo (if not already)
git clone <YOUR_GIT_URL>
cd vdf-ui

# Install dependencies
npm install

# Copy env and point to backend (see Environment below)
cp .env.example .env

# Start the dev server
npm run dev
```

The app runs at **http://localhost:5173**. For full functionality, start the [vdf-backend](../vdf-backend) first.

---

## Environment

Vite only loads variables from **`.env`** (not `.env.example`). Create `.env` from the example:

```bash
cp .env.example .env
```

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | Base URL of the vdf-backend API (no trailing slash) | `http://localhost:8080` |

- **Local development:** Set `VITE_API_BASE_URL=http://localhost:8080` so the UI talks to the backend on port 8080.
- **Production:** Set this in your build/deploy environment (e.g. `VITE_API_BASE_URL=https://api.yourdomain.com`).

Only env vars prefixed with `VITE_` are exposed to the app via `import.meta.env`.

---

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server (port 5173) with HMR |
| `npm run build` | Production build (output in `dist/`) |
| `npm run build:dev` | Build in development mode |
| `npm run preview` | Serve the production build locally |
| `npm run lint` | Run ESLint |
| `npm run test` | Run Vitest once |
| `npm run test:watch` | Run Vitest in watch mode |

---

## Tech stack

- **Vite** – Build tool and dev server
- **React 18** – UI library
- **TypeScript** – Typing
- **React Router 6** – Routing
- **shadcn/ui** (Radix) – Accessible components
- **Tailwind CSS** – Styling
- **Redux Toolkit + RTK Query** – State and API (JWT auth, base URL from env)
- **React Hook Form + Zod** – Forms and validation
- **Vitest + Testing Library** – Unit tests

---

## Project structure (high level)

```
vdf-ui/
├── src/
│   ├── components/   # Reusable UI components
│   ├── lib/          # Auth store, API types, utilities
│   ├── pages/        # Route-level pages (Login, Dashboard, etc.)
│   ├── store/        # Redux store, RTK Query API (api.ts)
│   └── ...
├── docs/             # UI/backend integration, backend approach
├── .env.example      # Env template (copy to .env)
└── package.json
```

API calls and JWT handling live in `src/store/api.ts`; the base URL is read from `VITE_API_BASE_URL`.

---

## Working with the backend

1. **Start the backend** (see [vdf-backend README](../vdf-backend/README.md)) so it is running on the port you set in `VITE_API_BASE_URL` (default 8080).
2. **CORS:** Backend allows `http://localhost:5173` by default; no extra CORS config needed for local dev.
3. **Auth:** Log in with one of the [seeded demo users](../vdf-backend/README.md#demo-users); the UI sends the JWT in `Authorization: Bearer <token>`.

For implementation details (env, auth store, RTK Query), see [docs/UI_BACKEND_INTEGRATION.md](docs/UI_BACKEND_INTEGRATION.md).

---

## Contributing

1. **Branch:** Create a feature branch from `main` (or your team’s default branch).
2. **Code style:** Run `npm run lint` before committing; fix any reported issues.
3. **Tests:** Run `npm run test` and add tests for new behavior where appropriate.
4. **Env:** Do not commit `.env`; use `.env.example` as the template and document any new `VITE_*` variables there.
5. **Backend contract:** For API changes, coordinate with the backend (see [vdf-backend](../vdf-backend) and [spring-boot-jwt-backend-approach.md](docs/spring-boot-jwt-backend-approach.md)).

---

## Docs

- [UI_BACKEND_INTEGRATION.md](docs/UI_BACKEND_INTEGRATION.md) – Config and code for using the real backend
- [spring-boot-jwt-backend-approach.md](docs/spring-boot-jwt-backend-approach.md) – Backend auth and API contract
