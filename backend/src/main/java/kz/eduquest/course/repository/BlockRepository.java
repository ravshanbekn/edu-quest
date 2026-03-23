package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Block;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface BlockRepository extends JpaRepository<Block, UUID> {

    List<Block> findByCourseIdOrderBySortOrder(UUID courseId);
}
