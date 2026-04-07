import { Routes, Route, Navigate } from "react-router-dom";
import { AppLayout } from "@/components/layout/AppLayout";
import { ProtectedRoute } from "./ProtectedRoute";
import { RoleGuard } from "./RoleGuard";
import { LoginPage } from "@/features/auth/LoginPage";
import { RegisterPage } from "@/features/auth/RegisterPage";
import { DashboardPage } from "@/features/dashboard/DashboardPage";
import { ProfilePage } from "@/features/profile/ProfilePage";
import { EditProfilePage } from "@/features/profile/EditProfilePage";
import { PublicProfilePage } from "@/features/profile/PublicProfilePage";
import { CatalogPage } from "@/features/courses/CatalogPage";
import { CourseDetailPage } from "@/features/courses/CourseDetailPage";
import { CreateCoursePage } from "@/features/courses/CreateCoursePage";
import { EditCoursePage } from "@/features/courses/EditCoursePage";
import { MyCoursesPage } from "@/features/courses/MyCoursesPage";
import { LessonPage } from "@/features/lesson/LessonPage";
import { LeaderboardPage } from "@/features/gamification/LeaderboardPage";
import { BadgesPage } from "@/features/gamification/BadgesPage";
import { XpHistoryPage } from "@/features/gamification/XpHistoryPage";
import { UsersPage } from "@/features/admin/UsersPage";
import { NotFoundPage } from "@/features/errors/NotFoundPage";

export function AppRoutes() {
  return (
    <Routes>
      {/* Public routes without layout */}
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />

      {/* Routes with layout */}
      <Route element={<AppLayout />}>
        <Route element={<ProtectedRoute />}>
          <Route path="/" element={<Navigate to="/courses" replace />} />
          <Route path="/courses" element={<CatalogPage />} />
          <Route path="/courses/:id" element={<CourseDetailPage />} />
          <Route path="/leaderboard" element={<LeaderboardPage />} />
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/my-courses" element={<MyCoursesPage />} />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/profile/edit" element={<EditProfilePage />} />
          <Route path="/users/:id" element={<PublicProfilePage />} />
          <Route path="/lessons/:id" element={<LessonPage />} />
          <Route path="/badges" element={<BadgesPage />} />
          <Route path="/xp/history" element={<XpHistoryPage />} />

          {/* Teacher/Admin */}
          <Route element={<RoleGuard allowedRoles={["TEACHER", "ADMIN"]} />}>
            <Route path="/courses/create" element={<CreateCoursePage />} />
            <Route path="/courses/:id/edit" element={<EditCoursePage />} />
          </Route>

          {/* Admin only */}
          <Route element={<RoleGuard allowedRoles={["ADMIN"]} />}>
            <Route path="/admin/users" element={<UsersPage />} />
          </Route>
        </Route>

        {/* 404 */}
        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  );
}
