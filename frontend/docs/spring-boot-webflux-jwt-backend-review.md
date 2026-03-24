# Spring Boot WebFlux + JWT Backend — Review Document

This document reviews the suggested base structure for a Spring Boot backend using **WebFlux** and **Spring Security with JWT**, aligned with the API used by vdf-ui. It complements the existing [spring-boot-jwt-backend-approach.md](./spring-boot-jwt-backend-approach.md) (servlet/MVC version).

---

## 1. Technology Choices (Reactive Stack)

| Layer   | Choice                         | Rationale |
|--------|--------------------------------|-----------|
| Web    | **Spring WebFlux**             | Reactive controllers (`Mono`/`Flux`); non-blocking. |
| Security | **Spring Security (reactive)** | `SecurityWebFilterChain`, reactive auth converter/handlers. |
| JWT    | **jjwt** or **nimbus-jose-jwt** | Used inside a reactive converter returning `Mono<Authentication>`. |
| Data   | **Spring Data R2DBC**          | Reactive DB access; no blocking JPA. |
| DB     | **PostgreSQL** (R2DBC driver)  | JSONB for nested DTOs (`prelimData`, `detailedData`). |

---

## 2. Suggested Project Layout (Reactive)

```
vdf-backend/
├── pom.xml
├── src/main/java/com/sidbi/vdf/
│   ├── VdfApplication.java
│   │
│   ├── config/
│   │   ├── CorsConfig.java              # WebFilter for CORS (reactive)
│   │   ├── R2dbcConfig.java             # R2DBC connection (if needed beyond application.yml)
│   │   └── OpenApiConfig.java           # OpenAPI 3 / Swagger UI for WebFlux
│   │
│   ├── security/
│   │   ├── SecurityConfig.java          # @EnableWebFluxSecurity, SecurityWebFilterChain
│   │   ├── JwtProperties.java           # Signing key, issuer, expiration from application.yml
│   │   ├── JwtTokenProvider.java        # Create/validate JWT (sync API used inside reactive chain)
│   │   ├── BearerTokenServerAuthenticationConverter.java  # Authorization: Bearer → Mono<Authentication>
│   │   ├── JwtAuthenticationFailureHandler.java          # 401 on invalid/expired token
│   │   ├── JwtAuthenticationSuccessHandler.java          # Optional: on login success
│   │   ├── AuthService.java             # Reactive: validate credentials, return user + tokens
│   │   ├── AuthController.java          # WebFlux: POST /auth/login, GET /auth/me, POST /auth/refresh
│   │   └── dto/
│   │       ├── LoginRequest.java
│   │       ├── LoginResponse.java       # accessToken, refreshToken?, user (email, userType, sidbiRole)
│   │       └── AuthSessionDto.java      # Same shape as UI AuthSession
│   │
│   ├── domain/
│   │   ├── UserAccount.java             # R2DBC entity: id, email, passwordHash, userType, sidbiRole, enabled
│   │   ├── Registration.java
│   │   ├── Application.java             # prelimData/detailedData as JSONB
│   │   ├── CommitteeMeeting.java
│   │   ├── AuditEntry.java              # Or embedded in Application
│   │   └── enums/
│   │       ├── UserType.java
│   │       ├── SidbiRole.java
│   │       ├── AppStatus.java
│   │       ├── AppStage.java
│   │       ├── WorkflowStep.java
│   │       ├── WorkflowAction.java
│   │       ├── MeetingType.java
│   │       └── ...
│   │
│   ├── repository/
│   │   ├── UserAccountRepository.java   # ReactiveCrudRepository<UserAccount, UUID>
│   │   ├── RegistrationRepository.java
│   │   ├── ApplicationRepository.java
│   │   └── CommitteeMeetingRepository.java
│   │
│   ├── service/
│   │   ├── RegistrationService.java     # Reactive (Mono/Flux)
│   │   ├── ApplicationService.java
│   │   ├── WorkflowEngine.java          # Transition rules (can stay sync; call from reactive service)
│   │   └── CommitteeMeetingService.java
│   │
│   ├── web/
│   │   ├── RegistrationController.java
│   │   ├── ApplicationController.java
│   │   ├── CommitteeMeetingController.java
│   │   └── PublicDataController.java    # GET /api/public/data
│   │
│   └── exception/
│       ├── GlobalExceptionHandler.java  # @ControllerAdvice, return Mono/ServerResponse
│       └── ApiError.java
│
├── src/main/resources/
│   ├── application.yml
│   └── application-*.yml
└── src/test/...
```

---

## 3. Reactive Security with JWT (Conceptual)

- **Permit all (no JWT):**  
  `POST /auth/login`, `POST /auth/register` (if any), `GET /api/public/data` (if public).
- **Authenticated (JWT required):**  
  All other `/api/**` and `/auth/me`, `/auth/refresh`.

**SecurityWebFilterChain (in `SecurityConfig`):**

