import { Sun, Moon } from "lucide-react";
import { useThemeStore } from "@/stores/theme.store";
import { cn } from "@/lib/utils";

interface ThemeToggleProps {
  /** В свёрнутом sidebar показываем только иконку */
  collapsed?: boolean;
  className?: string;
}

export function ThemeToggle({ collapsed = false, className }: ThemeToggleProps) {
  const { theme, toggle } = useThemeStore();
  const isDark = theme === "dark";

  return (
    <button
      onClick={toggle}
      title={isDark ? "Переключить на светлую тему" : "Переключить на тёмную тему"}
      aria-label={isDark ? "Светлая тема" : "Тёмная тема"}
      className={cn(
        "flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors w-full",
        "text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground",
        collapsed && "justify-center px-2",
        className
      )}
    >
      <span
        className="h-4 w-4 shrink-0 transition-transform duration-500"
        style={{
          animation: "none",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        {isDark ? (
          <Sun className="h-4 w-4 text-xp" />
        ) : (
          <Moon className="h-4 w-4" />
        )}
      </span>
      {!collapsed && (
        <span>{isDark ? "Светлая тема" : "Тёмная тема"}</span>
      )}
    </button>
  );
}
