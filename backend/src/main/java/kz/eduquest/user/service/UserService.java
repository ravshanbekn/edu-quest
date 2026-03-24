package kz.eduquest.user.service;

import kz.eduquest.storage.StorageService;
import kz.eduquest.user.dto.ProfileResponse;
import kz.eduquest.user.dto.UpdateProfileRequest;
import kz.eduquest.user.dto.UserResponse;
import kz.eduquest.user.entity.Role;
import kz.eduquest.user.entity.User;
import kz.eduquest.user.entity.UserProfile;
import kz.eduquest.user.repository.RoleRepository;
import kz.eduquest.user.repository.UserProfileRepository;
import kz.eduquest.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private static final Set<String> ALLOWED_IMAGE_TYPES = Set.of("image/jpeg", "image/png", "image/webp");

    private final UserRepository userRepository;
    private final UserProfileRepository profileRepository;
    private final RoleRepository roleRepository;
    private final StorageService storageService;

    public UserResponse getUser(Long userId) {
        return toUserResponse(findUserOrThrow(userId));
    }

    /**
     * Возвращает профиль с учётом видимости (см. архитектурный документ §8).
     *
     * @param targetUserId     ID пользователя, чей профиль запрашивается
     * @param requestingUserId ID того, кто делает запрос (null — гость)
     * @param isAdmin          признак роли ADMIN у запрашивающего
     */
    public ProfileResponse getProfile(Long targetUserId, Long requestingUserId, boolean isAdmin) {
        UserProfile profile = profileRepository.findByUserId(targetUserId)
                .orElseThrow(() -> new IllegalArgumentException("Profile not found for user: " + targetUserId));

        if (isAdmin || targetUserId.equals(requestingUserId)) {
            return ProfileResponse.full(profile);
        }
        if (profile.isPublic()) {
            return ProfileResponse.publicView(profile);
        }
        return ProfileResponse.restricted(profile);
    }

    @Transactional
    public ProfileResponse updateProfile(Long userId, UpdateProfileRequest request) {
        UserProfile profile = profileRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = findUserOrThrow(userId);
                    return profileRepository.save(UserProfile.builder().user(user).build());
                });

        if (request.displayName() != null) profile.setDisplayName(request.displayName());
        if (request.bio() != null)         profile.setBio(request.bio());
        if (request.isPublic() != null)    profile.setPublic(request.isPublic());

        return ProfileResponse.full(profileRepository.save(profile));
    }

    public Page<UserResponse> getAllUsers(Pageable pageable) {
        return userRepository.findAllActive(pageable).map(this::toUserResponse);
    }

    @Transactional
    public ProfileResponse uploadAvatar(Long userId, MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }
        if (!ALLOWED_IMAGE_TYPES.contains(file.getContentType())) {
            throw new IllegalArgumentException("Only JPEG, PNG and WebP images are allowed");
        }

        UserProfile profile = profileRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = findUserOrThrow(userId);
                    return profileRepository.save(UserProfile.builder().user(user).build());
                });

        // Удалить старый аватар если есть
        if (profile.getAvatarUrl() != null) {
            storageService.delete(profile.getAvatarUrl());
        }

        String objectKey = storageService.upload("avatars", file);
        profile.setAvatarUrl(objectKey);
        profileRepository.save(profile);

        return ProfileResponse.full(profile);
    }

    @Transactional
    public UserResponse assignRoles(Long userId, Set<String> roleNames) {
        User user = findUserOrThrow(userId);
        Set<Role> roles = roleRepository.findByNameIn(roleNames);
        user.setRoles(roles);
        return toUserResponse(userRepository.save(user));
    }

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
    }

    private UserResponse toUserResponse(User user) {
        Set<String> roleNames = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());
        return new UserResponse(user.getId(), user.getEmail(), user.isActive(), roleNames, user.getCreatedAt());
    }
}