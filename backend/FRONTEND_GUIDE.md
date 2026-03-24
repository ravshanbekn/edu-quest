# EduQuest — Frontend Development Guide

## 1. Технологический стек

| Категория | Технология | Версия | Зачем |
|-----------|-----------|--------|-------|
| Framework | React | 19.x | SPA |
| Language | TypeScript | 5.x | Типобезопасность |
| Build | Vite | 6.x | Быстрая сборка |
| Routing | React Router | 7.x | Навигация |
| Data Fetching | TanStack Query | 5.x | Кеширование, мутации, рефетч |
| State | Zustand | 5.x | Глобальный стейт (auth, UI) |
| HTTP Client | Axios | 1.x | Interceptors для JWT |
| Стили | Tailwind CSS | 4.x | Utility-first, консистентность |
| UI Components | shadcn/ui | latest | Переиспользуемые компоненты на базе Radix |
| Формы | React Hook Form + Zod | latest | Валидация форм |
| Иконки | Lucide React | latest | Единый набор иконок |
| Тосты | Sonner | latest | Уведомления |

---

## 2. Структура проекта

```
src/
├── api/                      # API layer
│   ├── client.ts             # Axios instance + interceptors (JWT, refresh, errors)
│   ├── auth.api.ts           # Auth endpoints
│   ├── users.api.ts          # Users & profiles
│   ├── courses.api.ts        # Courses CRUD
│   ├── blocks.api.ts         # Blocks CRUD
│   ├── lessons.api.ts        # Lessons CRUD
│   ├── tasks.api.ts          # Tasks + hints + submit
│   ├── quizzes.api.ts        # Quizzes + attempts
│   ├── enrollments.api.ts    # Enrollments
│   ├── progress.api.ts       # Progress tracking
│   └── gamification.api.ts   # XP, badges, leaderboard
│
├── components/
│   ├── layout/               # Общий layout (используется ВЕЗДЕ)
│   │   ├── AppLayout.tsx     # Wrapper: Header + Sidebar + Main + Footer
│   │   ├── Header.tsx        # Единый хедер для всего приложения
│   │   ├── Sidebar.tsx       # Боковое меню (бургер на мобильных)
│   │   └── Footer.tsx        # Футер
│   │
│   ├── ui/                   # shadcn/ui компоненты (Button, Input, Card, Dialog, etc.)
│   │
│   └── shared/               # Переиспользуемые бизнес-компоненты
│       ├── CourseCard.tsx     # Карточка курса (каталог, мои курсы)
│       ├── BadgeIcon.tsx     # Отображение бейджа
│       ├── XpBar.tsx         # Прогресс-бар XP
│       ├── LevelBadge.tsx    # Индикатор уровня
│       ├── UserAvatar.tsx    # Аватар пользователя
│       ├── DataTable.tsx     # Таблица с пагинацией (admin)
│       ├── EmptyState.tsx    # Пустое состояние
│       ├── LoadingSpinner.tsx
│       └── ConfirmDialog.tsx # Модалка подтверждения
│
├── features/                 # Страницы и фичи
│   ├── auth/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   └── hooks/
│   │       └── useAuth.ts
│   │
│   ├── dashboard/
│   │   └── DashboardPage.tsx # Главная после логина
│   │
│   ├── courses/
│   │   ├── CatalogPage.tsx   # Каталог курсов
│   │   ├── CourseDetailPage.tsx
│   │   ├── CreateCoursePage.tsx
│   │   ├── EditCoursePage.tsx
│   │   └── components/
│   │       ├── BlockList.tsx
│   │       ├── BlockForm.tsx
│   │       ├── LessonList.tsx
│   │       └── LessonForm.tsx
│   │
│   ├── lesson/
│   │   ├── LessonPage.tsx    # Прохождение урока
│   │   └── components/
│   │       ├── ContentViewer.tsx
│   │       ├── TaskSection.tsx
│   │       └── QuizSection.tsx
│   │
│   ├── profile/
│   │   ├── ProfilePage.tsx
│   │   ├── EditProfilePage.tsx
│   │   └── PublicProfilePage.tsx
│   │
│   ├── gamification/
│   │   ├── LeaderboardPage.tsx
│   │   ├── BadgesPage.tsx
│   │   └── XpHistoryPage.tsx
│   │
│   └── admin/
│       ├── UsersPage.tsx
│       └── RolesPage.tsx
│
├── hooks/                    # Глобальные хуки
│   ├── useCurrentUser.ts     # GET /users/me через TanStack Query
│   └── usePagination.ts     # Переиспользуемая пагинация
│
├── stores/                   # Zustand stores
│   ├── auth.store.ts         # tokens, isAuthenticated, login(), logout()
│   └── ui.store.ts           # sidebarOpen, theme
│
├── types/                    # TypeScript типы (зеркало backend DTO)
│   ├── auth.types.ts
│   ├── user.types.ts
│   ├── course.types.ts
│   ├── lesson.types.ts
│   ├── task.types.ts
│   ├── quiz.types.ts
│   ├── enrollment.types.ts
│   ├── progress.types.ts
│   ├── gamification.types.ts
│   └── common.types.ts       # Page<T>, Pageable, enums
│
├── lib/                      # Утилиты
│   ├── utils.ts              # cn(), formatDate(), etc.
│   └── constants.ts          # API_BASE_URL, роли, XP формулы
│
├── routes/
│   ├── index.tsx             # Определение маршрутов
│   ├── ProtectedRoute.tsx    # Обёртка для авторизованных маршрутов
│   └── RoleGuard.tsx         # Обёртка для ролевого доступа
│
├── App.tsx
└── main.tsx
```