1. Permit the paths above with `.pathMatchers(...).permitAll()`.
2. Permit Swagger/OpenAPI: `.pathMatchers("/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/**").permitAll()` (see §7).
3. Protect `/api/**` and `/auth/me` with `.authenticated()`.
4. **JWT filter:** Custom `ServerAuthenticationConverter` that:
   - Reads `Authorization: Bearer <token>` from `ServerWebExchange`.
   - Validates token via `JwtTokenProvider` (run on `Schedulers.boundedElastic()` if blocking).
   - Builds `UsernamePasswordAuthenticationToken` with principal and authorities (`ROLE_APPLICANT`, `ROLE_SIDBI`, `ROLE_ADMIN`, etc.).
   - Returns `Mono.just(authentication)` or `Mono.error(...)`.
5. Use a `ReactiveAuthenticationManager` (or equivalent) so the chain uses this converter.
6. Set `ServerAuthenticationEntryPoint` to return 401 JSON when authentication fails.

**Login:** Validate credentials with `BCryptPasswordEncoder.matches()` (on `boundedElastic()` if desired), then issue JWT and return `LoginResponse` (accessToken, optional refreshToken, user object matching UI `AuthSession`).

---

## 4. WebFlux Controllers (Aligned with vdf-ui)

- **Auth:**  
  `POST /auth/login` (body: LoginRequest → LoginResponse), `GET /auth/me` (→ AuthSessionDto).
- **Registrations:**  
  GET list, POST create, PATCH status; all return `Mono`/`Flux`.
- **Applications:**  
  GET list, GET by id, POST prelim, PUT prelim, POST detailed, POST workflow action, DELETE; same contract as [spring-boot-jwt-backend-approach.md](./spring-boot-jwt-backend-approach.md).
- **Meetings:**  
  GET list, GET by id, POST create, PATCH status, POST vote; all reactive.

Request/response DTOs and enums should match vdf-ui types so the existing RTK Query client can switch from `fakeBaseQuery` to a real HTTP `baseQuery` with minimal changes.

---

## 5. Dependencies (Maven)

- `spring-boot-starter-webflux`
- `spring-boot-starter-security`
- `spring-boot-starter-data-r2dbc`
- `r2dbc-postgresql`
- `io.jsonwebtoken:jjwt-api` + `jjwt-impl` + `jjwt-jackson` (or nimbus-jose-jwt)
- `spring-boot-starter-validation`
- `springdoc-openapi-starter-webflux-ui` for Swagger/OpenAPI documentation (WebFlux)

Do **not** include `spring-boot-starter-web` (servlet) or `spring-boot-starter-data-jpa` when going full reactive.

---

## 6. Configuration (application.yml)

- **Server:** Standard Spring Boot port.
- **R2DBC:** `spring.r2dbc.url`, `username`, `password` (and pool if needed).
- **JWT:** e.g. `vdf.jwt.secret`, `vdf.jwt.accessTokenValidityMinutes`, optional refresh; use env/secrets in production.
- **CORS:** Allowed origins (e.g. `http://localhost:5173`), methods, headers (`Authorization`, `Content-Type`).
- **Swagger/OpenAPI:** See §7 below; optional `springdoc.api-docs.path`, `springdoc.swagger-ui.path`, and disable in production if needed.

---

## 7. Swagger / OpenAPI Documentation

Expose interactive API docs and machine-readable OpenAPI 3 spec so frontend and integrators can discover and test endpoints.

### 7.1 Dependency and setup

- **Dependency:** `org.springdoc:springdoc-openapi-starter-webflux-ui` (use a version compatible with your Spring Boot BOM).
- **Config class:** `config/OpenApiConfig.java` — define the OpenAPI bean and JWT security scheme.

### 7.2 OpenAPI bean and JWT security scheme

In `OpenApiConfig.java`:

- **OpenAPI bean:** Set `info.title`, `info.description`, `info.version` (e.g. "VDF API", "Venture Debt Fund backend for vdf-ui", "1.0").
- **Security scheme:** Add a scheme named e.g. `bearerAuth` (type `http`, scheme `bearer`, `bearerFormat: "JWT"`).
- **Global security requirement:** Apply `bearerAuth` globally so Swagger UI sends `Authorization: Bearer <token>` for protected endpoints. Optionally use `@SecurityRequirement(name = "bearerAuth")` per controller or operation to document which endpoints require JWT.

Example (conceptual):

```java
@Configuration
public class OpenApiConfig {
  @Bean
  public OpenAPI vdfOpenAPI() {
    return new OpenAPI()
        .info(new Info().title("VDF API").description("...").version("1.0"))
        .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
        .components(new Components()
            .addSecuritySchemes("bearerAuth",
                new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("bearer").bearerFormat("JWT")));
  }
}
```

### 7.3 Securing Swagger paths

In `SecurityConfig` (reactive), allow unauthenticated access to Swagger UI and API docs so developers can open the UI and use "Authorize" with a token:

