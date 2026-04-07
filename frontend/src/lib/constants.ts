export const API_BASE_URL = "/api/v1";

export const ROLES = {
  ADMIN: "ADMIN",
  TEACHER: "TEACHER",
  STUDENT: "STUDENT",
  GUEST: "GUEST",
} as const;

export const XP_PER_LEVEL = 1000;

export const DEFAULT_PAGE_SIZE = 10;

export const ENROLLMENT_STATUS_LABELS: Record<string, string> = {
  ACTIVE: "Активен",
  COMPLETED: "Завершён",
  DROPPED: "Отписан",
};

export const APP_NAME = "EduQuest";
