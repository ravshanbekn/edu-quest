package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Lesson;
import kz.eduquest.course.entity.LessonType;

import java.util.UUID;

public record LessonResponse(
        UUID id,
        UUID blockId,
        String title,
        LessonType type,
        int sortOrder,
        int xpReward
) {
    public static LessonResponse from(Lesson l) {
        return new LessonResponse(
                l.getId(), l.getBlock().getId(), l.getTitle(),
                l.getType(), l.getSortOrder(), l.getXpReward()
        );
    }
}
