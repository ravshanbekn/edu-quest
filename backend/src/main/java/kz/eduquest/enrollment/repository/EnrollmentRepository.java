package kz.eduquest.enrollment.repository;

import kz.eduquest.enrollment.entity.Enrollment;
import kz.eduquest.enrollment.entity.EnrollmentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface EnrollmentRepository extends JpaRepository<Enrollment, UUID> {

    Optional<Enrollment> findByUserIdAndCourseId(UUID userId, UUID courseId);

    Page<Enrollment> findByUserIdAndStatus(UUID userId, EnrollmentStatus status, Pageable pageable);

    Page<Enrollment> findByUserId(UUID userId, Pageable pageable);

    Page<Enrollment> findByCourseIdAndStatus(UUID courseId, EnrollmentStatus status, Pageable pageable);

    boolean existsByUserIdAndCourseId(UUID userId, UUID courseId);
}
