# EduQuest — Архитектурный документ

## 1. Обзор проекта

EduQuest — образовательная платформа с геймификацией, построенная на RBAC-модели. Учителя создают структурированные курсы (курс → блоки → уроки), студенты проходят их и зарабатывают опыт, уровни и бейджи за каждое действие.

---

## 2. Технологический стек

### Backend
- **Java 21 + Spring Boot 3.x** — основной фреймворк
- **Spring Security + JWT** — аутентификация и авторизация
- **Spring Data JPA (Hibernate)** — ORM
- **PostgreSQL** — основная база данных
- **Redis** — кеширование (профили, уровни, лидерборд)
- **MinIO** — хранение файлов (аватарки, видео)
- **RabbitMQ** — асинхронные события (геймификация)
- **Flyway** — миграции базы данных

### Frontend (рекомендация)
- **React + TypeScript + Vite**
- **TanStack Query** — data fetching
- **Tailwind CSS** — стилизация
- **Zustand** — state management

### Инфраструктура
- **Docker + Docker Compose** — контейнеризация
- **Spring Cloud Gateway** — API gateway (если микросервисы)
- **Swagger / OpenAPI** — документация API

---

## 3. Архитектурный подход

Рекомендую начать с **модульного монолита** — это Spring Boot приложение с чёткими модулями, где каждый модуль имеет свой пакет и общается через внутренние интерфейсы. Когда нагрузка вырастет, любой модуль легко выделяется в отдельный микросервис.

### Структура пакетов

```
com.eduquest
├── common/              # Общие утилиты, exceptions, DTO
│   ├── exception/
│   ├── security/
│   └── config/
├── user/                # Модуль пользователей и RBAC
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── entity/
│   └── dto/
├── course/              # Модуль курсов (блоки, уроки, контент)
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── entity/
│   └── dto/
├── enrollment/          # Модуль записи на курсы
│   ├── controller/
│   ├── service/
│   ├── repository/
│   └── entity/
├── progress/            # Модуль прогресса и прохождения
│   ├── controller/
│   ├── service/
│   ├── repository/
│   └── entity/
├── gamification/        # Модуль геймификации (XP, уровни, бейджи)
│   ├── engine/
│   ├── badge/
│   ├── level/
│   ├── listener/        # Event listeners
│   └── entity/
└── storage/             # Модуль файлового хранилища
    ├── controller/
    └── service/
```

---

## 4. RBAC — Модель ролей и прав

### 4.1 Роли

| Роль | Описание |
|------|----------|
| **ADMIN** | Полный доступ. Управление пользователями, ролями, всеми курсами. |
| **TEACHER** | Создание и управление своими курсами. Запись/отписка студентов. Просмотр прогресса своих студентов. |
| **STUDENT** | Прохождение курсов, выполнение задач, прохождение тестов. Редактирование своего профиля. |
| **GUEST** | Просмотр каталога курсов и публичных профилей. Без прохождения контента. |

### 4.2 Наследование прав

ADMIN наследует все права TEACHER, TEACHER наследует все права STUDENT. Это реализуется через Spring Security с `@PreAuthorize` и кастомным `PermissionEvaluator`.

### 4.3 Таблица permissions

| Код | Описание | Роли |
|-----|----------|------|
| `user:manage` | CRUD пользователей | ADMIN |
| `role:manage` | Назначение ролей | ADMIN |
| `course:create` | Создание курса | TEACHER, ADMIN |
| `course:manage_own` | Редактирование своих курсов | TEACHER, ADMIN |
| `course:manage_all` | Редактирование любых курсов | ADMIN |
| `enrollment:manage` | Запись/отписка студентов | TEACHER (свои курсы), ADMIN |
| `progress:view_students` | Просмотр прогресса студентов | TEACHER (свои курсы), ADMIN |
| `course:view` | Просмотр каталога курсов | Все роли |
| `lesson:complete` | Прохождение уроков | STUDENT |
| `task:submit` | Отправка решений задач | STUDENT |
| `quiz:take` | Прохождение тестов | STUDENT |
| `profile:edit_own` | Редактирование своего профиля | STUDENT, TEACHER, ADMIN |
| `profile:view_public` | Просмотр публичных профилей | Все роли |

### 4.4 Реализация в Spring Security

