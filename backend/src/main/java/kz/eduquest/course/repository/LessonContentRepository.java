package kz.eduquest.course.repository;

import kz.eduquest.course.entity.LessonContent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LessonContentRepository extends JpaRepository<LessonContent, Long> {

    List<LessonContent> findByLessonIdOrderBySortOrder(Long lessonId);
}
