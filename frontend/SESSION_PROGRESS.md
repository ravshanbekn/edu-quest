# EduQuest Frontend — Прогресс разработки

## Что уже сделано

### Фаза 0: Инициализация проекта — ГОТОВО
- Vite 6 + React 19 + TypeScript 5 проект
- Все зависимости установлены (`npm install` выполнен):
  - react-router-dom, @tanstack/react-query, zustand, axios
  - react-hook-form, @hookform/resolvers, zod
  - tailwindcss, @tailwindcss/vite
  - lucide-react, sonner, clsx, tailwind-merge
- Tailwind CSS 4 настроен с CSS-переменными (цвета, радиусы)
- Vite конфиг: алиас `@/` → `src/`, прокси `/api` → `localhost:8090`, порт 3000
- `README.md` с инструкцией по запуску
- `.gitignore`

### Фаза 1: Базовая инфраструктура — ГОТОВО
- `src/lib/utils.ts` — функция `cn()` (clsx + tailwind-merge)
- `src/lib/constants.ts` — API_BASE_URL, ROLES, XP_PER_LEVEL, DEFAULT_PAGE_SIZE
- `src/types/` — все TypeScript типы:
  - `common.types.ts` — enums (LessonType, TaskType, etc.), Page<T>, Pageable
  - `auth.types.ts` — LoginRequest, RegisterRequest, AuthResponse
  - `user.types.ts` — UserResponse, ProfileResponse
  - `course.types.ts` — CourseResponse, BlockResponse
  - `lesson.types.ts` — LessonResponse, LessonDetailResponse, ContentResponse
  - `task.types.ts` — TaskResponse, TaskSubmission, Hint
  - `quiz.types.ts` — QuizResponse, QuizAttempt
  - `enrollment.types.ts` — EnrollmentResponse
  - `progress.types.ts` — UserProgress
  - `gamification.types.ts` — XpResponse, BadgeResponse, LeaderboardEntry, XpLogResponse
- `src/stores/auth.store.ts` — Zustand store с persist (tokens, login/logout)
- `src/stores/ui.store.ts` — Zustand store (sidebarOpen)
- `src/api/client.ts` — Axios instance с JWT interceptors и auto-refresh

### Фаза 2: Layout и навигация — ГОТОВО (обновлено)
- `src/components/layout/AppLayout.tsx` — основной layout (Sidebar + Main + Footer), без Header
- `src/components/layout/Sidebar.tsx` — основная навигация: сворачиваемый sidebar (иконки/полный), логотип, профиль, logout внутри; мобильный overlay + hamburger кнопка
- `src/components/layout/Footer.tsx`
- `src/components/layout/Header.tsx` — **УДАЛЁН** (вся навигация перенесена в Sidebar)
- `src/stores/ui.store.ts` — sidebarOpen (мобильный) + sidebarCollapsed (десктоп, persist в localStorage)
- `src/routes/index.tsx` — все маршруты с Placeholder для нереализованных страниц
- `src/routes/ProtectedRoute.tsx` — редирект на /login если не авторизован
- `src/routes/RoleGuard.tsx` — проверка ролей

### Фаза 3: Auth — ГОТОВО
- `src/api/auth.api.ts` — loginApi, registerApi, logoutApi
- `src/features/auth/LoginPage.tsx` — форма входа (react-hook-form + zod)
- `src/features/auth/RegisterPage.tsx` — форма регистрации с подтверждением пароля
- `src/features/auth/hooks/useAuth.ts` — хуки useLogin, useRegister, useLogout (TanStack Query mutations)

### Фаза 4: Shared-компоненты — ГОТОВО
- `src/components/shared/LoadingSpinner.tsx`
- `src/components/shared/EmptyState.tsx`
- `src/components/shared/ConfirmDialog.tsx`
- `src/components/shared/UserAvatar.tsx` — аватар с инициалами/фото
- `src/components/shared/XpBar.tsx` — прогресс-бар опыта
- `src/components/shared/LevelBadge.tsx`
- `src/components/shared/BadgeIcon.tsx`
- `src/components/shared/CourseCard.tsx` — карточка курса
- `src/components/shared/DataTable.tsx` — таблица с пагинацией
- `src/hooks/usePagination.ts`
- `src/hooks/useCurrentUser.ts`

