package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Course;

import java.time.LocalDateTime;
import java.util.UUID;

public record CourseResponse(
        UUID id,
        UUID teacherId,
        String title,
        String description,
        String coverUrl,
        boolean published,
        LocalDateTime createdAt
) {
    public static CourseResponse from(Course c) {
        return new CourseResponse(
                c.getId(), c.getTeacher().getId(), c.getTitle(),
                c.getDescription(), c.getCoverUrl(), c.isPublished(), c.getCreatedAt()
        );
    }
}
