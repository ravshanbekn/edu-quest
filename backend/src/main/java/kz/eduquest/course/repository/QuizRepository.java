package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface QuizRepository extends JpaRepository<Quiz, UUID> {

    List<Quiz> findByLessonId(UUID lessonId);
}
