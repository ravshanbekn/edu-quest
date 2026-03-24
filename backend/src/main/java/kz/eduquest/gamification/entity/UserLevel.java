package kz.eduquest.gamification.entity;

import jakarta.persistence.*;
import kz.eduquest.user.entity.User;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_levels")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserLevel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "current_level", nullable = false)
    private int currentLevel;

    @Column(name = "total_xp", nullable = false)
    private int totalXp;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        updatedAt = LocalDateTime.now();
        if (currentLevel == 0) currentLevel = 1;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
