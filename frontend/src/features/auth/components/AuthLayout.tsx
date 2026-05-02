import type { ReactNode } from "react";
import { GraduationCap, Zap, Trophy, Star } from "lucide-react";

interface AuthLayoutProps {
  children: ReactNode;
}

const features = [
  { icon: GraduationCap, text: "Structured courses from practitioners" },
  { icon: Zap, text: "Earn XP for every lesson" },
  { icon: Trophy, text: "Compete on the leaderboard" },
  { icon: Star, text: "Earn badges for achievements" },
];

export function AuthLayout({ children }: AuthLayoutProps) {
  return (
    <div className="min-h-screen flex">
      {/* Left panel — branded (desktop only) */}
      <div
        className="hidden lg:flex lg:w-1/2 flex-col justify-between p-12 relative overflow-hidden"
        style={{
          background:
            "linear-gradient(135deg, hsl(243 60% 18%) 0%, hsl(262 65% 22%) 55%, hsl(224 40% 8%) 100%)",
        }}
      >
        {/* Dot grid pattern */}
        <div
          className="absolute inset-0 opacity-10"
          style={{
            backgroundImage:
              "radial-gradient(circle, rgba(255,255,255,0.6) 1px, transparent 1px)",
            backgroundSize: "28px 28px",
          }}
        />

        {/* Glow blobs */}
        <div
          className="absolute top-1/3 left-1/4 w-64 h-64 rounded-full pointer-events-none"
          style={{
            background: "radial-gradient(circle, hsl(262 90% 68% / 0.2) 0%, transparent 70%)",
          }}
        />
        <div
          className="absolute bottom-1/4 right-1/4 w-48 h-48 rounded-full pointer-events-none"
          style={{
            background: "radial-gradient(circle, hsl(38 92% 50% / 0.15) 0%, transparent 70%)",
          }}
        />

        <div className="relative z-10">
          {/* Logo */}
          <div className="flex items-center gap-3 mb-12">
            <div className="p-2 rounded-xl bg-white/10 backdrop-blur">
              <GraduationCap className="h-7 w-7 text-white" />
            </div>
            <span
              className="text-2xl font-bold text-white"
              style={{ fontFamily: "var(--font-display)" }}
            >
              EduQuest
            </span>
          </div>

          <h2
            className="text-4xl font-bold text-white leading-tight mb-4"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Learn. Grow.
            <br />
            <span style={{ color: "hsl(38 92% 60%)" }}>Win.</span>
          </h2>
          <p className="text-white/60 text-base max-w-xs leading-relaxed">
            A gamified educational platform where every lesson is a step to the next level.
          </p>
        </div>

        <div className="relative z-10 space-y-3">
          {features.map(({ icon: Icon, text }) => (
            <div key={text} className="flex items-center gap-3 text-white/75">
              <div className="p-1.5 rounded-lg bg-white/10 shrink-0">
                <Icon className="h-4 w-4" />
              </div>
              <span className="text-sm">{text}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Right panel — form */}
      <div className="flex flex-1 flex-col items-center justify-center px-6 py-12 bg-background">
        {/* Mobile logo */}
        <div className="flex items-center gap-2 mb-8 lg:hidden">
          <GraduationCap className="h-6 w-6 text-primary" />
          <span className="text-xl font-bold" style={{ fontFamily: "var(--font-display)" }}>
            EduQuest
          </span>
        </div>

        <div className="w-full max-w-sm">{children}</div>
      </div>
    </div>
  );
}
