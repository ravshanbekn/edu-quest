package kz.eduquest.progress.dto;

import jakarta.validation.constraints.NotBlank;

public record SubmitTaskRequest(@NotBlank String answer) {}