```java
// Кастомная аннотация
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@PreAuthorize("@permissionService.hasPermission(authentication, #courseId, 'course:manage_own')")
public @interface RequiresCourseOwner {}

// Сервис проверки
@Service
public class PermissionService {
    
    public boolean hasPermission(Authentication auth, UUID courseId, String permission) {
        UserPrincipal user = (UserPrincipal) auth.getPrincipal();
        
        // ADMIN имеет все права
        if (user.hasRole("ADMIN")) return true;
        
        // TEACHER может управлять только своими курсами
        if (permission.equals("course:manage_own")) {
            return courseRepository.existsByIdAndTeacherId(courseId, user.getId());
        }
        
        return user.hasPermission(permission);
    }
}
```

---

## 5. Модель данных

### 5.1 Пользователи и профили

```sql
CREATE TABLE users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active   BOOLEAN DEFAULT true,
    created_at  TIMESTAMP DEFAULT now(),
    updated_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE user_profiles (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL UNIQUE REFERENCES users(id),
    display_name VARCHAR(100),
    avatar_url   VARCHAR(500),
    bio          TEXT,
    is_public    BOOLEAN DEFAULT true,
    created_at   TIMESTAMP DEFAULT now(),
    updated_at   TIMESTAMP DEFAULT now()
);

CREATE TABLE roles (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE permissions (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id),
    role_id INT NOT NULL REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE role_permissions (
    role_id       INT NOT NULL REFERENCES roles(id),
    permission_id INT NOT NULL REFERENCES permissions(id),
    PRIMARY KEY (role_id, permission_id)
);
```

### 5.2 Курсы, блоки, уроки

```sql
CREATE TABLE courses (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id   UUID NOT NULL REFERENCES users(id),
    title        VARCHAR(255) NOT NULL,
    description  TEXT,
    cover_url    VARCHAR(500),
    is_published BOOLEAN DEFAULT false,
    created_at   TIMESTAMP DEFAULT now(),
    updated_at   TIMESTAMP DEFAULT now()
);

CREATE TABLE blocks (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id   UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    sort_order  INT NOT NULL DEFAULT 0,
    created_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE lessons (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    block_id    UUID NOT NULL REFERENCES blocks(id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    type        VARCHAR(50) NOT NULL DEFAULT 'MIXED',  -- VIDEO, TASK, QUIZ, MIXED
    sort_order  INT NOT NULL DEFAULT 0,
    xp_reward   INT NOT NULL DEFAULT 50,
    created_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE lesson_content (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id     UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    content_type  VARCHAR(50) NOT NULL,  -- TEXT, VIDEO, CODE_BLOCK
    body          TEXT,
    video_url     VARCHAR(500),
    sort_order    INT NOT NULL DEFAULT 0
);

CREATE TABLE tasks (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id   UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    solution    TEXT,                    -- Правильный ответ или reference solution
    task_type   VARCHAR(50) DEFAULT 'TEXT',  -- TEXT, CODE, FILE_UPLOAD
    xp_reward   INT NOT NULL DEFAULT 75,
    sort_order  INT NOT NULL DEFAULT 0
);

CREATE TABLE hints (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    content     TEXT NOT NULL,
    sort_order  INT NOT NULL DEFAULT 0,
    xp_penalty  INT NOT NULL DEFAULT 10  -- Штраф за использование подсказки
);

CREATE TABLE quizzes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id   UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title       VARCHAR(255),
    time_limit  INT,                     -- В секундах, NULL = без ограничения
    xp_reward   INT NOT NULL DEFAULT 100,
    created_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE quiz_questions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id     UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question    TEXT NOT NULL,
    options     JSONB NOT NULL,          -- ["option1", "option2", ...]
    correct     JSONB NOT NULL,          -- [0, 2] индексы правильных ответов
    sort_order  INT NOT NULL DEFAULT 0
);
```

### 5.3 Запись на курсы и прогресс

