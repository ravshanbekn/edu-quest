import { useState } from "react";
import type { LessonType } from "@/types/common.types";

interface LessonFormProps {
  initialTitle?: string;
  initialType?: LessonType;
  onSubmit: (title: string, type: LessonType) => void;
  onCancel: () => void;
  loading?: boolean;
}

const LESSON_TYPES: { value: LessonType; label: string }[] = [
  { value: "VIDEO", label: "Видео" },
  { value: "TASK", label: "Задание" },
  { value: "QUIZ", label: "Квиз" },
  { value: "MIXED", label: "Смешанный" },
  { value: "THEORY", label: "Теория" },
  { value: "PRACTICE", label: "Практика" },
];

export function LessonForm({ initialTitle = "", initialType = "MIXED", onSubmit, onCancel, loading }: LessonFormProps) {
  const [title, setTitle] = useState(initialTitle);
  const [type, setType] = useState<LessonType>(initialType);

  return (
    <div className="flex items-center gap-2">
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Название урока"
        className="flex-1 rounded-md border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
        autoFocus
      />
      <select
        value={type}
        onChange={(e) => setType(e.target.value as LessonType)}
        className="rounded-md border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
      >
        {LESSON_TYPES.map((lt) => (
          <option key={lt.value} value={lt.value}>{lt.label}</option>
        ))}
      </select>
      <button
        onClick={() => title.trim() && onSubmit(title.trim(), type)}
        disabled={!title.trim() || loading}
        className="px-3 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90 disabled:opacity-50"
      >
        {loading ? "..." : "Сохранить"}
      </button>
      <button
        onClick={onCancel}
        className="px-3 py-2 text-sm rounded-md border hover:bg-muted"
      >
        Отмена
      </button>
    </div>
  );
}
