package kz.eduquest.course.controller;

import jakarta.validation.Valid;
import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.course.dto.*;
import kz.eduquest.course.service.BlockService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@PreAuthorize("hasAuthority('course:manage_own')")
public class BlockController {

    private final BlockService blockService;

    @PostMapping("/api/v1/courses/{courseId}/blocks")
    public ResponseEntity<BlockResponse> create(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long courseId,
            @Valid @RequestBody CreateBlockRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(blockService.create(p.getId(), p.hasPermission("course:manage_all"), courseId, request));
    }

    @PutMapping("/api/v1/blocks/{id}")
    public ResponseEntity<BlockResponse> update(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @Valid @RequestBody UpdateBlockRequest request) {
        return ResponseEntity.ok(blockService.update(p.getId(), p.hasPermission("course:manage_all"), id, request));
    }

    @DeleteMapping("/api/v1/blocks/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id) {
        blockService.delete(p.getId(), p.hasPermission("course:manage_all"), id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/api/v1/courses/{courseId}/blocks/reorder")
    public ResponseEntity<List<BlockResponse>> reorder(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long courseId,
            @Valid @RequestBody ReorderRequest request) {
        return ResponseEntity.ok(blockService.reorder(p.getId(), p.hasPermission("course:manage_all"), courseId, request));
    }
}
