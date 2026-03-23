package kz.eduquest.progress.service;

import kz.eduquest.course.entity.Hint;
import kz.eduquest.course.entity.Lesson;
import kz.eduquest.course.entity.Quiz;
import kz.eduquest.course.entity.Task;
import kz.eduquest.course.repository.*;
import kz.eduquest.gamification.event.*;
import kz.eduquest.progress.entity.ProgressStatus;
import kz.eduquest.progress.entity.QuizAttempt;
import kz.eduquest.progress.entity.TaskSubmission;
import kz.eduquest.progress.entity.UserProgress;
import kz.eduquest.progress.repository.QuizAttemptRepository;
import kz.eduquest.progress.repository.TaskSubmissionRepository;
import kz.eduquest.progress.repository.UserProgressRepository;
import kz.eduquest.user.entity.User;
import kz.eduquest.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProgressService {

    private final UserProgressRepository progressRepository;
    private final TaskSubmissionRepository submissionRepository;
    private final QuizAttemptRepository attemptRepository;
    private final LessonRepository lessonRepository;
    private final TaskRepository taskRepository;
    private final QuizRepository quizRepository;
    private final HintRepository hintRepository;
    private final BlockRepository blockRepository;
    private final UserRepository userRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** Отметить урок как завершённый */
    @Transactional
    public UserProgress completeLesson(UUID userId, UUID lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new IllegalArgumentException("Lesson not found: " + lessonId));

        UserProgress progress = progressRepository.findByUserIdAndLessonId(userId, lessonId)
                .orElseGet(() -> UserProgress.builder()
                        .user(userRepository.getReferenceById(userId))
                        .lesson(lesson)
                        .build()
                );

        progress.setStatus(ProgressStatus.COMPLETED);
        progress.setCompletedAt(LocalDateTime.now());
        progressRepository.save(progress);

        eventPublisher.publishEvent(new LessonCompletedEvent(userId, lessonId));

        // Проверить: все ли уроки блока завершены?
        checkBlockCompletion(userId, lesson);

        return progress;
    }

    /** Отправить решение задачи */
    @Transactional
    public TaskSubmission submitTask(UUID userId, UUID taskId, String answer) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found: " + taskId));

        // Проверка ответа (простое сравнение; можно расширить)
        boolean isCorrect = task.getSolution() != null
                && task.getSolution().trim().equalsIgnoreCase(answer.trim());

        TaskSubmission submission = TaskSubmission.builder()
                .user(userRepository.getReferenceById(userId))
                .task(task)
                .answer(answer)
                .correct(isCorrect)
                .xpEarned(0)
                .build();
        submissionRepository.save(submission);

        // XP только за первое правильное решение (§9.5)
        if (isCorrect && !submissionRepository.existsByUserIdAndTaskIdAndCorrectTrue(userId, taskId)) {
            eventPublisher.publishEvent(new TaskSolvedEvent(userId, taskId));
        }

        return submission;
    }

    /** Отправить ответы на квиз */
    @Transactional
    public QuizAttempt submitQuiz(UUID userId, UUID quizId, Object answers, int score, int maxScore) {
        quizRepository.findById(quizId)
                .orElseThrow(() -> new IllegalArgumentException("Quiz not found: " + quizId));

        QuizAttempt attempt = QuizAttempt.builder()
                .user(userRepository.getReferenceById(userId))
                .quiz(quizRepository.getReferenceById(quizId))
                .answers(answers)
                .score(score)
                .maxScore(maxScore)
                .xpEarned(0)
                .finishedAt(LocalDateTime.now())
                .build();
        attemptRepository.save(attempt);

        int scorePercent = maxScore > 0 ? (score * 100 / maxScore) : 0;
        eventPublisher.publishEvent(new QuizPassedEvent(userId, quizId, scorePercent));

        return attempt;
    }

    /** Открыть подсказку (штраф XP) */
    @Transactional
    public Hint revealHint(UUID userId, UUID hintId) {
        Hint hint = hintRepository.findById(hintId)
                .orElseThrow(() -> new IllegalArgumentException("Hint not found: " + hintId));

        // Обновить счётчик подсказок в прогрессе урока
        UUID lessonId = hint.getTask().getLesson().getId();
        progressRepository.findByUserIdAndLessonId(userId, lessonId)
                .ifPresent(p -> {
                    p.setHintsUsed(p.getHintsUsed() + 1);
                    progressRepository.save(p);
                });

        eventPublisher.publishEvent(new HintUsedEvent(userId, hintId, hint.getTask().getId()));

        return hint;
    }

    /** Проверить завершение всех уроков в блоке */
    private void checkBlockCompletion(UUID userId, Lesson completedLesson) {
        UUID blockId = completedLesson.getBlock().getId();
        List<Lesson> allLessons = lessonRepository.findByBlockIdOrderBySortOrder(blockId);

        boolean allCompleted = allLessons.stream().allMatch(lesson ->
                progressRepository.findByUserIdAndLessonId(userId, lesson.getId())
                        .map(p -> p.getStatus() == ProgressStatus.COMPLETED)
                        .orElse(false)
        );

        if (allCompleted) {
            eventPublisher.publishEvent(new BlockCompletedEvent(userId, blockId));
            // TODO: проверить завершение всего курса
        }
    }
}
