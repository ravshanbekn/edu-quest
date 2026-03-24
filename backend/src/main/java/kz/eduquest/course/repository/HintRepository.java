package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Hint;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HintRepository extends JpaRepository<Hint, Long> {

    List<Hint> findByTaskIdOrderBySortOrder(Long taskId);

    java.util.Optional<Hint> findByTaskIdAndSortOrder(Long taskId, int sortOrder);
}
