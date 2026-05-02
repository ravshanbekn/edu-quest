import { useState, useRef } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useParams, Link } from "react-router-dom";
import { ArrowLeft, Plus, Trash2, Upload, Link2, Pencil, Check } from "lucide-react";
import { toast } from "sonner";
import { getLesson } from "@/api/lessons.api";
import { createContent, updateContent, deleteContent, uploadFile } from "@/api/content.api";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { NotFoundPage } from "@/features/errors/NotFoundPage";
import { usePageTitle } from "@/hooks/usePageTitle";
import type { ContentRequest, ContentResponse } from "@/types/lesson.types";
import type { ContentType } from "@/types/common.types";

const CONTENT_TYPES: { value: ContentType; label: string }[] = [
  { value: "TEXT", label: "Text (Markdown)" },
  { value: "IMAGE", label: "Image" },
  { value: "VIDEO", label: "Video" },
  { value: "CODE_BLOCK", label: "Code block" },
];

const TYPE_BADGE: Record<ContentType, string> = {
  TEXT: "bg-blue-100 text-blue-700",
  IMAGE: "bg-green-100 text-green-700",
  VIDEO: "bg-purple-100 text-purple-700",
  CODE_BLOCK: "bg-orange-100 text-orange-700",
};

function ContentPreview({ item }: { item: ContentResponse }) {
  if (item.contentType === "IMAGE" && item.videoUrl) {
    return <img src={item.videoUrl} alt="" className="h-16 rounded object-contain border" />;
  }
  if (item.contentType === "VIDEO" && item.videoUrl) {
    return <span className="text-xs text-muted-foreground truncate max-w-xs">{item.videoUrl}</span>;
  }
  if (item.body) {
    return <p className="text-xs text-muted-foreground line-clamp-2">{item.body}</p>;
  }
  return null;
}

interface BlockFormState {
  contentType: ContentType;
  body: string;
  videoUrl: string;
  sortOrder: number;
  useFile: boolean;
}

const EMPTY_FORM: BlockFormState = {
  contentType: "TEXT",
  body: "",
  videoUrl: "",
  sortOrder: 0,
  useFile: false,
};

