package kz.eduquest.course.dto;

import jakarta.validation.constraints.NotBlank;
import kz.eduquest.course.entity.LessonType;

public record CreateLessonRequest(
        @NotBlank String title,
        LessonType type,
        Integer xpReward
) {}
