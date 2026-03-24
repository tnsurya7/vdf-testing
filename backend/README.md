# VDF Backend

Spring Boot backend for the VDF (Venture Debt Fund) UI. REST API with JWT authentication and application workflow FSM aligned with `vdf-ui`.

## Prerequisites

- **JDK 17+**
- **PostgreSQL**

## 1. Create the database and user

```bash
# Create database and user (PostgreSQL)
createdb vdf
createuser -P vdf
# When prompted, set password (e.g. vdf)
```

If your PostgreSQL uses a different auth setup, create a database named `vdf` and a user `vdf` with a password that can connect to it.

## 2. Run the application

From the project root:

```bash
./mvnw spring-boot:run
```

Or with Maven on your PATH:

```bash
mvn spring-boot:run
```

Server runs on **port 8080** by default.

## 3. Override configuration (optional)

If your database or port differ, use environment variables or a profile:

```bash
# Different database
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/vdf
export SPRING_DATASOURCE_USERNAME=vdf
export SPRING_DATASOURCE_PASSWORD=yourpassword
./mvnw spring-boot:run

# Different port
SERVER_PORT=9090 ./mvnw spring-boot:run

# Dev profile (e.g. more logging)
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# UAT profile (uses application-uat.yml; DB and secrets from env)
export SPRING_DATASOURCE_PASSWORD=your-uat-db-password
export VDF_JWT_SECRET=your-jwt-secret-at-least-256-bits
export VDF_CORS_ORIGINS=https://your-uat-ui.example.com
./mvnw spring-boot:run -Dspring-boot.run.profiles=uat
```

## 4. Verify it’s running

- **Swagger UI:** http://localhost:8080/swagger-ui.html
- **Login:** `POST http://localhost:8080/auth/login` with body:
  ```json
  { "email": "applicant@demo.com", "password": "password" }
  ```

## Demo users (seeded by Flyway)

Password for all: **password**

| Email | Type | Sidbi role |
|-------|------|------------|
| applicant@demo.com | applicant | — |
| sidbi-maker@demo.com | sidbi | maker |
| sidbi-checker@demo.com | sidbi | checker |
| sidbi-convenor@demo.com | sidbi | convenor |
| sidbi-committee@demo.com | sidbi | committee_member |
| sidbi-approving@demo.com | sidbi | approving_authority |
| admin@demo.com | admin | — |

## Stack

- Java 17, Spring Boot 3.2
- Spring Security + JWT (jjwt)
- Spring Data JPA, PostgreSQL
- Flyway, Springdoc OpenAPI (Swagger UI)

## API overview

- **Auth:** `POST /auth/login`, `GET /auth/me`
- **Registrations:** `GET/POST /api/registrations`, `PATCH /api/registrations/{id}`
- **Applications:** `GET/POST /api/applications`, prelim/detailed/workflow endpoints, `DELETE /api/applications/{id}`
- **Application files:** `POST /api/applications/{id}/files` (multipart), `GET /api/applications/{id}/files`, `GET /api/files/{fileId}/download`, `DELETE /api/files/{fileId}`
- **Meetings:** `GET/POST /api/meetings`, `PATCH /api/meetings/{id}`, `POST /api/meetings/{id}/votes`
- **Public:** `GET /api/public/data`

## UAT deployment

The **`uat`** profile is configured in `application-uat.yml` for the UAT PostgreSQL (AWS RDS). It uses `ddl-auto: validate` and Flyway for schema.

**Required environment variables in UAT:**

- `SPRING_DATASOURCE_PASSWORD` – UAT database password (not committed; set in your deployment env).
- `VDF_JWT_SECRET` – JWT signing secret (at least 256 bits).
- **CORS:** UAT defaults to allowing any GitHub Pages origin (`https://*.github.io`). To restrict, set `VDF_CORS_ORIGIN_PATTERNS` (comma-separated patterns) or set `vdf.cors.allowed-origin-patterns` to empty and set `VDF_CORS_ORIGINS` to explicit origin(s).

Run with UAT profile: `spring.profiles.active=uat` (e.g. `-Dspring-boot.run.profiles=uat` or set `SPRING_PROFILES_ACTIVE=uat` in the server environment).

## File uploads

Uploaded files are stored on disk under **`vdf.files.storage-path`** (default `./data/vdf-uploads`). Override with `VDF_FILES_STORAGE_PATH`. Each file is stored with a UUID filename; metadata (application id, scope, label, original name) is stored in the `application_file` table. Max file size is 25MB (Spring `spring.servlet.multipart`).

See Swagger UI or `vdf-ui/docs/spring-boot-jwt-backend-approach.md` for full contract.
