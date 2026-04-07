import api from "./client";
import type { QuizResponse, CreateQuizRequest, QuizSubmitRequest, QuizAttempt } from "@/types/quiz.types";

export async function createQuiz(lessonId: string, body: CreateQuizRequest): Promise<QuizResponse> {
  const { data } = await api.post<QuizResponse>(`/lessons/${lessonId}/quizzes`, body);
  return data;
}

export async function startQuizAttempt(quizId: string): Promise<QuizResponse> {
  const { data } = await api.post<QuizResponse>(`/quizzes/${quizId}/attempt`);
  return data;
}

export async function submitQuizAttempt(quizId: string, attemptId: string, body: QuizSubmitRequest): Promise<QuizAttempt> {
  const { data } = await api.post<QuizAttempt>(`/quizzes/${quizId}/attempt/${attemptId}/submit`, body);
  return data;
}
