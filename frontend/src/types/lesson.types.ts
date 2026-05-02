import type { LessonType, ContentType } from "./common.types";
import type { TaskResponse } from "./task.types";
import type { QuizBriefResponse } from "./quiz.types";

export interface LessonResponse {
  id: string;
  blockId: string;
  title: string;
  type: LessonType;
  sortOrder: number;
  xpReward: number;
}

export interface LessonDetailResponse {
  id: string;
  title: string;
  type: LessonType;
  xpReward: number;
  contents: ContentResponse[];
  tasks: TaskResponse[];
  quizzes: QuizBriefResponse[];
}

export interface ContentResponse {
  id: string;
  contentType: ContentType;
  body: string | null;
  videoUrl: string | null;
  sortOrder: number;
}

export interface CreateLessonRequest {
  title: string;
  type: LessonType;
  xpReward?: number;
}

export interface UpdateLessonRequest {
  title?: string;
  type?: LessonType;
  xpReward?: number;
}

export interface ContentRequest {
  contentType: ContentType;
  body: string | null;
  videoUrl: string | null;
  sortOrder: number;
}
