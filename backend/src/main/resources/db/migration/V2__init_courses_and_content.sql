-- ============================================================
-- V2: Block 5.2 — Courses, Blocks, Lessons, Content, Tasks, Quizzes
-- ============================================================

-- courses
CREATE TABLE courses (
    id           BIGSERIAL    PRIMARY KEY,
    teacher_id   BIGINT       NOT NULL REFERENCES users (id),
    title        VARCHAR(255) NOT NULL,
    description  TEXT,
    cover_url    VARCHAR(500),
    is_published BOOLEAN      NOT NULL DEFAULT false,
    created_at   TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT now()
);

-- blocks (course sections)
CREATE TABLE blocks (
    id         BIGSERIAL    PRIMARY KEY,
    course_id  BIGINT       NOT NULL REFERENCES courses (id) ON DELETE CASCADE,
    title      VARCHAR(255) NOT NULL,
    sort_order INT          NOT NULL DEFAULT 0,
    created_at TIMESTAMP    NOT NULL DEFAULT now()
);

-- lessons
CREATE TABLE lessons (
    id         BIGSERIAL    PRIMARY KEY,
    block_id   BIGINT       NOT NULL REFERENCES blocks (id) ON DELETE CASCADE,
    title      VARCHAR(255) NOT NULL,
    type       VARCHAR(50)  NOT NULL DEFAULT 'MIXED',
    sort_order INT          NOT NULL DEFAULT 0,
    xp_reward  INT          NOT NULL DEFAULT 50,
    created_at TIMESTAMP    NOT NULL DEFAULT now()
);

-- lesson_content (polymorphic content blocks inside a lesson)
CREATE TABLE lesson_content (
    id           BIGSERIAL   PRIMARY KEY,
    lesson_id    BIGINT      NOT NULL REFERENCES lessons (id) ON DELETE CASCADE,
    content_type VARCHAR(50) NOT NULL,
    body         TEXT,
    video_url    VARCHAR(500),
    sort_order   INT         NOT NULL DEFAULT 0
);

-- tasks
CREATE TABLE tasks (
    id          BIGSERIAL   PRIMARY KEY,
    lesson_id   BIGINT      NOT NULL REFERENCES lessons (id) ON DELETE CASCADE,
    description TEXT        NOT NULL,
    solution    TEXT,
    task_type   VARCHAR(50) NOT NULL DEFAULT 'TEXT',
    xp_reward   INT         NOT NULL DEFAULT 75,
    sort_order  INT         NOT NULL DEFAULT 0
);

-- hints (per task)
CREATE TABLE hints (
    id         BIGSERIAL PRIMARY KEY,
    task_id    BIGINT    NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
    content    TEXT      NOT NULL,
    sort_order INT       NOT NULL DEFAULT 0,
    xp_penalty INT       NOT NULL DEFAULT 10
);

-- quizzes
CREATE TABLE quizzes (
    id         BIGSERIAL    PRIMARY KEY,
    lesson_id  BIGINT       NOT NULL REFERENCES lessons (id) ON DELETE CASCADE,
    title      VARCHAR(255),
    time_limit INT,
    xp_reward  INT          NOT NULL DEFAULT 100,
    created_at TIMESTAMP    NOT NULL DEFAULT now()
);

-- quiz_questions
CREATE TABLE quiz_questions (
    id         BIGSERIAL PRIMARY KEY,
    quiz_id    BIGINT    NOT NULL REFERENCES quizzes (id) ON DELETE CASCADE,
    question   TEXT      NOT NULL,
    options    JSONB     NOT NULL,
    correct    JSONB     NOT NULL,
    sort_order INT       NOT NULL DEFAULT 0
);

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX idx_courses_teacher   ON courses (teacher_id);
CREATE INDEX idx_blocks_course     ON blocks (course_id, sort_order);
CREATE INDEX idx_lessons_block     ON lessons (block_id, sort_order);
CREATE INDEX idx_content_lesson    ON lesson_content (lesson_id, sort_order);
CREATE INDEX idx_tasks_lesson      ON tasks (lesson_id, sort_order);
CREATE INDEX idx_hints_task        ON hints (task_id, sort_order);
CREATE INDEX idx_quizzes_lesson    ON quizzes (lesson_id);
CREATE INDEX idx_questions_quiz    ON quiz_questions (quiz_id, sort_order);
