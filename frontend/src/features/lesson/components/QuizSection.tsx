import { useState, useEffect, useCallback } from "react";
import { useMutation } from "@tanstack/react-query";
import { Clock, CheckCircle, XCircle } from "lucide-react";
import { toast } from "sonner";
import { startQuizAttempt, submitQuizAttempt } from "@/api/quizzes.api";
import type { QuizBriefResponse, QuizQuestionResponse, QuizAttempt } from "@/types/quiz.types";

interface QuizSectionProps {
  quizzes: QuizBriefResponse[];
}

function QuizItem({ quiz }: { quiz: QuizBriefResponse }) {
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [questions, setQuestions] = useState<QuizQuestionResponse[]>([]);
  const [answers, setAnswers] = useState<Record<string, number[]>>({});
  const [result, setResult] = useState<QuizAttempt | null>(null);
  const [timeLeft, setTimeLeft] = useState<number | null>(null);

  const startMutation = useMutation({
    mutationFn: () => startQuizAttempt(quiz.id),
    onSuccess: (data) => {
      setAttemptId(data.id);
      setQuestions(data.questions);
      if (data.timeLimit) setTimeLeft(data.timeLimit);
    },
    onError: () => toast.error("Ошибка начала квиза"),
  });

  const submitMutation = useMutation({
    mutationFn: () => submitQuizAttempt(quiz.id, attemptId!, { answers }),
    onSuccess: (data) => {
      setResult(data);
      setTimeLeft(null);
      if (data.passed) toast.success(`Квиз пройден! +${data.xpAwarded} XP`);
      else toast.error("Квиз не пройден");
    },
    onError: () => toast.error("Ошибка отправки квиза"),
  });

  const handleSubmit = useCallback(() => {
    if (attemptId) submitMutation.mutate();
  }, [attemptId, answers]);

  // Timer
  useEffect(() => {
    if (timeLeft === null || timeLeft <= 0) return;
    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev === null || prev <= 1) {
          clearInterval(timer);
          handleSubmit();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [timeLeft !== null, handleSubmit]);

  const toggleOption = (questionId: string, optionIndex: number) => {
    setAnswers((prev) => {
      const current = prev[questionId] || [];
      const has = current.includes(optionIndex);
      return {
        ...prev,
        [questionId]: has
          ? current.filter((i) => i !== optionIndex)
          : [...current, optionIndex],
      };
    });
  };

  const formatTime = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m}:${s.toString().padStart(2, "0")}`;
  };

  // Not started
  if (!attemptId && !result) {
    return (
      <div className="border rounded-lg p-4 space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="font-semibold text-sm">{quiz.title || "Квиз"}</h3>
          <span className="text-xs text-amber-600">{quiz.xpReward} XP</span>
        </div>
        <div className="flex items-center gap-4 text-xs text-muted-foreground">
          <span>{quiz.questionCount} вопросов</span>
          {quiz.timeLimit && (
            <span className="flex items-center gap-1">
              <Clock className="h-3.5 w-3.5" /> {Math.floor(quiz.timeLimit / 60)} мин
            </span>
          )}
        </div>
        <button
          onClick={() => startMutation.mutate()}
          disabled={startMutation.isPending}
          className="px-4 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90 disabled:opacity-50"
        >
          {startMutation.isPending ? "Загрузка..." : "Начать квиз"}
        </button>
      </div>
    );
  }

  // Result
  if (result) {
    return (
      <div className="border rounded-lg p-4 space-y-3">
        <h3 className="font-semibold text-sm">{quiz.title || "Квиз"}</h3>
        <div className={`flex items-center gap-2 p-3 rounded-md ${
          result.passed ? "bg-green-50 text-green-700" : "bg-red-50 text-red-700"
        }`}>
          {result.passed ? <CheckCircle className="h-5 w-5" /> : <XCircle className="h-5 w-5" />}
          <div>
            <p className="font-medium">{result.passed ? "Квиз пройден!" : "Квиз не пройден"}</p>
            <p className="text-sm">Результат: {result.score}% · {result.xpAwarded > 0 ? `+${result.xpAwarded} XP` : "0 XP"}</p>
          </div>
        </div>
      </div>
    );
  }

  // In progress
  return (
    <div className="border rounded-lg p-4 space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="font-semibold text-sm">{quiz.title || "Квиз"}</h3>
        {timeLeft !== null && (
          <span className={`flex items-center gap-1 text-sm font-mono ${timeLeft < 30 ? "text-destructive" : "text-muted-foreground"}`}>
            <Clock className="h-4 w-4" /> {formatTime(timeLeft)}
          </span>
        )}
      </div>

      <div className="space-y-4">
        {questions.map((q, qIdx) => (
          <div key={q.id} className="space-y-2">
            <p className="text-sm font-medium">{qIdx + 1}. {q.question}</p>
            <div className="space-y-1 pl-4">
              {q.options.map((option, oIdx) => {
                const selected = (answers[q.id] || []).includes(oIdx);
                return (
                  <label
                    key={oIdx}
                    className={`flex items-center gap-2 p-2 rounded-md cursor-pointer text-sm transition-colors ${
                      selected ? "bg-primary/10 border border-primary/30" : "hover:bg-muted border border-transparent"
                    }`}
                  >
                    <input
                      type="checkbox"
                      checked={selected}
                      onChange={() => toggleOption(q.id, oIdx)}
                      className="rounded"
                    />
                    {option}
                  </label>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      <button
        onClick={handleSubmit}
        disabled={submitMutation.isPending}
        className="px-4 py-2 text-sm rounded-md bg-primary text-white hover:bg-primary/90 disabled:opacity-50"
      >
        {submitMutation.isPending ? "Отправка..." : "Завершить квиз"}
      </button>
    </div>
  );
}

export function QuizSection({ quizzes }: QuizSectionProps) {
  if (quizzes.length === 0) return null;

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold">Квизы</h2>
      {quizzes.map((quiz) => (
        <QuizItem key={quiz.id} quiz={quiz} />
      ))}
    </div>
  );
}
