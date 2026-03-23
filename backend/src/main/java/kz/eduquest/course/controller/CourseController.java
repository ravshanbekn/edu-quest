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

import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/courses")
public class CourseController {

    private final CourseService courseService;

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
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
    public ResponseEntity<CourseResponse> getCourse(@PathVariable UUID id) {
        return ResponseEntity.ok(courseService.getCourse(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<CourseResponse> update(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID id,
            @Valid @RequestBody UpdateCourseRequest request) {
        return ResponseEntity.ok(courseService.update(p.getId(), p.hasRole("ADMIN"), id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID id) {
        courseService.delete(p.getId(), p.hasRole("ADMIN"), id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/publish")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<CourseResponse> publish(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID id) {
        return ResponseEntity.ok(courseService.publish(p.getId(), p.hasRole("ADMIN"), id));
    }

    @GetMapping("/{id}/students")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<Page<UserResponse>> getStudents(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID id,
            Pageable pageable) {
        return ResponseEntity.ok(courseService.getStudents(p.getId(), p.hasRole("ADMIN"), id, pageable));
    }
}
