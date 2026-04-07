package kz.eduquest.progress.repository;

import kz.eduquest.progress.entity.ProgressStatus;
import kz.eduquest.progress.entity.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserProgressRepository extends JpaRepository<UserProgress, Long> {

    Optional<UserProgress> findByUserIdAndLessonId(Long userId, Long lessonId);

    List<UserProgress> findByUserIdAndStatus(Long userId, ProgressStatus status);

    @Query("SELECT up FROM UserProgress up JOIN FETCH up.lesson l JOIN FETCH l.block b JOIN FETCH b.course WHERE up.user.id = :userId")
    List<UserProgress> findByUserId(@Param("userId") Long userId);
}
