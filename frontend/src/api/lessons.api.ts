import api from "./client";
import type { LessonResponse, LessonDetailResponse, CreateLessonRequest, UpdateLessonRequest } from "@/types/lesson.types";

export async function createLesson(blockId: string, body: CreateLessonRequest): Promise<LessonResponse> {
  const { data } = await api.post<LessonResponse>(`/blocks/${blockId}/lessons`, body);
  return data;
}

export async function getLesson(id: string): Promise<LessonDetailResponse> {
  const { data } = await api.get<LessonDetailResponse>(`/lessons/${id}`);
  return data;
}

export async function updateLesson(id: string, body: UpdateLessonRequest): Promise<LessonResponse> {
  const { data } = await api.put<LessonResponse>(`/lessons/${id}`, body);
  return data;
}

export async function deleteLesson(id: string): Promise<void> {
  await api.delete(`/lessons/${id}`);
}
