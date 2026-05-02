import { useParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { getUserProfile } from "@/api/users.api";
import { getUserBadges } from "@/api/gamification.api";
import { UserAvatar } from "@/components/shared/UserAvatar";
import { BadgeIcon } from "@/components/shared/BadgeIcon";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";

export function PublicProfilePage() {
  const { id } = useParams<{ id: string }>();
  const { data: profile, isLoading } = useQuery({
    queryKey: ["userProfile", id],
    queryFn: () => getUserProfile(id!),
    enabled: !!id,
  });
  const { data: badges } = useQuery({
    queryKey: ["userBadges", id],
    queryFn: () => getUserBadges(id!),
    enabled: !!id,
  });

  if (isLoading) return <LoadingSpinner className="py-20" />;
  if (!profile) return <p className="text-muted-foreground">Profile not found</p>;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <UserAvatar
          avatarUrl={profile.avatarUrl}
          displayName={profile.displayName}
          size="lg"
        />
        <div>
          <h1 className="text-2xl font-bold">
            {profile.displayName || "User"}
          </h1>
        </div>
      </div>

      {profile.bio && (
        <div className="rounded-lg border p-4">
          <h2 className="text-lg font-semibold mb-2">About</h2>
          <p className="text-sm text-muted-foreground">{profile.bio}</p>
        </div>
      )}

      {badges && badges.length > 0 && (
        <div className="rounded-lg border p-4">
          <h2 className="text-lg font-semibold mb-3">Badges</h2>
          <div className="flex flex-wrap gap-3">
            {badges.map((b) => (
              <div key={b.badgeId} className="flex flex-col items-center gap-1">
                <BadgeIcon name={b.name} iconUrl={b.iconUrl} />
                <span className="text-xs text-muted-foreground">{b.name}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
