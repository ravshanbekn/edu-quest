package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Task;
import kz.eduquest.course.entity.TaskType;

import java.util.UUID;

public record TaskResponse(
        UUID id,
        UUID lessonId,
        String description,
        TaskType taskType,
        int xpReward,
        int sortOrder,
        int hintCount
) {
    public static TaskResponse from(Task t) {
        return new TaskResponse(
                t.getId(), t.getLesson().getId(), t.getDescription(),
                t.getTaskType(), t.getXpReward(), t.getSortOrder(), t.getHints().size()
        );
    }
}
