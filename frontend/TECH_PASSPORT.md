# EduQuest Frontend — Технический Паспорт

> **Версия документа:** 1.0
> **Дата:** 2026-03-24
> **Назначение:** Полное описание архитектуры, структуры и состояния frontend-части приложения для быстрого онбординга разработчиков и AI-ассистентов.

---

## 1. Назначение приложения

**EduQuest** — геймифицированная образовательная платформа (LMS). Студенты проходят курсы, зарабатывают XP и бейджи, соревнуются в лидерборде. Преподаватели создают и редактируют курсы. Администраторы управляют пользователями.

---

## 2. Технологический стек

| Категория | Технология | Версия |
|---|---|---|
| UI-фреймворк | React | ^19.0.0 |
| Язык | TypeScript | ~5.7.0 |
| Сборщик | Vite | ^6.0.0 |
| Стили | Tailwind CSS | ^4.0.0 |
| Роутинг | React Router | ^7.0.0 |
| Серверное состояние | TanStack Query | ^5.0.0 |
| Клиентское состояние | Zustand | ^5.0.0 |
| HTTP-клиент | Axios | ^1.7.0 |
| Формы | React Hook Form + Zod | ^7.54 / ^3.24 |
| Иконки | Lucide React | ^0.468.0 |
| Уведомления | Sonner | ^1.7.0 |
| Утилиты CSS | clsx + tailwind-merge | — |

---

## 3. Структура проекта

```
src/
├── api/                    # HTTP-слой (по одному файлу на ресурс)
│   ├── client.ts           # Axios instance + JWT interceptors (refresh token)
│   ├── auth.api.ts
│   ├── users.api.ts
│   ├── courses.api.ts
│   ├── blocks.api.ts       # Блоки внутри курса
│   ├── lessons.api.ts
│   ├── tasks.api.ts
│   ├── quizzes.api.ts
│   ├── progress.api.ts
│   ├── enrollments.api.ts
│   └── gamification.api.ts
│
├── components/
│   ├── layout/
│   │   ├── AppLayout.tsx   # Обёртка: Sidebar + main + Footer
│   │   ├── Sidebar.tsx     # Адаптивный sidebar с коллапсом
│   │   └── Footer.tsx
│   └── shared/             # Переиспользуемые UI-компоненты
│       ├── CourseCard.tsx
│       ├── DataTable.tsx
│       ├── LoadingSpinner.tsx
│       ├── EmptyState.tsx
│       ├── ConfirmDialog.tsx
│       ├── UserAvatar.tsx
│       ├── XpBar.tsx       # Полоса прогресса XP
│       ├── LevelBadge.tsx
│       └── BadgeIcon.tsx
│
├── features/               # Бизнес-логика по доменам
│   ├── auth/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   └── hooks/useAuth.ts
│   ├── dashboard/
│   │   └── DashboardPage.tsx
│   ├── courses/
│   │   ├── CatalogPage.tsx
│   │   ├── CourseDetailPage.tsx
│   │   ├── CreateCoursePage.tsx
│   │   ├── EditCoursePage.tsx
│   │   ├── MyCoursesPage.tsx
│   │   └── components/     # BlockForm, LessonForm, BlockList, LessonList
│   ├── lesson/
│   │   ├── LessonPage.tsx
│   │   └── components/     # ContentViewer, TaskSection, QuizSection
│   ├── gamification/
│   │   ├── LeaderboardPage.tsx
│   │   ├── BadgesPage.tsx
│   │   └── XpHistoryPage.tsx
│   ├── profile/
│   │   ├── ProfilePage.tsx
│   │   ├── EditProfilePage.tsx
│   │   └── PublicProfilePage.tsx
│   └── admin/
│       └── UsersPage.tsx
│
├── hooks/                  # Глобальные хуки
│   ├── useCurrentUser.ts   # Текущий пользователь из API
│   └── usePagination.ts    # Управление page/size
│
├── routes/
│   ├── index.tsx           # Декларация всех маршрутов
│   ├── ProtectedRoute.tsx  # Редирект на /login если не авторизован
│   └── RoleGuard.tsx       # Проверка ролей, иначе 403
│
├── stores/
│   ├── auth.store.ts       # Zustand: accessToken, refreshToken, isAuthenticated
│   └── ui.store.ts         # Zustand: sidebarOpen, sidebarCollapsed
│
├── types/                  # TypeScript-интерфейсы по доменам
│   ├── common.types.ts
│   ├── auth.types.ts
│   ├── user.types.ts
│   ├── course.types.ts
│   ├── lesson.types.ts
│   ├── quiz.types.ts
│   ├── task.types.ts
│   ├── enrollment.types.ts
│   ├── progress.types.ts
│   └── gamification.types.ts
│
├── lib/
│   ├── constants.ts        # API_BASE_URL, ROLES, XP_PER_LEVEL, DEFAULT_PAGE_SIZE
│   └── utils.ts            # cn() helper (clsx + tailwind-merge)
│
├── App.tsx                 # QueryClientProvider + BrowserRouter + Toaster
├── main.tsx
└── index.css               # Tailwind v4 @theme + CSS-переменные
```

