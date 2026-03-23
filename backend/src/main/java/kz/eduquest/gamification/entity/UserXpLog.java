package kz.eduquest.gamification.entity;

import jakarta.persistence.*;
import kz.eduquest.user.entity.User;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_xp_log")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserXpLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", nullable = false, length = 100)
    private ActionType actionType;

    /** Может быть отрицательным (штраф за подсказку) */
    @Column(name = "xp_amount", nullable = false)
    private int xpAmount;

    /** ID урока/задачи/квиза, за который начислен XP */
    @Column(name = "reference_id")
    private UUID referenceId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
