import { useQuery } from "@tanstack/react-query";
import { History, TrendingUp, TrendingDown } from "lucide-react";
import { getXpHistory } from "@/api/gamification.api";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { EmptyState } from "@/components/shared/EmptyState";
import { usePagination } from "@/hooks/usePagination";
import { ChevronLeft, ChevronRight } from "lucide-react";
import type { ActionType } from "@/types/common.types";
import { usePageTitle } from "@/hooks/usePageTitle";

const actionLabels: Record<ActionType, string> = {
  LESSON_COMPLETE: "Lesson completed",
  TASK_SOLVED: "Task solved",
  QUIZ_PASSED: "Quiz passed",
  HINT_USED: "Hint used",
  BLOCK_COMPLETE: "Block completed",
  COURSE_COMPLETE: "Course completed",
  DAILY_LOGIN: "Daily login",
};

export function XpHistoryPage() {
  usePageTitle("XP History");
  const { page, size, setPage } = usePagination();

  const { data, isLoading } = useQuery({
    queryKey: ["xpHistory", page, size],
    queryFn: () => getXpHistory({ page, size, sort: "createdAt,desc" }),
  });

  return (
    <div className="space-y-6 max-w-3xl mx-auto">
      <div className="flex items-center gap-2">
        <History className="h-6 w-6 text-primary" />
        <h1 className="text-2xl font-bold">XP History</h1>
      </div>

      {isLoading ? (
        <LoadingSpinner size="lg" className="py-20" />
      ) : !data || data.empty ? (
        <EmptyState
          title="No history yet"
          description="Start completing courses to earn XP"
          icon={History}
        />
      ) : (
        <>
          <div className="border rounded-lg divide-y">
            {data.content.map((entry) => {
              const positive = entry.xpAmount > 0;
              return (
                <div key={entry.id} className="flex items-center gap-3 px-4 py-3">
                  {positive ? (
                    <TrendingUp className="h-4 w-4 text-green-600 shrink-0" />
                  ) : (
                    <TrendingDown className="h-4 w-4 text-red-500 shrink-0" />
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium">{actionLabels[entry.actionType] || entry.actionType}</p>
                    <p className="text-xs text-muted-foreground">
                      {new Date(entry.createdAt).toLocaleString("en-US")}
                    </p>
                  </div>
                  <span className={`text-sm font-semibold ${positive ? "text-green-600" : "text-red-500"}`}>
                    {positive ? "+" : ""}{entry.xpAmount} XP
                  </span>
                </div>
              );
            })}
          </div>

          {data.totalPages > 1 && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">
                Page {data.number + 1} of {data.totalPages}
              </span>
              <div className="flex gap-1">
                <button
                  onClick={() => setPage(page - 1)}
                  disabled={data.first}
                  className="p-2 rounded-md hover:bg-muted disabled:opacity-30"
                >
                  <ChevronLeft className="h-4 w-4" />
                </button>
                <button
                  onClick={() => setPage(page + 1)}
                  disabled={data.last}
                  className="p-2 rounded-md hover:bg-muted disabled:opacity-30"
                >
                  <ChevronRight className="h-4 w-4" />
                </button>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
