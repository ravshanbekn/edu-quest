package kz.eduquest.course.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateBlockRequest(@NotBlank String title) {}
