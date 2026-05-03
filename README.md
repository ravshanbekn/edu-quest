# EduQuest

An online learning platform with course management, quizzes, progress tracking, and gamification (XP, badges, leaderboards).

## Stack

| Layer | Tech |
|-------|------|
| Frontend | React 19, TypeScript, TailwindCSS, Vite |
| Backend | Spring Boot 4 (Java 17), JWT auth, Flyway |
| Database | PostgreSQL 16 |
| Storage | MinIO (S3-compatible) |
| Logging | Logstash → Elasticsearch → Kibana |
| Metrics | Prometheus → Grafana |

## Running

**Prerequisites:** Docker and Docker Compose installed.

```bash
git clone <repo-url>
cd edu-quest
docker compose up -d
```

That's it. All services start automatically with health checks.

## Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:5173 | — |
| Backend API | http://localhost:8090 | — |
| API Docs (Swagger) | http://localhost:8090/swagger-ui.html | — |
| MinIO Console | http://localhost:9001 | `minioadmin` / `minioadmin` |
| Kibana | http://localhost:5601 | — |
| Grafana | http://localhost:3000 | `admin` / `admin` |
| Prometheus | http://localhost:9090 | — |

## Monitoring

- **Kibana** — view and search application logs shipped via Logstash
- **Grafana** — pre-provisioned dashboards for backend metrics (JVM, HTTP, DB)
- **Prometheus** — raw metrics scrape endpoint at `/actuator/prometheus`

## Stopping

```bash
docker compose down          # stop containers
docker compose down -v       # stop and remove all volumes (deletes data)
```

## Worked on:
- 230103046
- 230103054