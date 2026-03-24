-- ============================================================
-- V3: Block 5.3 — Enrollments, Progress, Submissions, Attempts
-- ============================================================

-- enrollments
CREATE TABLE enrollments (
    id          BIGSERIAL   PRIMARY KEY,
    user_id     BIGINT      NOT NULL REFERENCES users (id),
    course_id   BIGINT      NOT NULL REFERENCES courses (id),
    status      VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    enrolled_at TIMESTAMP   NOT NULL DEFAULT now(),
    enrolled_by BIGINT      REFERENCES users (id),
    UNIQUE (user_id, course_id)
);

-- user_progress
CREATE TABLE user_progress (
    id           BIGSERIAL   PRIMARY KEY,
    user_id      BIGINT      NOT NULL REFERENCES users (id),
    lesson_id    BIGINT      NOT NULL REFERENCES lessons (id),
    status       VARCHAR(50) NOT NULL DEFAULT 'IN_PROGRESS',
    score        INT         NOT NULL DEFAULT 0,
    hints_used   INT         NOT NULL DEFAULT 0,
    completed_at TIMESTAMP,
    UNIQUE (user_id, lesson_id)
);

-- task_submissions
CREATE TABLE task_submissions (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT    NOT NULL REFERENCES users (id),
    task_id      BIGINT    NOT NULL REFERENCES tasks (id),
    answer       TEXT      NOT NULL,
    is_correct   BOOLEAN,
    xp_earned    INT       NOT NULL DEFAULT 0,
    submitted_at TIMESTAMP NOT NULL DEFAULT now()
);

-- quiz_attempts
CREATE TABLE quiz_attempts (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT    NOT NULL REFERENCES users (id),
    quiz_id     BIGINT    NOT NULL REFERENCES quizzes (id),
    answers     JSONB     NOT NULL,
    score       INT       NOT NULL,
    max_score   INT       NOT NULL,
    xp_earned   INT       NOT NULL DEFAULT 0,
    started_at  TIMESTAMP NOT NULL DEFAULT now(),
    finished_at TIMESTAMP
);

-- ============================================================
-- Indexes (from arch doc §5.3)
-- ============================================================
CREATE INDEX idx_enrollments_user   ON enrollments (user_id, status);
CREATE INDEX idx_enrollments_course ON enrollments (course_id, status);
CREATE INDEX idx_progress_user      ON user_progress (user_id, status);
CREATE INDEX idx_submissions_user   ON task_submissions (user_id, task_id);
CREATE INDEX idx_attempts_user      ON quiz_attempts (user_id, quiz_id);
