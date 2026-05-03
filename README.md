# EduQuest — Online Learning Platform

**Student IDs:** 230103046, 230103054

---

## Problem Statement

Traditional LMS platforms are rigid and provide little motivation to keep learning. EduQuest combines structured course delivery with gamification — XP, levels, badges, leaderboards — to make learning engaging and progress measurable. Teachers get a simple tool to create and publish courses; students get a reward system that incentivizes completion.

---

## What It Does

- **Teachers** create courses with blocks, lessons, tasks, and quizzes, then publish them
- **Students** enroll, complete lessons, submit answers, take quizzes, and earn XP
- **Admins** manage users and assign roles
- **Observers** monitor system health via Grafana and search logs via Kibana

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, TypeScript, Vite 6, TailwindCSS 4 |
| State | Zustand (client), TanStack React Query (server) |
| Backend | Spring Boot 4, Java 17 |
| Auth | JWT HS256, Spring Security, RBAC |
| Database | PostgreSQL 16 + Flyway migrations |
| Storage | MinIO (S3-compatible) |
| Logging | Logback → Logstash → Elasticsearch → Kibana |
| Metrics | Spring Actuator → Prometheus → Grafana |
| Runtime | Docker + Docker Compose |

---

## Architecture

```
Browser
  └── React SPA :5173
        └── REST /api/v1
              └── Spring Boot :8090
                    ├── PostgreSQL :5432
                    ├── MinIO :9000
                    └── Logstash :5000
                          └── Elasticsearch :9200
                                └── Kibana :5601

Spring Actuator → Prometheus :9090 → Grafana :3000
```

---

## Backend

**Base package:** `kz.eduquest`

### Domain Structure

| Package | Responsibility |
|---------|---------------|
| `auth` | Registration, login, JWT refresh/logout |
| `user` | Profiles, roles, permissions |
| `course` | Courses, blocks, lessons, content |
| `enrollment` | Self-enroll and teacher-managed enrollment |
| `progress` | Lesson completion, task/quiz submissions |
| `gamification` | XP engine, levels, badges, leaderboards |
| `storage` | File upload via MinIO |
| `common` | Security config, JWT filter, exception handling |

### Key API Groups

- `POST /api/v1/auth/**` — register, login, refresh, logout
- `GET|POST|PUT|DELETE /api/v1/courses/**` — course + block + lesson CRUD
- `POST /api/v1/tasks/{id}/submit` — submit task answer
- `POST /api/v1/quizzes/{id}/attempt` — take quiz
- `POST /api/v1/courses/{id}/enroll` — enroll in course
- `POST /api/v1/lessons/{id}/complete` — mark lesson complete
- `GET /api/v1/users/me/xp`, `/badges`, `/leaderboard` — gamification

Full API docs available at `/swagger-ui.html` when running.

### Security

- JWT access token (15 min) + refresh token (7 days)
- Roles: `ADMIN`, `TEACHER`, `STUDENT`
- Fine-grained permissions: `course:create`, `task:submit`, `enrollment:manage`, etc.

### Gamification Engine

| Action | XP |
|--------|----|
| Lesson complete | +50 |
| Task solved | +75 |
| Quiz ≥80% | +100 |
| Quiz <80% | +50 |
| Hint used | −10 |
| Block complete | +200 |
| Course complete | +500 |

Level formula: **N² × 100 XP**

---

## Frontend

```
src/
  api/         — Axios client + per-domain modules
  components/  — CourseCard, XpBar, BadgeIcon, DataTable, LevelBadge
  pages/       — one file per route
  stores/      — auth.store (JWT), theme.store (dark/light)
  types/       — TypeScript interfaces
```

### Main Routes

| Path | Access |
|------|--------|
| `/courses` | All users |
| `/courses/create`, `/courses/:id/edit` | Teacher / Admin |
| `/lessons/:id` | Enrolled students |
| `/dashboard`, `/leaderboard`, `/badges` | Auth |
| `/admin/users` | Admin only |

The Axios client automatically injects the Bearer token and handles 401 → token refresh → logout.

---

## Database (Key Tables)

```
users, user_profiles, roles, permissions
courses → blocks → lessons → lesson_contents
tasks, hints, quizzes, quiz_questions
enrollments, user_progress, task_submissions, quiz_attempts
user_levels, user_xp_logs, badge_definitions, user_badges
```

---

## Local Deployment

**Requires:** Docker + Docker Compose

```bash
git clone <repo-url>
cd edu-quest
cp .env.example .env    # edit if needed, defaults work as-is
docker compose up -d
```

First startup takes ~2–3 min (Elasticsearch + Kibana are slow).

### Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:5173 | — |
| Backend API | http://localhost:8090 | — |
| Swagger UI | http://localhost:8090/swagger-ui.html | — |
| MinIO Console | http://localhost:9001 | `minioadmin / minioadmin` |
| Kibana | http://localhost:5601 | — |
| Grafana | http://localhost:3000 | `admin / admin` |
| Prometheus | http://localhost:9090 | — |

```bash
docker compose down        # stop, keep data
docker compose down -v     # stop + wipe all volumes

docker compose build backend frontend && docker compose up -d   # rebuild

docker compose logs -f backend   # view logs
```