### Фаза 5: Dashboard и профиль — ГОТОВО
- `src/api/users.api.ts` — getCurrentUser, updateProfile, uploadAvatar, getUserProfile, getUsers, updateUserRoles
- `src/api/gamification.api.ts` — getMyXp, getMyBadges, getUserBadges, getLeaderboard, getXpHistory
- `src/api/enrollments.api.ts` — enrollInCourse, getMyEnrollments и т.д.
- `src/api/progress.api.ts` — getMyProgress, getCourseProgress, completeLesson
- `src/features/dashboard/DashboardPage.tsx` — XP карточка, быстрые ссылки, последние записи
- `src/features/profile/ProfilePage.tsx` — аватар, XP, бейджи, инфо
- `src/features/profile/EditProfilePage.tsx` — форма редактирования + загрузка аватара
- `src/features/profile/PublicProfilePage.tsx`
- Все страницы подключены в routes/index.tsx

### Фаза 6: Курсы — ГОТОВО
- `src/api/courses.api.ts` — getCourses, getCourse, createCourse, updateCourse, deleteCourse, publishCourse, getCourseStudents
- `src/api/blocks.api.ts` — createBlock, updateBlock, deleteBlock, reorderBlocks
- `src/api/lessons.api.ts` — createLesson, getLesson, updateLesson, deleteLesson
- `src/features/courses/CatalogPage.tsx` — каталог с пагинацией и кнопкой "Создать курс" для преподавателей
- `src/features/courses/CourseDetailPage.tsx` — детальная страница: обложка, блоки/уроки, запись на курс, публикация, редактирование, удаление
- `src/features/courses/CreateCoursePage.tsx` — форма создания курса (название + описание)
- `src/features/courses/EditCoursePage.tsx` — форма редактирования курса (название, описание, URL обложки)
- `src/features/courses/MyCoursesPage.tsx` — "Мои курсы": курсы преподавателя + записи студента
- `src/features/courses/components/BlockList.tsx` — список блоков с раскрытием, CRUD операции
- `src/features/courses/components/BlockForm.tsx` — инлайн-форма создания/редактирования блока
- `src/features/courses/components/LessonList.tsx` — список уроков в блоке, CRUD операции
- `src/features/courses/components/LessonForm.tsx` — инлайн-форма создания/редактирования урока (название + тип)
- Все Placeholder в routes/index.tsx заменены на реальные компоненты курсов
- Проект билдится без ошибок

### Фаза 7: Уроки и задания — ГОТОВО
- `src/api/tasks.api.ts` — createTask, updateTask, addHint, submitTask, revealHint
- `src/api/quizzes.api.ts` — createQuiz, startQuizAttempt, submitQuizAttempt
- `src/features/lesson/LessonPage.tsx` — страница прохождения урока: контент, задания, квизы, кнопка завершения
- `src/features/lesson/components/ContentViewer.tsx` — отображение TEXT/VIDEO/CODE_BLOCK контента
- `src/features/lesson/components/TaskSection.tsx` — задания с отправкой ответов, подсказками, результатами
- `src/features/lesson/components/QuizSection.tsx` — квизы с таймером, выбором ответов, результатами
- Подключено в routes/index.tsx

### Фаза 8: Геймификация — ГОТОВО
- `src/features/gamification/LeaderboardPage.tsx` — таблица лидеров с медалями, ссылками на профили
- `src/features/gamification/BadgesPage.tsx` — все бейджи пользователя с описаниями и датами
- `src/features/gamification/XpHistoryPage.tsx` — история начислений XP с пагинацией
- Подключено в routes/index.tsx

### Фаза 9: Админка — ГОТОВО
- `src/features/admin/UsersPage.tsx` — список пользователей (DataTable) + управление ролями (модалка RoleEditor)
- Подключено в routes/index.tsx
- Все Placeholder удалены — все маршруты подключены к реальным компонентам

---

## Статус: ВСЕ ФАЗЫ ЗАВЕРШЕНЫ

Проект полностью реализован. Все страницы подключены, Placeholder удалён.
- TypeScript компиляция: без ошибок
- Vite build: успешно
- Dev-сервер: `npm run dev` (порт 3000)

## Спецификация API
Полная спецификация всех эндпоинтов — в файле `FRONTEND_GUIDE.md`.
