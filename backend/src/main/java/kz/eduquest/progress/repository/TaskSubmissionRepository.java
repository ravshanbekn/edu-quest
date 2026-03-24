package kz.eduquest.progress.repository;

import kz.eduquest.progress.entity.TaskSubmission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TaskSubmissionRepository extends JpaRepository<TaskSubmission, Long> {

    List<TaskSubmission> findByUserIdAndTaskId(Long userId, Long taskId);

    boolean existsByUserIdAndTaskIdAndCorrectTrue(Long userId, Long taskId);
}
