package kz.eduquest.gamification.event;

public record LessonCompletedEvent(Long userId, Long lessonId) {}
