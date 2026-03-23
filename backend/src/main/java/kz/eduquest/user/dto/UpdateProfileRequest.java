package kz.eduquest.user.dto;

import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @Size(max = 100) String displayName,
        String bio,
        Boolean isPublic
) {}