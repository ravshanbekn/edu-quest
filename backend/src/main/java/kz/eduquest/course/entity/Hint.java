package kz.eduquest.course.entity;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Table(name = "hints")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Hint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id", nullable = false)
    private Task task;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @Column(name = "xp_penalty", nullable = false)
    private int xpPenalty;

    @PrePersist
    void onCreate() {
        if (xpPenalty == 0) xpPenalty = 10;
    }
}