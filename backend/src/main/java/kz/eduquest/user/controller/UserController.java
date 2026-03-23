package kz.eduquest.user.controller;

import jakarta.validation.Valid;
import kz.eduquest.user.dto.ProfileResponse;
import kz.eduquest.user.dto.UpdateProfileRequest;
import kz.eduquest.user.dto.UserResponse;
import kz.eduquest.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Set;
import java.util.UUID;

/**
 * REST API: Users & Profiles (архитектурный документ §7.2).
 *
 * TODO Sprint 1: заменить параметр userId на Spring Security Principal
 *               и добавить @PreAuthorize по ролям/правам.
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    /** GET /api/v1/users/me — текущий пользователь */
    @GetMapping("/me")
    public ResponseEntity<UserResponse> getMe(@RequestParam UUID userId) {
        return ResponseEntity.ok(userService.getUser(userId));
    }

    /** PUT /api/v1/users/me/profile — обновить профиль */
    @PutMapping("/me/profile")
    public ResponseEntity<ProfileResponse> updateMyProfile(
            @RequestParam UUID userId,
            @Valid @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(userService.updateProfile(userId, request));
    }

    /** GET /api/v1/users/{id}/profile — профиль пользователя */
    @GetMapping("/{id}/profile")
    public ResponseEntity<ProfileResponse> getUserProfile(
            @PathVariable UUID id,
            @RequestParam(required = false) UUID requestingUserId,
            @RequestParam(defaultValue = "false") boolean admin) {
        return ResponseEntity.ok(userService.getProfile(id, requestingUserId, admin));
    }

    /** GET /api/v1/users — список пользователей (ADMIN only) */
    @GetMapping
    public ResponseEntity<Page<UserResponse>> getAllUsers(Pageable pageable) {
        return ResponseEntity.ok(userService.getAllUsers(pageable));
    }

    /** PUT /api/v1/users/{id}/roles — назначить роли (ADMIN only) */
    @PutMapping("/{id}/roles")
    public ResponseEntity<UserResponse> assignRoles(
            @PathVariable UUID id,
            @RequestBody Set<String> roleNames) {
        return ResponseEntity.ok(userService.assignRoles(id, roleNames));
    }
}