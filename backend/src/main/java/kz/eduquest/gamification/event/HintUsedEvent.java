package kz.eduquest.gamification.event;

public record HintUsedEvent(Long userId, Long hintId, Long taskId, int xpPenalty) {}