---

## 3. Единый стиль и Layout

### 3.1 Принцип: один Layout — все страницы

Все страницы рендерятся внутри `<AppLayout>`. Хедер, сайдбар и футер **одни на всё приложение** и никогда не пересоздаются при навигации.

```tsx
// routes/index.tsx
<Route element={<AppLayout />}>
  <Route path="/dashboard" element={<DashboardPage />} />
  <Route path="/courses" element={<CatalogPage />} />
  <Route path="/courses/:id" element={<CourseDetailPage />} />
  <Route path="/profile" element={<ProfilePage />} />
  <Route path="/leaderboard" element={<LeaderboardPage />} />
  {/* Все остальные маршруты */}
</Route>
```

```tsx
// components/layout/AppLayout.tsx
export function AppLayout() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <div className="flex flex-1">
        <Sidebar />
        <main className="flex-1 p-6">
          <Outlet />  {/* Здесь рендерится текущая страница */}
        </main>
      </div>
      <Footer />
    </div>
  );
}
```

### 3.2 Header — единый для всех

```
┌─────────────────────────────────────────────────────────────┐
│ ☰  EduQuest          [Каталог] [Мои курсы] [Лидерборд]     │
│                                  🔔  [Аватар ▼ dropdown]    │
└─────────────────────────────────────────────────────────────┘
```

- Логотип слева, навигация по центру, профиль справа
- На мобильных: бургер-меню `☰` открывает Sidebar
- Навигация адаптируется по роли (ADMIN видит "Управление", TEACHER видит "Мои курсы", STUDENT видит "Обучение")
- Текущая вкладка подсвечивается активным стилем

### 3.3 Sidebar

- На десктопе: фиксированная боковая панель (можно сворачивать)
- На мобильных: выдвигается по нажатию бургера в Header, поверх контента с overlay
- Содержит: навигацию, XP-бар, текущий уровень, быстрые ссылки
- Состояние open/closed хранится в `ui.store.ts`

### 3.4 Цветовая палитра (Tailwind)

Использовать CSS-переменные через `tailwind.config.ts` для единообразия:

```ts
// tailwind.config.ts — расширение цветов
colors: {
  primary:    "hsl(var(--primary))",
  secondary:  "hsl(var(--secondary))",
  accent:     "hsl(var(--accent))",
  background: "hsl(var(--background))",
  foreground: "hsl(var(--foreground))",
  muted:      "hsl(var(--muted))",
  destructive:"hsl(var(--destructive))",
}
```

### 3.5 Типографика

- Заголовки страниц: `text-2xl font-bold`
- Подзаголовки секций: `text-lg font-semibold`
- Обычный текст: `text-sm` или `text-base`
- Мелкий текст (даты, метки): `text-xs text-muted-foreground`

---

## 4. Переиспользование компонентов

### 4.1 Правила

1. **Компонент используется 2+ раза → выносить в `shared/`**
2. **Компонент специфичен для одной фичи → оставлять в `features/*/components/`**
3. **UI-примитивы (Button, Input, Card) → `ui/` через shadcn/ui**
4. **Никогда не дублировать стили** — использовать `cn()` для условного объединения классов

### 4.2 Ключевые shared-компоненты

| Компонент | Где используется |
|-----------|-----------------|
| `CourseCard` | Каталог, мои курсы, dashboard, профиль учителя |
| `UserAvatar` | Header, sidebar, профиль, лидерборд, список студентов |
| `XpBar` | Sidebar, dashboard, профиль |
| `LevelBadge` | Рядом с аватаром везде |
| `BadgeIcon` | Профиль, бейджи, публичный профиль |
| `DataTable` | Админка (пользователи), список студентов курса |
| `EmptyState` | Любой список, когда данных нет |
| `ConfirmDialog` | Удаление курса/блока/урока, отписка |