---

## 4. Маршруты приложения

| Путь | Компонент | Доступ |
|---|---|---|
| `/login` | LoginPage | Публичный |
| `/register` | RegisterPage | Публичный |
| `/` | → редирект на `/courses` | Авторизованные |
| `/courses` | CatalogPage | Авторизованные |
| `/courses/:id` | CourseDetailPage | Авторизованные |
| `/courses/create` | CreateCoursePage | TEACHER, ADMIN |
| `/courses/:id/edit` | EditCoursePage | TEACHER, ADMIN |
| `/my-courses` | MyCoursesPage | Авторизованные |
| `/lessons/:id` | LessonPage | Авторизованные |
| `/dashboard` | DashboardPage | Авторизованные |
| `/leaderboard` | LeaderboardPage | Авторизованные |
| `/badges` | BadgesPage | Авторизованные |
| `/xp/history` | XpHistoryPage | Авторизованные |
| `/profile` | ProfilePage | Авторизованные |
| `/profile/edit` | EditProfilePage | Авторизованные |
| `/users/:id` | PublicProfilePage | Авторизованные |
| `/admin/users` | UsersPage | ADMIN |

---

## 5. Роли пользователей

```
GUEST    — не авторизован (видит каталог и лидерборд)
STUDENT  — стандартный пользователь (проходит курсы)
TEACHER  — может создавать/редактировать курсы
ADMIN    — полный доступ + управление пользователями
```

---

## 6. Аутентификация и авторизация

- **Механизм:** JWT (Access Token + Refresh Token)
- **Хранение:** Zustand с `persist` middleware → `localStorage` (ключ: `edu-quest-auth`)
- **Auto-refresh:** В `api/client.ts` response interceptor перехватывает 401, выполняет `POST /api/v1/auth/refresh` с refreshToken, обновляет accessToken и повторяет запрос
- **Выход при ошибке refresh:** `logout()` + редирект на `/login`
- **ProtectedRoute:** Проверяет `isAuthenticated` из `auth.store`, редиректит на `/login`
- **RoleGuard:** Принимает `allowedRoles[]`, проверяет `user.roles`, показывает 403-экран

---

## 7. Управление данными (TanStack Query)

- **staleTime:** 5 минут (глобально)
- **retry:** 1
- **refetchOnWindowFocus:** отключён
- **Ключи запросов (Query Keys):**
  - `["currentUser"]` — текущий пользователь
  - `["courses", page, size]` — каталог курсов
  - `["myEnrollments", { page, size }]` — мои записи на курсы
  - `["myXp"]` — XP текущего пользователя
  - `["myBadges"]` — бейджи текущего пользователя
  - `["leaderboard", page, size]` — лидерборд
  - `["lesson", id]` — урок по ID
  - `["myProgress"]` — прогресс прохождения
- **Инвалидация:** После завершения урока инвалидируются `myProgress` и `myXp`

---

## 8. Доменные сущности

### Course (Курс)
```typescript
{ id, teacherId, title, description, coverUrl, published, createdAt }
```
Структура: Курс → Блоки (`Block`) → Уроки (`Lesson`)

### Lesson (Урок)
```typescript
{ id, blockId, title, sortOrder, xpReward, contents[], tasks[], quizzes[] }
```
Содержит: контент (ContentViewer), задания (TaskSection), квизы (QuizSection)

### Gamification
```typescript
XpResponse:        { totalXp, currentLevel, xpForNextLevel }
BadgeResponse:     { badgeId, name, description, iconUrl, awardedAt }
LeaderboardEntry:  { rank, userId, displayName, totalXp, level }
XpLogResponse:     { id, actionType, xpAmount, referenceId, createdAt }
```

### Enrollment (Запись на курс)
```typescript
{ id, courseId, courseTitle, status, enrolledAt }
```
Статусы: `ACTIVE`, `COMPLETED`, `DROPPED` (строки от бэкенда)

---

## 9. Стили и дизайн-система

- **CSS-фреймворк:** Tailwind CSS v4 с кастомными переменными через `@theme` в `index.css`
- **Шрифты:** Nunito (заголовки h1-h6) + Inter (body) — подключены через Google Fonts
- **Dark mode:** Class-based — JS добавляет `.dark` на `<html>`, CSS-переменные переопределяются в `.dark { }`
- **Переключатель:** `ThemeToggle` в нижней части Sidebar; состояние в `stores/theme.store.ts` (persist в localStorage)

### Цветовые токены

