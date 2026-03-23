package kz.eduquest.course.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record CreateQuizRequest(
        String title,
        Integer timeLimit,
        Integer xpReward,
        @NotEmpty List<QuestionRequest> questions
) {
    public record QuestionRequest(
            String question,
            List<String> options,
            List<Integer> correct
    ) {}
}