---

## 5. API — Полный справочник эндпоинтов

**Base URL:** `http://localhost:8090`
**Auth:** JWT Bearer token в заголовке `Authorization: Bearer <token>`
**Пагинация:** `?page=0&size=10&sort=createdAt,desc`

### 5.1 Auth — `/api/v1/auth`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| POST | `/register` | `{ email, password, displayName? }` | `{ accessToken, refreshToken, expiresIn }` | — |
| POST | `/login` | `{ email, password }` | `{ accessToken, refreshToken, expiresIn }` | — |
| POST | `/refresh` | `{ refreshToken }` | `{ accessToken, refreshToken, expiresIn }` | — |
| POST | `/logout` | `{ refreshToken }` | — | — |

**Валидация:**
- `email`: обязательный, валидный email
- `password`: обязательный, 6–128 символов
- `displayName`: опциональный, макс. 100 символов

### 5.2 Users & Profiles — `/api/v1/users`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| GET | `/me` | — | `UserResponse` | Any |
| PUT | `/me/profile` | `{ displayName?, bio?, isPublic? }` | `ProfileResponse` | Any |
| POST | `/me/avatar` | `multipart/form-data: file` | `ProfileResponse` | Any |
| GET | `/{id}/profile` | — | `ProfileResponse` (видимость по ролям) | Any |
| GET | `/` | `?page&size&sort` | `Page<UserResponse>` | ADMIN |
| PUT | `/{id}/roles` | `["TEACHER", "STUDENT"]` | `UserResponse` | ADMIN |

**UserResponse:**
```ts
{
  id: string           // UUID
  email: string
  active: boolean
  roles: string[]      // ["STUDENT", "TEACHER"]
  createdAt: string    // ISO datetime
}
```

**ProfileResponse:**
```ts
{
  userId: string
  displayName: string | null
  avatarUrl: string | null
  bio: string | null
  isPublic: boolean
}
```
Видимость: владелец и ADMIN видят всё; публичный профиль — displayName + avatar + bio + бейджи + уровень; закрытый — только displayName + avatar.

### 5.3 Courses — `/api/v1/courses`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| POST | `/` | `{ title, description? }` | `CourseResponse` | TEACHER/ADMIN |
| GET | `/` | `?page&size&sort` | `Page<CourseResponse>` | Public |
| GET | `/{id}` | — | `CourseResponse` | Public |
| PUT | `/{id}` | `{ title?, description?, coverUrl? }` | `CourseResponse` | Owner/ADMIN |
| DELETE | `/{id}` | — | 204 | Owner/ADMIN |
| PUT | `/{id}/publish` | — | `CourseResponse` | Owner/ADMIN |
| GET | `/{id}/students` | `?page&size&sort` | `Page<UserResponse>` | Owner/ADMIN |

**CourseResponse:**
```ts
{
  id: string
  teacherId: string
  title: string
  description: string | null
  coverUrl: string | null
  published: boolean
  createdAt: string
}
```

### 5.4 Blocks — `/api/v1`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| POST | `/courses/{courseId}/blocks` | `{ title }` | `BlockResponse` | Owner/ADMIN |
| PUT | `/blocks/{id}` | `{ title? }` | `BlockResponse` | Owner/ADMIN |
| DELETE | `/blocks/{id}` | — | 204 | Owner/ADMIN |
| PUT | `/courses/{courseId}/blocks/reorder` | `{ orderedIds: string[] }` | `BlockResponse[]` | Owner/ADMIN |

**BlockResponse:**
```ts
{
  id: string
  courseId: string
  title: string
  sortOrder: number
}
```

### 5.5 Lessons — `/api/v1`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| POST | `/blocks/{blockId}/lessons` | `{ title, type, xpReward? }` | `LessonResponse` | Owner/ADMIN |
| GET | `/lessons/{id}` | — | `LessonDetailResponse` | Public |
| PUT | `/lessons/{id}` | `{ title?, type?, xpReward? }` | `LessonResponse` | Owner/ADMIN |
| DELETE | `/lessons/{id}` | — | 204 | Owner/ADMIN |

**LessonType:** `"VIDEO"` | `"TASK"` | `"QUIZ"` | `"MIXED"`

**LessonResponse:**
```ts
{
  id: string
  blockId: string
  title: string
  type: LessonType
  sortOrder: number
  xpReward: number
}
```

