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
  { value: "VIDEO", label: "Video" },
  { value: "TASK", label: "Task" },
  { value: "QUIZ", label: "Quiz" },
  { value: "MIXED", label: "Mixed" },
  { value: "THEORY", label: "Theory" },
  { value: "PRACTICE", label: "Practice" },
];

export function LessonForm({ initialTitle = "", initialType = "MIXED", onSubmit, onCancel, loading }: LessonFormProps) {
  const [title, setTitle] = useState(initialTitle);
  const [type, setType] = useState<LessonType>(initialType);

  return (
    <div className="flex items-center gap-2">
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Lesson title"
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
        {loading ? "..." : "Save"}
      </button>
      <button
        onClick={onCancel}
        className="px-3 py-2 text-sm rounded-md border hover:bg-muted"
      >
        Cancel
      </button>
    </div>
  );
}
