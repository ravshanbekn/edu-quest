import { Link } from "react-router-dom";
import type { CourseResponse } from "@/types/course.types";

const GRADIENTS = [
  "from-violet-500 to-indigo-600",
  "from-amber-400 to-orange-500",
  "from-emerald-400 to-teal-600",
  "from-rose-400 to-pink-600",
  "from-sky-400 to-blue-600",
  "from-fuchsia-500 to-purple-600",
];

function getCourseGradient(title: string): string {
  let hash = 0;
  for (let i = 0; i < title.length; i++) {
    hash = (hash * 31 + title.charCodeAt(i)) >>> 0;
  }
  return GRADIENTS[hash % GRADIENTS.length];
}

interface CourseCardProps {
  course: CourseResponse;
}

export function CourseCard({ course }: CourseCardProps) {
  const gradient = getCourseGradient(course.title);
  const initial = course.title.trim()[0]?.toUpperCase() ?? "?";

  return (
    <Link
      to={`/courses/${course.id}`}
      className="group block rounded-lg border bg-card shadow-sm hover:shadow-md transition-all duration-200 overflow-hidden hover:-translate-y-0.5"
    >
      {/* Cover */}
      <div className="aspect-video overflow-hidden">
        {course.coverUrl ? (
          <img
            src={course.coverUrl}
            alt={course.title}
            className="h-full w-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
        ) : (
          <div
            className={`h-full w-full bg-gradient-to-br ${gradient} flex items-center justify-center`}
          >
            <span className="text-5xl font-bold text-white/80 select-none" style={{ fontFamily: "var(--font-display)" }}>
              {initial}
            </span>
          </div>
        )}
      </div>

      {/* Info */}
      <div className="p-4 space-y-2">
        <h3 className="font-semibold text-sm group-hover:text-primary transition-colors line-clamp-2">
          {course.title}
        </h3>
        {course.description && (
          <p className="text-xs text-muted-foreground line-clamp-2">
            {course.description}
          </p>
        )}
        {!course.published && (
          <span className="inline-block text-xs bg-muted text-muted-foreground px-2 py-0.5 rounded">
            Draft
          </span>
        )}
      </div>
    </Link>
  );
}
