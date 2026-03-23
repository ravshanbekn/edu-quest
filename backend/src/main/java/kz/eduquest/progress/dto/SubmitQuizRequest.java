package kz.eduquest.progress.dto;

import jakarta.validation.constraints.NotNull;

import java.util.Map;
import java.util.UUID;

/** Ответы на квиз: questionId → список выбранных индексов */
public record SubmitQuizRequest(
        @NotNull Map<UUID, java.util.List<Integer>> answers
) {}
