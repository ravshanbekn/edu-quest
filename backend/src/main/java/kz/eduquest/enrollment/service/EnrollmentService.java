package kz.eduquest.enrollment.service;

import kz.eduquest.course.entity.Course;
import kz.eduquest.course.service.CourseService;
import kz.eduquest.enrollment.dto.EnrollmentResponse;
import kz.eduquest.enrollment.entity.Enrollment;
import kz.eduquest.enrollment.entity.EnrollmentStatus;
import kz.eduquest.enrollment.repository.EnrollmentRepository;
import kz.eduquest.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final CourseService courseService;
    private final UserRepository userRepository;

    @Transactional
    public EnrollmentResponse selfEnroll(Long studentId, Long courseId) {
        Course course = courseService.findCourseOrThrow(courseId);
        if (!course.isPublished()) {
            throw new IllegalArgumentException("Cannot enroll in unpublished course");
        }
        return enroll(studentId, courseId, null);
    }

    @Transactional
    public EnrollmentResponse enrollByTeacher(Long teacherId, boolean isAdmin, Long courseId, Long studentId) {
        Course course = courseService.findCourseOrThrow(courseId);
        courseService.checkOwnerOrAdmin(course, teacherId, isAdmin);
        return enroll(studentId, courseId, teacherId);
    }

    @Transactional
    public void unenroll(Long teacherId, boolean isAdmin, Long courseId, Long studentId) {
        Course course = courseService.findCourseOrThrow(courseId);
        courseService.checkOwnerOrAdmin(course, teacherId, isAdmin);

        Enrollment enrollment = enrollmentRepository.findByUserIdAndCourseId(studentId, courseId)
                .orElseThrow(() -> new IllegalArgumentException("Enrollment not found"));
        enrollment.setStatus(EnrollmentStatus.DROPPED);
        enrollmentRepository.save(enrollment);
    }

    public Page<EnrollmentResponse> getMyEnrollments(Long userId, Pageable pageable) {
        return enrollmentRepository.findByUserId(userId, pageable).map(EnrollmentResponse::from);
    }

    private EnrollmentResponse enroll(Long studentId, Long courseId, Long enrolledById) {
        if (enrollmentRepository.existsByUserIdAndCourseId(studentId, courseId)) {
            throw new IllegalArgumentException("Already enrolled in this course");
        }

        Enrollment enrollment = Enrollment.builder()
                .user(userRepository.getReferenceById(studentId))
                .course(courseService.findCourseOrThrow(courseId))
                .enrolledBy(enrolledById != null ? userRepository.getReferenceById(enrolledById) : null)
                .build();
        return EnrollmentResponse.from(enrollmentRepository.save(enrollment));
    }
}
