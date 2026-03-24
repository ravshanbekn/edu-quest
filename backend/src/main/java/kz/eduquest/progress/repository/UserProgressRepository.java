package kz.eduquest.progress.repository;

import kz.eduquest.progress.entity.ProgressStatus;
import kz.eduquest.progress.entity.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserProgressRepository extends JpaRepository<UserProgress, Long> {

    Optional<UserProgress> findByUserIdAndLessonId(Long userId, Long lessonId);

    List<UserProgress> findByUserIdAndStatus(Long userId, ProgressStatus status);

    List<UserProgress> findByUserId(Long userId);
}