```sql
CREATE TABLE enrollments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    course_id   UUID NOT NULL REFERENCES courses(id),
    status      VARCHAR(50) DEFAULT 'ACTIVE',  -- ACTIVE, COMPLETED, DROPPED
    enrolled_at TIMESTAMP DEFAULT now(),
    enrolled_by UUID REFERENCES users(id),      -- NULL = самозапись, иначе = учитель
    UNIQUE (user_id, course_id)
);

CREATE TABLE user_progress (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users(id),
    lesson_id    UUID NOT NULL REFERENCES lessons(id),
    status       VARCHAR(50) DEFAULT 'IN_PROGRESS',  -- NOT_STARTED, IN_PROGRESS, COMPLETED
    score        INT DEFAULT 0,
    hints_used   INT DEFAULT 0,
    completed_at TIMESTAMP,
    UNIQUE (user_id, lesson_id)
);

CREATE TABLE task_submissions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    task_id     UUID NOT NULL REFERENCES tasks(id),
    answer      TEXT NOT NULL,
    is_correct  BOOLEAN,
    xp_earned   INT DEFAULT 0,
    submitted_at TIMESTAMP DEFAULT now()
);

CREATE TABLE quiz_attempts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    quiz_id     UUID NOT NULL REFERENCES quizzes(id),
    answers     JSONB NOT NULL,
    score       INT NOT NULL,
    max_score   INT NOT NULL,
    xp_earned   INT DEFAULT 0,
    started_at  TIMESTAMP DEFAULT now(),
    finished_at TIMESTAMP
);
```

### 5.4 Геймификация

```sql
CREATE TABLE user_xp_log (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users(id),
    action_type  VARCHAR(100) NOT NULL,   -- LESSON_COMPLETE, TASK_SOLVED, QUIZ_PASSED, HINT_USED
    xp_amount    INT NOT NULL,            -- Может быть отрицательным (штраф за подсказку)
    reference_id UUID,                    -- ID урока/задачи/квиза
    created_at   TIMESTAMP DEFAULT now()
);

CREATE TABLE user_levels (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL UNIQUE REFERENCES users(id),
    current_level INT NOT NULL DEFAULT 1,
    total_xp      INT NOT NULL DEFAULT 0,
    updated_at    TIMESTAMP DEFAULT now()
);

CREATE TABLE badge_definitions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    icon_url        VARCHAR(500),
    condition_type  VARCHAR(100) NOT NULL,  -- LESSONS_COMPLETED, COURSES_COMPLETED, STREAK, LEVEL_REACHED, XP_EARNED
    condition_value INT NOT NULL,           -- Числовое условие (например, 10 уроков)
    is_active       BOOLEAN DEFAULT true
);

CREATE TABLE user_badges (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id),
    badge_id   UUID NOT NULL REFERENCES badge_definitions(id),
    awarded_at TIMESTAMP DEFAULT now(),
    UNIQUE (user_id, badge_id)
);

CREATE INDEX idx_xp_log_user ON user_xp_log(user_id, created_at DESC);
CREATE INDEX idx_user_badges_user ON user_badges(user_id);
CREATE INDEX idx_progress_user ON user_progress(user_id, status);
CREATE INDEX idx_enrollments_user ON enrollments(user_id, status);
CREATE INDEX idx_enrollments_course ON enrollments(course_id, status);
```

---

## 6. Система геймификации

### 6.1 Таблица XP за действия

| Действие | XP | Примечание |
|----------|----|----|
| Завершение урока | +50 | Базовая награда |
| Решение задачи | +75 | Первое правильное решение |
| Прохождение теста (≥80%) | +100 | Полный XP только при ≥80% |
| Прохождение теста (<80%) | +50 | Частичный XP |
| Использование подсказки | −10 | Штраф за каждую подсказку |
| Завершение блока | +200 | Бонус за завершение всего блока |
| Завершение курса | +500 | Бонус за полное прохождение |
| Первый вход за день | +10 | Daily login bonus |

### 6.2 Система уровней

Прогрессивная формула: для уровня N нужно `N² × 100` XP от предыдущего уровня.

| Уровень | Общий XP | Прирост |
|---------|----------|---------|
| 1 | 0 | — |
| 2 | 100 | 100 |
| 3 | 500 | 400 |
| 4 | 1400 | 900 |
| 5 | 2900 | 1600 |
| 10 | 28500 | 8100 |
| 20 | 253500 | 36100 |

### 6.3 Бейджи

| Бейдж | Условие | Тип |
|-------|---------|-----|
| 🔰 Первые шаги | Завершить 1 урок | `LESSONS_COMPLETED = 1` |
| 📚 Прилежный ученик | Завершить 10 уроков | `LESSONS_COMPLETED = 10` |
| 🏆 Мастер курса | Завершить любой курс на 100% | `COURSES_COMPLETED = 1` |
| 🔥 Стрик ×5 | 5 дней подряд заходить и учиться | `STREAK = 5` |
| 🔥 Стрик ×30 | 30 дней подряд | `STREAK = 30` |
| 🧠 Решатель | Решить 50 задач | `TASKS_SOLVED = 50` |
| 🎯 Снайпер | Пройти 10 тестов на 100% | `PERFECT_QUIZZES = 10` |
| ⭐ Уровень 10 | Достичь 10 уровня | `LEVEL_REACHED = 10` |
| 💎 Уровень 25 | Достичь 25 уровня | `LEVEL_REACHED = 25` |
| 🚀 Без подсказок | Завершить курс без подсказок | `COURSE_NO_HINTS = 1` |

