import type { ActionType } from "./common.types";

export interface XpResponse {
  totalXp: number;
  currentLevel: number;
  xpForNextLevel: number;
}

export interface BadgeResponse {
  badgeId: string;
  name: string;
  description: string;
  iconUrl: string | null;
  awardedAt: string;
}

export interface LeaderboardEntry {
  rank: number;
  userId: string;
  displayName: string;
  totalXp: number;
  level: number;
}

export interface XpLogResponse {
  id: string;
  actionType: ActionType;
  xpAmount: number;
  referenceId: string;
  createdAt: string;
}
