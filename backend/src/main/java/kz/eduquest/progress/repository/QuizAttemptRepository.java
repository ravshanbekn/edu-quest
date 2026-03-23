package kz.eduquest.progress.repository;

import kz.eduquest.progress.entity.QuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, UUID> {

    List<QuizAttempt> findByUserIdAndQuizId(UUID userId, UUID quizId);

    List<QuizAttempt> findByUserId(UUID userId);
}
