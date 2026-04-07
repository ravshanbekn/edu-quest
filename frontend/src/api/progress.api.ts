import api from "./client";
import type { UserProgress } from "@/types/progress.types";

export async function getMyProgress(): Promise<UserProgress[]> {
  const { data } = await api.get<UserProgress[]>("/users/me/progress");
  return data;
}

export async function getCourseProgress(courseId: string): Promise<UserProgress[]> {
  const { data } = await api.get<UserProgress[]>(`/courses/${courseId}/progress`);
  return data;
}

export async function completeLesson(lessonId: string): Promise<UserProgress> {
  const { data } = await api.post<UserProgress>(`/lessons/${lessonId}/complete`);
  return data;
}