- Permit: `/swagger-ui/**`, `/swagger-ui.html`, `/v3/api-docs/**`.
- Restrict these to dev/test only in production if desired (e.g. via profile or `permitAll()` only when `swagger.enabled=true`).

### 7.4 Controller and DTO annotations

Use OpenAPI annotations to document operations and models:

- **Controllers:** `@Tag(name = "Auth")` (or "Registrations", "Applications", "Meetings", "Public") on each controller.
- **Endpoints:** `@Operation(summary = "...", description = "...")`, `@ApiResponse(responseCode = "200/201/400/401/403/404", description = "...")`. For path/query/body parameters use `@Parameter(description = "...")`.
- **Request/response bodies:** Ensure DTOs are discoverable (e.g. as method parameters or return types). Use `@Schema(description = "...")` on DTO fields and enums where helpful.
- **Auth:** Document that `GET /auth/me` and all `/api/**` (except public) require the Bearer token; the global security requirement and `bearerAuth` scheme cover this in Swagger UI.

Key groups to tag: **Auth** (login, me, refresh), **Registrations**, **Applications**, **Meetings**, **Public**.

### 7.5 application.yml (springdoc)

```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
    enabled: true   # set to false in prod if you want to disable
  swagger-ui:
    path: /swagger-ui.html
    enabled: true
    # Optional: persist "Authorize" token in browser
    persist-authorization: true
```

In production, set `enabled: false` for both if you do not want to expose docs.

### 7.6 URLs

- **Swagger UI:** `http://localhost:8080/swagger-ui.html` (or configured path).
- **OpenAPI JSON:** `http://localhost:8080/v3/api-docs`.
- **OpenAPI YAML:** `http://localhost:8080/v3/api-docs.yaml` (if supported by the springdoc version).

Use "Authorize" in Swagger UI to paste the JWT obtained from `POST /auth/login`; subsequent requests will include `Authorization: Bearer <token>`.

---

## 8. API Contract Reference

Same as in [spring-boot-jwt-backend-approach.md](./spring-boot-jwt-backend-approach.md) §5:

| Area          | Method | Path                          | Auth   | Description |
|---------------|--------|-------------------------------|--------|-------------|
| Auth          | POST   | `/auth/login`                 | No     | `{ email, password }` → `{ accessToken, refreshToken?, user }` |
| Auth          | GET    | `/auth/me`                   | JWT    | → `{ email, userType, sidbiRole? }` |
| Registrations | GET    | `/api/registrations`         | JWT    | List (admin) |
| Registrations | POST   | `/api/registrations`         | JWT    | Create |
| Registrations | PATCH  | `/api/registrations/{id}`    | JWT    | Update status |
| Applications  | GET    | `/api/applications`          | JWT    | List (filtered by user/role) |
| Applications  | GET    | `/api/applications/{id}`     | JWT    | Get one |
| Applications  | POST   | `/api/applications/prelim`   | JWT    | Create prelim |
| Applications  | PUT    | `/api/applications/{id}/prelim` | JWT  | Update prelim |
| Applications  | POST   | `/api/applications/{id}/detailed` | JWT | Submit detailed |
| Applications  | POST   | `/api/applications/{id}/workflow` | JWT | Apply workflow action |
| Applications  | DELETE | `/api/applications/{id}`     | JWT    | Delete |
| Meetings      | GET    | `/api/meetings`              | JWT    | List (`?type=icvd|ccic`) |
| Meetings      | GET    | `/api/meetings/{id}`         | JWT    | Get one |
| Meetings      | POST   | `/api/meetings`              | JWT    | Create |
| Meetings      | PATCH  | `/api/meetings/{id}`         | JWT    | Update status/outcome |
| Meetings      | POST   | `/api/meetings/{id}/votes`   | JWT    | Add vote |
| Public        | GET    | `/api/public/data`           | No/JWT | Optional; read-only aggregated data |

---

## 9. Summary

- **WebFlux** for all HTTP; controllers and services use `Mono`/`Flux`.
- **Reactive Spring Security** with custom JWT `ServerAuthenticationConverter` and `SecurityWebFilterChain`; login issues JWT and returns the same auth shape as vdf-ui.
- **R2DBC** for persistence; entities and repositories reactive; domain and API contract aligned with the existing approach doc and `vdf-ui/src/store/api.ts`.
- **Workflow engine** can remain sync and be invoked from reactive services (e.g. via `Schedulers.boundedElastic()` or a dedicated blocking call).
- **Application FSM:** The backend must implement the same finite state machine as vdf-ui: states = `WorkflowStep`, events = `WorkflowAction`, with validation via “state → allowed actions” and transition via “action → next step”. Full FSM specification (transition tables, status/stage derivation) is in [spring-boot-jwt-backend-approach.md](./spring-boot-jwt-backend-approach.md) §6.1; source of truth in code is `vdf-ui/src/lib/applicationStore.ts`.

Use this document alongside the existing approach doc when implementing or reviewing the WebFlux + JWT backend for vdf-ui.
