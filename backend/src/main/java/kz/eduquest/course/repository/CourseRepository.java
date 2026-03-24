package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRepository extends JpaRepository<Course, Long> {

    Page<Course> findAll(Pageable pageable);

    Page<Course> findByTeacherId(Long teacherId, Pageable pageable);

    boolean existsByIdAndTeacherId(Long id, Long teacherId);
}
