import api from "./client";
import type { UserResponse, ProfileResponse, UpdateProfileRequest } from "@/types/user.types";
import type { Page, Pageable } from "@/types/common.types";

export async function getCurrentUser(): Promise<UserResponse> {
  const { data } = await api.get<UserResponse>("/users/me");
  return data;
}

export async function getMyProfile(): Promise<ProfileResponse> {
  const { data } = await api.get<ProfileResponse>("/users/me/profile");
  return data;
}

export async function updateProfile(req: UpdateProfileRequest): Promise<ProfileResponse> {
  const { data } = await api.put<ProfileResponse>("/users/me/profile", req);
  return data;
}

export async function uploadAvatar(file: File): Promise<ProfileResponse> {
  const formData = new FormData();
  formData.append("file", file);
  const { data } = await api.post<ProfileResponse>("/users/me/avatar", formData, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  return data;
}

export async function getUserProfile(userId: string): Promise<ProfileResponse> {
  const { data } = await api.get<ProfileResponse>(`/users/${userId}/profile`);
  return data;
}

export async function getUsers(params: Pageable): Promise<Page<UserResponse>> {
  const { data } = await api.get<Page<UserResponse>>("/users", { params });
  return data;
}

export async function updateUserRoles(userId: string, roles: string[]): Promise<UserResponse> {
  const { data } = await api.put<UserResponse>(`/users/${userId}/roles`, roles);
  return data;
}
