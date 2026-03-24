package kz.eduquest.course.dto;

import kz.eduquest.course.entity.*;

import java.util.List;

public record LessonDetailResponse(
        Long id,
        String title,
        LessonType type,
        int xpReward,
        List<ContentResponse> contents,
        List<TaskResponse> tasks,
        List<QuizBriefResponse> quizzes
) {
    public static LessonDetailResponse from(Lesson l) {
        return new LessonDetailResponse(
                l.getId(), l.getTitle(), l.getType(), l.getXpReward(),
                l.getContents().stream().map(ContentResponse::from).toList(),
                l.getTasks().stream().map(TaskResponse::from).toList(),
                l.getQuizzes().stream().map(QuizBriefResponse::from).toList()
        );
    }

    public record ContentResponse(Long id, ContentType contentType, String body, String videoUrl, int sortOrder) {
        static ContentResponse from(LessonContent c) {
            return new ContentResponse(c.getId(), c.getContentType(), c.getBody(), c.getVideoUrl(), c.getSortOrder());
        }
    }

    public record TaskResponse(Long id, String description, TaskType taskType, int xpReward, int hintCount) {
        static TaskResponse from(Task t) {
            return new TaskResponse(t.getId(), t.getDescription(), t.getTaskType(), t.getXpReward(), t.getHints().size());
        }
    }

    public record QuizBriefResponse(Long id, String title, Integer timeLimit, int xpReward, int questionCount) {
        static QuizBriefResponse from(Quiz q) {
            return new QuizBriefResponse(q.getId(), q.getTitle(), q.getTimeLimit(), q.getXpReward(), q.getQuestions().size());
        }
    }
}