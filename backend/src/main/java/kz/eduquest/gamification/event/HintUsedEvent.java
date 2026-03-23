package kz.eduquest.gamification.event;

import java.util.UUID;

public record HintUsedEvent(UUID userId, UUID hintId, UUID taskId) {}
