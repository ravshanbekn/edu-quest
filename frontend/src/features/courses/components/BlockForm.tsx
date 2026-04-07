import { useState } from "react";

interface BlockFormProps {
  initialTitle?: string;
  onSubmit: (title: string) => void;
  onCancel: () => void;
  loading?: boolean;
}

export function BlockForm({ initialTitle = "", onSubmit, onCancel, loading }: BlockFormProps) {
  const [title, setTitle] = useState(initialTitle);

  return (
    <div className="flex items-center gap-2">
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Название блока"
        className="flex-1 rounded-md border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
        autoFocus
      />
      <button
        onClick={() => title.trim() && onSubmit(title.trim())}
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
