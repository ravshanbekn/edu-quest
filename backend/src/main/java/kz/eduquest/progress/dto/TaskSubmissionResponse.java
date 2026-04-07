package kz.eduquest.progress.dto;

import kz.eduquest.progress.entity.TaskSubmission;

import java.time.LocalDateTime;

public record TaskSubmissionResponse(
        Long id,
        Long taskId,
        String answer,
        boolean correct,
        int xpEarned,
        LocalDateTime submittedAt
) {
    public static TaskSubmissionResponse from(TaskSubmission s) {
        return new TaskSubmissionResponse(
                s.getId(),
                s.getTask().getId(),
                s.getAnswer(),
                Boolean.TRUE.equals(s.getCorrect()),
                s.getXpEarned(),
                s.getSubmittedAt()
        );
    }
}
