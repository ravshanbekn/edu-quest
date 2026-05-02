import { cn } from "@/lib/utils";

interface XpBarProps {
  currentXp: number;
  xpForNextLevel: number;
  level: number;
  className?: string;
}

export function XpBar({ currentXp, xpForNextLevel, level, className }: XpBarProps) {
  const progress = xpForNextLevel > 0 ? Math.min((currentXp / xpForNextLevel) * 100, 100) : 0;

  return (
    <div className={cn("space-y-2", className)}>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-level text-level-foreground">
            Lvl. {level}
          </span>
        </div>
        <span className="text-xs text-muted-foreground">
          {currentXp.toLocaleString("en")} / {xpForNextLevel.toLocaleString("en")} XP
        </span>
      </div>

      {/* Progress track */}
      <div className="h-3 bg-muted rounded-full overflow-hidden relative">
        <div
          className="h-full rounded-full transition-all duration-700 ease-out relative overflow-hidden"
          style={{
            width: `${progress}%`,
            background: "linear-gradient(90deg, hsl(38 92% 45%), hsl(38 92% 58%), hsl(32 95% 55%))",
          }}
        >
          {/* Shimmer overlay */}
          <div
            className="absolute inset-0 rounded-full"
            style={{
              background:
                "linear-gradient(90deg, transparent 0%, rgba(255,255,255,0.35) 50%, transparent 100%)",
              backgroundSize: "200% 100%",
              animation: "shimmer 2s linear infinite",
            }}
          />
        </div>
      </div>
    </div>
  );
}
