export interface QuizQuestion {
  question: string;
  options: string[];
  correct: number[];
}

export interface CreateQuizRequest {
  title?: string;
  timeLimit?: number;
  xpReward?: number;
  questions: QuizQuestion[];
}

export interface QuizQuestionResponse {
  id: string;
  question: string;
  options: string[];
  sortOrder: number;
}

export interface QuizResponse {
  id: string;
  lessonId: string;
  title: string | null;
  timeLimit: number | null;
  xpReward: number;
  questions: QuizQuestionResponse[];
}

export interface QuizBriefResponse {
  id: string;
  title: string | null;
  timeLimit: number | null;
  xpReward: number;
  questionCount: number;
}

export interface QuizSubmitRequest {
  answers: Record<string, number[]>;
}

export interface QuizAttempt {
  id: string;
  quizId: string;
  score: number;
  passed: boolean;
  xpAwarded: number;
}
