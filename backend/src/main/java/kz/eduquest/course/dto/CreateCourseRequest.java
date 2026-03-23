package kz.eduquest.course.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateCourseRequest(
        @NotBlank String title,
        String description
) {}
