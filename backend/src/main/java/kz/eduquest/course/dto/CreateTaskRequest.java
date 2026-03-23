package kz.eduquest.course.dto;

import jakarta.validation.constraints.NotBlank;
import kz.eduquest.course.entity.TaskType;

public record CreateTaskRequest(
        @NotBlank String description,
        String solution,
        TaskType taskType,
        Integer xpReward
) {}
