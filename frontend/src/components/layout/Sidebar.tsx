import { Link, useLocation } from "react-router-dom";
import {
  Home,
  BookOpen,
  GraduationCap,
  Trophy,
  Award,
  History,
  Settings,
  X,
  PanelLeftClose,
  PanelLeftOpen,
  LogOut,
  User,
  LogIn,
  Menu,
  Sun,
  Moon,
} from "lucide-react";
import { useUiStore } from "@/stores/ui.store";
import { useAuthStore } from "@/stores/auth.store";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { useThemeStore } from "@/stores/theme.store";
import { cn } from "@/lib/utils";

interface NavItem {
  to: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  roles?: string[];
  authRequired?: boolean;
}

const navItems: NavItem[] = [
  { to: "/dashboard",   label: "Главная",      icon: Home,          authRequired: true },
  { to: "/courses",     label: "Каталог курсов", icon: BookOpen },
  { to: "/my-courses",  label: "Мои курсы",    icon: GraduationCap, authRequired: true },
  { to: "/leaderboard", label: "Лидерборд",    icon: Trophy },
  { to: "/badges",      label: "Бейджи",       icon: Award,         authRequired: true },
  { to: "/xp/history",  label: "История XP",   icon: History,       authRequired: true },
  { to: "/admin/users", label: "Управление",   icon: Settings,      roles: ["ADMIN"] },
];

// Пункты доступные без авторизации / для гостей
const GUEST_ROUTES = new Set(["/courses", "/leaderboard"]);

// Единый класс для всех кнопок/ссылок в сайдбаре (обеспечивает одинаковое выравнивание)
const itemBase = "flex items-center gap-3 rounded-md text-sm transition-colors";
const itemPadding = "px-3 py-2";
const itemPaddingCollapsed = "px-2 py-2 justify-center";

