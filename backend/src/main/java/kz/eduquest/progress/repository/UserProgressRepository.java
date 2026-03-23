package kz.eduquest.progress.repository;

import kz.eduquest.progress.entity.ProgressStatus;
import kz.eduquest.progress.entity.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserProgressRepository extends JpaRepository<UserProgress, UUID> {

    Optional<UserProgress> findByUserIdAndLessonId(UUID userId, UUID lessonId);

    List<UserProgress> findByUserIdAndStatus(UUID userId, ProgressStatus status);

    List<UserProgress> findByUserId(UUID userId);
}
