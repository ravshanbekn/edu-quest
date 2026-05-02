package kz.eduquest.progress.dto;

import jakarta.validation.constraints.NotNull;

import java.util.Map;

public record SubmitQuizRequest(
        @NotNull Map<Long, java.util.List<Integer>> answers
) {}