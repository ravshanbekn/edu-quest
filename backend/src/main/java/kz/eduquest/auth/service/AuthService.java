package kz.eduquest.auth.service;

import kz.eduquest.auth.dto.AuthResponse;
import kz.eduquest.auth.dto.LoginRequest;
import kz.eduquest.auth.dto.RefreshRequest;
import kz.eduquest.auth.dto.RegisterRequest;
import kz.eduquest.common.security.JwtService;
import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.user.entity.Role;
import kz.eduquest.user.entity.User;
import kz.eduquest.user.entity.UserProfile;
import kz.eduquest.user.repository.RoleRepository;
import kz.eduquest.user.repository.UserProfileRepository;
import kz.eduquest.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserProfileRepository profileRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("Email already in use: " + request.email());
        }
        User user = User.builder()
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .build();
        roleRepository.findByName("STUDENT")
                .ifPresent(role -> user.getRoles().add(role));

        userRepository.save(user);
        profileRepository.save(
                UserProfile.builder()
                        .user(user)
                        .displayName(request.displayName())
                        .build()
        );

        return generateTokens(user);
    }

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        UserPrincipal principal = (UserPrincipal) authentication.getPrincipal();

        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));

        return generateTokens(user);
    }

    public AuthResponse refresh(RefreshRequest request) {
        if (!jwtService.isValid(request.refreshToken())) {
            throw new IllegalArgumentException("Invalid or expired refresh token");
        }

        var userId = jwtService.extractUserId(request.refreshToken());
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        jwtService.blacklistRefreshToken(request.refreshToken());

        return generateTokens(user);
    }

    public void logout(String refreshToken) {
        jwtService.blacklistRefreshToken(refreshToken);
    }

    private AuthResponse generateTokens(User user) {
        Set<String> roleNames = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        String accessToken = jwtService.generateAccessToken(user.getId(), user.getEmail(), roleNames);
        String refreshToken = jwtService.generateRefreshToken(user.getId());

        return new AuthResponse(accessToken, refreshToken, jwtService.getAccessExpirationMs());
    }
}
