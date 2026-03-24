package kz.eduquest.course.controller;

import jakarta.validation.Valid;
import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.course.dto.*;
import kz.eduquest.course.service.TaskService;
import kz.eduquest.progress.dto.SubmitTaskRequest;
import kz.eduquest.progress.entity.TaskSubmission;
import kz.eduquest.progress.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;
    private final ProgressService progressService;

    @PostMapping("/api/v1/lessons/{lessonId}/tasks")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<TaskResponse> create(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long lessonId,
            @Valid @RequestBody CreateTaskRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(taskService.create(p.getId(), p.hasRole("ADMIN"), lessonId, request));
    }

    @PutMapping("/api/v1/tasks/{id}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<TaskResponse> update(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @Valid @RequestBody UpdateTaskRequest request) {
        return ResponseEntity.ok(taskService.update(p.getId(), p.hasRole("ADMIN"), id, request));
    }

    @PostMapping("/api/v1/tasks/{id}/hints")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<Void> addHint(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @Valid @RequestBody CreateHintRequest request) {
        taskService.addHint(p.getId(), p.hasRole("ADMIN"), id, request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/api/v1/tasks/{id}/submit")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<TaskSubmission> submit(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @Valid @RequestBody SubmitTaskRequest request) {
        return ResponseEntity.ok(progressService.submitTask(p.getId(), id, request.answer()));
    }

    @PostMapping("/api/v1/tasks/{id}/hints/{hintOrder}/reveal")
    public ResponseEntity<HintResponse> revealHint(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @PathVariable int hintOrder) {
        return ResponseEntity.ok(HintResponse.from(progressService.revealHint(p.getId(), id, hintOrder)));
    }
}