export function Sidebar() {
  const location = useLocation();
  const sidebarOpen = useUiStore((s) => s.sidebarOpen);
  const setSidebarOpen = useUiStore((s) => s.setSidebarOpen);
  const sidebarCollapsed = useUiStore((s) => s.sidebarCollapsed);
  const toggleSidebarCollapsed = useUiStore((s) => s.toggleSidebarCollapsed);
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const logout = useAuthStore((s) => s.logout);
  const { data: user } = useCurrentUser();
  const { theme, toggle: toggleTheme } = useThemeStore();

  const userRoles = user?.roles ?? [];
  // Гость = не авторизован ИЛИ имеет только роль GUEST
  const isGuest =
    !isAuthenticated ||
    (userRoles.length > 0 && userRoles.every((r) => r === "GUEST"));

  const filteredItems = navItems.filter((item) => {
    // Гость видит только маршруты из GUEST_ROUTES
    if (isGuest && !GUEST_ROUTES.has(item.to)) return false;
    // Требует авторизации
    if (item.authRequired && !isAuthenticated) return false;
    // Требует определённую роль
    if (item.roles && !item.roles.some((r) => userRoles.includes(r))) return false;
    return true;
  });

  const sidebarContent = (collapsed: boolean) => {
    const padding = collapsed ? itemPaddingCollapsed : itemPadding;

    return (
      <div className="flex flex-col h-full">
        {/* ── Header ─────────────────────────────────────────── */}
        <div className="flex items-center h-14 px-3 border-b border-sidebar-border shrink-0">
          {!collapsed && (
            <Link
              to="/"
              onClick={() => setSidebarOpen(false)}
              className="font-bold text-lg whitespace-nowrap text-sidebar-accent-foreground hover:text-white transition-colors"
              style={{ fontFamily: "var(--font-display)" }}
            >
              EduQuest
            </Link>
          )}

          {/* Mobile: закрыть */}
          <button
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden ml-auto p-2 rounded-md text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground transition-colors"
            aria-label="Закрыть меню"
          >
            <X className="h-5 w-5" />
          </button>

          {/* Desktop: свернуть/развернуть */}
          <button
            onClick={toggleSidebarCollapsed}
            className={cn(
              "hidden lg:flex p-2 rounded-md text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground transition-colors",
              collapsed ? "mx-auto" : "ml-auto"
            )}
            aria-label={collapsed ? "Развернуть меню" : "Свернуть меню"}
          >
            {collapsed ? (
              <PanelLeftOpen className="h-5 w-5" />
            ) : (
              <PanelLeftClose className="h-5 w-5" />
            )}
          </button>
        </div>

        {/* ── Navigation ─────────────────────────────────────── */}
        <nav className="flex-1 px-3 py-3 space-y-0.5 overflow-y-auto">
          {filteredItems.map((item) => {
            const Icon = item.icon;
            const isActive =
              location.pathname === item.to ||
              location.pathname.startsWith(item.to + "/");
            return (
              <Link
                key={item.to}
                to={item.to}
                onClick={() => setSidebarOpen(false)}
                title={collapsed ? item.label : undefined}
                className={cn(
                  itemBase,
                  padding,
                  isActive
                    ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                    : "text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground"
                )}
              >
                <Icon className="h-4 w-4 shrink-0" />
                {!collapsed && <span>{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        {/* ── Bottom: тема + профиль + выход ─────────────────── */}
        <div className="border-t border-sidebar-border px-3 py-3 space-y-0.5">
          {/* Переключатель темы */}
          <button
            onClick={toggleTheme}
            title={
              collapsed
                ? theme === "dark"
                  ? "Светлая тема"
                  : "Тёмная тема"
                : undefined
            }
            aria-label={theme === "dark" ? "Переключить на светлую тему" : "Переключить на тёмную тему"}
            className={cn(itemBase, padding, "w-full text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground")}
          >
            {theme === "dark" ? (
              <Sun className="h-4 w-4 shrink-0 text-xp" />
            ) : (
              <Moon className="h-4 w-4 shrink-0" />
            )}
            {!collapsed && (
              <span>{theme === "dark" ? "Светлая тема" : "Тёмная тема"}</span>
            )}
          </button>

          {/* Авторизован и не гость — Профиль + Выйти */}
          {isAuthenticated && !isGuest && (
            <>
              <Link
                to="/profile"
                onClick={() => setSidebarOpen(false)}
                title={collapsed ? "Профиль" : undefined}
                className={cn(
                  itemBase,
                  padding,
                  location.pathname === "/profile"
                    ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                    : "text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground"
                )}
              >
                <User className="h-4 w-4 shrink-0" />
                {!collapsed && <span>Профиль</span>}
              </Link>

              <button
                onClick={logout}
                title={collapsed ? "Выйти" : undefined}
                className={cn(itemBase, padding, "w-full text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground")}
              >
                <LogOut className="h-4 w-4 shrink-0" />
                {!collapsed && <span>Выйти</span>}
              </button>
            </>
          )}

          {/* Авторизован как GUEST — только Выйти */}
          {isAuthenticated && isGuest && (
            <button
              onClick={logout}
              title={collapsed ? "Выйти" : undefined}
              className={cn(itemBase, padding, "w-full text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground")}
            >
              <LogOut className="h-4 w-4 shrink-0" />
              {!collapsed && <span>Выйти</span>}
            </button>
          )}

          {/* Не авторизован — только Войти */}
          {!isAuthenticated && (
            <Link
              to="/login"
              onClick={() => setSidebarOpen(false)}
              title={collapsed ? "Войти" : undefined}
              className={cn(itemBase, padding, "text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground")}
            >
              <LogIn className="h-4 w-4 shrink-0" />
              {!collapsed && <span>Войти</span>}
            </Link>
          )}
        </div>
      </div>
    );
  };

  return (
    <>
      {/* Hamburger — mobile */}
      <button
        onClick={() => setSidebarOpen(true)}
        className="fixed top-3 left-3 z-30 lg:hidden p-2 rounded-md bg-background/80 backdrop-blur border text-foreground hover:bg-muted transition-colors"
        aria-label="Открыть меню"
      >
        <Menu className="h-5 w-5" />
      </button>

      {/* Overlay — mobile */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/50 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar — mobile (fixed) */}
      <aside
        className={cn(
          "fixed inset-y-0 left-0 z-50 w-64 bg-sidebar border-r border-sidebar-border transform transition-transform lg:hidden",
          sidebarOpen ? "translate-x-0" : "-translate-x-full"
        )}
      >
        {sidebarContent(false)}
      </aside>

      {/* Sidebar — desktop (sticky) */}
      <aside
        className={cn(
          "hidden lg:flex flex-col bg-sidebar border-r border-sidebar-border shrink-0",
          "sticky top-0 h-screen overflow-y-auto",
          "transition-all duration-200",
          sidebarCollapsed ? "w-16" : "w-64"
        )}
      >
        {sidebarContent(sidebarCollapsed)}
      </aside>
    </>
  );
}
