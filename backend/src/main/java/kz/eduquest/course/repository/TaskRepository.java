package kz.eduquest.course.repository;

import kz.eduquest.course.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TaskRepository extends JpaRepository<Task, UUID> {

    List<Task> findByLessonIdOrderBySortOrder(UUID lessonId);
}
