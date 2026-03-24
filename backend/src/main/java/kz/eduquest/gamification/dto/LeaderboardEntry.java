package kz.eduquest.gamification.dto;

public record LeaderboardEntry(int rank, Long userId, String displayName, int totalXp, int level) {}