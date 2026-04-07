import type { ProgressStatus } from "./common.types";

export interface UserProgress {
  lessonId: string;
  courseId: string;
  status: ProgressStatus;
  completedAt: string | null;
}