| Токен | Light | Dark | Назначение |
|---|---|---|---|
| `--color-primary` | `hsl(243 75% 57%)` | `hsl(243 80% 68%)` | Кнопки, ссылки, фокус-кольцо |
| `--color-background` | `hsl(220 20% 97%)` | `hsl(224 40% 7%)` | Основной фон страницы |
| `--color-foreground` | `hsl(222 47% 10%)` | `hsl(213 25% 90%)` | Основной текст |
| `--color-card` | `hsl(0 0% 100%)` | `hsl(224 38% 11%)` | Фон карточек |
| `--color-sidebar` | `hsl(224 35% 11%)` | `hsl(224 40% 5%)` | Тёмный sidebar в обоих режимах |
| `--color-xp` | `hsl(38 92% 50%)` | `hsl(38 95% 57%)` | XP, очки, прогресс |
| `--color-level` | `hsl(262 83% 58%)` | `hsl(262 90% 70%)` | Уровни, бейджи |

> **Важно:** primary — electric indigo, а не dark navy. Это обеспечивает видимость `bg-primary text-white` в обеих темах. Sidebar намеренно тёмный в обоих режимах (game-nav стиль).

- **Утилита cn():** `clsx` + `tailwind-merge` — в `lib/utils.ts`

### Система тем (файлы)

| Файл | Роль |
|---|---|
| `src/index.css` | Токены в `@theme` (light) и `.dark { }` (overrides) |
| `src/stores/theme.store.ts` | Zustand store + `applyTheme()` функция |
| `src/components/shared/ThemeToggle.tsx` | Кнопка Sun/Moon для sidebar |
| `src/App.tsx` | `ThemeInitializer` — mount + system preference listener |

---

## 10. Layout

- **Desktop:** Фиксированный sidebar (64px свёрнутый / 256px развёрнутый) + основной контент
- **Mobile:** Sidebar скрыт, появляет по нажатию hamburger (fixed top-left), overlay с затемнением
- **Состояние sidebar:** `ui.store.ts` — `sidebarOpen` (mobile), `sidebarCollapsed` (desktop)
- **Max-width контента:** `max-w-7xl` в большинстве страниц

---

## 11. API-слой

- **Base URL:** `/api/v1` (proxied через Vite)
- **Формат:** REST/JSON
- **Пагинация:** Spring Page формат: `{ content[], totalPages, totalElements, number, first, last, empty }`
- **Все запросы** проходят через `api/client.ts` с автоматическим добавлением Bearer token

---

## 12. Конфигурационные файлы

| Файл | Назначение |
|---|---|
| `vite.config.ts` | Vite конфиг (React plugin, Tailwind plugin) |
| `tsconfig.json` | TypeScript корневой конфиг |
| `tsconfig.app.json` | Конфиг для src/, path alias `@` → `./src` |
| `tsconfig.node.json` | Конфиг для vite.config.ts |
| `index.html` | Точка входа HTML |

---

## 13. Анализ: Проблемы UX/UI и лучших практик

### 🔴 Критические

| # | Проблема | Где | Влияние |
|---|---|---|---|
| C1 | JWT хранится в `localStorage` через Zustand persist | `auth.store.ts` | Уязвимость XSS — токены доступны любому JS-коду |
| C2 | `window.location.href` в API клиенте вместо React Router navigate | `api/client.ts:27,38` | Полная перезагрузка страницы, потеря состояния |
| C3 | Нет Error Boundaries | Весь app | При любой ошибке рендера — белый экран без recovery |

### 🟠 Важные UX-проблемы

| # | Проблема | Где | Влияние |
|---|---|---|---|
| U1 | Dashboard приветствует по `email` вместо `displayName` | `DashboardPage.tsx:28` | Безличный опыт |
| U2 | Статусы записей показываются на английском (`ACTIVE`, `COMPLETED`) | `DashboardPage.tsx:88` | Несоответствие русскому UI |
| U3 | Нет поиска и фильтрации в каталоге курсов | `CatalogPage.tsx` | Основной use-case заблокирован при росте |
| U4 | Кнопка "Завершить урок" всегда активна, даже если урок пройден | `LessonPage.tsx` | Дублирование, путаница |
| U5 | 404 страница — просто инлайновый текст | `routes/index.tsx:61` | Нет навигации обратно |
| U6 | Нет скелетонов загрузки | Все страницы | Spinner без размеров вызывает layout shift |
| U7 | Pagination в Leaderboard импортирован но не отображается в UI | `LeaderboardPage.tsx` | Неполная фича |

### 🟡 Дизайн и визуал

