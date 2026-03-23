package kz.eduquest.course.service;

import kz.eduquest.course.dto.CreateQuizRequest;
import kz.eduquest.course.dto.QuizResponse;
import kz.eduquest.course.entity.Lesson;
import kz.eduquest.course.entity.Quiz;
import kz.eduquest.course.entity.QuizQuestion;
import kz.eduquest.course.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuizService {

    private final QuizRepository quizRepository;
    private final LessonService lessonService;
    private final CourseService courseService;

    @Transactional
    public QuizResponse create(UUID userId, boolean isAdmin, UUID lessonId, CreateQuizRequest request) {
        Lesson lesson = lessonService.findLessonOrThrow(lessonId);
        courseService.checkOwnerOrAdmin(lesson.getBlock().getCourse(), userId, isAdmin);

        Quiz quiz = Quiz.builder()
                .lesson(lesson)
                .title(request.title())
                .timeLimit(request.timeLimit())
                .xpReward(request.xpReward() != null ? request.xpReward() : 100)
                .build();

        for (int i = 0; i < request.questions().size(); i++) {
            var qr = request.questions().get(i);
            quiz.getQuestions().add(
                    QuizQuestion.builder()
                            .quiz(quiz)
                            .question(qr.question())
                            .options(qr.options())
                            .correct(qr.correct())
                            .sortOrder(i)
                            .build()
            );
        }

        return QuizResponse.from(quizRepository.save(quiz));
    }

    public QuizResponse getQuiz(UUID quizId) {
        return QuizResponse.from(findQuizOrThrow(quizId));
    }

    public Quiz findQuizOrThrow(UUID quizId) {
        return quizRepository.findById(quizId)
                .orElseThrow(() -> new IllegalArgumentException("Quiz not found: " + quizId));
    }
}
