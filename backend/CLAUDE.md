# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
./gradlew build          # Full build
./gradlew bootRun        # Run application (port 8090)
./gradlew test           # Run all tests
./gradlew clean build    # Clean rebuild
```

Infrastructure (PostgreSQL, Redis, MinIO, RabbitMQ):
```bash
cd infra && docker-compose up -d
```

## Architecture

Spring Boot 4.0.3 modular monolith (Java 17, Gradle) with PostgreSQL 16, Flyway migrations, JWT auth, and an event-driven gamification engine.

**Root package:** `kz.eduquest`

### Module Layout

Each feature module follows the pattern: `controller/ → service/ → repository/ → entity/ → dto/`

- **auth** — Register, login, refresh, logout. JWT access (15min) + refresh (7d) tokens. In-memory blacklist (planned Redis migration).
- **user** — User accounts, profiles, RBAC. Roles: ADMIN, TEACHER, STUDENT, GUEST with granular permissions.
- **course** — Courses → Blocks → Lessons → (LessonContent, Tasks with Hints, Quizzes with Questions). Teachers own courses; `@PreAuthorize` + owner checks enforce access.
- **enrollment** — Student-course enrollment with status tracking (ACTIVE, COMPLETED, DROPPED).
- **progress** — Lesson progress, task submissions, quiz attempts.
- **gamification** — XP/level/badge system. `XpEngine` and `BadgeEvaluator` listen to Spring application events published by other services (e.g., `LessonCompletedEvent`, `TaskSolvedEvent`). XP awards are idempotent via unique constraint on (user_id, action_type, reference_id).
- **storage** — MinIO-backed file storage.
- **common** — Security config, JWT filter/service, OpenAPI config, global exception handler.

### Key Patterns

- **Event-driven gamification:** Services publish domain events via `ApplicationEventPublisher`; `XpEngine` and `BadgeEvaluator` consume them with `@EventListener`. Currently synchronous (RabbitMQ async is planned).
- **DTO mapping:** Static `from(entity)` factory methods on response DTOs. Request DTOs use Jakarta Validation (`@Valid`).
- **Transactions:** `@Transactional(readOnly = true)` at class level on services, `@Transactional` override on write methods.
- **Entity IDs:** UUID in Java entities (`GenerationType.UUID`), BIGSERIAL in Flyway migrations — Hibernate handles the mapping.
- **Fetch strategy:** LAZY loading by default with `@OrderBy` on collections.

### Security

- Stateless JWT with `JwtAuthenticationFilter` before `UsernamePasswordAuthenticationFilter`.
- Public endpoints: `/api/v1/auth/**`, `/v3/api-docs/**`, `/swagger-ui/**`.
- Role-based: `@PreAuthorize("hasAnyRole('TEACHER','ADMIN')")` on controllers + service-level owner checks.
- CORS origins configurable via `app.cors.allowed-origins` (defaults: localhost:5173, localhost:3000).

### Database

- **Flyway migrations** in `src/main/resources/db/migration/` (V1–V5). DDL auto is `none`.
- V1: users, roles, permissions, RBAC seed data. V2: courses/content hierarchy. V3: enrollments/progress. V4: gamification tables. V5: mock seed data.

## Access Points (Local Dev)

- API: `http://localhost:8090`
- Swagger UI: `http://localhost:8090/swagger-ui.html`
- PostgreSQL: `localhost:5432` (eduquest/eduquest)
- MinIO Console: `http://localhost:9001` (minioadmin/minioadmin)
- RabbitMQ Console: `http://localhost:15672` (guest/guest)

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `DB_USERNAME` | eduquest | PostgreSQL username |
| `DB_PASSWORD` | eduquest | PostgreSQL password |
| `JWT_SECRET` | (hardcoded fallback) | JWT signing key |
| `MINIO_URL` | http://localhost:9000 | MinIO endpoint |
| `MINIO_ACCESS_KEY` | minioadmin | MinIO access key |
| `MINIO_SECRET_KEY` | minioadmin | MinIO secret key |
