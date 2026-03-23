package kz.eduquest.gamification.event;

import java.util.UUID;

/**
 * @param scorePercent процент правильных ответов (0–100)
 */
public record QuizPassedEvent(UUID userId, UUID quizId, int scorePercent) {}
