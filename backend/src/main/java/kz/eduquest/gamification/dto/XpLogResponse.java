package kz.eduquest.gamification.dto;

import kz.eduquest.gamification.entity.ActionType;
import kz.eduquest.gamification.entity.UserXpLog;

import java.time.LocalDateTime;

public record XpLogResponse(
        Long id,
        ActionType actionType,
        int xpAmount,
        Long referenceId,
        LocalDateTime createdAt
) {
    public static XpLogResponse from(UserXpLog log) {
        return new XpLogResponse(log.getId(), log.getActionType(), log.getXpAmount(), log.getReferenceId(), log.getCreatedAt());
    }
}