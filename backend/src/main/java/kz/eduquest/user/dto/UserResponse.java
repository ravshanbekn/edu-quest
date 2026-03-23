package kz.eduquest.user.dto;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

public record UserResponse(
        UUID id,
        String email,
        boolean active,
        Set<String> roles,
        LocalDateTime createdAt
) {}