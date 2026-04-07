import { cn } from "@/lib/utils";

interface LevelBadgeProps {
  level: number;
  className?: string;
}

export function LevelBadge({ level, className }: LevelBadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center justify-center rounded-full bg-level/15 text-level text-xs font-bold px-2.5 py-0.5",
        className
      )}
    >
      Lv.{level}
    </span>
  );
}
