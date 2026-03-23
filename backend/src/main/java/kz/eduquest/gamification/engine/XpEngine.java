package kz.eduquest.gamification.engine;

import kz.eduquest.gamification.entity.ActionType;
import kz.eduquest.gamification.entity.UserXpLog;
import kz.eduquest.gamification.event.*;
import kz.eduquest.gamification.repository.UserXpLogRepository;
import kz.eduquest.gamification.service.UserLevelService;
import kz.eduquest.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * XP Engine — слушает события прогресса и начисляет XP (§6.1, §6.4).
 * Idempotent: одно действие = одно начисление (§9.5).
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class XpEngine {

    private static final int XP_LESSON_COMPLETE  = 50;
    private static final int XP_TASK_SOLVED      = 75;
    private static final int XP_QUIZ_HIGH        = 100;  // ≥ 80%
    private static final int XP_QUIZ_LOW         = 50;   // < 80%
    private static final int XP_HINT_PENALTY     = -10;
    private static final int XP_BLOCK_COMPLETE   = 200;
    private static final int XP_COURSE_COMPLETE  = 500;

    private final UserXpLogRepository xpLogRepository;
    private final UserLevelService userLevelService;
    private final UserRepository userRepository;

    @EventListener
    @Transactional
    public void onLessonCompleted(LessonCompletedEvent event) {
        awardXpOnce(event.userId(), ActionType.LESSON_COMPLETE, event.lessonId(), XP_LESSON_COMPLETE);
    }

    @EventListener
    @Transactional
    public void onTaskSolved(TaskSolvedEvent event) {
        awardXpOnce(event.userId(), ActionType.TASK_SOLVED, event.taskId(), XP_TASK_SOLVED);
    }

    @EventListener
    @Transactional
    public void onQuizPassed(QuizPassedEvent event) {
        int xp = event.scorePercent() >= 80 ? XP_QUIZ_HIGH : XP_QUIZ_LOW;
        awardXpOnce(event.userId(), ActionType.QUIZ_PASSED, event.quizId(), xp);
    }

    @EventListener
    @Transactional
    public void onHintUsed(HintUsedEvent event) {
        // Штраф за каждую подсказку — не idempotent, можно использовать несколько хинтов
        awardXp(event.userId(), ActionType.HINT_USED, event.hintId(), XP_HINT_PENALTY);
    }

    @EventListener
    @Transactional
    public void onBlockCompleted(BlockCompletedEvent event) {
        awardXpOnce(event.userId(), ActionType.BLOCK_COMPLETE, event.blockId(), XP_BLOCK_COMPLETE);
    }

    @EventListener
    @Transactional
    public void onCourseCompleted(CourseCompletedEvent event) {
        awardXpOnce(event.userId(), ActionType.COURSE_COMPLETE, event.courseId(), XP_COURSE_COMPLETE);
    }

    /**
     * Начисляет XP только один раз за (userId, actionType, referenceId).
     */
    private void awardXpOnce(UUID userId, ActionType actionType, UUID referenceId, int xpAmount) {
        if (xpLogRepository.existsByUserIdAndActionTypeAndReferenceId(userId, actionType, referenceId)) {
            log.debug("XP already awarded: userId={}, action={}, ref={}", userId, actionType, referenceId);
            return;
        }
        awardXp(userId, actionType, referenceId, xpAmount);
    }

    private void awardXp(UUID userId, ActionType actionType, UUID referenceId, int xpAmount) {
        var user = userRepository.getReferenceById(userId);

        xpLogRepository.save(
                UserXpLog.builder()
                        .user(user)
                        .actionType(actionType)
                        .xpAmount(xpAmount)
                        .referenceId(referenceId)
                        .build()
        );

        userLevelService.addXp(userId, xpAmount);
        log.info("XP awarded: userId={}, action={}, xp={}", userId, actionType, xpAmount);
    }
}