| # | Проблема | Где | Влияние |
|---|---|---|---|
| D1 | Шрифт Inter — самый generic AI-шрифт | `index.css:34` | Нет характера у геймиф. платформы |
| D2 | Одна светлая тема, нет dark mode | `index.css` | Современный стандарт игнорируется |
| D3 | XpBar — тонкая серая полоса без анимации | `XpBar.tsx` | Главный геймиф. элемент не вовлекает |
| D4 | CourseCard без cover показывает пустой серый прямоугольник | `CourseCard.tsx:15` | Нет fallback-дизайна |
| D5 | Цветовая схема — тёмно-синий + белый, нет акцентного цвета | `index.css` | Нет игровой атмосферы |
| D6 | Badges Grid — простые border-карточки | `BadgesPage.tsx` | Достижение должно ощущаться наградой |
| D7 | Leaderboard — plain HTML таблица | `LeaderboardPage.tsx` | Топ-3 визуально не отличается |
| D8 | Нет page transitions | Весь app | Навигация ощущается резкой |
| D9 | Login/Register страницы — минимальный white form | `LoginPage.tsx` | Первое впечатление скучное |

### 🔵 Технический долг

| # | Проблема | Где |
|---|---|---|
| T1 | Нет тестов (unit, integration) | `package.json` — нет test script |
| T2 | Нет React.Suspense | Весь app |
| T3 | `getLesson(id!)` — non-null assertion вместо guard | `LessonPage.tsx:18` |
| T4 | Нет обновления `<title>` страницы при навигации | Весь app |
| T5 | Нет обработки offline/network error | `api/client.ts` |
| T6 | `useCurrentUser` делает запрос на каждом рендере sidebar | `Sidebar.tsx:49` |

---

## 14. План улучшений (приоритизированный)

### Фаза 1 — Критические исправления (делать первыми)

```
[ ] C1: Перенести токены в httpOnly cookies (нужна поддержка бэкенда)
      Если бэкенд не поддерживает — минимум добавить note в README о риске
[ ] C2: Заменить window.location.href на useNavigate (создать NavigationService)
[ ] C3: Добавить ErrorBoundary в App.tsx обёртку с fallback UI
[ ] T3: Заменить id! на ранний return если !id
```

### Фаза 2 — UX-улучшения

```
[ ] U1: Показывать displayName в приветствии Dashboard
[ ] U2: Маппинг статусов enrollment: ACTIVE → "Активен", COMPLETED → "Завершён"
[ ] U4: Получать статус прохождения урока, дизейблить/менять кнопку
[ ] U5: Создать полноценную 404-страницу с кнопкой "На главную"
[ ] U7: Добавить UI пагинации в Leaderboard (кнопки уже в компоненте есть)
[ ] U3: Добавить поиск по названию курса в CatalogPage
```

### Фаза 3 — Дизайн и геймификация

```
[ ] D1: Сменить шрифт — для заголовков взять что-то с характером
         (Suggestion: Sora, Nunito, или Space Grotesk для h1/h2)
[ ] D2: Добавить dark mode (Tailwind v4 поддерживает через @media prefers-color-scheme)
[ ] D3: Улучшить XpBar — добавить gradient fill, shimmer animation, число уровня крупнее
[ ] D4: CourseCard fallback — использовать gradient + первую букву названия
[ ] D5: Добавить акцентный цвет (amber/yellow для XP, violet для уровней)
[ ] D6: Badges с glow-эффектом, hover scale, анимация появления при первом рендере
[ ] D7: Leaderboard топ-3 — выделить строки gold/silver/bronze фоном
[ ] D8: Page transitions через CSS classes (fade-in при смене маршрута)
[ ] D9: Login страница — добавить branded background (gradient или pattern)
```

### Фаза 4 — Технический долг

```
[ ] T1: Настроить Vitest + React Testing Library
[ ] T2: Обернуть route-level компоненты в Suspense с skeleton fallback
[ ] T4: Использовать document.title в useEffect на каждой странице
[ ] T5: Глобальный обработчик network error в QueryClient (onError callback)
[ ] T6: Убедиться что useCurrentUser правильно кешируется (staleTime достаточен)
```

---

## 15. Быстрый старт для разработчика

```bash
# Установка
npm install

# Разработка (требует запущенный бэкенд на :8080)
npm run dev

# Сборка
npm run build

# Lint
npm run lint
```

**Прокси:** Vite проксирует `/api/v1/*` на бэкенд (проверить `vite.config.ts`).

**Добавление новой страницы:**
1. Создать `src/features/<domain>/<PageName>.tsx`
2. Добавить API-функции в `src/api/<domain>.api.ts`
3. Добавить маршрут в `src/routes/index.tsx`
4. При необходимости — добавить в `navItems` в `Sidebar.tsx`

**Добавление нового API-запроса:**
1. Добавить функцию в соответствующий `api/*.api.ts`
2. Использовать `useQuery` / `useMutation` в компоненте
3. Определить уникальный `queryKey`

---

*Документ сгенерирован на основе анализа исходного кода. Актуальность: 2026-03-24.*