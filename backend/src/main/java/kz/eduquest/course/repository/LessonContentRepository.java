package kz.eduquest.course.repository;

import kz.eduquest.course.entity.LessonContent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface LessonContentRepository extends JpaRepository<LessonContent, UUID> {

    List<LessonContent> findByLessonIdOrderBySortOrder(UUID lessonId);
}
