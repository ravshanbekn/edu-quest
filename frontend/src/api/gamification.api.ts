import api from "./client";
import type { XpResponse, BadgeResponse, LeaderboardEntry, XpLogResponse } from "@/types/gamification.types";
import type { Page, Pageable } from "@/types/common.types";

export async function getMyXp(): Promise<XpResponse> {
  const { data } = await api.get<XpResponse>("/users/me/xp");
  return data;
}

export async function getMyBadges(): Promise<BadgeResponse[]> {
  const { data } = await api.get<BadgeResponse[]>("/users/me/badges");
  return data;
}

export async function getUserBadges(userId: string): Promise<BadgeResponse[]> {
  const { data } = await api.get<BadgeResponse[]>(`/users/${userId}/badges`);
  return data;
}

export async function getLeaderboard(params: Pageable): Promise<LeaderboardEntry[]> {
  const { data } = await api.get<LeaderboardEntry[]>("/leaderboard", { params });
  return data;
}

export async function getXpHistory(params: Pageable): Promise<Page<XpLogResponse>> {
  const { data } = await api.get<Page<XpLogResponse>>("/users/me/xp/history", { params });
  return data;
}
