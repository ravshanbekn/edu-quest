import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useParams, Link } from "react-router-dom";
import { ArrowLeft, CheckCircle } from "lucide-react";
import { toast } from "sonner";
import { getLesson } from "@/api/lessons.api";
import { completeLesson, getMyProgress } from "@/api/progress.api";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { NotFoundPage } from "@/features/errors/NotFoundPage";
import { ContentViewer } from "./components/ContentViewer";
import { TaskSection } from "./components/TaskSection";
import { QuizSection } from "./components/QuizSection";
import { usePageTitle } from "@/hooks/usePageTitle";

export function LessonPage() {
  const { id } = useParams<{ id: string }>();
  const queryClient = useQueryClient();

  const { data: lesson, isLoading } = useQuery({
    queryKey: ["lesson", id],
    queryFn: () => getLesson(id ?? ""),
    enabled: !!id,
  });

  const { data: progress } = useQuery({
    queryKey: ["myProgress"],
    queryFn: getMyProgress,
    enabled: !!id,
  });

  const isCompleted = progress?.some(
    (p) => p.lessonId === id && p.status === "COMPLETED"
  ) ?? false;

  const completeMutation = useMutation({
    mutationFn: () => completeLesson(id ?? ""),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["myProgress"] });
      queryClient.invalidateQueries({ queryKey: ["myXp"] });
      toast.success("Урок завершён!");
    },
    onError: () => toast.error("Ошибка завершения урока"),
  });

  usePageTitle(lesson?.title ?? "Урок");

  if (!id) return <NotFoundPage />;
  if (isLoading) return <LoadingSpinner size="lg" className="py-20" />;
  if (!lesson) return <NotFoundPage />;

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Header */}
      <div className="space-y-2">
        <Link to="/my-courses" className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors">
          <ArrowLeft className="h-4 w-4" /> Назад к курсам
        </Link>
        <div className="flex items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold">{lesson.title}</h1>
            {lesson.xpReward > 0 && (
              <span className="text-sm text-xp font-medium">{lesson.xpReward} XP за урок</span>
            )}
          </div>
          {isCompleted ? (
            <div className="flex items-center gap-2 px-4 py-2 text-sm rounded-md bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 shrink-0">
              <CheckCircle className="h-4 w-4" />
              Урок пройден
            </div>
          ) : (
            <button
              onClick={() => completeMutation.mutate()}
              disabled={completeMutation.isPending}
              className="flex items-center gap-2 px-4 py-2 text-sm rounded-md bg-green-600 text-white hover:bg-green-700 disabled:opacity-50 shrink-0 transition-colors"
            >
              <CheckCircle className="h-4 w-4" />
              {completeMutation.isPending ? "Сохраняем..." : "Завершить урок"}
            </button>
          )}
        </div>
      </div>

      {/* Content */}
      {lesson.contents.length > 0 && (
        <section>
          <ContentViewer contents={lesson.contents} />
        </section>
      )}

      {/* Tasks */}
      {lesson.tasks.length > 0 && (
        <section>
          <TaskSection tasks={lesson.tasks} />
        </section>
      )}

      {/* Quizzes */}
      {lesson.quizzes.length > 0 && (
        <section>
          <QuizSection quizzes={lesson.quizzes} />
        </section>
      )}
    </div>
  );
}
