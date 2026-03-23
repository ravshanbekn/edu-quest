package kz.eduquest.gamification.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "badge_definitions")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BadgeDefinition {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "icon_url", length = 500)
    private String iconUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "condition_type", nullable = false, length = 100)
    private BadgeConditionType conditionType;

    @Column(name = "condition_value", nullable = false)
    private int conditionValue;

    @Column(name = "is_active", nullable = false)
    private boolean active;

    @PrePersist
    void onCreate() {
        active = true;
    }
}
