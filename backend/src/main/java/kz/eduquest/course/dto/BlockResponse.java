package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Block;

import java.util.UUID;

public record BlockResponse(
        UUID id,
        UUID courseId,
        String title,
        int sortOrder
) {
    public static BlockResponse from(Block b) {
        return new BlockResponse(b.getId(), b.getCourse().getId(), b.getTitle(), b.getSortOrder());
    }
}