### 6.4 Архитектура геймификации (Event-Driven)

Геймификация работает асинхронно через события:

```java
// 1. Сервис прогресса публикует событие
@Service
public class ProgressService {
    private final ApplicationEventPublisher eventPublisher;
    
    public void completeLesson(UUID userId, UUID lessonId) {
        // Обновить прогресс...
        eventPublisher.publishEvent(new LessonCompletedEvent(userId, lessonId));
    }
}

// 2. XP Engine слушает событие
@Component
public class XpEngine {
    @EventListener
    public void onLessonCompleted(LessonCompletedEvent event) {
        int xp = calculateXp(event);
        xpLogRepository.save(new XpLogEntry(event.getUserId(), "LESSON_COMPLETE", xp, event.getLessonId()));
        userLevelService.addXp(event.getUserId(), xp);
    }
}

// 3. Badge Evaluator тоже слушает
@Component 
public class BadgeEvaluator {
    @EventListener
    public void onLessonCompleted(LessonCompletedEvent event) {
        evaluateAndAward(event.getUserId());
    }
    
    private void evaluateAndAward(UUID userId) {
        List<BadgeDefinition> unearned = badgeRepository.findUnearnedByUser(userId);
        for (BadgeDefinition badge : unearned) {
            if (conditionMet(userId, badge)) {
                userBadgeRepository.save(new UserBadge(userId, badge.getId()));
                // Можно отправить уведомление
            }
        }
    }
}
```

---

## 7. API — Основные эндпоинты

### 7.1 Auth

```
POST   /api/v1/auth/register          — Регистрация
POST   /api/v1/auth/login             — Вход (возвращает JWT access + refresh)
POST   /api/v1/auth/refresh           — Обновление токена
POST   /api/v1/auth/logout            — Выход
```

### 7.2 Users & Profiles

```
GET    /api/v1/users/me                — Текущий пользователь
PUT    /api/v1/users/me/profile        — Обновить профиль
POST   /api/v1/users/me/avatar         — Загрузить аватар
GET    /api/v1/users/{id}/profile      — Профиль пользователя (публичный/приватный)
GET    /api/v1/users                   — Список (ADMIN only, с пагинацией)
PUT    /api/v1/users/{id}/roles        — Назначить роли (ADMIN only)
```

### 7.3 Courses

```
POST   /api/v1/courses                 — Создать курс (TEACHER)
GET    /api/v1/courses                 — Каталог курсов (с фильтрами)
GET    /api/v1/courses/{id}            — Детали курса
PUT    /api/v1/courses/{id}            — Обновить курс (owner / ADMIN)
DELETE /api/v1/courses/{id}            — Удалить курс (owner / ADMIN)
PUT    /api/v1/courses/{id}/publish    — Опубликовать курс
GET    /api/v1/courses/{id}/students   — Список студентов (TEACHER)
```

### 7.4 Blocks & Lessons

```
POST   /api/v1/courses/{courseId}/blocks              — Создать блок
PUT    /api/v1/blocks/{id}                            — Обновить блок
DELETE /api/v1/blocks/{id}                            — Удалить блок
PUT    /api/v1/courses/{courseId}/blocks/reorder       — Изменить порядок

POST   /api/v1/blocks/{blockId}/lessons               — Создать урок
GET    /api/v1/lessons/{id}                           — Детали урока (с контентом)
PUT    /api/v1/lessons/{id}                           — Обновить урок
DELETE /api/v1/lessons/{id}                           — Удалить урок
```

### 7.5 Tasks & Quizzes

```
POST   /api/v1/lessons/{lessonId}/tasks               — Создать задачу
PUT    /api/v1/tasks/{id}                             — Обновить задачу
POST   /api/v1/tasks/{id}/hints                       — Добавить подсказку
POST   /api/v1/tasks/{id}/submit                      — Отправить решение (STUDENT)
POST   /api/v1/tasks/{id}/hints/{hintId}/reveal       — Открыть подсказку (STUDENT, -XP)

POST   /api/v1/lessons/{lessonId}/quizzes             — Создать квиз
POST   /api/v1/quizzes/{id}/attempt                   — Начать попытку
POST   /api/v1/quizzes/{id}/attempt/{attemptId}/submit — Отправить ответы
```

