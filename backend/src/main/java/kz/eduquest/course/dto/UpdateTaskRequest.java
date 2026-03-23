package kz.eduquest.course.dto;

import kz.eduquest.course.entity.TaskType;

public record UpdateTaskRequest(
        String description,
        String solution,
        TaskType taskType,
        Integer xpReward
) {}
