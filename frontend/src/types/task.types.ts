import type { TaskType } from "./common.types";

export interface TaskResponse {
  id: string;
  lessonId: string;
  description: string;
  taskType: TaskType;
  xpReward: number;
  sortOrder: number;
  hintCount: number;
}

export interface CreateTaskRequest {
  description: string;
  solution?: string;
  taskType?: TaskType;
  xpReward?: number;
}

export interface UpdateTaskRequest {
  description?: string;
  solution?: string;
  taskType?: TaskType;
  xpReward?: number;
}

export interface TaskSubmitRequest {
  answer: string;
}

export interface TaskSubmission {
  id: string;
  taskId: string;
  answer: string;
  correct: boolean;
  xpEarned: number;
  submittedAt: string;
}

export interface CreateHintRequest {
  content: string;
  xpPenalty?: number;
}

export interface Hint {
  id: string;
  content: string;
  xpPenalty: number;
}
