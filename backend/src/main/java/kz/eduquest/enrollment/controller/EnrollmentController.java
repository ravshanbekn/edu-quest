package kz.eduquest.enrollment.controller;

import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.enrollment.dto.EnrollmentResponse;
import kz.eduquest.enrollment.service.EnrollmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    /** Самозапись студента */
    @PostMapping("/api/v1/courses/{id}/enroll")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<EnrollmentResponse> selfEnroll(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(enrollmentService.selfEnroll(p.getId(), id));
    }

    /** Учитель записывает студента */
    @PostMapping("/api/v1/courses/{id}/enroll/{userId}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<EnrollmentResponse> enrollByTeacher(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @PathVariable Long userId) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(enrollmentService.enrollByTeacher(p.getId(), p.hasRole("ADMIN"), id, userId));
    }

    /** Учитель отписывает студента */
    @DeleteMapping("/api/v1/courses/{id}/enroll/{userId}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<Void> unenroll(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @PathVariable Long userId) {
        enrollmentService.unenroll(p.getId(), p.hasRole("ADMIN"), id, userId);
        return ResponseEntity.noContent().build();
    }

    /** Мои курсы */
    @GetMapping("/api/v1/users/me/enrollments")
    public ResponseEntity<Page<EnrollmentResponse>> myEnrollments(
            @AuthenticationPrincipal UserPrincipal p,
            Pageable pageable) {
        return ResponseEntity.ok(enrollmentService.getMyEnrollments(p.getId(), pageable));
    }
}
