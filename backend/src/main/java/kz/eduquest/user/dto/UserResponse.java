package kz.eduquest.user.dto;

import java.time.LocalDateTime;
import java.util.Set;

public record UserResponse(
        Long id,
        String email,
        boolean active,
        Set<String> roles,
        LocalDateTime createdAt
) {}