function BlockForm({
  initial,
  maxOrder,
  onSave,
  onCancel,
  saving,
}: {
  initial?: BlockFormState;
  maxOrder: number;
  onSave: (req: ContentRequest) => void;
  onCancel?: () => void;
  saving: boolean;
}) {
  const [form, setForm] = useState<BlockFormState>(
    initial ?? { ...EMPTY_FORM, sortOrder: maxOrder + 1 }
  );
  const [uploading, setUploading] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const needsMedia = form.contentType === "IMAGE" || form.contentType === "VIDEO";
  const needsBody = form.contentType === "TEXT" || form.contentType === "CODE_BLOCK";
  const folder = form.contentType === "IMAGE" ? "images" : "videos";

  async function handleFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true);
    try {
      const url = await uploadFile(file, folder);
      setForm((f) => ({ ...f, videoUrl: url }));
      toast.success("File uploaded");
    } catch {
      toast.error("Error uploading file");
    } finally {
      setUploading(false);
    }
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    onSave({
      contentType: form.contentType,
      body: needsBody ? form.body || null : null,
      videoUrl: needsMedia ? form.videoUrl || null : null,
      sortOrder: form.sortOrder,
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3 border rounded-lg p-4 bg-muted/30">
      <div className="grid grid-cols-2 gap-3">
        <div className="space-y-1">
          <label className="text-xs font-medium text-muted-foreground">Block type</label>
          <select
            value={form.contentType}
            onChange={(e) => setForm((f) => ({ ...f, contentType: e.target.value as ContentType }))}
            className="w-full border rounded-md px-3 py-2 text-sm bg-background"
          >
            {CONTENT_TYPES.map((t) => (
              <option key={t.value} value={t.value}>{t.label}</option>
            ))}
          </select>
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium text-muted-foreground">Order</label>
          <input
            type="number"
            value={form.sortOrder}
            onChange={(e) => setForm((f) => ({ ...f, sortOrder: Number(e.target.value) }))}
            className="w-full border rounded-md px-3 py-2 text-sm bg-background"
          />
        </div>
      </div>

      {needsBody && (
        <div className="space-y-1">
          <label className="text-xs font-medium text-muted-foreground">
            {form.contentType === "CODE_BLOCK" ? "Code" : "Text (Markdown)"}
          </label>
          <textarea
            value={form.body}
            onChange={(e) => setForm((f) => ({ ...f, body: e.target.value }))}
            rows={5}
            className="w-full border rounded-md px-3 py-2 text-sm bg-background font-mono resize-y"
            placeholder={form.contentType === "CODE_BLOCK" ? "// code here" : "**Heading**\n\nText..."}
          />
        </div>
      )}

      {needsMedia && (
        <div className="space-y-2">
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setForm((f) => ({ ...f, useFile: false }))}
              className={`flex items-center gap-1 px-3 py-1.5 text-xs rounded-md border transition-colors ${
                !form.useFile ? "bg-primary text-primary-foreground" : "hover:bg-muted"
              }`}
            >
              <Link2 className="h-3 w-3" /> URL
            </button>
            <button
              type="button"
              onClick={() => setForm((f) => ({ ...f, useFile: true }))}
              className={`flex items-center gap-1 px-3 py-1.5 text-xs rounded-md border transition-colors ${
                form.useFile ? "bg-primary text-primary-foreground" : "hover:bg-muted"
              }`}
            >
              <Upload className="h-3 w-3" /> Upload file
            </button>
          </div>

          {form.useFile ? (
            <div className="space-y-1">
              <input
                ref={fileRef}
                type="file"
                accept={form.contentType === "IMAGE" ? "image/*" : "video/*"}
                onChange={handleFile}
                className="hidden"
              />
              <button
                type="button"
                onClick={() => fileRef.current?.click()}
                disabled={uploading}
                className="w-full border-2 border-dashed rounded-md px-4 py-3 text-sm text-muted-foreground hover:border-primary hover:text-primary transition-colors disabled:opacity-50"
              >
                {uploading ? "Uploading..." : form.videoUrl ? "File uploaded — click to replace" : "Click to select file"}
              </button>
              {form.videoUrl && (
                <p className="text-xs text-green-600 truncate">{form.videoUrl}</p>
              )}
            </div>
          ) : (
            <input
              type="url"
              value={form.videoUrl}
              onChange={(e) => setForm((f) => ({ ...f, videoUrl: e.target.value }))}
              placeholder={form.contentType === "IMAGE" ? "https://..." : "https://youtube.com/watch?v=..."}
              className="w-full border rounded-md px-3 py-2 text-sm bg-background"
            />
          )}
        </div>
      )}

      <div className="flex justify-end gap-2 pt-1">
        {onCancel && (
          <button type="button" onClick={onCancel} className="px-3 py-1.5 text-sm rounded-md border hover:bg-muted">
            Cancel
          </button>
        )}
        <button
          type="submit"
          disabled={saving || uploading}
          className="flex items-center gap-1.5 px-4 py-1.5 text-sm rounded-md bg-primary text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
        >
          <Check className="h-3.5 w-3.5" />
          {saving ? "Saving..." : "Save"}
        </button>
      </div>
    </form>
  );
}

