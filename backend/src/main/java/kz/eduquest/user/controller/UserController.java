package kz.eduquest.user.controller;

import jakarta.validation.Valid;
import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.user.dto.ProfileResponse;
import kz.eduquest.user.dto.UpdateProfileRequest;
import kz.eduquest.user.dto.UserResponse;
import kz.eduquest.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Set;

/**
 * REST API: Users & Profiles (архитектурный документ §7.2).
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    /** GET /api/v1/users/me — текущий пользователь */
    @GetMapping("/me")
    public ResponseEntity<UserResponse> getMe(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(userService.getUser(principal.getId()));
    }

    /** PUT /api/v1/users/me/profile — обновить профиль */
    @PutMapping("/me/profile")
    public ResponseEntity<ProfileResponse> updateMyProfile(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(userService.updateProfile(principal.getId(), request));
    }

    /** POST /api/v1/users/me/avatar — загрузить аватар */
    @PostMapping(value = "/me/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ProfileResponse> uploadAvatar(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(userService.uploadAvatar(principal.getId(), file));
    }

    /** GET /api/v1/users/{id}/profile — профиль пользователя */
    @GetMapping("/{id}/profile")
    public ResponseEntity<ProfileResponse> getUserProfile(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal principal) {
        boolean isAdmin = principal.hasPermission("user:manage");
        return ResponseEntity.ok(userService.getProfile(id, principal.getId(), isAdmin));
    }

    /** GET /api/v1/users — список пользователей (ADMIN only) */
    @GetMapping
    @PreAuthorize("hasAuthority('user:manage')")
    public ResponseEntity<Page<UserResponse>> getAllUsers(Pageable pageable) {
        return ResponseEntity.ok(userService.getAllUsers(pageable));
    }

    /** PUT /api/v1/users/{id}/roles — назначить роли (ADMIN only) */
    @PutMapping("/{id}/roles")
    @PreAuthorize("hasAuthority('role:manage')")
    public ResponseEntity<UserResponse> assignRoles(
            @PathVariable Long id,
            @RequestBody Set<String> roleNames) {
        return ResponseEntity.ok(userService.assignRoles(id, roleNames));
    }
}
