package kz.eduquest.gamification.event;

import java.util.UUID;

public record BlockCompletedEvent(UUID userId, UUID blockId) {}
