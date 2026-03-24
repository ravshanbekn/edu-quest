package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Block;

public record BlockResponse(
        Long id,
        Long courseId,
        String title,
        int sortOrder
) {
    public static BlockResponse from(Block b) {
        return new BlockResponse(b.getId(), b.getCourse().getId(), b.getTitle(), b.getSortOrder());
    }
}