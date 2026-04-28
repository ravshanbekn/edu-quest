package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Block;
import kz.eduquest.course.entity.Course;
import kz.eduquest.course.entity.Lesson;
import kz.eduquest.course.entity.LessonType;

import java.time.LocalDateTime;
import java.util.List;

public record CourseDetailResponse(
        Long id,
        Long teacherId,
        String title,
        String description,
        String coverUrl,
        boolean published,
        LocalDateTime createdAt,
        List<BlockDetail> blocks
) {
    public static CourseDetailResponse from(Course c) {
        return new CourseDetailResponse(
                c.getId(), c.getTeacher().getId(), c.getTitle(),
                c.getDescription(), c.getCoverUrl(), c.isPublished(), c.getCreatedAt(),
                c.getBlocks().stream().map(BlockDetail::from).toList()
        );
    }

    public record BlockDetail(
            Long id,
            Long courseId,
            String title,
            int sortOrder,
            List<LessonBrief> lessons
    ) {
        static BlockDetail from(Block b) {
            return new BlockDetail(
                    b.getId(), b.getCourse().getId(), b.getTitle(), b.getSortOrder(),
                    b.getLessons().stream().map(LessonBrief::from).toList()
            );
        }
    }

    public record LessonBrief(
            Long id,
            Long blockId,
            String title,
            LessonType type,
            int sortOrder,
            int xpReward
    ) {
        static LessonBrief from(Lesson l) {
            return new LessonBrief(
                    l.getId(), l.getBlock().getId(), l.getTitle(), l.getType(),
                    l.getSortOrder(), l.getXpReward()
            );
        }
    }
}