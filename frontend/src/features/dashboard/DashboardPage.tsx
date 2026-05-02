import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { BookOpen, Trophy, Award } from "lucide-react";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { getMyXp } from "@/api/gamification.api";
import { getMyEnrollments } from "@/api/enrollments.api";
import { getMyProfile } from "@/api/users.api";
import { XpBar } from "@/components/shared/XpBar";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { EmptyState } from "@/components/shared/EmptyState";
import { usePageTitle } from "@/hooks/usePageTitle";
import { ENROLLMENT_STATUS_LABELS } from "@/lib/constants";

export function DashboardPage() {
  usePageTitle("Home");
  const { data: user } = useCurrentUser();
  const { data: profile } = useQuery({
    queryKey: ["myProfile"],
    queryFn: getMyProfile,
    enabled: !!user,
  });
  const { data: xp } = useQuery({
    queryKey: ["myXp"],
    queryFn: getMyXp,
  });
  const { data: enrollments, isLoading } = useQuery({
    queryKey: ["myEnrollments", { page: 0, size: 5 }],
    queryFn: () => getMyEnrollments({ page: 0, size: 5 }),
  });

  const displayName = profile?.displayName ?? user?.email ?? "Student";

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">
          Hello, {displayName}!
        </h1>
        <p className="text-muted-foreground text-sm mt-1">Your learning progress</p>
      </div>

      {/* XP card */}
      {xp && (
        <div className="rounded-lg border p-4 space-y-3">
          <div className="flex items-center gap-3">
            <Trophy className="h-5 w-5 text-xp" />
            <span className="font-semibold">Your XP</span>
            <span className="ml-auto text-sm text-muted-foreground font-medium">
              {xp.totalXp.toLocaleString("en")} XP
            </span>
          </div>
          <XpBar
            currentXp={xp.totalXp % xp.xpForNextLevel}
            xpForNextLevel={xp.xpForNextLevel}
            level={xp.currentLevel}
          />
        </div>
      )}

      {/* Quick links */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Link
          to="/courses"
          className="flex items-center gap-3 p-4 rounded-lg border hover:bg-muted/50 transition-colors"
        >
          <BookOpen className="h-5 w-5 text-primary" />
          <span className="text-sm font-medium">Course catalog</span>
        </Link>
        <Link
          to="/leaderboard"
          className="flex items-center gap-3 p-4 rounded-lg border hover:bg-muted/50 transition-colors"
        >
          <Trophy className="h-5 w-5 text-xp" />
          <span className="text-sm font-medium">Leaderboard</span>
        </Link>
        <Link
          to="/badges"
          className="flex items-center gap-3 p-4 rounded-lg border hover:bg-muted/50 transition-colors"
        >
          <Award className="h-5 w-5 text-level" />
          <span className="text-sm font-medium">Badges</span>
        </Link>
      </div>

      {/* Recent enrollments */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold">My courses</h2>
        {isLoading ? (
          <LoadingSpinner />
        ) : enrollments && enrollments.content.length > 0 ? (
          <div className="text-sm text-muted-foreground space-y-2">
            {enrollments.content.map((e) => (
              <Link
                key={e.id}
                to={`/courses/${e.courseId}`}
                className="block p-3 rounded-lg border hover:bg-muted/50 transition-colors"
              >
                <div className="font-medium text-foreground">{e.courseTitle}</div>
                <div className="text-xs mt-1">
                  Status:{" "}
                  <span className="font-medium">
                    {ENROLLMENT_STATUS_LABELS[e.status] ?? e.status}
                  </span>{" "}
                  &middot; Enrolled:{" "}
                  {new Date(e.enrolledAt).toLocaleDateString("en")}
                </div>
              </Link>
            ))}
            <Link to="/my-courses" className="text-primary text-xs hover:underline">
              All courses &rarr;
            </Link>
          </div>
        ) : (
          <EmptyState
            title="You are not enrolled in any courses"
            description="Open the catalog and choose a course to start learning"
          />
        )}
      </div>
    </div>
  );
}
