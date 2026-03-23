package kz.eduquest.gamification.dto;

import kz.eduquest.gamification.entity.UserBadge;

import java.time.LocalDateTime;
import java.util.UUID;

public record BadgeResponse(
        UUID badgeId,
        String name,
        String description,
        String iconUrl,
        LocalDateTime awardedAt
) {
    public static BadgeResponse from(UserBadge ub) {
        return new BadgeResponse(
                ub.getBadge().getId(), ub.getBadge().getName(),
                ub.getBadge().getDescription(), ub.getBadge().getIconUrl(),
                ub.getAwardedAt()
        );
    }
}
