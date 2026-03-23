package kz.eduquest.gamification.dto;

import java.util.UUID;

public record LeaderboardEntry(int rank, UUID userId, String displayName, int totalXp, int level) {}
