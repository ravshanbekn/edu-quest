import { useQuery } from "@tanstack/react-query";
import { Trophy, Medal, ChevronLeft, ChevronRight } from "lucide-react";
import { Link } from "react-router-dom";
import { getLeaderboard } from "@/api/gamification.api";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { EmptyState } from "@/components/shared/EmptyState";
import { UserAvatar } from "@/components/shared/UserAvatar";
import { LevelBadge } from "@/components/shared/LevelBadge";
import { usePagination } from "@/hooks/usePagination";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { usePageTitle } from "@/hooks/usePageTitle";

const rankColors: Record<number, string> = {
  1: "text-amber-500",
  2: "text-slate-400",
  3: "text-amber-700",
};

const rankRowColors: Record<number, string> = {
  1: "bg-amber-50 dark:bg-amber-950/30",
  2: "bg-slate-50 dark:bg-slate-800/30",
  3: "bg-orange-50 dark:bg-orange-950/20",
};

export function LeaderboardPage() {
  usePageTitle("Лидерборд");
  const { page, size, setPage } = usePagination(20);
  const { data: user } = useCurrentUser();

  const { data: entries, isLoading } = useQuery({
    queryKey: ["leaderboard", page, size],
    queryFn: () => getLeaderboard({ page, size }),
  });

  const hasEntries = entries && entries.length > 0;
  const canGoPrev = page > 0;
  const canGoNext = hasEntries && entries.length === size;

  return (
    <div className="space-y-6 max-w-3xl mx-auto">
      <div className="flex items-center gap-2">
        <Trophy className="h-6 w-6 text-xp" />
        <h1 className="text-2xl font-bold">Лидерборд</h1>
      </div>

      {isLoading ? (
        <LoadingSpinner size="lg" className="py-20" />
      ) : !hasEntries ? (
        <EmptyState title="Лидерборд пуст" description="Пока никто не набрал опыт" icon={Trophy} />
      ) : (
        <>
          <div className="border rounded-lg overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-muted/50">
                <tr>
                  <th className="text-left px-4 py-3 font-medium w-16">#</th>
                  <th className="text-left px-4 py-3 font-medium">Пользователь</th>
                  <th className="text-right px-4 py-3 font-medium">Уровень</th>
                  <th className="text-right px-4 py-3 font-medium">XP</th>
                </tr>
              </thead>
              <tbody>
                {entries.map((entry) => {
                  const isMe = user?.id === entry.userId;
                  const rowColor = rankRowColors[entry.rank] ?? "";
                  return (
                    <tr
                      key={entry.userId}
                      className={`border-t transition-colors ${
                        isMe ? "bg-primary/5" : rowColor || "hover:bg-muted/30"
                      }`}
                    >
                      <td className="px-4 py-3">
                        {entry.rank <= 3 ? (
                          <Medal className={`h-5 w-5 ${rankColors[entry.rank]}`} />
                        ) : (
                          <span className="text-muted-foreground">{entry.rank}</span>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        <Link
                          to={`/users/${entry.userId}`}
                          className="flex items-center gap-2 hover:text-primary transition-colors"
                        >
                          <UserAvatar displayName={entry.displayName} size="sm" />
                          <span className={isMe ? "font-semibold" : ""}>
                            {entry.displayName}
                            {isMe && (
                              <span className="text-xs text-muted-foreground ml-1">(вы)</span>
                            )}
                          </span>
                        </Link>
                      </td>
                      <td className="px-4 py-3 text-right">
                        <LevelBadge level={entry.level} />
                      </td>
                      <td className={`px-4 py-3 text-right font-medium text-xp ${entry.rank <= 3 ? "text-base font-bold" : ""}`}>
                        {entry.totalXp.toLocaleString("ru")}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {(canGoPrev || canGoNext) && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">Страница {page + 1}</span>
              <div className="flex gap-1">
                <button
                  onClick={() => setPage(page - 1)}
                  disabled={!canGoPrev}
                  className="p-2 rounded-md hover:bg-muted disabled:opacity-30 transition-colors"
                  aria-label="Предыдущая страница"
                >
                  <ChevronLeft className="h-4 w-4" />
                </button>
                <button
                  onClick={() => setPage(page + 1)}
                  disabled={!canGoNext}
                  className="p-2 rounded-md hover:bg-muted disabled:opacity-30 transition-colors"
                  aria-label="Следующая страница"
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
