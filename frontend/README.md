# EduQuest — Frontend

React SPA for the EduQuest gamified learning platform. Students browse courses, earn XP and badges, compete on a leaderboard. Teachers manage courses and content.

## Tech Stack

| | |
|---|---|
| Framework | React 19 |
| Language | TypeScript 5 |
| Build | Vite 6 |
| Styles | Tailwind CSS 4 |
| Routing | React Router 7 |
| Server state | TanStack Query 5 |
| Client state | Zustand 5 |
| HTTP | Axios 1 |
| Forms | React Hook Form + Zod |
| Icons | Lucide React |
| Notifications | Sonner |

## Getting Started

### Prerequisites

Backend must be running on `http://localhost:8090`. See the [backend README](../backend/README.md).

### Install dependencies

```bash
npm install
```

### Run development server

```bash
npm run dev
```

App is available at `http://localhost:3000`. All `/api` requests are proxied to the backend.

## Commands

```bash
npm run dev      # Start dev server (port 3000)
npm run build    # Production build
npm run lint     # Run ESLint
```

## Project Structure

```
src/
├── api/          # Axios API functions (one file per resource)
├── components/   # layout/ and shared/ reusable components
├── features/     # Pages and domain logic (auth, courses, lesson, profile, gamification, admin)
├── hooks/        # Global hooks (useCurrentUser, usePagination)
├── routes/       # Route definitions, ProtectedRoute, RoleGuard
├── stores/       # Zustand stores (auth, ui, theme)
├── types/        # TypeScript interfaces mirroring backend DTOs
└── lib/          # Utilities (cn, constants)
```

## Authentication

JWT-based auth. Tokens are stored via Zustand persist in `localStorage`. The Axios client automatically refreshes the access token on 401 responses.

## Roles

| Role | Access |
|------|--------|
| `GUEST` | Course catalog, leaderboard |
| `STUDENT` | All above + enroll in courses, complete lessons, earn XP |
| `TEACHER` | All above + create and manage own courses |
| `ADMIN` | Full access + user management |
