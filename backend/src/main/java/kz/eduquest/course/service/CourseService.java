package kz.eduquest.course.service;

import kz.eduquest.course.dto.*;
import kz.eduquest.course.entity.Course;
import kz.eduquest.course.repository.CourseRepository;
import kz.eduquest.user.dto.UserResponse;
import kz.eduquest.user.entity.User;
import kz.eduquest.user.repository.UserRepository;
import kz.eduquest.enrollment.repository.EnrollmentRepository;
import kz.eduquest.enrollment.entity.EnrollmentStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CourseService {

    private final CourseRepository courseRepository;
    private final UserRepository userRepository;
    private final EnrollmentRepository enrollmentRepository;

    @Transactional
    public CourseResponse create(Long teacherId, CreateCourseRequest request) {
        User teacher = userRepository.getReferenceById(teacherId);
        Course course = Course.builder()
                .teacher(teacher)
                .title(request.title())
                .description(request.description())
                .build();
        return CourseResponse.from(courseRepository.save(course));
    }

    public Page<CourseResponse> getCatalog(Pageable pageable) {
        return courseRepository.findAll(pageable).map(CourseResponse::from);
    }

    public CourseDetailResponse getCourse(Long courseId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new IllegalArgumentException("Course not found: " + courseId));
        return CourseDetailResponse.from(course);
    }

    @Transactional
    public CourseResponse update(Long userId, boolean isAdmin, Long courseId, UpdateCourseRequest request) {
        Course course = findCourseOrThrow(courseId);
        checkOwnerOrAdmin(course, userId, isAdmin);

        if (request.title() != null)       course.setTitle(request.title());
        if (request.description() != null) course.setDescription(request.description());
        if (request.coverUrl() != null)    course.setCoverUrl(request.coverUrl());

        return CourseResponse.from(courseRepository.save(course));
    }

    @Transactional
    public void delete(Long userId, boolean isAdmin, Long courseId) {
        Course course = findCourseOrThrow(courseId);
        checkOwnerOrAdmin(course, userId, isAdmin);
        courseRepository.delete(course);
    }

    @Transactional
    public CourseResponse publish(Long userId, boolean isAdmin, Long courseId) {
        Course course = findCourseOrThrow(courseId);
        checkOwnerOrAdmin(course, userId, isAdmin);
        course.setPublished(true);
        return CourseResponse.from(courseRepository.save(course));
    }

    public Page<UserResponse> getStudents(Long userId, boolean isAdmin, Long courseId, Pageable pageable) {
        Course course = findCourseOrThrow(courseId);
        checkOwnerOrAdmin(course, userId, isAdmin);
        return enrollmentRepository.findByCourseIdAndStatus(courseId, EnrollmentStatus.ACTIVE, pageable)
                .map(e -> {
                    var u = e.getUser();
                    return new UserResponse(u.getId(), u.getEmail(), u.isActive(), java.util.Set.of(), u.getCreatedAt());
                });
    }

    // ── helpers ──

    public Course findCourseOrThrow(Long courseId) {
        return courseRepository.findById(courseId)
                .orElseThrow(() -> new IllegalArgumentException("Course not found: " + courseId));
    }

    public void checkOwnerOrAdmin(Course course, Long userId, boolean isAdmin) {
        if (!isAdmin && !course.getTeacher().getId().equals(userId)) {
            throw new org.springframework.security.access.AccessDeniedException("Not the course owner");
        }
    }
}
