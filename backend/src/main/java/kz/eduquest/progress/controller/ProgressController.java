package kz.eduquest.progress.controller;

import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.progress.entity.ProgressStatus;
import kz.eduquest.progress.entity.UserProgress;
import kz.eduquest.progress.repository.UserProgressRepository;
import kz.eduquest.progress.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class ProgressController {

    private final ProgressService progressService;
    private final UserProgressRepository progressRepository;

    /** GET /api/v1/users/me/progress — общий прогресс */
    @GetMapping("/api/v1/users/me/progress")
    public ResponseEntity<List<UserProgress>> myProgress(@AuthenticationPrincipal UserPrincipal p) {
        return ResponseEntity.ok(progressRepository.findByUserId(p.getId()));
    }

    /** GET /api/v1/courses/{id}/progress — прогресс по курсу */
    @GetMapping("/api/v1/courses/{id}/progress")
    public ResponseEntity<List<UserProgress>> courseProgress(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID id) {
        // Фильтруем прогресс по урокам данного курса
        List<UserProgress> all = progressRepository.findByUserId(p.getId());
        List<UserProgress> forCourse = all.stream()
                .filter(up -> up.getLesson().getBlock().getCourse().getId().equals(id))
                .toList();
        return ResponseEntity.ok(forCourse);
    }

    /** POST /api/v1/lessons/{id}/complete — отметить урок завершённым */
    @PostMapping("/api/v1/lessons/{id}/complete")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<UserProgress> completeLesson(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID id) {
        return ResponseEntity.ok(progressService.completeLesson(p.getId(), id));
    }
}