export function LessonEditPage() {
  const { id } = useParams<{ id: string }>();
  const queryClient = useQueryClient();
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);

  const { data: lesson, isLoading } = useQuery({
    queryKey: ["lesson", id],
    queryFn: () => getLesson(id ?? ""),
    enabled: !!id,
  });

  const createMut = useMutation({
    mutationFn: (req: ContentRequest) => createContent(id!, req),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["lesson", id] });
      setShowAddForm(false);
      toast.success("Block added");
    },
    onError: () => toast.error("Error adding block"),
  });

  const updateMut = useMutation({
    mutationFn: ({ cid, req }: { cid: string; req: ContentRequest }) => updateContent(cid, req),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["lesson", id] });
      setEditingId(null);
      toast.success("Block updated");
    },
    onError: () => toast.error("Error updating block"),
  });

  const deleteMut = useMutation({
    mutationFn: (cid: string) => deleteContent(cid),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["lesson", id] });
      toast.success("Block deleted");
    },
    onError: () => toast.error("Error deleting block"),
  });

  usePageTitle(lesson ? `Editor: ${lesson.title}` : "Lesson editor");

  if (!id) return <NotFoundPage />;
  if (isLoading) return <LoadingSpinner size="lg" className="py-20" />;
  if (!lesson) return <NotFoundPage />;

  const sorted = [...lesson.contents].sort((a, b) => a.sortOrder - b.sortOrder);
  const maxOrder = sorted.length > 0 ? Math.max(...sorted.map((c) => c.sortOrder)) : 0;

  return (
    <div className="space-y-6 max-w-3xl mx-auto">
      <div className="space-y-1">
        <Link
          to={`/lessons/${id}`}
          className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          <ArrowLeft className="h-4 w-4" /> Back to lesson
        </Link>
        <h1 className="text-2xl font-bold">Content editor</h1>
        <p className="text-muted-foreground text-sm">{lesson.title}</p>
      </div>

      {/* Existing blocks */}
      <div className="space-y-3">
        <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">
          Content blocks ({sorted.length})
        </h2>

        {sorted.length === 0 && (
          <p className="text-sm text-muted-foreground py-4 text-center border rounded-lg">
            No blocks yet. Add the first block below.
          </p>
        )}

        {sorted.map((item) =>
          editingId === item.id ? (
            <BlockForm
              key={item.id}
              initial={{
                contentType: item.contentType,
                body: item.body ?? "",
                videoUrl: item.videoUrl ?? "",
                sortOrder: item.sortOrder,
                useFile: false,
              }}
              maxOrder={maxOrder}
              onSave={(req) => updateMut.mutate({ cid: item.id, req })}
              onCancel={() => setEditingId(null)}
              saving={updateMut.isPending}
            />
          ) : (
            <div key={item.id} className="flex items-start gap-3 border rounded-lg p-3 bg-background">
              <span className={`text-xs px-2 py-0.5 rounded-full font-medium shrink-0 mt-0.5 ${TYPE_BADGE[item.contentType]}`}>
                {CONTENT_TYPES.find((t) => t.value === item.contentType)?.label}
              </span>
              <div className="flex-1 min-w-0 space-y-1">
                <ContentPreview item={item} />
                <span className="text-xs text-muted-foreground">order: {item.sortOrder}</span>
              </div>
              <div className="flex gap-1 shrink-0">
                <button
                  onClick={() => setEditingId(item.id)}
                  className="p-1.5 rounded-md hover:bg-muted text-muted-foreground hover:text-foreground transition-colors"
                  title="Edit"
                >
                  <Pencil className="h-3.5 w-3.5" />
                </button>
                <button
                  onClick={() => deleteMut.mutate(item.id)}
                  disabled={deleteMut.isPending}
                  className="p-1.5 rounded-md hover:bg-destructive/10 text-muted-foreground hover:text-destructive transition-colors disabled:opacity-50"
                  title="Delete"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </button>
              </div>
            </div>
          )
        )}
      </div>

      {/* Add new block */}
      <div className="space-y-3">
        <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">
          Add block
        </h2>
        {showAddForm ? (
          <BlockForm
            maxOrder={maxOrder}
            onSave={(req) => createMut.mutate(req)}
            onCancel={() => setShowAddForm(false)}
            saving={createMut.isPending}
          />
        ) : (
          <button
            onClick={() => setShowAddForm(true)}
            className="flex items-center gap-2 w-full border-2 border-dashed rounded-lg px-4 py-3 text-sm text-muted-foreground hover:border-primary hover:text-primary transition-colors"
          >
            <Plus className="h-4 w-4" />
            New block
          </button>
        )}
      </div>
    </div>
  );
}
