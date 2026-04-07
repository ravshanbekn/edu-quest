package kz.eduquest.course.controller;

import jakarta.validation.Valid;
import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.course.dto.*;
import kz.eduquest.course.service.CourseService;
import kz.eduquest.user.dto.UserResponse;
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
@RequestMapping("/api/v1/courses")
public class CourseController {

    private final CourseService courseService;

    @PostMapping
    @PreAuthorize("hasAuthority('course:create')")
    public ResponseEntity<CourseResponse> create(
            @AuthenticationPrincipal UserPrincipal p,
            @Valid @RequestBody CreateCourseRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(courseService.create(p.getId(), request));
    }

    @GetMapping
    public ResponseEntity<Page<CourseResponse>> getCatalog(Pageable pageable) {
        return ResponseEntity.ok(courseService.getCatalog(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CourseDetailResponse> getCourse(@PathVariable Long id) {
        return ResponseEntity.ok(courseService.getCourse(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('course:manage_own')")
    public ResponseEntity<CourseResponse> update(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @Valid @RequestBody UpdateCourseRequest request) {
        return ResponseEntity.ok(courseService.update(p.getId(), p.hasPermission("course:manage_all"), id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('course:manage_own')")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id) {
        courseService.delete(p.getId(), p.hasPermission("course:manage_all"), id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/publish")
    @PreAuthorize("hasAuthority('course:manage_own')")
    public ResponseEntity<CourseResponse> publish(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id) {
        return ResponseEntity.ok(courseService.publish(p.getId(), p.hasPermission("course:manage_all"), id));
    }

    @GetMapping("/{id}/students")
    @PreAuthorize("hasAuthority('progress:view_students')")
    public ResponseEntity<Page<UserResponse>> getStudents(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            Pageable pageable) {
        return ResponseEntity.ok(courseService.getStudents(p.getId(), p.hasPermission("course:manage_all"), id, pageable));
    }
}
