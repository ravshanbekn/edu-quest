package kz.eduquest.course.service;

import kz.eduquest.course.dto.*;
import kz.eduquest.course.entity.Block;
import kz.eduquest.course.entity.Lesson;
import kz.eduquest.course.entity.LessonType;
import kz.eduquest.course.repository.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LessonService {

    private final LessonRepository lessonRepository;
    private final BlockService blockService;
    private final CourseService courseService;

    @Transactional
    public LessonResponse create(UUID userId, boolean isAdmin, UUID blockId, CreateLessonRequest request) {
        Block block = blockService.findBlockOrThrow(blockId);
        courseService.checkOwnerOrAdmin(block.getCourse(), userId, isAdmin);

        int nextOrder = lessonRepository.findByBlockIdOrderBySortOrder(blockId).size();

        Lesson lesson = Lesson.builder()
                .block(block)
                .title(request.title())
                .type(request.type() != null ? request.type() : LessonType.MIXED)
                .xpReward(request.xpReward() != null ? request.xpReward() : 50)
                .sortOrder(nextOrder)
                .build();
        return LessonResponse.from(lessonRepository.save(lesson));
    }

    public LessonDetailResponse getDetail(UUID lessonId) {
        Lesson lesson = findLessonOrThrow(lessonId);
        return LessonDetailResponse.from(lesson);
    }

    @Transactional
    public LessonResponse update(UUID userId, boolean isAdmin, UUID lessonId, UpdateLessonRequest request) {
        Lesson lesson = findLessonOrThrow(lessonId);
        courseService.checkOwnerOrAdmin(lesson.getBlock().getCourse(), userId, isAdmin);

        if (request.title() != null)    lesson.setTitle(request.title());
        if (request.type() != null)     lesson.setType(request.type());
        if (request.xpReward() != null) lesson.setXpReward(request.xpReward());

        return LessonResponse.from(lessonRepository.save(lesson));
    }

    @Transactional
    public void delete(UUID userId, boolean isAdmin, UUID lessonId) {
        Lesson lesson = findLessonOrThrow(lessonId);
        courseService.checkOwnerOrAdmin(lesson.getBlock().getCourse(), userId, isAdmin);
        lessonRepository.delete(lesson);
    }

    Lesson findLessonOrThrow(UUID lessonId) {
        return lessonRepository.findById(lessonId)
                .orElseThrow(() -> new IllegalArgumentException("Lesson not found: " + lessonId));
    }
}
