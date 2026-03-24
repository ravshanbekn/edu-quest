package kz.eduquest.progress.dto;

import jakarta.validation.constraints.NotNull;

import java.util.Map;

/** Ответы на квиз: questionId → список выбранных индексов */
public record SubmitQuizRequest(
        @NotNull Map<Long, java.util.List<Integer>> answers
) {}