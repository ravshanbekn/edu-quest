import { BrowserRouter, useNavigate } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "sonner";
import { useEffect } from "react";
import { AppRoutes } from "./routes";
import { NavigationService } from "@/lib/navigation";
import { ErrorBoundary } from "@/components/shared/ErrorBoundary";
import { applyTheme, useThemeStore } from "@/stores/theme.store";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 5 * 60 * 1000,
    },
  },
});

function NavigationInitializer() {
  const navigate = useNavigate();
  useEffect(() => {
    NavigationService.setNavigate(navigate);
  }, [navigate]);
  return null;
}

function ThemeInitializer() {
  const theme = useThemeStore((s) => s.theme);
  const setTheme = useThemeStore((s) => s.setTheme);

  useEffect(() => {
    applyTheme(theme);

    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    const stored = localStorage.getItem("edu-quest-theme");
    if (!stored) {
      const onSystemChange = (e: MediaQueryListEvent) => {
        setTheme(e.matches ? "dark" : "light");
      };
      mq.addEventListener("change", onSystemChange);
      return () => mq.removeEventListener("change", onSystemChange);
    }
  }, []);  // eslint-disable-line react-hooks/exhaustive-deps

  return null;
}

export default function App() {
  return (
    <ErrorBoundary>
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <NavigationInitializer />
          <ThemeInitializer />
          <AppRoutes />
          <Toaster position="top-right" richColors />
        </BrowserRouter>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}
