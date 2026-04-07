import { User } from "lucide-react";
import { cn } from "@/lib/utils";

interface UserAvatarProps {
  avatarUrl?: string | null;
  displayName?: string | null;
  size?: "sm" | "md" | "lg";
  className?: string;
}

const sizeMap = {
  sm: "h-8 w-8 text-xs",
  md: "h-10 w-10 text-sm",
  lg: "h-16 w-16 text-lg",
};

export function UserAvatar({ avatarUrl, displayName, size = "md", className }: UserAvatarProps) {
  const initials = displayName
    ? displayName
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
    : null;

  return (
    <div
      className={cn(
        "rounded-full bg-muted flex items-center justify-center overflow-hidden shrink-0",
        sizeMap[size],
        className
      )}
    >
      {avatarUrl ? (
        <img src={avatarUrl} alt={displayName ?? "avatar"} className="h-full w-full object-cover" />
      ) : initials ? (
        <span className="font-medium text-muted-foreground">{initials}</span>
      ) : (
        <User className="h-1/2 w-1/2 text-muted-foreground" />
      )}
    </div>
  );
}
