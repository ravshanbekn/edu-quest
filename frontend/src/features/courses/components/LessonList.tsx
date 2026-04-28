import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { Plus, Pencil, Trash2, Video, FileText, HelpCircle, Layers, BookOpen, Dumbbell } from "lucide-react";
import { toast } from "sonner";
import { createLesson, deleteLesson, updateLesson } from "@/api/lessons.api";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { LessonForm } from "./LessonForm";
import type { LessonResponse } from "@/types/lesson.types";
import type { LessonType } from "@/types/common.types";

interface LessonListProps {
  blockId: string;
  lessons: LessonResponse[];
  courseId: string;
  canEdit: boolean;
}

const typeIcons: Record<LessonType, React.ComponentType<{ className?: string }>> = {
  VIDEO: Video,
  TASK: FileText,
  QUIZ: HelpCircle,
  MIXED: Layers,
  THEORY: BookOpen,
  PRACTICE: Dumbbell,
};

const typeLabels: Record<LessonType, string> = {
  VIDEO: "Видео",
  TASK: "Задание",
  QUIZ: "Квиз",
  MIXED: "Смешанный",
  THEORY: "Теория",
  PRACTICE: "Практика",
};

export function LessonList({ blockId, lessons, courseId, canEdit }: LessonListProps) {
  const queryClient = useQueryClient();
  const [showAdd, setShowAdd] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ["course", courseId] });

  const addMutation = useMutation({
    mutationFn: (data: { title: string; type: LessonType }) => createLesson(blockId, data),
    onSuccess: () => { invalidate(); setShowAdd(false); toast.success("Урок создан"); },
    onError: () => toast.error("Ошибка создания урока"),
  });

  const editMutation = useMutation({
    mutationFn: (data: { id: string; title: string; type: LessonType }) => updateLesson(data.id, { title: data.title, type: data.type }),
    onSuccess: () => { invalidate(); setEditingId(null); toast.success("Урок обновлён"); },
    onError: () => toast.error("Ошибка обновления урока"),
  });

  const deleteMutation = useMutation({
    mutationFn: deleteLesson,
    onSuccess: () => { invalidate(); setDeleteId(null); toast.success("Урок удалён"); },
    onError: () => toast.error("Ошибка удаления урока"),
  });

  const editingLesson = lessons.find((l) => l.id === editingId);

  return (
    <div className="space-y-1">
      {lessons.map((lesson) => {
        const Icon = typeIcons[lesson.type];
        if (editingId === lesson.id) {
          return (
            <div key={lesson.id} className="pl-2">
              <LessonForm
                initialTitle={editingLesson?.title}
                initialType={editingLesson?.type}
                onSubmit={(title, type) => editMutation.mutate({ id: lesson.id, title, type })}
                onCancel={() => setEditingId(null)}
                loading={editMutation.isPending}
              />
            </div>
          );
        }
        return (
          <div key={lesson.id} className="flex items-center gap-2 group rounded-md px-2 py-1.5 hover:bg-muted/50">
            <Icon className="h-4 w-4 text-muted-foreground shrink-0" />
            <Link to={`/lessons/${lesson.id}`} className="flex-1 text-sm hover:text-primary transition-colors">
              {lesson.title}
            </Link>
            <span className="text-xs text-muted-foreground">{typeLabels[lesson.type]}</span>
            {lesson.xpReward > 0 && (
              <span className="text-xs text-amber-600">{lesson.xpReward} XP</span>
            )}
            {canEdit && (
              <div className="hidden group-hover:flex items-center gap-1">
                <button onClick={() => setEditingId(lesson.id)} className="p-1 rounded hover:bg-muted">
                  <Pencil className="h-3.5 w-3.5 text-muted-foreground" />
                </button>
                <button onClick={() => setDeleteId(lesson.id)} className="p-1 rounded hover:bg-muted">
                  <Trash2 className="h-3.5 w-3.5 text-destructive" />
                </button>
              </div>
            )}
          </div>
        );
      })}

      {canEdit && (
        showAdd ? (
          <div className="pl-2">
            <LessonForm
              onSubmit={(title, type) => addMutation.mutate({ title, type })}
              onCancel={() => setShowAdd(false)}
              loading={addMutation.isPending}
            />
          </div>
        ) : (
          <button
            onClick={() => setShowAdd(true)}
            className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground px-2 py-1"
          >
            <Plus className="h-3.5 w-3.5" /> Добавить урок
          </button>
        )
      )}

      <ConfirmDialog
        open={!!deleteId}
        onClose={() => setDeleteId(null)}
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        title="Удалить урок?"
        description="Это действие нельзя отменить."
        confirmLabel="Удалить"
        destructive
        loading={deleteMutation.isPending}
      />
    </div>
  );
}