### 7.6 Enrollments

```
POST   /api/v1/courses/{id}/enroll                    — Записаться (STUDENT — самозапись)
POST   /api/v1/courses/{id}/enroll/{userId}           — Записать студента (TEACHER)
DELETE /api/v1/courses/{id}/enroll/{userId}            — Отписать студента (TEACHER)
GET    /api/v1/users/me/enrollments                   — Мои курсы
```

### 7.7 Progress & Gamification

```
GET    /api/v1/users/me/progress                      — Общий прогресс
GET    /api/v1/courses/{id}/progress                  — Прогресс по курсу
POST   /api/v1/lessons/{id}/complete                  — Отметить урок завершённым

GET    /api/v1/users/me/xp                            — Мой XP и уровень
GET    /api/v1/users/me/badges                        — Мои бейджи
GET    /api/v1/users/{id}/badges                      — Бейджи пользователя (публичные)
GET    /api/v1/leaderboard                            — Лидерборд (top-N по XP)
GET    /api/v1/users/me/xp/history                    — История начислений XP
```

---

## 8. Логика видимости профилей

```java
@Service
public class ProfileService {
    
    public ProfileResponse getProfile(UUID targetUserId, Authentication auth) {
        UserProfile profile = profileRepository.findByUserId(targetUserId)
            .orElseThrow(() -> new NotFoundException("Profile not found"));
        
        // Свой профиль — полный доступ
        if (isOwner(auth, targetUserId)) {
            return ProfileResponse.full(profile);
        }
        
        // ADMIN видит всё
        if (hasRole(auth, "ADMIN")) {
            return ProfileResponse.full(profile);
        }
        
        // Публичный профиль — показываем публичные данные
        if (profile.isPublic()) {
            return ProfileResponse.publicView(profile);  
            // display_name, avatar, bio, бейджи, уровень
        }
        
        // Закрытый профиль — только display_name и avatar
        return ProfileResponse.restricted(profile);
    }
}
```

---

## 9. Мои рекомендации и улучшения

### 9.1 Самозапись студентов
Помимо записи учителем, студенты могут сами записываться на опубликованные курсы. Учитель может отключить самозапись в настройках курса.

### 9.2 Стрик-система
Добавить механику daily streak — студент получает бонус за ежедневную активность. Стрик ломается, если пропустить день. Это сильнейший retention-механизм (как в Duolingo).

### 9.3 Лидерборд
Глобальный и per-course лидерборды. Кеширование в Redis с TTL 5 минут. Показывать top-100 + позицию текущего пользователя.

### 9.4 Уведомления (future)
WebSocket или SSE для real-time уведомлений: «Вы получили бейдж!», «Новый уровень!», «Учитель записал вас на курс».

### 9.5 Anti-cheat
Однократное начисление XP за действие (idempotency через `UNIQUE(user_id, lesson_id)` в `user_progress`). Задачи можно пересдавать, но XP за задачу начисляется только за первое правильное решение.

### 9.6 Мягкое удаление
Использовать soft delete (`is_deleted` + `deleted_at`) для курсов и пользователей. Прогресс студентов не должен исчезать при удалении курса.

### 9.7 Аудит-лог
Логировать все значимые действия (создание/удаление курсов, изменение ролей, записи на курсы) для прозрачности.

---

## 10. Порядок разработки (план спринтов)

1. **Sprint 1** — Auth + RBAC: регистрация, JWT, роли, права
2. **Sprint 2** — Профили: CRUD, аватарки, приватность
3. **Sprint 3** — Курсы: CRUD курсов, блоков, уроков
4. **Sprint 4** — Контент: видео, задачи, тесты, подсказки
5. **Sprint 5** — Enrollment: запись, отписка, списки
6. **Sprint 6** — Прогресс: прохождение уроков, сдача задач/тестов
7. **Sprint 7** — Геймификация: XP engine, уровни, бейджи
8. **Sprint 8** — Лидерборд, стрики, уведомления
9. **Sprint 9** — Frontend MVP
10. **Sprint 10** — Тестирование, оптимизация, деплой
