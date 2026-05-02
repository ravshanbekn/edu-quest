package kz.eduquest.course.dto;

import jakarta.validation.constraints.NotNull;
import kz.eduquest.course.entity.ContentType;

public record ContentRequest(
        @NotNull ContentType contentType,
        String body,
        String videoUrl,
        int sortOrder
) {}
