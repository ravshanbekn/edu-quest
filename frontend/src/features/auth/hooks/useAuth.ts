import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useNavigate, useLocation } from "react-router-dom";
import { toast } from "sonner";
import { loginApi, registerApi, logoutApi } from "@/api/auth.api";
import { useAuthStore } from "@/stores/auth.store";
import type { LoginRequest, RegisterRequest } from "@/types/auth.types";

export function useLogin() {
  const navigate = useNavigate();
  const location = useLocation();
  const login = useAuthStore((s) => s.login);

  return useMutation({
    mutationFn: (data: LoginRequest) => loginApi(data),
    onSuccess: (data) => {
      login(data.accessToken, data.refreshToken);
      const from = (location.state as { from?: { pathname: string } })?.from?.pathname || "/dashboard";
      navigate(from, { replace: true });
      toast.success("Вы вошли в систему");
    },
    onError: () => {
      toast.error("Неверный email или пароль");
    },
  });
}

export function useRegister() {
  const navigate = useNavigate();
  const login = useAuthStore((s) => s.login);

  return useMutation({
    mutationFn: (data: RegisterRequest) => registerApi(data),
    onSuccess: (data) => {
      login(data.accessToken, data.refreshToken);
      navigate("/dashboard", { replace: true });
      toast.success("Регистрация прошла успешно");
    },
    onError: () => {
      toast.error("Ошибка регистрации. Возможно, email уже занят.");
    },
  });
}

export function useLogout() {
  const logout = useAuthStore((s) => s.logout);
  const refreshToken = useAuthStore((s) => s.refreshToken);
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => logoutApi({ refreshToken: refreshToken! }),
    onSettled: () => {
      logout();
      queryClient.clear();
      navigate("/login", { replace: true });
    },
  });
}
