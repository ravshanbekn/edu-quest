package kz.eduquest.course.dto;

import kz.eduquest.course.entity.LessonType;

public record UpdateLessonRequest(
        String title,
        LessonType type,
        Integer xpReward
) {}
