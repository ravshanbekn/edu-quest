package kz.eduquest.course.controller;

import jakarta.validation.Valid;
import kz.eduquest.course.dto.ContentRequest;
import kz.eduquest.course.dto.LessonDetailResponse.ContentResponse;
import kz.eduquest.course.service.LessonContentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class ContentController {

    private final LessonContentService contentService;

    @PostMapping("/api/v1/lessons/{lessonId}/content")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ContentResponse> create(
            @PathVariable Long lessonId,
            @Valid @RequestBody ContentRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(contentService.create(lessonId, req));
    }

    @PutMapping("/api/v1/content/{contentId}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ContentResponse> update(
            @PathVariable Long contentId,
            @Valid @RequestBody ContentRequest req) {
        return ResponseEntity.ok(contentService.update(contentId, req));
    }

    @DeleteMapping("/api/v1/content/{contentId}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long contentId) {
        contentService.delete(contentId);
        return ResponseEntity.noContent().build();
    }
}
