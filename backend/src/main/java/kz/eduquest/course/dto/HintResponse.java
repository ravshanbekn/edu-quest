package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Hint;

public record HintResponse(
        Long id,
        Long taskId,
        String content,
        int sortOrder,
        int xpPenalty
) {
    public static HintResponse from(Hint h) {
        return new HintResponse(
                h.getId(), h.getTask().getId(), h.getContent(),
                h.getSortOrder(), h.getXpPenalty()
        );
    }
}
