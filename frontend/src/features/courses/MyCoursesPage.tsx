import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { Plus, BookOpen } from "lucide-react";
import { getMyEnrollments } from "@/api/enrollments.api";
import { getCourses } from "@/api/courses.api";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";
import { EmptyState } from "@/components/shared/EmptyState";
import { usePagination } from "@/hooks/usePagination";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { usePageTitle } from "@/hooks/usePageTitle";
import { ENROLLMENT_STATUS_LABELS } from "@/lib/constants";

export function MyCoursesPage() {
  usePageTitle("Мои курсы");
  const { data: user } = useCurrentUser();
  const isTeacher = user?.roles.some((r) => r === "TEACHER" || r === "ADMIN");
  const isStudent = user?.roles.includes("STUDENT");

  const enrollPagination = usePagination();
  const teacherPagination = usePagination();

  // Student: enrolled courses
  const { data: enrollments, isLoading: loadingEnrollments } = useQuery({
    queryKey: ["myEnrollments", enrollPagination.page, enrollPagination.size],
    queryFn: () => getMyEnrollments({ page: enrollPagination.page, size: enrollPagination.size }),
    enabled: !!isStudent,
  });

  // Teacher: own courses (filter by teacherId on client)
  const { data: allCourses, isLoading: loadingCourses } = useQuery({
    queryKey: ["courses", "teacher", teacherPagination.page, teacherPagination.size],
    queryFn: () => getCourses({ page: teacherPagination.page, size: 100 }),
    enabled: !!isTeacher,
  });

  const myCourses = allCourses?.content.filter((c) => c.teacherId === user?.id) || [];
  const isLoading = loadingEnrollments || loadingCourses;

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Мои курсы</h1>
        {isTeacher && (
          <Link
            to="/courses/create"
            className="flex items-center gap-2 px-4 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90"
          >
            <Plus className="h-4 w-4" /> Создать курс
          </Link>
        )}
      </div>

      {isLoading ? (
        <LoadingSpinner size="lg" className="py-20" />
      ) : (
        <div className="space-y-8">
          {/* Teacher's courses */}
          {isTeacher && (
            <section className="space-y-3">
              <h2 className="text-lg font-semibold">Мои курсы (преподаватель)</h2>
              {myCourses.length === 0 ? (
                <EmptyState
                  title="Вы ещё не создали курсов"
                  description="Создайте свой первый курс"
                  icon={BookOpen}
                />
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {myCourses.map((course) => (
                    <Link
                      key={course.id}
                      to={`/courses/${course.id}`}
                      className="block rounded-lg border bg-card shadow-sm hover:shadow-md transition-shadow p-4 space-y-2"
                    >
                      <h3 className="font-semibold text-sm hover:text-primary transition-colors">
                        {course.title}
                      </h3>
                      {course.description && (
                        <p className="text-xs text-muted-foreground line-clamp-2">{course.description}</p>
                      )}
                      <div className="flex items-center gap-2">
                        {course.published ? (
                          <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded">Опубликован</span>
                        ) : (
                          <span className="text-xs bg-muted px-2 py-0.5 rounded">Черновик</span>
                        )}
                      </div>
                    </Link>
                  ))}
                </div>
              )}
            </section>
          )}

          {/* Student's enrolled courses */}
          {isStudent && (
            <section className="space-y-3">
              <h2 className="text-lg font-semibold">Записи на курсы</h2>
              {!enrollments || enrollments.empty ? (
                <EmptyState
                  title="Вы ещё не записаны на курсы"
                  description="Перейдите в каталог, чтобы найти интересный курс"
                  icon={BookOpen}
                >
                  <Link
                    to="/courses"
                    className="px-4 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90"
                  >
                    Перейти в каталог
                  </Link>
                </EmptyState>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {enrollments.content.map((enrollment) => (
                    <Link
                      key={enrollment.id}
                      to={`/courses/${enrollment.courseId}`}
                      className="block rounded-lg border bg-card shadow-sm hover:shadow-md transition-shadow p-4 space-y-2"
                    >
                      <h3 className="font-semibold text-sm hover:text-primary transition-colors">
                        {enrollment.courseTitle}
                      </h3>
                      <div className="flex items-center gap-2 text-xs text-muted-foreground">
                        <span className={
                          enrollment.status === "COMPLETED" ? "text-green-600" :
                          enrollment.status === "DROPPED" ? "text-destructive" : ""
                        }>
                          {ENROLLMENT_STATUS_LABELS[enrollment.status] ?? enrollment.status}
                        </span>
                        <span>· {new Date(enrollment.enrolledAt).toLocaleDateString("ru-RU")}</span>
                      </div>
                    </Link>
                  ))}
                </div>
              )}
            </section>
          )}
        </div>
      )}
    </div>
  );
}
