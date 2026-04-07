import { useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { CheckCircle, XCircle, Lightbulb, Send } from "lucide-react";
import { toast } from "sonner";
import { submitTask, revealHint } from "@/api/tasks.api";
import type { TaskResponse, Hint } from "@/types/task.types";

interface TaskSectionProps {
  tasks: TaskResponse[];
}

function TaskItem({ task }: { task: TaskResponse }) {
  const [answer, setAnswer] = useState("");
  const [result, setResult] = useState<{ correct: boolean; xpEarned: number } | null>(null);
  const [revealedHints, setRevealedHints] = useState<Hint[]>([]);
  const [nextHintIndex, setNextHintIndex] = useState(0);

  const submitMutation = useMutation({
    mutationFn: () => submitTask(task.id, { answer }),
    onSuccess: (data) => {
      setResult({ correct: data.correct, xpEarned: data.xpEarned });
      if (data.correct) {
        if (data.xpEarned === -1) toast.info("Правильно! XP уже был начислен ранее");
        else toast.success(`Правильно! +${data.xpEarned} XP`);
      } else {
        toast.error("Неправильный ответ");
      }
    },
    onError: () => toast.error("Ошибка отправки ответа"),
  });

  const hintMutation = useMutation({
    mutationFn: (hintId: string) => revealHint(task.id, hintId),
    onSuccess: (hint) => {
      setRevealedHints((prev) => [...prev, hint]);
      setNextHintIndex((prev) => prev + 1);
    },
    onError: () => toast.error("Ошибка получения подсказки"),
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!answer.trim()) return;
    submitMutation.mutate();
  };

  return (
    <div className="border rounded-lg p-4 space-y-3">
      <div className="flex items-start justify-between gap-2">
        <p className="text-sm whitespace-pre-wrap">{task.description}</p>
        <span className="text-xs text-amber-600 shrink-0">{task.xpReward} XP</span>
      </div>

      {/* Revealed hints */}
      {revealedHints.length > 0 && (
        <div className="space-y-2">
          {revealedHints.map((hint) => (
            <div key={hint.id} className="flex items-start gap-2 bg-amber-50 border border-amber-200 rounded-md p-2 text-sm">
              <Lightbulb className="h-4 w-4 text-amber-500 shrink-0 mt-0.5" />
              <div>
                <p>{hint.content}</p>
                {hint.xpPenalty > 0 && (
                  <p className="text-xs text-amber-600 mt-1">-{hint.xpPenalty} XP</p>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Result */}
      {result && (
        <div className={`flex items-center gap-2 p-2 rounded-md text-sm ${
          result.correct ? "bg-green-50 text-green-700" : "bg-red-50 text-red-700"
        }`}>
          {result.correct ? <CheckCircle className="h-4 w-4" /> : <XCircle className="h-4 w-4" />}
          {result.correct
              ? result.xpEarned === -1
                ? "Верно! XP уже был начислен ранее"
                : `Верно! +${result.xpEarned} XP`
              : "Неверно, попробуйте ещё раз"}
        </div>
      )}

      {/* Answer form */}
      {(!result || !result.correct) && (
        <form onSubmit={handleSubmit} className="space-y-2">
          {task.taskType === "CODE" ? (
            <textarea
              value={answer}
              onChange={(e) => setAnswer(e.target.value)}
              placeholder="Введите ваш код..."
              rows={4}
              className="w-full rounded-md border bg-background px-3 py-2 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary resize-none"
            />
          ) : (
            <input
              value={answer}
              onChange={(e) => setAnswer(e.target.value)}
              placeholder="Введите ответ..."
              className="w-full rounded-md border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
          )}

          <div className="flex items-center gap-2">
            <button
              type="submit"
              disabled={!answer.trim() || submitMutation.isPending}
              className="flex items-center gap-1 px-3 py-1.5 text-sm rounded-md bg-primary text-white hover:bg-primary/90 disabled:opacity-50"
            >
              <Send className="h-3.5 w-3.5" />
              {submitMutation.isPending ? "..." : "Отправить"}
            </button>

            {task.hintCount > nextHintIndex && (
              <button
                type="button"
                onClick={() => hintMutation.mutate(String(nextHintIndex))}
                disabled={hintMutation.isPending}
                className="flex items-center gap-1 px-3 py-1.5 text-sm rounded-md border hover:bg-muted disabled:opacity-50"
              >
                <Lightbulb className="h-3.5 w-3.5" />
                Подсказка ({task.hintCount - nextHintIndex})
              </button>
            )}
          </div>
        </form>
      )}
    </div>
  );
}

export function TaskSection({ tasks }: TaskSectionProps) {
  if (tasks.length === 0) return null;

  const sorted = [...tasks].sort((a, b) => a.sortOrder - b.sortOrder);

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold">Задания</h2>
      {sorted.map((task) => (
        <TaskItem key={task.id} task={task} />
      ))}
    </div>
  );
}
