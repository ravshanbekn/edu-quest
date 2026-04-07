import api from "./client";
import type { EnrollmentResponse } from "@/types/enrollment.types";
import type { Page, Pageable } from "@/types/common.types";

export async function enrollInCourse(courseId: string): Promise<EnrollmentResponse> {
  const { data } = await api.post<EnrollmentResponse>(`/courses/${courseId}/enroll`);
  return data;
}

export async function enrollUser(courseId: string, userId: string): Promise<EnrollmentResponse> {
  const { data } = await api.post<EnrollmentResponse>(`/courses/${courseId}/enroll/${userId}`);
  return data;
}

export async function unenrollUser(courseId: string, userId: string): Promise<void> {
  await api.delete(`/courses/${courseId}/enroll/${userId}`);
}

export async function getMyEnrollments(params: Pageable): Promise<Page<EnrollmentResponse>> {
  const { data } = await api.get<Page<EnrollmentResponse>>("/users/me/enrollments", { params });
  return data;
}
