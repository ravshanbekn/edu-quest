-- ============================================================
-- V5: Seed mock data — Math course with blocks, lessons,
--     video content, tasks, and hints
-- ============================================================

-- ============================================================
-- 1. Users: teacher + student (password = "password123")
-- ============================================================
INSERT INTO users (email, password_hash) VALUES
    ('teacher@eduquest.kz', '{noop}password123'),
    ('student@eduquest.kz', '{noop}password123')
ON CONFLICT (email) DO NOTHING;

-- Profiles
INSERT INTO user_profiles (user_id, display_name, bio) VALUES
    ((SELECT id FROM users WHERE email = 'teacher@eduquest.kz'), 'Айгуль Математикова', 'Преподаватель математики, 10 лет опыта'),
    ((SELECT id FROM users WHERE email = 'student@eduquest.kz'), 'Арман Студентов', 'Студент 1 курса')
ON CONFLICT (user_id) DO NOTHING;

-- Assign roles
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r WHERE u.email = 'teacher@eduquest.kz' AND r.name = 'TEACHER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r WHERE u.email = 'student@eduquest.kz' AND r.name = 'STUDENT'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. Course: Основы математики
-- ============================================================
INSERT INTO courses (teacher_id, title, description, is_published) VALUES
    ((SELECT id FROM users WHERE email = 'teacher@eduquest.kz'),
     'Основы математики',
     'Краткий курс по основам арифметики и алгебры. Подходит для начинающих.',
     true);

-- ============================================================
-- 3. Blocks (2 блока)
-- ============================================================
INSERT INTO blocks (course_id, title, sort_order) VALUES
    ((SELECT id FROM courses WHERE title = 'Основы математики'), 'Блок 1: Арифметика', 0),
    ((SELECT id FROM courses WHERE title = 'Основы математики'), 'Блок 2: Основы алгебры', 1);

-- ============================================================
-- 4. Lessons (2 урока в каждом блоке = 4 урока)
-- ============================================================
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward) VALUES
    ((SELECT id FROM blocks WHERE title = 'Блок 1: Арифметика'), 'Сложение и вычитание', 'MIXED', 0, 50),
    ((SELECT id FROM blocks WHERE title = 'Блок 1: Арифметика'), 'Умножение и деление', 'MIXED', 1, 50),
    ((SELECT id FROM blocks WHERE title = 'Блок 2: Основы алгебры'), 'Переменные и выражения', 'MIXED', 0, 50),
    ((SELECT id FROM blocks WHERE title = 'Блок 2: Основы алгебры'), 'Линейные уравнения', 'MIXED', 1, 50);

-- ============================================================
-- 5. Lesson Content — 1 видео на каждый урок
-- ============================================================
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order) VALUES
    ((SELECT id FROM lessons WHERE title = 'Сложение и вычитание'),
     'VIDEO', 'Видеоурок: основы сложения и вычитания целых чисел.',
     'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0),
    ((SELECT id FROM lessons WHERE title = 'Умножение и деление'),
     'VIDEO', 'Видеоурок: таблица умножения и правила деления.',
     'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0),
    ((SELECT id FROM lessons WHERE title = 'Переменные и выражения'),
     'VIDEO', 'Видеоурок: что такое переменные и как составлять алгебраические выражения.',
     'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0),
    ((SELECT id FROM lessons WHERE title = 'Линейные уравнения'),
     'VIDEO', 'Видеоурок: решение линейных уравнений вида ax + b = c.',
     'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0);

-- ============================================================
-- 6. Tasks — 3 задачи на каждый урок (12 задач)
-- ============================================================

-- Урок 1: Сложение и вычитание
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order) VALUES
    ((SELECT id FROM lessons WHERE title = 'Сложение и вычитание'), 'Вычислите: 27 + 45', '72', 'TEXT', 75, 0),
    ((SELECT id FROM lessons WHERE title = 'Сложение и вычитание'), 'Вычислите: 103 - 58', '45', 'TEXT', 75, 1),
    ((SELECT id FROM lessons WHERE title = 'Сложение и вычитание'), 'Найдите значение выражения: 250 + 130 - 80', '300', 'TEXT', 75, 2);

-- Урок 2: Умножение и деление
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order) VALUES
    ((SELECT id FROM lessons WHERE title = 'Умножение и деление'), 'Вычислите: 12 × 8', '96', 'TEXT', 75, 0),
    ((SELECT id FROM lessons WHERE title = 'Умножение и деление'), 'Вычислите: 144 ÷ 12', '12', 'TEXT', 75, 1),
    ((SELECT id FROM lessons WHERE title = 'Умножение и деление'), 'Найдите значение выражения: 7 × 9 + 36 ÷ 6', '69', 'TEXT', 75, 2);

-- Урок 3: Переменные и выражения
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order) VALUES
    ((SELECT id FROM lessons WHERE title = 'Переменные и выражения'), 'Если x = 5, найдите значение выражения: 3x + 2', '17', 'TEXT', 75, 0),
    ((SELECT id FROM lessons WHERE title = 'Переменные и выражения'), 'Упростите выражение: 2a + 3a - a', '4a', 'TEXT', 75, 1),
    ((SELECT id FROM lessons WHERE title = 'Переменные и выражения'), 'Если y = 4, найдите значение: y² - 3y + 1', '5', 'TEXT', 75, 2);

-- Урок 4: Линейные уравнения
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order) VALUES
    ((SELECT id FROM lessons WHERE title = 'Линейные уравнения'), 'Решите уравнение: x + 7 = 15', '8', 'TEXT', 75, 0),
    ((SELECT id FROM lessons WHERE title = 'Линейные уравнения'), 'Решите уравнение: 3x = 21', '7', 'TEXT', 75, 1),
    ((SELECT id FROM lessons WHERE title = 'Линейные уравнения'), 'Решите уравнение: 2x + 5 = 19', '7', 'TEXT', 75, 2);

