package kz.eduquest.gamification.event;

import java.util.UUID;

public record CourseCompletedEvent(UUID userId, UUID courseId) {}
