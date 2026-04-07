import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useParams, useNavigate, Link } from "react-router-dom";
import { Pencil, Trash2, BookOpen, Globe } from "lucide-react";
import { toast } from "sonner";
import { getCourse, deleteCourse, publishCourse } from "@/api/courses.api";
import { enrollInCourse } from "@/api/enrollments.api";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { BlockList } from "./components/BlockList";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { useState } from "react";

interface CourseDetailWithBlocks {
  id: string;
  teacherId: string;
  title: string;
  description: string | null;
  coverUrl: string | null;
  published: boolean;
  createdAt: string;
  blocks?: Array<{
    id: string;
    courseId: string;
    title: string;
    sortOrder: number;
    lessons?: Array<{
      id: string;
      blockId: string;
      title: string;
      type: "VIDEO" | "TASK" | "QUIZ" | "MIXED";
      sortOrder: number;
      xpReward: number;
    }>;
  }>;
}

export function CourseDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { data: user } = useCurrentUser();
  const [showDelete, setShowDelete] = useState(false);

  const { data: course, isLoading } = useQuery<CourseDetailWithBlocks>({
    queryKey: ["course", id],
    queryFn: () => getCourse(id!),
    enabled: !!id,
  });

  const deleteM = useMutation({
    mutationFn: () => deleteCourse(id!),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["courses"] });
      toast.success("Курс удалён");
      navigate("/courses");
    },
    onError: () => toast.error("Ошибка удаления курса"),
  });

  const publishM = useMutation({
    mutationFn: () => publishCourse(id!),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["course", id] });
      toast.success("Курс опубликован");
    },
    onError: () => toast.error("Ошибка публикации"),
  });

  const enrollM = useMutation({
    mutationFn: () => enrollInCourse(id!),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["myEnrollments"] });
      toast.success("Вы записались на курс");
    },
    onError: () => toast.error("Ошибка записи на курс"),
  });

  if (isLoading) return <LoadingSpinner size="lg" className="py-20" />;
  if (!course) return <p className="text-muted-foreground py-10 text-center">Курс не найден</p>;

  const isOwner = user?.id === course.teacherId;
  const isAdmin = user?.roles.includes("ADMIN");
  const canEdit = isOwner || isAdmin;
  const isStudent = user?.roles.includes("STUDENT");

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Header */}
      <div className="space-y-4">
        {course.coverUrl ? (
          <div className="aspect-video rounded-lg overflow-hidden bg-muted">
            <img src={course.coverUrl} alt={course.title} className="h-full w-full object-cover" />
          </div>
        ) : (
          <div className="aspect-video rounded-lg bg-muted flex items-center justify-center">
            <BookOpen className="h-16 w-16 text-muted-foreground/30" />
          </div>
        )}

        <div className="flex items-start justify-between gap-4">
          <div className="space-y-1">
            <h1 className="text-2xl font-bold">{course.title}</h1>
            {course.description && (
              <p className="text-muted-foreground">{course.description}</p>
            )}
            <div className="flex items-center gap-3 text-xs text-muted-foreground">
              {!course.published && (
                <span className="bg-muted px-2 py-0.5 rounded">Черновик</span>
              )}
              <span>{new Date(course.createdAt).toLocaleDateString("ru-RU")}</span>
            </div>
          </div>

          <div className="flex items-center gap-2 shrink-0">
            {isStudent && (
              <button
                onClick={() => enrollM.mutate()}
                disabled={enrollM.isPending}
                className="px-4 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90 disabled:opacity-50"
              >
                {enrollM.isPending ? "..." : "Записаться"}
              </button>
            )}
            {canEdit && !course.published && (
              <button
                onClick={() => publishM.mutate()}
                disabled={publishM.isPending}
                className="flex items-center gap-1 px-3 py-2 text-sm rounded-md border hover:bg-muted"
              >
                <Globe className="h-4 w-4" /> Опубликовать
              </button>
            )}
            {canEdit && (
              <>
                <Link
                  to={`/courses/${course.id}/edit`}
                  className="flex items-center gap-1 px-3 py-2 text-sm rounded-md border hover:bg-muted"
                >
                  <Pencil className="h-4 w-4" /> Редактировать
                </Link>
                <button
                  onClick={() => setShowDelete(true)}
                  className="flex items-center gap-1 px-3 py-2 text-sm rounded-md border border-destructive/30 text-destructive hover:bg-destructive/10"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </>
            )}
          </div>
        </div>
      </div>

      {/* Blocks & Lessons */}
      <div className="space-y-3">
        <h2 className="text-lg font-semibold">Содержание курса</h2>
        {course.blocks && course.blocks.length > 0 ? (
          <BlockList courseId={course.id} blocks={course.blocks} canEdit={!!canEdit} />
        ) : (
          <div className="border border-dashed rounded-lg p-6 text-center text-muted-foreground text-sm">
            {canEdit ? (
              <BlockList courseId={course.id} blocks={[]} canEdit={true} />
            ) : (
              "Содержание пока не добавлено"
            )}
          </div>
        )}
      </div>

      <ConfirmDialog
        open={showDelete}
        onClose={() => setShowDelete(false)}
        onConfirm={() => deleteM.mutate()}
        title="Удалить курс?"
        description="Все блоки и уроки курса будут удалены. Это действие нельзя отменить."
        confirmLabel="Удалить курс"
        destructive
        loading={deleteM.isPending}
      />
    </div>
  );
}
