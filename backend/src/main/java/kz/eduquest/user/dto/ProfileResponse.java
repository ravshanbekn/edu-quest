package kz.eduquest.user.dto;

import kz.eduquest.user.entity.UserProfile;

public record ProfileResponse(
        Long userId,
        String displayName,
        String avatarUrl,
        String bio,
        boolean isPublic
) {
    public static ProfileResponse full(UserProfile p) {
        return new ProfileResponse(
                p.getUser().getId(),
                p.getDisplayName(),
                p.getAvatarUrl(),
                p.getBio(),
                p.isPublic()
        );
    }

    /** Public profile — all fields except hidden ones */
    public static ProfileResponse publicView(UserProfile p) {
        return new ProfileResponse(
                p.getUser().getId(),
                p.getDisplayName(),
                p.getAvatarUrl(),
                p.getBio(),
                p.isPublic()
        );
    }

    /** Restricted profile — name and avatar only */
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