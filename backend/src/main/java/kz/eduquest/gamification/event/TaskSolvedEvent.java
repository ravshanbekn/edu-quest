package kz.eduquest.gamification.event;

import java.util.UUID;

public record TaskSolvedEvent(UUID userId, UUID taskId) {}
