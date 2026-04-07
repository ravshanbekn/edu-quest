# EduQuest Frontend

Фронтенд образовательной платформы EduQuest — React SPA.

## Требования


- **Node.js** >= 18 (рекомендуется 20+)
- **npm** >= 9
- Backend API запущен на `http://localhost:8090`

## Быстрый старт

```bash
# 1. Установить зависимости (если ещё не установлены)


# 2. Запустить dev-сервер
npm run dev
```

Приложение откроется на **http://localhost:3000**.

API-запросы к `/api/*` автоматически проксируются на `http://localhost:8090`.

## Команды

| Команда         | Описание                                    |
|-----------------|---------------------------------------------|
| `npm run dev`   | Запуск dev-сервера (http://localhost:3000)   |
| `npm run build` | Сборка для продакшена в папку `dist/`        |
| `npm run preview` | Просмотр собранной версии                 |
| `npm run lint`  | Проверка кода линтером                      |

## Технологии

- React 19 + TypeScript 5
- Vite 6 (сборка и dev-сервер)
- Tailwind CSS 4 (стили)
- React Router 7 (навигация)
- TanStack Query 5 (запросы к API, кеширование)
- Zustand 5 (глобальный стейт)
- Axios (HTTP-клиент с JWT interceptors)
- React Hook Form + Zod (формы и валидация)
- shadcn/ui (UI-компоненты)
- Lucide React (иконки)
- Sonner (тосты/уведомления)

## Структура проекта

```
src/
├── api/          # Axios клиент и функции для каждого API-модуля
├── components/
│   ├── layout/   # AppLayout, Header, Sidebar, Footer
│   ├── ui/       # shadcn/ui компоненты (Button, Input, Card...)
│   └── shared/   # Переиспользуемые бизнес-компоненты
├── features/     # Страницы, сгруппированные по фичам
│   ├── auth/     # Логин, регистрация
│   ├── dashboard/
│   ├── courses/  # Каталог, создание, редактирование курсов
│   ├── lesson/   # Прохождение уроков
│   ├── profile/  # Профиль пользователя
│   ├── gamification/ # Лидерборд, бейджи, XP
│   └── admin/    # Админ-панель
├── hooks/        # Глобальные React-хуки
├── stores/       # Zustand stores (auth, ui)
├── types/        # TypeScript типы
├── lib/          # Утилиты (cn(), константы)
└── routes/       # Маршруты и guards
```
