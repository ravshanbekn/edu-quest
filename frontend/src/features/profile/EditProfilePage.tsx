import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";
import { useCurrentUser } from "@/hooks/useCurrentUser";
import { getUserProfile, updateProfile, uploadAvatar } from "@/api/users.api";
import { UserAvatar } from "@/components/shared/UserAvatar";
import { LoadingSpinner } from "@/components/shared/LoadingSpinner";

const schema = z.object({
  displayName: z.string().max(100, "Максимум 100 символов").optional(),
  bio: z.string().max(500, "Максимум 500 символов").optional(),
  isPublic: z.boolean(),
});

type FormValues = z.infer<typeof schema>;

export function EditProfilePage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { data: user } = useCurrentUser();
  const { data: profile, isLoading } = useQuery({
    queryKey: ["myProfile"],
    queryFn: () => getUserProfile(user!.id),
    enabled: !!user,
  });

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    values: {
      displayName: profile?.displayName ?? "",
      bio: profile?.bio ?? "",
      isPublic: profile?.isPublic ?? true,
    },
  });

  const mutation = useMutation({
    mutationFn: updateProfile,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["myProfile"] });
      toast.success("Профиль обновлён");
      navigate("/profile");
    },
    onError: () => toast.error("Ошибка обновления профиля"),
  });

  const avatarMutation = useMutation({
    mutationFn: uploadAvatar,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["myProfile"] });
      toast.success("Аватар обновлён");
    },
    onError: () => toast.error("Ошибка загрузки аватара"),
  });

  if (isLoading) return <LoadingSpinner className="py-20" />;

  return (
    <div className="max-w-lg space-y-6">
      <h1 className="text-2xl font-bold">Редактирование профиля</h1>

      <div className="flex items-center gap-4">
        <UserAvatar
          avatarUrl={profile?.avatarUrl}
          displayName={profile?.displayName}
          size="lg"
        />
        <label className="cursor-pointer px-3 py-2 text-sm border rounded-md hover:bg-muted">
          Загрузить аватар
          <input
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) avatarMutation.mutate(file);
            }}
          />
        </label>
      </div>

      <form
        onSubmit={handleSubmit((data) => mutation.mutate(data))}
        className="space-y-4"
      >
        <div className="space-y-2">
          <label className="text-sm font-medium">Имя</label>
          <input
            type="text"
            className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
            {...register("displayName")}
          />
          {errors.displayName && (
            <p className="text-xs text-destructive">{errors.displayName.message}</p>
          )}
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium">О себе</label>
          <textarea
            rows={4}
            className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-ring resize-none"
            {...register("bio")}
          />
          {errors.bio && (
            <p className="text-xs text-destructive">{errors.bio.message}</p>
          )}
        </div>

        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" {...register("isPublic")} className="rounded" />
          Публичный профиль
        </label>

        <div className="flex gap-2">
          <button
            type="submit"
            disabled={mutation.isPending}
            className="px-4 py-2 text-sm rounded-md bg-primary text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {mutation.isPending ? "Сохранение..." : "Сохранить"}
          </button>
          <button
            type="button"
            onClick={() => navigate("/profile")}
            className="px-4 py-2 text-sm rounded-md border hover:bg-muted"
          >
            Отмена
          </button>
        </div>
      </form>
    </div>
  );
}
