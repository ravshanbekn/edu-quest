import type { LessonType } from "./common.types";

export interface CourseResponse {
  id: string;
  teacherId: string;
  title: string;
  description: string | null;
  coverUrl: string | null;
  published: boolean;
  createdAt: string;
}

export interface CourseDetailResponse extends CourseResponse {
  blocks: BlockDetail[];
}

export interface BlockDetail {
  id: string;
  courseId: string;
  title: string;
  sortOrder: number;
  lessons: LessonBrief[];
}

export interface LessonBrief {
  id: string;
  blockId: string;
  title: string;
  type: LessonType;
  sortOrder: number;
  xpReward: number;
}

export interface CreateCourseRequest {
  title: string;
  description?: string;
}

export interface UpdateCourseRequest {
  title?: string;
  description?: string;
  coverUrl?: string;
}

export interface BlockResponse {
  id: string;
  courseId: string;
  title: string;
  sortOrder: number;
}

export interface CreateBlockRequest {
  title: string;
}

export interface ReorderBlocksRequest {
  orderedIds: string[];
}
