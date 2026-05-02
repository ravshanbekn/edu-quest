package kz.eduquest.gamification.event;

public record QuizPassedEvent(Long userId, Long quizId, int scorePercent) {}
