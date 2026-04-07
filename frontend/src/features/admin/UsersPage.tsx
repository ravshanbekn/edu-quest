import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Shield, UserCog } from "lucide-react";
import { toast } from "sonner";
import { getUsers, updateUserRoles } from "@/api/users.api";
import { DataTable } from "@/components/shared/DataTable";
import { usePagination } from "@/hooks/usePagination";
import type { UserResponse } from "@/types/user.types";

const ALL_ROLES = ["STUDENT", "TEACHER", "ADMIN"] as const;

function RoleEditor({ user, onClose }: { user: UserResponse; onClose: () => void }) {
  const queryClient = useQueryClient();
  const [selectedRoles, setSelectedRoles] = useState<string[]>(user.roles);

  const mutation = useMutation({
    mutationFn: () => updateUserRoles(user.id, selectedRoles),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["adminUsers"] });
      toast.success("Роли обновлены");
      onClose();
    },
    onError: () => toast.error("Ошибка обновления ролей"),
  });

  const toggleRole = (role: string) => {
    setSelectedRoles((prev) =>
      prev.includes(role) ? prev.filter((r) => r !== role) : [...prev, role]
    );
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black/50" onClick={onClose} />
      <div className="relative bg-background rounded-lg border shadow-lg p-6 w-full max-w-sm mx-4 space-y-4">
        <h2 className="text-lg font-semibold">Роли: {user.email}</h2>
        <div className="space-y-2">
          {ALL_ROLES.map((role) => (
            <label key={role} className="flex items-center gap-2 text-sm cursor-pointer">
              <input
                type="checkbox"
                checked={selectedRoles.includes(role)}
                onChange={() => toggleRole(role)}
                className="rounded"
              />
              {role}
            </label>
          ))}
        </div>
        <div className="flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 text-sm rounded-md border hover:bg-muted">
            Отмена
          </button>
          <button
            onClick={() => mutation.mutate()}
            disabled={mutation.isPending || selectedRoles.length === 0}
            className="px-4 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90 disabled:opacity-50"
          >
            {mutation.isPending ? "..." : "Сохранить"}
          </button>
        </div>
      </div>
    </div>
  );
}

export function UsersPage() {
  const { page, size, setPage } = usePagination();
  const [editingUser, setEditingUser] = useState<UserResponse | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["adminUsers", page, size],
    queryFn: () => getUsers({ page, size, sort: "createdAt,desc" }),
  });

  const columns = [
    {
      key: "email",
      header: "Email",
      render: (user: UserResponse) => <span className="text-sm">{user.email}</span>,
    },
    {
      key: "roles",
      header: "Роли",
      render: (user: UserResponse) => (
        <div className="flex gap-1">
          {user.roles.map((role) => (
            <span key={role} className="text-xs bg-muted px-2 py-0.5 rounded">
              {role}
            </span>
          ))}
        </div>
      ),
    },
    {
      key: "active",
      header: "Статус",
      render: (user: UserResponse) => (
        <span className={`text-xs ${user.active ? "text-green-600" : "text-red-500"}`}>
          {user.active ? "Активен" : "Неактивен"}
        </span>
      ),
    },
    {
      key: "createdAt",
      header: "Регистрация",
      render: (user: UserResponse) => (
        <span className="text-xs text-muted-foreground">
          {new Date(user.createdAt).toLocaleDateString("ru-RU")}
        </span>
      ),
    },
    {
      key: "actions",
      header: "",
      render: (user: UserResponse) => (
        <button
          onClick={() => setEditingUser(user)}
          className="p-1 rounded hover:bg-muted"
          title="Изменить роли"
        >
          <UserCog className="h-4 w-4 text-muted-foreground" />
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6 max-w-5xl mx-auto">
      <div className="flex items-center gap-2">
        <Shield className="h-6 w-6 text-primary" />
        <h1 className="text-2xl font-bold">Управление пользователями</h1>
      </div>

      <DataTable
        data={data}
        columns={columns}
        isLoading={isLoading}
        onPageChange={setPage}
      />

      {editingUser && (
        <RoleEditor user={editingUser} onClose={() => setEditingUser(null)} />
      )}
    </div>
  );
}
