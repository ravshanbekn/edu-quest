package kz.eduquest.course.service;

import kz.eduquest.course.dto.*;
import kz.eduquest.course.entity.Hint;
import kz.eduquest.course.entity.Lesson;
import kz.eduquest.course.entity.Task;
import kz.eduquest.course.entity.TaskType;
import kz.eduquest.course.repository.HintRepository;
import kz.eduquest.course.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskService {

    private final TaskRepository taskRepository;
    private final HintRepository hintRepository;
    private final LessonService lessonService;
    private final CourseService courseService;

    @Transactional
    public TaskResponse create(Long userId, boolean isAdmin, Long lessonId, CreateTaskRequest request) {
        Lesson lesson = lessonService.findLessonOrThrow(lessonId);
        courseService.checkOwnerOrAdmin(lesson.getBlock().getCourse(), userId, isAdmin);

        int nextOrder = taskRepository.findByLessonIdOrderBySortOrder(lessonId).size();

        Task task = Task.builder()
                .lesson(lesson)
                .description(request.description())
                .solution(request.solution())
                .taskType(request.taskType() != null ? request.taskType() : TaskType.TEXT)
                .xpReward(request.xpReward() != null ? request.xpReward() : 75)
                .sortOrder(nextOrder)
                .build();
        return TaskResponse.from(taskRepository.save(task));
    }

    @Transactional
    public TaskResponse update(Long userId, boolean isAdmin, Long taskId, UpdateTaskRequest request) {
        Task task = findTaskOrThrow(taskId);
        courseService.checkOwnerOrAdmin(task.getLesson().getBlock().getCourse(), userId, isAdmin);

        if (request.description() != null) task.setDescription(request.description());
        if (request.solution() != null)    task.setSolution(request.solution());
        if (request.taskType() != null)    task.setTaskType(request.taskType());
        if (request.xpReward() != null)    task.setXpReward(request.xpReward());

        return TaskResponse.from(taskRepository.save(task));
    }

    @Transactional
    public void addHint(Long userId, boolean isAdmin, Long taskId, CreateHintRequest request) {
        Task task = findTaskOrThrow(taskId);
        courseService.checkOwnerOrAdmin(task.getLesson().getBlock().getCourse(), userId, isAdmin);

        int nextOrder = hintRepository.findByTaskIdOrderBySortOrder(taskId).size();

        hintRepository.save(
                Hint.builder()
                        .task(task)
                        .content(request.content())
                        .xpPenalty(request.xpPenalty() != null ? request.xpPenalty() : 10)
                        .sortOrder(nextOrder)
                        .build()
        );
    }

    Task findTaskOrThrow(Long taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found: " + taskId));
    }
}
