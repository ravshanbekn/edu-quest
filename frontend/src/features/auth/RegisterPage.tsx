import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Link } from "react-router-dom";
import { useRegister } from "./hooks/useAuth";
import { AuthLayout } from "./components/AuthLayout";

const registerSchema = z
  .object({
    email: z.string().email("Введите корректный email"),
    displayName: z.string().max(100, "Максимум 100 символов").optional(),
    password: z.string().min(6, "Минимум 6 символов").max(128, "Максимум 128 символов"),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Пароли не совпадают",
    path: ["confirmPassword"],
  });

type RegisterForm = z.infer<typeof registerSchema>;

const inputClass =
  "w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring transition-shadow";

export function RegisterPage() {
  const { mutate, isPending } = useRegister();
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterForm>({
    resolver: zodResolver(registerSchema),
  });

  return (
    <AuthLayout>
      <div className="space-y-6" style={{ animation: "fadeIn 0.35s ease" }}>
        <div className="space-y-1">
          <h1 className="text-2xl font-bold">Создать аккаунт</h1>
          <p className="text-sm text-muted-foreground">Начните свой путь в EduQuest</p>
        </div>

        <form
          onSubmit={handleSubmit(({ email, password, displayName }) =>
            mutate({ email, password, displayName: displayName || undefined })
          )}
          className="space-y-4"
        >
          <div className="space-y-1.5">
            <label htmlFor="email" className="text-sm font-medium">
              Email
            </label>
            <input
              id="email"
              type="email"
              placeholder="example@mail.com"
              className={inputClass}
              {...register("email")}
            />
            {errors.email && (
              <p className="text-xs text-destructive">{errors.email.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <label htmlFor="displayName" className="text-sm font-medium">
              Имя{" "}
              <span className="text-muted-foreground font-normal">(необязательно)</span>
            </label>
            <input
              id="displayName"
              type="text"
              placeholder="Ваше имя"
              className={inputClass}
              {...register("displayName")}
            />
            {errors.displayName && (
              <p className="text-xs text-destructive">{errors.displayName.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <label htmlFor="password" className="text-sm font-medium">
              Пароль
            </label>
            <input
              id="password"
              type="password"
              placeholder="Минимум 6 символов"
              className={inputClass}
              {...register("password")}
            />
            {errors.password && (
              <p className="text-xs text-destructive">{errors.password.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <label htmlFor="confirmPassword" className="text-sm font-medium">
              Подтвердите пароль
            </label>
            <input
              id="confirmPassword"
              type="password"
              placeholder="Повторите пароль"
              className={inputClass}
              {...register("confirmPassword")}
            />
            {errors.confirmPassword && (
              <p className="text-xs text-destructive">{errors.confirmPassword.message}</p>
            )}
          </div>

          <button
            type="submit"
            disabled={isPending}
            className="w-full rounded-lg bg-primary px-4 py-2.5 text-sm font-semibold text-primary-foreground hover:bg-primary/90 disabled:opacity-50 transition-colors mt-2"
          >
            {isPending ? "Создаём аккаунт..." : "Зарегистрироваться"}
          </button>
        </form>

        <p className="text-center text-sm text-muted-foreground">
          Уже есть аккаунт?{" "}
          <Link to="/login" className="text-primary font-medium hover:underline">
            Войти
          </Link>
        </p>
      </div>
    </AuthLayout>
  );
}
