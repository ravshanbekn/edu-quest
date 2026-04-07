import api from "./client";
import type {
  LoginRequest,
  RegisterRequest,
  AuthResponse,
  LogoutRequest,
} from "@/types/auth.types";

export async function loginApi(data: LoginRequest): Promise<AuthResponse> {
  const res = await api.post<AuthResponse>("/auth/login", data);
  return res.data;
}

export async function registerApi(data: RegisterRequest): Promise<AuthResponse> {
  const res = await api.post<AuthResponse>("/auth/register", data);
  return res.data;
}

export async function logoutApi(data: LogoutRequest): Promise<void> {
  await api.post("/auth/logout", data);
}
