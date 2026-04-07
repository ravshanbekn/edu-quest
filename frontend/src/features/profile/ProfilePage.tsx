import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { Pencil } from "lucide-react";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { getUserProfile } from "@/api/users.api";
import { getMyXp, getMyBadges } from "@/api/gamification.api";
import { UserAvatar } from "@/components/shared/UserAvatar";
import { XpBar } from "@/components/shared/XpBar";
import { LevelBadge } from "@/components/shared/LevelBadge";
import { BadgeIcon } from "@/components/shared/BadgeIcon";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";

export function ProfilePage() {
  const { data: user, isLoading: userLoading } = useCurrentUser();
  const { data: profile, isLoading: profileLoading } = useQuery({
    queryKey: ["myProfile"],
    queryFn: () => getUserProfile(user!.id),
    enabled: !!user,
  });
  const { data: xp } = useQuery({
    queryKey: ["myXp"],
    queryFn: getMyXp,
  });
  const { data: badges } = useQuery({
    queryKey: ["myBadges"],
    queryFn: getMyBadges,
  });

  if (userLoading || !user || profileLoading) return <LoadingSpinner className="py-20" />;

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-4">
          <UserAvatar
            avatarUrl={profile?.avatarUrl}
            displayName={profile?.displayName}
            size="lg"
          />
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold">
                {profile?.displayName || user?.email}
              </h1>
              {xp && <LevelBadge level={xp.currentLevel} />}
            </div>
            <p className="text-sm text-muted-foreground">{user?.email}</p>
            <div className="flex gap-1 mt-1">
              {user?.roles.map((role) => (
                <span
                  key={role}
                  className="text-xs bg-muted px-2 py-0.5 rounded"
                >
                  {role}
                </span>
              ))}
            </div>
          </div>
        </div>
        <Link
          to="/profile/edit"
          className="flex items-center gap-1 px-3 py-2 text-sm border rounded-md hover:bg-muted"
        >
          <Pencil className="h-4 w-4" />
          Редактировать
        </Link>
      </div>

      {profile?.bio && (
        <div className="rounded-lg border p-4">
          <h2 className="text-lg font-semibold mb-2">О себе</h2>
          <p className="text-sm text-muted-foreground">{profile.bio}</p>
        </div>
      )}

      {xp && (
        <div className="rounded-lg border p-4">
          <h2 className="text-lg font-semibold mb-3">Опыт</h2>
          <XpBar
            currentXp={xp.totalXp % xp.xpForNextLevel}
            xpForNextLevel={xp.xpForNextLevel}
            level={xp.currentLevel}
          />
          <p className="text-xs text-muted-foreground mt-2">
            Всего: {xp.totalXp} XP
          </p>
        </div>
      )}

      {badges && badges.length > 0 && (
        <div className="rounded-lg border p-4">
          <h2 className="text-lg font-semibold mb-3">Бейджи</h2>
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
