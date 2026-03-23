package kz.eduquest.gamification.engine;

import kz.eduquest.gamification.entity.BadgeConditionType;
import kz.eduquest.gamification.entity.BadgeDefinition;
import kz.eduquest.gamification.entity.UserBadge;
import kz.eduquest.gamification.event.*;
import kz.eduquest.gamification.repository.BadgeDefinitionRepository;
import kz.eduquest.gamification.repository.UserBadgeRepository;
import kz.eduquest.gamification.repository.UserLevelRepository;
import kz.eduquest.gamification.repository.UserXpLogRepository;
import kz.eduquest.progress.entity.ProgressStatus;
import kz.eduquest.progress.repository.TaskSubmissionRepository;
import kz.eduquest.progress.repository.UserProgressRepository;
import kz.eduquest.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * Badge Evaluator — слушает события и проверяет условия для выдачи бейджей (§6.3, §6.4).
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class BadgeEvaluator {

    private final BadgeDefinitionRepository badgeDefinitionRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final UserProgressRepository progressRepository;
    private final TaskSubmissionRepository submissionRepository;
    private final UserLevelRepository levelRepository;
    private final UserXpLogRepository xpLogRepository;
    private final UserRepository userRepository;

    @EventListener
    @Transactional
    public void onLessonCompleted(LessonCompletedEvent event) {
        evaluateAndAward(event.userId());
    }

    @EventListener
    @Transactional
    public void onTaskSolved(TaskSolvedEvent event) {
        evaluateAndAward(event.userId());
    }

    @EventListener
    @Transactional
    public void onQuizPassed(QuizPassedEvent event) {
        evaluateAndAward(event.userId());
    }

    @EventListener
    @Transactional
    public void onCourseCompleted(CourseCompletedEvent event) {
        evaluateAndAward(event.userId());
    }

    private void evaluateAndAward(UUID userId) {
        List<BadgeDefinition> unearned = badgeDefinitionRepository.findUnearnedByUser(userId);

        for (BadgeDefinition badge : unearned) {
            if (conditionMet(userId, badge)) {
                userBadgeRepository.save(
                        UserBadge.builder()
                                .user(userRepository.getReferenceById(userId))
                                .badge(badge)
                                .build()
                );
                log.info("Badge awarded: userId={}, badge={}", userId, badge.getName());
            }
        }
    }

    private boolean conditionMet(UUID userId, BadgeDefinition badge) {
        int required = badge.getConditionValue();

        return switch (badge.getConditionType()) {
            case LESSONS_COMPLETED -> countCompletedLessons(userId) >= required;
            case COURSES_COMPLETED -> countCompletedCourses(userId) >= required;
            case TASKS_SOLVED      -> countSolvedTasks(userId) >= required;
            case LEVEL_REACHED     -> getCurrentLevel(userId) >= required;
            case XP_EARNED         -> getTotalXp(userId) >= required;
            // TODO: STREAK, PERFECT_QUIZZES, COURSE_NO_HINTS — реализовать при добавлении соответствующей логики
            case STREAK, PERFECT_QUIZZES, COURSE_NO_HINTS -> false;
        };
    }

    private long countCompletedLessons(UUID userId) {
        return progressRepository.findByUserIdAndStatus(userId, ProgressStatus.COMPLETED).size();
    }

    private long countCompletedCourses(UUID userId) {
        // Считаем по XP логу с типом COURSE_COMPLETE
        return xpLogRepository.findByUserIdOrderByCreatedAtDesc(userId, org.springframework.data.domain.Pageable.unpaged())
                .stream()
                .filter(entry -> entry.getActionType() == kz.eduquest.gamification.entity.ActionType.COURSE_COMPLETE)
                .count();
    }

    private long countSolvedTasks(UUID userId) {
        // Уникальные решённые задачи через XP лог
        return xpLogRepository.findByUserIdOrderByCreatedAtDesc(userId, org.springframework.data.domain.Pageable.unpaged())
                .stream()
                .filter(entry -> entry.getActionType() == kz.eduquest.gamification.entity.ActionType.TASK_SOLVED)
                .count();
    }

    private int getCurrentLevel(UUID userId) {
        return levelRepository.findByUserId(userId)
                .map(kz.eduquest.gamification.entity.UserLevel::getCurrentLevel)
                .orElse(1);
    }

    private int getTotalXp(UUID userId) {
        return levelRepository.findByUserId(userId)
                .map(kz.eduquest.gamification.entity.UserLevel::getTotalXp)
                .orElse(0);
    }
}
