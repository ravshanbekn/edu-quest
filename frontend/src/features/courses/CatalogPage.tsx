import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { Plus } from "lucide-react";
import { getCourses } from "@/api/courses.api";
import { CourseCard } from "@/components/shared/CourseCard";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { EmptyState } from "@/components/shared/EmptyState";
import { usePagination } from "@/hooks/usePagination";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { usePageTitle } from "@/hooks/usePageTitle";

export function CatalogPage() {
  usePageTitle("Course catalog");
  const { page, size, setPage } = usePagination();
  const { data: user } = useCurrentUser();

  const { data, isLoading } = useQuery({
    queryKey: ["courses", page, size],
    queryFn: () => getCourses({ page, size, sort: "createdAt,desc" }),
  });

  const canCreate = user?.roles.some((r) => r === "TEACHER" || r === "ADMIN");

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Course catalog</h1>
        {canCreate && (
          <Link
            to="/courses/create"
            className="flex items-center gap-2 px-4 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90"
          >
            <Plus className="h-4 w-4" /> Create course
          </Link>
        )}
      </div>

      {isLoading ? (
        <LoadingSpinner size="lg" className="py-20" />
      ) : !data || data.empty ? (
        <EmptyState
          title="No courses yet"
          description="Courses will appear here soon"
        />
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {data.content.map((course) => (
              <CourseCard key={course.id} course={course} />
            ))}
          </div>

          {data.totalPages > 1 && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">
                Page {data.number + 1} of {data.totalPages}
              </span>
              <div className="flex gap-1">
                <button
                  onClick={() => setPage(page - 1)}
                  disabled={data.first}
                  className="p-2 rounded-md hover:bg-muted disabled:opacity-30"
                >
                  <ChevronLeft className="h-4 w-4" />
                </button>
                <button
                  onClick={() => setPage(page + 1)}
                  disabled={data.last}
                  className="p-2 rounded-md hover:bg-muted disabled:opacity-30"
                >
                  <ChevronRight className="h-4 w-4" />
                </button>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
