package kz.eduquest.progress.dto;

import kz.eduquest.progress.entity.ProgressStatus;
import kz.eduquest.progress.entity.UserProgress;

import java.time.LocalDateTime;

public record UserProgressResponse(
        Long id,
        Long lessonId,
        String lessonTitle,
        Long courseId,
        ProgressStatus status,
        int score,
        int hintsUsed,
        LocalDateTime completedAt
) {
    public static UserProgressResponse from(UserProgress p) {
        return new UserProgressResponse(
                p.getId(),
                p.getLesson().getId(),
                p.getLesson().getTitle(),
                p.getLesson().getBlock().getCourse().getId(),
                p.getStatus(),
                p.getScore(),
                p.getHintsUsed(),
                p.getCompletedAt()
        );
    }
}
