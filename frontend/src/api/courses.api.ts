import api from "./client";
import type { CourseResponse, CourseDetailResponse, CreateCourseRequest, UpdateCourseRequest } from "@/types/course.types";
import type { Page, Pageable } from "@/types/common.types";
import type { UserResponse } from "@/types/user.types";

export async function getCourses(params: Pageable): Promise<Page<CourseResponse>> {
  const { data } = await api.get<Page<CourseResponse>>("/courses", { params });
  return data;
}

export async function getCourse(id: string): Promise<CourseDetailResponse> {
  const { data } = await api.get<CourseDetailResponse>(`/courses/${id}`);
  return data;
}

export async function createCourse(body: CreateCourseRequest): Promise<CourseResponse> {
  const { data } = await api.post<CourseResponse>("/courses", body);
  return data;
}

export async function updateCourse(id: string, body: UpdateCourseRequest): Promise<CourseResponse> {
  const { data } = await api.put<CourseResponse>(`/courses/${id}`, body);
  return data;
}

export async function deleteCourse(id: string): Promise<void> {
  await api.delete(`/courses/${id}`);
}

export async function publishCourse(id: string): Promise<CourseResponse> {
  const { data } = await api.put<CourseResponse>(`/courses/${id}/publish`);
  return data;
}

export async function getCourseStudents(id: string, params: Pageable): Promise<Page<UserResponse>> {
  const { data } = await api.get<Page<UserResponse>>(`/courses/${id}/students`, { params });
  return data;
}
