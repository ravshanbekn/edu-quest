package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CourseRepository extends JpaRepository<Course, UUID> {

    Page<Course> findByPublishedTrue(Pageable pageable);

    Page<Course> findByTeacherId(UUID teacherId, Pageable pageable);

    boolean existsByIdAndTeacherId(UUID id, UUID teacherId);
}
