import api from "./client";
import type { BlockResponse, CreateBlockRequest, ReorderBlocksRequest } from "@/types/course.types";

export async function createBlock(courseId: string, body: CreateBlockRequest): Promise<BlockResponse> {
  const { data } = await api.post<BlockResponse>(`/courses/${courseId}/blocks`, body);
  return data;
}

export async function updateBlock(id: string, body: CreateBlockRequest): Promise<BlockResponse> {
  const { data } = await api.put<BlockResponse>(`/blocks/${id}`, body);
  return data;
}

export async function deleteBlock(id: string): Promise<void> {
  await api.delete(`/blocks/${id}`);
}

export async function reorderBlocks(courseId: string, body: ReorderBlocksRequest): Promise<BlockResponse[]> {
  const { data } = await api.put<BlockResponse[]>(`/courses/${courseId}/blocks/reorder`, body);
  return data;
}
