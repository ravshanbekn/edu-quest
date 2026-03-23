package kz.eduquest.enrollment.entity;

import jakarta.persistence.*;
import kz.eduquest.course.entity.Course;
import kz.eduquest.user.entity.User;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "enrollments", uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "course_id"}))
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Enrollment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private EnrollmentStatus status;

    @Column(name = "enrolled_at", nullable = false, updatable = false)
    private LocalDateTime enrolledAt;

    /** NULL = самозапись, иначе = учитель/админ */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "enrolled_by")
    private User enrolledBy;

    @PrePersist
    void onCreate() {
        enrolledAt = LocalDateTime.now();
        if (status == null) status = EnrollmentStatus.ACTIVE;
    }
}
