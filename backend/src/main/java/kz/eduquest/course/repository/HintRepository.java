package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Hint;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface HintRepository extends JpaRepository<Hint, UUID> {

    List<Hint> findByTaskIdOrderBySortOrder(UUID taskId);
}
