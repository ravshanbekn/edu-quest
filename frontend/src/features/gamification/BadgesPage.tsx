import { useQuery } from "@tanstack/react-query";
import { Award } from "lucide-react";
import { getMyBadges } from "@/api/gamification.api";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { EmptyState } from "@/components/shared/EmptyState";
import { BadgeIcon } from "@/components/shared/BadgeIcon";
import { usePageTitle } from "@/hooks/usePageTitle";

export function BadgesPage() {
  usePageTitle("My Badges");
  const { data: badges, isLoading } = useQuery({
    queryKey: ["myBadges"],
    queryFn: getMyBadges,
  });

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      <div className="flex items-center gap-2">
        <Award className="h-6 w-6 text-xp" />
        <h1 className="text-2xl font-bold">My Badges</h1>
      </div>

      {isLoading ? (
        <LoadingSpinner size="lg" className="py-20" />
      ) : !badges || badges.length === 0 ? (
        <EmptyState
          title="No badges yet"
          description="Complete courses and tasks to earn badges"
          icon={Award}
        />
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {badges.map((badge, i) => (
            <div
              key={badge.badgeId}
              className="border rounded-xl p-5 text-center space-y-2 bg-card
                         hover:shadow-lg hover:scale-105 hover:ring-2 hover:ring-xp/40
                         transition-all duration-200 cursor-default"
              style={{
                animation: "fadeInUp 0.4s ease both",
                animationDelay: `${i * 60}ms`,
              }}
            >
              <div className="flex justify-center mb-1">
                <div className="p-2 rounded-full bg-gradient-to-br from-amber-100 to-amber-50 dark:from-amber-900/30 dark:to-amber-800/20 ring-2 ring-xp/20">
                  <BadgeIcon name={badge.name} iconUrl={badge.iconUrl} size="lg" />
                </div>
              </div>
              <h3 className="font-bold text-sm">{badge.name}</h3>
              <p className="text-xs text-muted-foreground leading-relaxed">{badge.description}</p>
              <p className="text-xs text-muted-foreground/70">
                {new Date(badge.awardedAt).toLocaleDateString("en-US")}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
