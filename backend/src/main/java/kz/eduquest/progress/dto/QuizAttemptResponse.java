package kz.eduquest.progress.dto;

public record QuizAttemptResponse(
        Long id,
        Long quizId,
        int score,
        boolean passed,
        int xpAwarded
) {
    private static final int PASS_THRESHOLD = 80;
    private static final int XP_HIGH = 100;
    private static final int XP_LOW  = 50;

    public static QuizAttemptResponse of(Long id, Long quizId, int score, int maxScore) {
        int scorePercent = maxScore > 0 ? (score * 100 / maxScore) : 0;
        boolean passed   = scorePercent >= PASS_THRESHOLD;
        int xpAwarded    = passed ? XP_HIGH : XP_LOW;
        return new QuizAttemptResponse(id, quizId, scorePercent, passed, xpAwarded);
    }
}
