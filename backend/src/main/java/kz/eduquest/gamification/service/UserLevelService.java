package kz.eduquest.gamification.service;

import kz.eduquest.gamification.entity.UserLevel;
import kz.eduquest.gamification.repository.UserLevelRepository;
import kz.eduquest.user.entity.User;
import kz.eduquest.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor
public class UserLevelService {

    private final UserLevelRepository levelRepository;
    private final UserRepository userRepository;

    @Transactional
    public UserLevel addXp(Long userId, int xpAmount) {
        UserLevel level = levelRepository.findByUserId(userId)
                .orElseGet(() -> createInitialLevel(userId));

        level.setTotalXp(Math.max(0, level.getTotalXp() + xpAmount));

        int newLevel = calculateLevel(level.getTotalXp());
        level.setCurrentLevel(newLevel);

        return levelRepository.save(level);
    }

    public UserLevel getLevel(Long userId) {
        return levelRepository.findByUserId(userId)
                .orElseGet(() -> createInitialLevel(userId));
    }

    int calculateLevel(int totalXp) {
        int level = 1;
        int cumulativeXp = 0;

        while (true) {
            int xpForNext = level * level * 100;
            if (cumulativeXp + xpForNext > totalXp) break;
            cumulativeXp += xpForNext;
            level++;
        }

        return level;
    }

    private UserLevel createInitialLevel(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        return levelRepository.save(
                UserLevel.builder()
                        .user(user)
                        .currentLevel(1)
                        .totalXp(0)
                        .build()
        );
    }
}
