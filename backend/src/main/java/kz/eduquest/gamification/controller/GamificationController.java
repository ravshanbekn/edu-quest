package kz.eduquest.gamification.controller;

import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.gamification.dto.*;
import kz.eduquest.gamification.entity.UserLevel;
import kz.eduquest.gamification.repository.UserBadgeRepository;
import kz.eduquest.gamification.repository.UserLevelRepository;
import kz.eduquest.gamification.repository.UserXpLogRepository;
import kz.eduquest.gamification.service.UserLevelService;
import kz.eduquest.user.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

@RestController
@RequiredArgsConstructor
public class GamificationController {

    private final UserLevelService levelService;
    private final UserLevelRepository levelRepository;
    private final UserBadgeRepository badgeRepository;
    private final UserXpLogRepository xpLogRepository;
    private final UserProfileRepository profileRepository;

    /** GET /api/v1/users/me/xp — мой XP и уровень */
    @GetMapping("/api/v1/users/me/xp")
    public ResponseEntity<XpResponse> myXp(@AuthenticationPrincipal UserPrincipal p) {
        UserLevel level = levelService.getLevel(p.getId());
        int xpForNext = (level.getCurrentLevel()) * (level.getCurrentLevel()) * 100;
        return ResponseEntity.ok(new XpResponse(level.getTotalXp(), level.getCurrentLevel(), xpForNext));
    }

    /** GET /api/v1/users/me/badges — мои бейджи */
    @GetMapping("/api/v1/users/me/badges")
    public ResponseEntity<List<BadgeResponse>> myBadges(@AuthenticationPrincipal UserPrincipal p) {
        return ResponseEntity.ok(
                badgeRepository.findByUserId(p.getId()).stream().map(BadgeResponse::from).toList()
        );
    }

    /** GET /api/v1/users/{id}/badges — бейджи пользователя */
    @GetMapping("/api/v1/users/{id}/badges")
    public ResponseEntity<List<BadgeResponse>> userBadges(@PathVariable Long id) {
        return ResponseEntity.ok(
                badgeRepository.findByUserId(id).stream().map(BadgeResponse::from).toList()
        );
    }

    /** GET /api/v1/leaderboard — лидерборд (top-N по XP) */
    @GetMapping("/api/v1/leaderboard")
    public ResponseEntity<List<LeaderboardEntry>> leaderboard(Pageable pageable) {
        Page<UserLevel> page = levelRepository.findAllByOrderByTotalXpDesc(pageable);
        AtomicInteger rank = new AtomicInteger(pageable.getPageNumber() * pageable.getPageSize() + 1);

        List<LeaderboardEntry> entries = page.getContent().stream().map(ul -> {
            String displayName = profileRepository.findByUserId(ul.getUser().getId())
                    .map(pr -> pr.getDisplayName())
                    .orElse("User");
            return new LeaderboardEntry(
                    rank.getAndIncrement(), ul.getUser().getId(),
                    displayName, ul.getTotalXp(), ul.getCurrentLevel()
            );
        }).toList();

        return ResponseEntity.ok(entries);
    }

    /** GET /api/v1/users/me/xp/history — история начислений XP */
    @GetMapping("/api/v1/users/me/xp/history")
    public ResponseEntity<Page<XpLogResponse>> xpHistory(
            @AuthenticationPrincipal UserPrincipal p,
            Pageable pageable) {
        return ResponseEntity.ok(
                xpLogRepository.findByUserIdOrderByCreatedAtDesc(p.getId(), pageable).map(XpLogResponse::from)
        );
    }
}
