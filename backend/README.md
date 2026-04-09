# EduQuest — Backend

Gamified educational platform (LMS) built as a Spring Boot modular monolith. Teachers create structured courses, students earn XP, levels, and badges as they progress.

## Tech Stack

| | |
|---|---|
| Language | Java 17 |
| Framework | Spring Boot 4.0.3 |
| Build | Gradle |
| Database | PostgreSQL 16 + Flyway |
| ORM | Spring Data JPA (Hibernate) |
| Auth | Spring Security + JWT |
| Cache | Redis |
| Storage | MinIO |
| Messaging | RabbitMQ |
| API Docs | Swagger / OpenAPI |

## Getting Started

### Prerequisites

Docker and Docker Compose must be installed.

### 1. Start infrastructure

```bash
cd infra && docker-compose up -d
```

This starts PostgreSQL, Redis, MinIO, and RabbitMQ.

### 2. Run the application

```bash
./gradlew bootRun
```

The API will be available at `http://localhost:8090`.

## Commands

```bash
./gradlew build          # Full build
./gradlew bootRun        # Run application
./gradlew test           # Run tests
./gradlew clean build    # Clean rebuild
```

## Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| API | http://localhost:8090 | — |
| Swagger UI | http://localhost:8090/swagger-ui.html | — |
| PostgreSQL | localhost:5432 | eduquest / eduquest |
| MinIO Console | http://localhost:9001 | minioadmin / minioadmin |
| RabbitMQ Console | http://localhost:15672 | guest / guest |

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `DB_USERNAME` | eduquest | PostgreSQL username |
| `DB_PASSWORD` | eduquest | PostgreSQL password |
| `JWT_SECRET` | hardcoded fallback | JWT signing key |
| `MINIO_URL` | http://localhost:9000 | MinIO endpoint |
| `MINIO_ACCESS_KEY` | minioadmin | MinIO access key |
| `MINIO_SECRET_KEY` | minioadmin | MinIO secret key |

## Architecture

The application is organized as a modular monolith under the `kz.eduquest` root package. Each module follows the pattern: `controller → service → repository → entity → dto`.

**Modules:** `auth`, `user`, `course`, `enrollment`, `progress`, `gamification`, `storage`, `common`

**Key patterns:**
- Event-driven gamification via Spring `ApplicationEventPublisher`
- Stateless JWT authentication with auto-refresh
- Flyway migrations (V1–V5) — DDL auto is disabled
- RBAC with roles: `ADMIN`, `TEACHER`, `STUDENT`, `GUEST`

## API

Public endpoints: `/api/v1/auth/**`, `/v3/api-docs/**`, `/swagger-ui/**`

Full API reference available at Swagger UI after starting the application.