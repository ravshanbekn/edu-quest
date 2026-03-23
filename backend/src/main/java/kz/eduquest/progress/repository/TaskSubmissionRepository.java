package kz.eduquest.progress.repository;

import kz.eduquest.progress.entity.TaskSubmission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TaskSubmissionRepository extends JpaRepository<TaskSubmission, UUID> {

    List<TaskSubmission> findByUserIdAndTaskId(UUID userId, UUID taskId);

    boolean existsByUserIdAndTaskIdAndCorrectTrue(UUID userId, UUID taskId);
}
