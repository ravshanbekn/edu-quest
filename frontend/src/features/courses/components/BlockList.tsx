import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Plus, Pencil, Trash2, ChevronDown, ChevronRight } from "lucide-react";
import { toast } from "sonner";
import { createBlock, updateBlock, deleteBlock } from "@/api/blocks.api";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { BlockForm } from "./BlockForm";
import { LessonList } from "./LessonList";
import type { BlockResponse } from "@/types/course.types";
import type { LessonResponse } from "@/types/lesson.types";

interface BlockWithLessons extends BlockResponse {
  lessons?: LessonResponse[];
}

interface BlockListProps {
  courseId: string;
  blocks: BlockWithLessons[];
  canEdit: boolean;
}

export function BlockList({ courseId, blocks, canEdit }: BlockListProps) {
  const queryClient = useQueryClient();
  const [expandedBlocks, setExpandedBlocks] = useState<Set<string>>(
    new Set(blocks.map((b) => b.id))
  );
  const [showAdd, setShowAdd] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ["course", courseId] });

  const toggleBlock = (id: string) => {
    setExpandedBlocks((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const addMutation = useMutation({
    mutationFn: (title: string) => createBlock(courseId, { title }),
    onSuccess: () => { invalidate(); setShowAdd(false); toast.success("Block created"); },
    onError: () => toast.error("Error creating block"),
  });

  const editMutation = useMutation({
    mutationFn: (data: { id: string; title: string }) => updateBlock(data.id, { title: data.title }),
    onSuccess: () => { invalidate(); setEditingId(null); toast.success("Block updated"); },
    onError: () => toast.error("Error updating block"),
  });

  const deleteMutation = useMutation({
    mutationFn: deleteBlock,
    onSuccess: () => { invalidate(); setDeleteId(null); toast.success("Block deleted"); },
    onError: () => toast.error("Error deleting block"),
  });

  const sorted = [...blocks].sort((a, b) => a.sortOrder - b.sortOrder);

  return (
    <div className="space-y-3">
      {sorted.map((block) => {
        const expanded = expandedBlocks.has(block.id);
        return (
          <div key={block.id} className="border rounded-lg">
            {editingId === block.id ? (
              <div className="p-3">
                <BlockForm
                  initialTitle={block.title}
                  onSubmit={(title) => editMutation.mutate({ id: block.id, title })}
                  onCancel={() => setEditingId(null)}
                  loading={editMutation.isPending}
                />
              </div>
            ) : (
              <div className="flex items-center gap-2 p-3">
                <button onClick={() => toggleBlock(block.id)} className="p-0.5 rounded hover:bg-muted">
                  {expanded
                    ? <ChevronDown className="h-4 w-4 text-muted-foreground" />
                    : <ChevronRight className="h-4 w-4 text-muted-foreground" />}
                </button>
                <h3 className="flex-1 font-semibold text-sm">{block.title}</h3>
                {block.lessons && (
                  <span className="text-xs text-muted-foreground">
                    {block.lessons.length} {block.lessons.length === 1 ? "lesson" : "lessons"}
                  </span>
                )}
                {canEdit && (
                  <div className="flex items-center gap-1">
                    <button onClick={() => setEditingId(block.id)} className="p-1 rounded hover:bg-muted">
                      <Pencil className="h-3.5 w-3.5 text-muted-foreground" />
                    </button>
                    <button onClick={() => setDeleteId(block.id)} className="p-1 rounded hover:bg-muted">
                      <Trash2 className="h-3.5 w-3.5 text-destructive" />
                    </button>
                  </div>
                )}
              </div>
            )}
            {expanded && editingId !== block.id && (
              <div className="px-3 pb-3 border-t pt-2">
                <LessonList
                  blockId={block.id}
                  lessons={block.lessons || []}
                  courseId={courseId}
                  canEdit={canEdit}
                />
              </div>
            )}
          </div>
        );
      })}

      {canEdit && (
        showAdd ? (
          <BlockForm
            onSubmit={(title) => addMutation.mutate(title)}
            onCancel={() => setShowAdd(false)}
            loading={addMutation.isPending}
          />
        ) : (
          <button
            onClick={() => setShowAdd(true)}
            className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground border border-dashed rounded-lg p-3 w-full justify-center"
          >
            <Plus className="h-4 w-4" /> Add block
          </button>
        )
      )}

      <ConfirmDialog
        open={!!deleteId}
        onClose={() => setDeleteId(null)}
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        title="Delete block?"
        description="All lessons in this block will also be deleted."
        confirmLabel="Delete"
        destructive
        loading={deleteMutation.isPending}
      />
    </div>
  );
}
