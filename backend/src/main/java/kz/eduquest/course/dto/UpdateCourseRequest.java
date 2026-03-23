package kz.eduquest.course.dto;

public record UpdateCourseRequest(
        String title,
        String description,
        String coverUrl
) {}
