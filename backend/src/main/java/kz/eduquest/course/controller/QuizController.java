package kz.eduquest.course.controller;

import jakarta.validation.Valid;
import kz.eduquest.common.security.UserPrincipal;
import kz.eduquest.course.dto.CreateQuizRequest;
import kz.eduquest.course.dto.QuizResponse;
import kz.eduquest.course.entity.QuizQuestion;
import kz.eduquest.course.service.QuizService;
import kz.eduquest.progress.dto.QuizAttemptResponse;
import kz.eduquest.progress.dto.SubmitQuizRequest;
import kz.eduquest.progress.entity.QuizAttempt;
import kz.eduquest.progress.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;
    private final ProgressService progressService;

    @PostMapping("/api/v1/lessons/{lessonId}/quizzes")
    @PreAuthorize("hasAuthority('course:manage_own')")
    public ResponseEntity<QuizResponse> create(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long lessonId,
            @Valid @RequestBody CreateQuizRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(quizService.create(p.getId(), p.hasPermission("course:manage_all"), lessonId, request));
    }

    @PostMapping("/api/v1/quizzes/{id}/attempt")
    @PreAuthorize("hasAuthority('quiz:take')")
    public ResponseEntity<QuizResponse> startAttempt(@PathVariable Long id) {
        return ResponseEntity.ok(quizService.getQuiz(id));
    }

    @PostMapping("/api/v1/quizzes/{id}/attempt/{attemptId}/submit")
    @PreAuthorize("hasAuthority('quiz:take')")
    public ResponseEntity<QuizAttemptResponse> submitAttempt(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable Long id,
            @PathVariable Long attemptId,
            @Valid @RequestBody SubmitQuizRequest request) {

        var quiz = quizService.findQuizOrThrow(id);
        int score = 0;
        int maxScore = quiz.getQuestions().size();

        for (QuizQuestion question : quiz.getQuestions()) {
            List<Integer> userAnswer = request.answers().get(question.getId());
            if (userAnswer != null && userAnswer.equals(question.getCorrect())) {
                score++;
            }
        }

        QuizAttempt attempt = progressService.submitQuiz(p.getId(), id, request.answers(), score, maxScore);
        return ResponseEntity.ok(QuizAttemptResponse.of(attempt.getId(), id, score, maxScore));
    }
}
