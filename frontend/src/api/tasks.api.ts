import api from "./client";
import type { TaskResponse, CreateTaskRequest, UpdateTaskRequest, TaskSubmitRequest, TaskSubmission, CreateHintRequest, Hint } from "@/types/task.types";

export async function createTask(lessonId: string, body: CreateTaskRequest): Promise<TaskResponse> {
  const { data } = await api.post<TaskResponse>(`/lessons/${lessonId}/tasks`, body);
  return data;
}

export async function updateTask(id: string, body: UpdateTaskRequest): Promise<TaskResponse> {
  const { data } = await api.put<TaskResponse>(`/tasks/${id}`, body);
  return data;
}

export async function addHint(taskId: string, body: CreateHintRequest): Promise<void> {
  await api.post(`/tasks/${taskId}/hints`, body);
}

export async function submitTask(taskId: string, body: TaskSubmitRequest): Promise<TaskSubmission> {
  const { data } = await api.post<TaskSubmission>(`/tasks/${taskId}/submit`, body);
  return data;
}

export async function revealHint(taskId: string, hintId: string): Promise<Hint> {
  const { data } = await api.post<Hint>(`/tasks/${taskId}/hints/${hintId}/reveal`);
  return data;
}
