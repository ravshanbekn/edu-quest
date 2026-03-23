package kz.eduquest.course.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateHintRequest(
        @NotBlank String content,
        Integer xpPenalty
) {}
