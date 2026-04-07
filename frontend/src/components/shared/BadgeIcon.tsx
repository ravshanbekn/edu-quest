import { Award } from "lucide-react";
import { cn } from "@/lib/utils";

interface BadgeIconProps {
  name: string;
  iconUrl?: string | null;
  size?: "sm" | "md" | "lg";
  className?: string;
}

const sizeMap = {
  sm: "h-8 w-8",
  md: "h-12 w-12",
  lg: "h-16 w-16",
};

export function BadgeIcon({ name, iconUrl, size = "md", className }: BadgeIconProps) {
  return (
    <div
      className={cn(
        "rounded-full bg-accent flex items-center justify-center overflow-hidden",
        sizeMap[size],
        className
      )}
      title={name}
    >
      {iconUrl ? (
        <img src={iconUrl} alt={name} className="h-full w-full object-cover" />
      ) : (
        <Award className="h-1/2 w-1/2 text-accent-foreground" />
      )}
    </div>
  );
}
