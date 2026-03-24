package kz.eduquest.course.entity;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Table(name = "lesson_content")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LessonContent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", nullable = false)
    private Lesson lesson;

    @Enumerated(EnumType.STRING)
    @Column(name = "content_type", nullable = false, length = 50)
    private ContentType contentType;

    @Column(columnDefinition = "TEXT")
    private String body;

    @Column(name = "video_url", length = 500)
    private String videoUrl;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;
}