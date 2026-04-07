package kz.eduquest.course.controller;

import jakarta.validation.Valid;
import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.course.dto.*;
import kz.eduquest.course.service.LessonService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class LessonController {

    private final LessonService lessonService;

    @PostMapping("/api/v1/blocks/{blockId}/lessons")
    @PreAuthorize("hasAuthority('course:manage_own')")
    public ResponseEntity<LessonResponse> create(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long blockId,
            @Valid @RequestBody CreateLessonRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(lessonService.create(p.getId(), p.hasPermission("course:manage_all"), blockId, request));
    }

    @GetMapping("/api/v1/lessons/{id}")
    public ResponseEntity<LessonDetailResponse> getDetail(@PathVariable Long id) {
        return ResponseEntity.ok(lessonService.getDetail(id));
    }

    @PutMapping("/api/v1/lessons/{id}")
    @PreAuthorize("hasAuthority('course:manage_own')")
    public ResponseEntity<LessonResponse> update(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @Valid @RequestBody UpdateLessonRequest request) {
        return ResponseEntity.ok(lessonService.update(p.getId(), p.hasPermission("course:manage_all"), id, request));
    }

    @DeleteMapping("/api/v1/lessons/{id}")
    @PreAuthorize("hasAuthority('course:manage_own')")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id) {
        lessonService.delete(p.getId(), p.hasPermission("course:manage_all"), id);
        return ResponseEntity.noContent().build();
    }
}
