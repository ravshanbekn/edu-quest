export interface CourseResponse {
  id: string;
  teacherId: string;
  title: string;
  description: string | null;
  coverUrl: string | null;
  published: boolean;
  createdAt: string;
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
