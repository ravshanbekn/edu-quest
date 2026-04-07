import { FileText, Video, Code } from "lucide-react";
import type { ContentResponse } from "@/types/lesson.types";

interface ContentViewerProps {
  contents: ContentResponse[];
}

export function ContentViewer({ contents }: ContentViewerProps) {
  const sorted = [...contents].sort((a, b) => a.sortOrder - b.sortOrder);

  if (sorted.length === 0) return null;

  return (
    <div className="space-y-6">
      {sorted.map((content) => (
        <div key={content.id}>
          {content.contentType === "TEXT" && content.body && (
            <div className="prose prose-sm max-w-none">
              <div className="flex items-center gap-2 text-xs text-muted-foreground mb-2">
                <FileText className="h-3.5 w-3.5" /> Текст
              </div>
              <div className="whitespace-pre-wrap text-sm leading-relaxed">{content.body}</div>
            </div>
          )}

          {content.contentType === "VIDEO" && content.videoUrl && (
            <div className="space-y-2">
              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <Video className="h-3.5 w-3.5" /> Видео
              </div>
              <div className="aspect-video rounded-lg overflow-hidden bg-black">
                <iframe
                  src={content.videoUrl}
                  title="Видео урока"
                  className="h-full w-full"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
            </div>
          )}

          {content.contentType === "CODE_BLOCK" && content.body && (
            <div className="space-y-2">
              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <Code className="h-3.5 w-3.5" /> Код
              </div>
              <pre className="bg-muted rounded-lg p-4 overflow-x-auto text-sm">
                <code>{content.body}</code>
              </pre>
            </div>
          )}
        </div>
      ))}
    </div>
  );
}