**LessonDetailResponse:**
```ts
{
  id: string
  title: string
  type: LessonType
  xpReward: number
  contents: ContentResponse[]
  tasks: TaskResponse[]
  quizzes: QuizBriefResponse[]
}
```

**ContentResponse:**
```ts
{
  id: string
  contentType: "TEXT" | "VIDEO" | "CODE_BLOCK"
  body: string | null
  videoUrl: string | null
  sortOrder: number
}
```

### 5.6 Tasks — `/api/v1`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| POST | `/lessons/{lessonId}/tasks` | `{ description, solution?, taskType?, xpReward? }` | `TaskResponse` | Owner/ADMIN |
| PUT | `/tasks/{id}` | `{ description?, solution?, taskType?, xpReward? }` | `TaskResponse` | Owner/ADMIN |
| POST | `/tasks/{id}/hints` | `{ content, xpPenalty? }` | 201 | Owner/ADMIN |
| POST | `/tasks/{id}/submit` | `{ answer }` | `TaskSubmission` | STUDENT |
| POST | `/tasks/{id}/hints/{hintId}/reveal` | — | `Hint` | STUDENT |

**TaskType:** `"TEXT"` | `"CODE"` | `"FILE_UPLOAD"`

**TaskResponse:**
```ts
{
  id: string
  lessonId: string
  description: string
  taskType: TaskType
  xpReward: number
  sortOrder: number
  hintCount: number
}
```

### 5.7 Quizzes — `/api/v1`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| POST | `/lessons/{lessonId}/quizzes` | `{ title?, timeLimit?, xpReward?, questions }` | `QuizResponse` | Owner/ADMIN |
| POST | `/quizzes/{id}/attempt` | — | `QuizResponse` (без ответов) | STUDENT |
| POST | `/quizzes/{id}/attempt/{attemptId}/submit` | `{ answers: { [questionId]: number[] } }` | `QuizAttempt` | STUDENT |

**Создание квиза — questions:**
```ts
{
  question: string
  options: string[]
  correct: number[]    // индексы правильных ответов
}
```

**QuizResponse:**
```ts
{
  id: string
  lessonId: string
  title: string | null
  timeLimit: number | null   // секунды
  xpReward: number
  questions: {
    id: string
    question: string
    options: string[]
    sortOrder: number
  }[]
}
```

### 5.8 Enrollments — `/api/v1`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| POST | `/courses/{id}/enroll` | — | `EnrollmentResponse` | STUDENT |
| POST | `/courses/{id}/enroll/{userId}` | — | `EnrollmentResponse` | Owner/ADMIN |
| DELETE | `/courses/{id}/enroll/{userId}` | — | 204 | Owner/ADMIN |
| GET | `/users/me/enrollments` | `?page&size&sort` | `Page<EnrollmentResponse>` | Any |

**EnrollmentStatus:** `"ACTIVE"` | `"COMPLETED"` | `"DROPPED"`

**EnrollmentResponse:**
```ts
{
  id: string
  userId: string
  courseId: string
  courseTitle: string
  status: EnrollmentStatus
  enrolledAt: string
}
```

### 5.9 Progress — `/api/v1`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| GET | `/users/me/progress` | — | `UserProgress[]` | Any |
| GET | `/courses/{id}/progress` | — | `UserProgress[]` | Any |
| POST | `/lessons/{id}/complete` | — | `UserProgress` | STUDENT |

**ProgressStatus:** `"NOT_STARTED"` | `"IN_PROGRESS"` | `"COMPLETED"`

### 5.10 Gamification — `/api/v1`

| Метод | URL | Тело запроса | Ответ | Auth |
|-------|-----|-------------|-------|------|
| GET | `/users/me/xp` | — | `XpResponse` | Any |
| GET | `/users/me/badges` | — | `BadgeResponse[]` | Any |
| GET | `/users/{id}/badges` | — | `BadgeResponse[]` | Public |
| GET | `/leaderboard` | `?page&size` | `LeaderboardEntry[]` | Public |
| GET | `/users/me/xp/history` | `?page&size&sort` | `Page<XpLogResponse>` | Any |

**XpResponse:**
```ts
{
  totalXp: number
  currentLevel: number
  xpForNextLevel: number
}
```

**BadgeResponse:**
```ts
{
  badgeId: string
  name: string
  description: string
  iconUrl: string | null
  awardedAt: string
}
```

**LeaderboardEntry:**
```ts
{
  rank: number
  userId: string
  displayName: string
  totalXp: number
  level: number
}
```

