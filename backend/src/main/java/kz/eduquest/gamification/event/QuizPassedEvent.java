package kz.eduquest.gamification.event;

/**
 * @param scorePercent процент правильных ответов (0–100)
 */
public record QuizPassedEvent(Long userId, Long quizId, int scorePercent) {}
