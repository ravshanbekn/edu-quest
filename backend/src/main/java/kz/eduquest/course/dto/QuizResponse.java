package kz.eduquest.course.dto;

import kz.eduquest.course.entity.Quiz;
import kz.eduquest.course.entity.QuizQuestion;

import java.util.List;

public record QuizResponse(
        Long id,
        Long lessonId,
        String title,
        Integer timeLimit,
        int xpReward,
        List<QuestionResponse> questions
) {
    public static QuizResponse from(Quiz q) {
        return new QuizResponse(
                q.getId(), q.getLesson().getId(), q.getTitle(),
                q.getTimeLimit(), q.getXpReward(),
                q.getQuestions().stream().map(QuestionResponse::from).toList()
        );
    }

    public record QuestionResponse(Long id, String question, List<String> options, int sortOrder) {
        static QuestionResponse from(QuizQuestion qq) {
            return new QuestionResponse(qq.getId(), qq.getQuestion(), qq.getOptions(), qq.getSortOrder());
        }
    }
}