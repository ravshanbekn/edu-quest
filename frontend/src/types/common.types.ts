export type LessonType = "VIDEO" | "TASK" | "QUIZ" | "MIXED";
export type TaskType = "TEXT" | "CODE" | "FILE_UPLOAD";
export type ContentType = "TEXT" | "VIDEO" | "CODE_BLOCK";
export type ProgressStatus = "NOT_STARTED" | "IN_PROGRESS" | "COMPLETED";
export type EnrollmentStatus = "ACTIVE" | "COMPLETED" | "DROPPED";
export type ActionType =
  | "LESSON_COMPLETE"
  | "TASK_SOLVED"
  | "QUIZ_PASSED"
  | "HINT_USED"
  | "BLOCK_COMPLETE"
  | "COURSE_COMPLETE"
  | "DAILY_LOGIN";
export type Role = "ADMIN" | "TEACHER" | "STUDENT" | "GUEST";

export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
  first: boolean;
  last: boolean;
  empty: boolean;
}

export interface Pageable {
  page?: number;
  size?: number;
  sort?: string;
}