-- ============================================================
-- 7. Hints — подсказки к каждой задаче (по 2 подсказки)
-- ============================================================

-- Задача 1: 27 + 45
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 27 + 45'), 'Сложите сначала десятки: 20 + 40 = 60', 0, 10),
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 27 + 45'), 'Затем сложите единицы: 7 + 5 = 12', 1, 10);

-- Задача 2: 103 - 58
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 103 - 58'), 'Представьте 103 как 100 + 3', 0, 10),
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 103 - 58'), '100 - 58 = 42, затем прибавьте 3', 1, 10);

-- Задача 3: 250 + 130 - 80
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description LIKE '%250 + 130 - 80'), 'Сначала сложите: 250 + 130 = 380', 0, 10),
    ((SELECT id FROM tasks WHERE description LIKE '%250 + 130 - 80'), 'Затем вычтите: 380 - 80 = ?', 1, 10);

-- Задача 4: 12 × 8
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 12 × 8'), 'Разложите: 12 × 8 = (10 + 2) × 8', 0, 10),
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 12 × 8'), '10 × 8 = 80, 2 × 8 = 16. Сложите результаты.', 1, 10);

-- Задача 5: 144 ÷ 12
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 144 ÷ 12'), 'Вспомните таблицу умножения на 12', 0, 10),
    ((SELECT id FROM tasks WHERE description = 'Вычислите: 144 ÷ 12'), '12 × ? = 144. Попробуйте числа от 10 до 15.', 1, 10);

-- Задача 6: 7 × 9 + 36 ÷ 6
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description LIKE '%7 × 9 + 36 ÷ 6'), 'Помните порядок действий: сначала умножение и деление, потом сложение', 0, 10),
    ((SELECT id FROM tasks WHERE description LIKE '%7 × 9 + 36 ÷ 6'), '7 × 9 = 63, 36 ÷ 6 = 6. Теперь сложите.', 1, 10);

-- Задача 7: 3x + 2, x = 5
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description LIKE '%3x + 2'), 'Подставьте x = 5 в выражение: 3 × 5 + 2', 0, 10),
    ((SELECT id FROM tasks WHERE description LIKE '%3x + 2'), '3 × 5 = 15. Осталось прибавить 2.', 1, 10);

-- Задача 8: 2a + 3a - a
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description LIKE '%2a + 3a - a'), 'Сложите коэффициенты при одинаковых переменных', 0, 10),
    ((SELECT id FROM tasks WHERE description LIKE '%2a + 3a - a'), '2 + 3 - 1 = ?. Приписать «a» к результату.', 1, 10);

-- Задача 9: y² - 3y + 1, y = 4
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description LIKE '%y² - 3y + 1'), 'Подставьте y = 4: 4² - 3×4 + 1', 0, 10),
    ((SELECT id FROM tasks WHERE description LIKE '%y² - 3y + 1'), '16 - 12 + 1 = ?', 1, 10);

-- Задача 10: x + 7 = 15
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description = 'Решите уравнение: x + 7 = 15'), 'Перенесите 7 в правую часть с противоположным знаком', 0, 10),
    ((SELECT id FROM tasks WHERE description = 'Решите уравнение: x + 7 = 15'), 'x = 15 - 7', 1, 10);

-- Задача 11: 3x = 21
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description = 'Решите уравнение: 3x = 21'), 'Разделите обе части уравнения на коэффициент при x', 0, 10),
    ((SELECT id FROM tasks WHERE description = 'Решите уравнение: 3x = 21'), 'x = 21 ÷ 3', 1, 10);

-- Задача 12: 2x + 5 = 19
INSERT INTO hints (task_id, content, sort_order, xp_penalty) VALUES
    ((SELECT id FROM tasks WHERE description = 'Решите уравнение: 2x + 5 = 19'), 'Сначала перенесите 5 в правую часть: 2x = 19 - 5', 0, 10),
    ((SELECT id FROM tasks WHERE description = 'Решите уравнение: 2x + 5 = 19'), '2x = 14. Разделите обе части на 2.', 1, 10);

-- ============================================================
-- 8. Badge definitions
-- ============================================================
INSERT INTO badge_definitions (name, description, icon_url, condition_type, condition_value) VALUES
    ('Первые шаги',      'Завершить 1 урок',                    NULL, 'LESSONS_COMPLETED', 1),
    ('Прилежный ученик', 'Завершить 10 уроков',                 NULL, 'LESSONS_COMPLETED', 10),
    ('Мастер курса',     'Завершить любой курс на 100%',        NULL, 'COURSES_COMPLETED', 1),
    ('Стрик ×5',         '5 дней подряд заходить и учиться',    NULL, 'STREAK',            5),
    ('Стрик ×30',        '30 дней подряд',                      NULL, 'STREAK',            30),
    ('Решатель',         'Решить 50 задач',                     NULL, 'TASKS_SOLVED',      50),
    ('Снайпер',          'Пройти 10 тестов на 100%',            NULL, 'PERFECT_QUIZZES',   10),
    ('Уровень 10',       'Достичь 10 уровня',                   NULL, 'LEVEL_REACHED',     10),
    ('Уровень 25',       'Достичь 25 уровня',                   NULL, 'LEVEL_REACHED',     25),
    ('Без подсказок',    'Завершить курс без единой подсказки',  NULL, 'COURSE_NO_HINTS',   1)
ON CONFLICT (name) DO NOTHING;
