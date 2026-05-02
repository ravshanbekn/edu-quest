package kz.eduquest.course.service;

import kz.eduquest.course.dto.ContentRequest;
import kz.eduquest.course.dto.LessonDetailResponse.ContentResponse;
import kz.eduquest.course.entity.LessonContent;
import kz.eduquest.course.repository.LessonContentRepository;
import kz.eduquest.course.repository.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LessonContentService {

    private final LessonContentRepository contentRepository;
    private final LessonRepository lessonRepository;

    @Transactional
    public ContentResponse create(Long lessonId, ContentRequest req) {
        var lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new IllegalArgumentException("Lesson not found: " + lessonId));
        var content = LessonContent.builder()
                .lesson(lesson)
                .contentType(req.contentType())
                .body(req.body())
                .videoUrl(req.videoUrl())
                .sortOrder(req.sortOrder())
                .build();
        return ContentResponse.from(contentRepository.save(content));
    }

    @Transactional
    public ContentResponse update(Long contentId, ContentRequest req) {
        var content = contentRepository.findById(contentId)
                .orElseThrow(() -> new IllegalArgumentException("Content not found: " + contentId));
        content.setContentType(req.contentType());
        content.setBody(req.body());
        content.setVideoUrl(req.videoUrl());
        content.setSortOrder(req.sortOrder());
        return ContentResponse.from(contentRepository.save(content));
    }

    @Transactional
    public void delete(Long contentId) {
        if (!contentRepository.existsById(contentId)) {
            throw new IllegalArgumentException("Content not found: " + contentId);
        }
        contentRepository.deleteById(contentId);
    }
}
