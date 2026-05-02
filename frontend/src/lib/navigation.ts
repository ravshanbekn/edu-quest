import type { NavigateFunction } from "react-router-dom";

let _navigate: NavigateFunction | null = null;

export const NavigationService = {
  setNavigate(fn: NavigateFunction) {
    _navigate = fn;
  },
  navigate(to: string) {
    if (_navigate) {
      _navigate(to);
    } else {
      // Fallback if service is not yet initialized
      window.location.href = to;
    }
  },
};
