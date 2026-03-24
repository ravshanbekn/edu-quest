package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Block;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BlockRepository extends JpaRepository<Block, Long> {

    List<Block> findByCourseIdOrderBySortOrder(Long courseId);
}
