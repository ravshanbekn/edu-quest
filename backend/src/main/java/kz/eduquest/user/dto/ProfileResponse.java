package kz.eduquest.user.dto;

import kz.eduquest.user.entity.UserProfile;

public record ProfileResponse(
        Long userId,
        String displayName,
        String avatarUrl,
        String bio,
        boolean isPublic
) {
    /** Владелец профиля или ADMIN — полные данные */
    public static ProfileResponse full(UserProfile p) {
        return new ProfileResponse(
                p.getUser().getId(),
                p.getDisplayName(),
                p.getAvatarUrl(),
                p.getBio(),
                p.isPublic()
        );
    }

    /** Публичный профиль — все поля, кроме скрытых */
    public static ProfileResponse publicView(UserProfile p) {
        return new ProfileResponse(
                p.getUser().getId(),
                p.getDisplayName(),
                p.getAvatarUrl(),
                p.getBio(),
                p.isPublic()
        );
    }

    /** Закрытый профиль — только имя и аватар */
    public static ProfileResponse restricted(UserProfile p) {
        return new ProfileResponse(
                p.getUser().getId(),
                p.getDisplayName(),
                p.getAvatarUrl(),
                null,
                false
        );
    }
}