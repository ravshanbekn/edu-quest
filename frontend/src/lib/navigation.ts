import type { NavigateFunction } from "react-router-dom";

/**
 * Глобальный NavigationService для навигации вне React-компонентов (например, в axios interceptors).
 * Инициализируется в App.tsx через setNavigate().
 */
let _navigate: NavigateFunction | null = null;

export const NavigationService = {
  setNavigate(fn: NavigateFunction) {
    _navigate = fn;
  },
  navigate(to: string) {
    if (_navigate) {
      _navigate(to);
    } else {
      // Fallback если сервис ещё не инициализирован
      window.location.href = to;
    }
  },
};
