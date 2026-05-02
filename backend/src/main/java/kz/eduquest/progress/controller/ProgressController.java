package kz.eduquest.progress.controller;

import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.progress.dto.UserProgressResponse;
import kz.eduquest.progress.repository.UserProgressRepository;
import kz.eduquest.progress.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ProgressController {

    private final ProgressService progressService;
    private final UserProgressRepository progressRepository;

    @GetMapping("/api/v1/users/me/progress")
    public ResponseEntity<List<UserProgressResponse>> myProgress(@AuthenticationPrincipal UserPrincipal p) {
        return ResponseEntity.ok(progressRepository.findByUserId(p.getId()).stream()
                .map(UserProgressResponse::from).toList());
    }

    @GetMapping("/api/v1/courses/{id}/progress")
    public ResponseEntity<List<UserProgressResponse>> courseProgress(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id) {
        return ResponseEntity.ok(progressRepository.findByUserId(p.getId()).stream()
                .filter(up -> up.getLesson().getBlock().getCourse().getId().equals(id))
                .map(UserProgressResponse::from).toList());
    }

    @PostMapping("/api/v1/lessons/{id}/complete")
    @PreAuthorize("hasAuthority('lesson:complete')")
    public ResponseEntity<UserProgressResponse> completeLesson(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id) {
        return ResponseEntity.ok(UserProgressResponse.from(progressService.completeLesson(p.getId(), id)));
    }
}
