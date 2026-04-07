import { useQuery } from "@tanstack/react-query";
import api from "@/api/client";
import { useAuthStore } from "@/stores/auth.store";
import type { UserResponse } from "@/types/user.types";

export function useCurrentUser() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);

  return useQuery<UserResponse>({
    queryKey: ["currentUser"],
    queryFn: async () => {
      const { data } = await api.get<UserResponse>("/users/me");
      return data;
    },
    enabled: isAuthenticated,
  });
}
