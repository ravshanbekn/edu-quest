package kz.eduquest.gamification.dto;

import kz.eduquest.gamification.entity.ActionType;
import kz.eduquest.gamification.entity.UserXpLog;

import java.time.LocalDateTime;
import java.util.UUID;

public record XpLogResponse(
        UUID id,
        ActionType actionType,
        int xpAmount,
        UUID referenceId,
        LocalDateTime createdAt
) {
    public static XpLogResponse from(UserXpLog log) {
        return new XpLogResponse(log.getId(), log.getActionType(), log.getXpAmount(), log.getReferenceId(), log.getCreatedAt());
    }
}
