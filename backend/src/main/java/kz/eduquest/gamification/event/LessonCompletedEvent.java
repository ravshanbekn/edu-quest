package kz.eduquest.gamification.event;

import java.util.UUID;

public record LessonCompletedEvent(UUID userId, UUID lessonId) {}
