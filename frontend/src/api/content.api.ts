import api from "./client";
import type { ContentResponse } from "@/types/lesson.types";
import type { ContentRequest } from "@/types/lesson.types";

export async function createContent(lessonId: string, body: ContentRequest): Promise<ContentResponse> {
  const { data } = await api.post<ContentResponse>(`/lessons/${lessonId}/content`, body);
  return data;
}

export async function updateContent(contentId: string, body: ContentRequest): Promise<ContentResponse> {
  const { data } = await api.put<ContentResponse>(`/content/${contentId}`, body);
  return data;
}

export async function deleteContent(contentId: string): Promise<void> {
  await api.delete(`/content/${contentId}`);
}

export async function uploadFile(file: File, folder: string): Promise<string> {
  const form = new FormData();
  form.append("file", file);
  form.append("folder", folder);
  const { data } = await api.post<{ url: string }>("/storage/upload", form, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  return data.url;
}
