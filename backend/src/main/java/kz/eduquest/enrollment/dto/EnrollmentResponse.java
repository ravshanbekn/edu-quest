package kz.eduquest.enrollment.dto;

import kz.eduquest.enrollment.entity.Enrollment;
import kz.eduquest.enrollment.entity.EnrollmentStatus;

import java.time.LocalDateTime;

public record EnrollmentResponse(
        Long id,
        Long userId,
        Long courseId,
        String courseTitle,
        EnrollmentStatus status,
        LocalDateTime enrolledAt
) {
    public static EnrollmentResponse from(Enrollment e) {
        return new EnrollmentResponse(
                e.getId(), e.getUser().getId(), e.getCourse().getId(),
                e.getCourse().getTitle(), e.getStatus(), e.getEnrolledAt()
        );
    }
}