**ActionType:** `"LESSON_COMPLETE"` | `"TASK_SOLVED"` | `"QUIZ_PASSED"` | `"HINT_USED"` | `"BLOCK_COMPLETE"` | `"COURSE_COMPLETE"` | `"DAILY_LOGIN"`

**XpLogResponse:**
```ts
{
  id: string
  actionType: ActionType
  xpAmount: number       // может быть отрицательным (штраф за hint)
  referenceId: string
  createdAt: string
}
```

---

## 6. Axios Client — JWT и рефреш токена

```ts
// api/client.ts
const api = axios.create({ baseURL: "http://localhost:8090" });

// Добавляем токен ко всем запросам
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Автоматический рефреш при 401
api.interceptors.response.use(
  (res) => res,
  async (error) => {
    if (error.response?.status === 401 && !error.config._retry) {
      error.config._retry = true;
      const newTokens = await refreshTokens();
      error.config.headers.Authorization = `Bearer ${newTokens.accessToken}`;
      return api(error.config);
    }
    return Promise.reject(error);
  }
);
```

---

## 7. Enum-типы — полный список

```ts
// types/common.types.ts

type LessonType = "VIDEO" | "TASK" | "QUIZ" | "MIXED";
type TaskType = "TEXT" | "CODE" | "FILE_UPLOAD";
type ContentType = "TEXT" | "VIDEO" | "CODE_BLOCK";
type ProgressStatus = "NOT_STARTED" | "IN_PROGRESS" | "COMPLETED";
type EnrollmentStatus = "ACTIVE" | "COMPLETED" | "DROPPED";
type ActionType =
  | "LESSON_COMPLETE" | "TASK_SOLVED" | "QUIZ_PASSED"
  | "HINT_USED" | "BLOCK_COMPLETE" | "COURSE_COMPLETE" | "DAILY_LOGIN";
type Role = "ADMIN" | "TEACHER" | "STUDENT" | "GUEST";
```

---

## 8. Пагинация — формат Spring

Все пагинированные эндпоинты принимают query-параметры и возвращают обёртку:

**Запрос:** `?page=0&size=10&sort=createdAt,desc`

**Ответ:**
```ts
interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;        // текущая страница (0-based)
  first: boolean;
  last: boolean;
  empty: boolean;
}
```

---

## 9. Маршруты приложения

| Маршрут | Страница | Доступ |
|---------|----------|--------|
| `/login` | Вход | Public |
| `/register` | Регистрация | Public |
| `/dashboard` | Главная (после логина) | Auth |
| `/courses` | Каталог курсов | Public |
| `/courses/:id` | Детали курса | Public |
| `/courses/create` | Создание курса | TEACHER/ADMIN |
| `/courses/:id/edit` | Редактирование курса | Owner/ADMIN |
| `/lessons/:id` | Прохождение урока | STUDENT |
| `/profile` | Мой профиль | Auth |
| `/profile/edit` | Редактирование профиля | Auth |
| `/users/:id` | Публичный профиль | Auth |
| `/leaderboard` | Лидерборд | Public |
| `/badges` | Мои бейджи | Auth |
| `/xp/history` | История XP | Auth |
| `/admin/users` | Управление пользователями | ADMIN |
| `/my-courses` | Мои курсы (студент/учитель) | Auth |

---

## 10. Чек-лист консистентности

- [ ] Все страницы рендерятся внутри `<AppLayout>` — один Header/Sidebar на всё приложение
- [ ] Один компонент `Header` — не создавать отдельные хедеры для разных страниц
- [ ] Один компонент `Sidebar` — навигация адаптируется по роли, но **один и тот же компонент**
- [ ] Бургер-меню на мобильных открывает **тот же Sidebar**, а не отдельное меню
- [ ] Все кнопки — через `<Button>` из `ui/`, никакого сырого `<button>`
- [ ] Все карточки — через `<Card>` из `ui/`, единый border-radius и shadow
- [ ] Все формы — через React Hook Form + `<Input>`, `<Textarea>`, `<Select>` из `ui/`
- [ ] Все модалки — через `<Dialog>` из `ui/`
- [ ] Все тосты/уведомления — через Sonner, единая позиция (top-right)
- [ ] Цвета только через CSS-переменные (`primary`, `secondary`, `muted`, etc.)
- [ ] Отступы между секциями: `space-y-6`, между элементами: `space-y-4` или `gap-4`
- [ ] Максимальная ширина контента: `max-w-7xl mx-auto`
- [ ] Состояния загрузки: скелетоны через `<Skeleton>` из `ui/`, не спиннеры на каждую страницу
- [ ] Пустые состояния: через `<EmptyState>`, не просто пустой экран
