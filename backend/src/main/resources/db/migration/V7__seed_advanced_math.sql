-- ============================================================
-- V7: Полный демо-датасет | Высшая математика
-- «Алгебра, Тригонометрия и Начала Анализа»
-- 4 блока · 10 уроков · 30 задач · 60 подсказок
-- 10 квизов · 50 вопросов · 3 студента с прогрессом
-- ============================================================

-- ============================================================
-- 1. ПОЛЬЗОВАТЕЛИ
-- ============================================================

INSERT INTO users (email, password_hash) VALUES
    ('admin@eduquest.kz',              '{noop}password123'),
    ('asyl.nurlanovna@eduquest.kz',    '{noop}password123'),
    ('daniyar.bekzhanov@eduquest.kz',  '{noop}password123'),
    ('zarina.alibekova@eduquest.kz',   '{noop}password123'),
    ('timur.seitkali@eduquest.kz',     '{noop}password123')
ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, display_name, bio, is_public) VALUES
    ((SELECT id FROM users WHERE email = 'admin@eduquest.kz'),
     'Администратор EduQuest',
     'Системный администратор платформы EduQuest.',
     false),
    ((SELECT id FROM users WHERE email = 'asyl.nurlanovna@eduquest.kz'),
     'Доктор Асель Нурланова',
     'Профессор математики, КазНУ. Кандидат физико-математических наук. Автор 3 учебников по высшей математике. Специализация: математический анализ и линейная алгебра.',
     true),
    ((SELECT id FROM users WHERE email = 'daniyar.bekzhanov@eduquest.kz'),
     'Данияр Бекжанов',
     'Студент 3-го курса ИТ-факультета. Увлекается прикладной математикой и машинным обучением. Цель — поступить в магистратуру по Data Science.',
     true),
    ((SELECT id FROM users WHERE email = 'zarina.alibekova@eduquest.kz'),
     'Зарина Алибекова',
     'Студентка экономического факультета. Изучает математику для финансового моделирования и Data Science.',
     true),
    ((SELECT id FROM users WHERE email = 'timur.seitkali@eduquest.kz'),
     'Тимур Сейткали',
     'Первокурсник физического факультета. Только начинаю изучать высшую математику.',
     true)
ON CONFLICT (user_id) DO NOTHING;

-- Роли
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'admin@eduquest.kz' AND r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'asyl.nurlanovna@eduquest.kz' AND r.name = 'TEACHER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email IN ('daniyar.bekzhanov@eduquest.kz','zarina.alibekova@eduquest.kz','timur.seitkali@eduquest.kz')
  AND r.name = 'STUDENT'
ON CONFLICT DO NOTHING;

-- enrollment:self для ADMIN
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.code = 'enrollment:self'
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. КУРС
-- ============================================================

INSERT INTO courses (teacher_id, title, description, is_published) VALUES
    ((SELECT id FROM users WHERE email = 'asyl.nurlanovna@eduquest.kz'),
     'Высшая математика: от алгебры до анализа',
     'Фундаментальный курс для студентов технических специальностей. '
     'Охватывает: алгебру функций, тригонометрию, пределы, производные и интегралы. '
     'Каждая тема включает теорию, видеолекцию, задачи с подсказками и тест. '
     'Уровень: продвинутый (требуется знание школьной математики на уровне ЕГЭ/ЕНТ).',
     true);

-- ============================================================
-- 3. БЛОКИ (4 блока)
-- ============================================================

INSERT INTO blocks (course_id, title, sort_order)
SELECT c.id, b.title, b.ord
FROM courses c
CROSS JOIN (VALUES
    ('Блок 1: Алгебра и функции',                     0),
    ('Блок 2: Степени, логарифмы и показательные',    1),
    ('Блок 3: Тригонометрия',                         2),
    ('Блок 4: Начала математического анализа',        3)
) AS b(title, ord)
WHERE c.title = 'Высшая математика: от алгебры до анализа';

-- ============================================================
-- 4. УРОКИ (10 уроков)
-- ============================================================

-- Блок 1: 3 урока
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Функции и их свойства',                    'THEORY',   0,  60),
    ('Квадратные уравнения и дискриминант',      'PRACTICE', 1,  80),
    ('Системы линейных уравнений',               'MIXED',    2,  90)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Блок 1: Алгебра и функции';

-- Блок 2: 2 урока
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Степени и корни: свойства и вычисления',   'THEORY',   0,  70),
    ('Логарифмы и их свойства',                  'MIXED',    1, 100)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Блок 2: Степени, логарифмы и показательные';

-- Блок 3: 2 урока
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Тригонометрические функции и единичная окружность', 'THEORY',   0, 100),
    ('Тригонометрические уравнения',                      'PRACTICE', 1, 120)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Блок 3: Тригонометрия';

-- Блок 4: 3 урока
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Пределы функций и непрерывность',          'THEORY',   0, 120),
    ('Производная: правила и приложения',        'MIXED',    1, 150),
    ('Интегралы: неопределённый и определённый', 'PRACTICE', 2, 150)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Блок 4: Начала математического анализа';

-- ============================================================
-- 5. КОНТЕНТ УРОКОВ (TEXT + VIDEO + IMAGE для каждого урока)
-- ============================================================

-- Урок 1: Функции и их свойства
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Понятие функции\n\n'
     'Функция — это правило, которое каждому элементу множества X (области определения) '
     'ставит в соответствие **ровно один** элемент множества Y (области значений).\n\n'
     '**Запись:** y = f(x), где x — аргумент, y — значение функции.\n\n'
     '### Основные характеристики\n'
     '- **Область определения D(f)** — все допустимые значения x\n'
     '- **Область значений E(f)** — все возможные значения y\n'
     '- **Чётность:** f(-x) = f(x) — чётная; f(-x) = -f(x) — нечётная\n'
     '- **Возрастание/убывание** — монотонность функции\n\n'
     '### Примеры\n'
     '| Функция | D(f) | Тип |\n'
     '|---------|------|-----|\n'
     '| f(x) = x² | ℝ | чётная |\n'
     '| f(x) = x³ | ℝ | нечётная |\n'
     '| f(x) = √x | [0; +∞) | общая |\n'
     '| f(x) = 1/x | ℝ \\ {0} | нечётная |',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Введение в понятие функции. Область определения, область значений, чётность.',
     'https://www.youtube.com/watch?v=kvGsIo1TmsM', 1),
    ('IMAGE',
     'Декартова система координат и примеры графиков основных функций',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Cartesian-coordinate-system.svg/600px-Cartesian-coordinate-system.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Функции и их свойства';

-- Урок 2: Квадратные уравнения
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Квадратное уравнение\n\n'
     'Уравнение вида **ax² + bx + c = 0**, где a ≠ 0.\n\n'
     '### Формула дискриминанта\n'
     '**D = b² − 4ac**\n\n'
     '### Анализ дискриминанта\n'
     '| Условие | Количество корней |\n'
     '|---------|-------------------|\n'
     '| D > 0 | 2 действительных корня |\n'
     '| D = 0 | 1 корень (кратный) |\n'
     '| D < 0 | Нет действительных корней |\n\n'
     '### Формула корней\n'
     'x₁,₂ = (−b ± √D) / (2a)\n\n'
     '### Теорема Виета\n'
     'x₁ + x₂ = −b/a &emsp; x₁ · x₂ = c/a',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Решение квадратных уравнений. Дискриминант и теорема Виета.',
     'https://www.youtube.com/watch?v=2ZzuZvz33X0', 1),
    ('IMAGE',
     'Парабола y = ax² + bx + c и её расположение относительно оси x в зависимости от знака D',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Parabola_with_focus_and_directrix.svg/600px-Parabola_with_focus_and_directrix.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Квадратные уравнения и дискриминант';

-- Урок 3: Системы линейных уравнений
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Системы линейных уравнений\n\n'
     'Система из двух уравнений с двумя неизвестными:\n'
     '{ a₁x + b₁y = c₁\n'
     '{ a₂x + b₂y = c₂\n\n'
     '### Методы решения\n\n'
     '**1. Метод подстановки:**\n'
     'Выразить одну переменную через другую из одного уравнения и подставить во второе.\n\n'
     '**2. Метод сложения (алгебраического исключения):**\n'
     'Умножить уравнения на коэффициенты так, чтобы при сложении одна переменная исчезла.\n\n'
     '### Типы систем\n'
     '- **Совместная** (имеет решение): прямые пересекаются или совпадают\n'
     '- **Несовместная** (нет решения): прямые параллельны\n'
     '- **Определённая**: единственное решение\n'
     '- **Неопределённая**: бесконечно много решений',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Системы уравнений — метод подстановки и метод сложения.',
     'https://www.youtube.com/watch?v=nok99JOhcjo', 1),
    ('TEXT',
     E'### Пример решения методом сложения\n\n'
     'Система: { 2x + 3y = 12; 4x − 3y = 6 }\n\n'
     'Складываем уравнения: 6x = 18 → x = 3\n'
     'Подставляем: 2(3) + 3y = 12 → 3y = 6 → y = 2\n\n'
     '**Ответ:** x = 3, y = 2\n\n'
     'Проверка: 2·3 + 3·2 = 12 ✓; 4·3 − 3·2 = 6 ✓',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Системы линейных уравнений';

-- Урок 4: Степени и корни
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Степени и корни\n\n'
     '### Свойства степеней (a > 0)\n'
     '| Правило | Формула |\n'
     '|---------|--------|\n'
     '| Произведение | aᵐ · aⁿ = aᵐ⁺ⁿ |\n'
     '| Частное | aᵐ / aⁿ = aᵐ⁻ⁿ |\n'
     '| Степень степени | (aᵐ)ⁿ = aᵐⁿ |\n'
     '| Нулевая степень | a⁰ = 1 |\n'
     '| Отрицательная | a⁻ⁿ = 1/aⁿ |\n'
     '| Дробная | aᵐ/ⁿ = ⁿ√aᵐ |\n\n'
     '### Упрощение корней\n'
     '√72 = √(36·2) = 6√2\n'
     '³√54 = ³√(27·2) = 3·³√2',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Свойства степеней и корней. Упрощение выражений.',
     'https://www.youtube.com/watch?v=XZRQhkii0h0', 1),
    ('TEXT',
     E'### Показательные уравнения\n\n'
     'Уравнение вида **aˣ = aⁿ** решается сведением к равенству показателей: x = n.\n\n'
     '**Пример:** 2ˣ = 32 → 2ˣ = 2⁵ → x = 5\n\n'
     '**Пример:** 3^(2x-1) = 27 → 3^(2x-1) = 3³ → 2x−1 = 3 → x = 2',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Степени и корни: свойства и вычисления';

-- Урок 5: Логарифмы
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Логарифмы\n\n'
     '**Определение:** log_a(b) = x означает aˣ = b (a > 0, a ≠ 1, b > 0)\n\n'
     '### Основные свойства\n'
     '| Свойство | Формула |\n'
     '|----------|--------|\n'
     '| Логарифм единицы | log_a(1) = 0 |\n'
     '| Логарифм основания | log_a(a) = 1 |\n'
     '| Произведение | log_a(bc) = log_a(b) + log_a(c) |\n'
     '| Частное | log_a(b/c) = log_a(b) − log_a(c) |\n'
     '| Степень | log_a(bⁿ) = n·log_a(b) |\n'
     '| Переход основания | log_a(b) = log_c(b) / log_c(a) |\n\n'
     '### Специальные логарифмы\n'
     '- **lg(x)** = log₁₀(x) — десятичный логарифм\n'
     '- **ln(x)** = log_e(x) — натуральный логарифм, e ≈ 2.718',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Логарифмы — определение, свойства, вычисление.',
     'https://www.youtube.com/watch?v=Z5myJ8dg_rM', 1),
    ('IMAGE',
     'Графики логарифмических функций с разными основаниями',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Log_different_bases.svg/600px-Log_different_bases.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Логарифмы и их свойства';

-- Урок 6: Тригонометрические функции
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Тригонометрические функции\n\n'
     '### Определения через единичную окружность\n'
     'Для угла x (в радианах): точка на единичной окружности (cos x, sin x)\n\n'
     '### Значения в ключевых точках\n'
     '| Угол | sin | cos | tg |\n'
     '|------|-----|-----|----|\n'
     '| 0° | 0 | 1 | 0 |\n'
     '| 30° = π/6 | 1/2 | √3/2 | 1/√3 |\n'
     '| 45° = π/4 | √2/2 | √2/2 | 1 |\n'
     '| 60° = π/3 | √3/2 | 1/2 | √3 |\n'
     '| 90° = π/2 | 1 | 0 | — |\n\n'
     '### Основные тождества\n'
     '- sin²x + cos²x = 1 (основное тригонометрическое тождество)\n'
     '- tg(x) = sin(x)/cos(x)\n'
     '- sin(2x) = 2·sin(x)·cos(x)\n'
     '- cos(2x) = cos²x − sin²x',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Единичная окружность и тригонометрические функции.',
     'https://www.youtube.com/watch?v=yBw67Fb31Cs', 1),
    ('IMAGE',
     'Единичная окружность с углами и значениями sin/cos',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Unit_circle_angles_color.svg/600px-Unit_circle_angles_color.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Тригонометрические функции и единичная окружность';

-- Урок 7: Тригонометрические уравнения
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Тригонометрические уравнения\n\n'
     '### Общие решения\n'
     '| Уравнение | Общее решение |\n'
     '|-----------|---------------|\n'
     '| sin(x) = 0 | x = πn, n ∈ ℤ |\n'
     '| cos(x) = 0 | x = π/2 + πn |\n'
     '| sin(x) = a, |a| ≤ 1 | x = (−1)ⁿ·arcsin(a) + πn |\n'
     '| cos(x) = a, |a| ≤ 1 | x = ±arccos(a) + 2πn |\n'
     '| tg(x) = a | x = arctg(a) + πn |\n\n'
     '### Важно!\n'
     'Уравнение sin(x) = a или cos(x) = a **не имеет решений**, если |a| > 1.',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Решение тригонометрических уравнений. Формулы общего решения.',
     'https://www.youtube.com/watch?v=FhD9GBdVGXQ', 1),
    ('TEXT',
     E'### Пример: решить 2sin(x) − 1 = 0 на [0; 2π]\n\n'
     '1. sin(x) = 1/2\n'
     '2. Опорный угол: arcsin(1/2) = π/6\n'
     '3. Решения в [0; 2π]: x = π/6 и x = π − π/6 = 5π/6\n\n'
     '**Ответ:** x = π/6, x = 5π/6',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Тригонометрические уравнения';

-- Урок 8: Пределы
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Пределы функций\n\n'
     '**Определение:** lim(x→a) f(x) = L означает, что при x → a значения f(x) '
     'сколь угодно близко приближаются к L.\n\n'
     '### Свойства пределов\n'
     '- lim(c) = c (предел константы)\n'
     '- lim(x→a) [f + g] = lim f + lim g\n'
     '- lim(x→a) [f · g] = lim f · lim g\n\n'
     '### Замечательные пределы\n'
     '1. **Первый:** lim(x→0) sin(x)/x = **1**\n'
     '2. **Второй:** lim(x→∞) (1 + 1/x)ˣ = **e ≈ 2.718**\n\n'
     '### Непрерывность\n'
     'f(x) непрерывна в точке x₀, если lim(x→x₀) f(x) = f(x₀)',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Понятие предела. Замечательные пределы. Непрерывность.',
     'https://www.youtube.com/watch?v=riXcZT2ICjA', 1),
    ('TEXT',
     E'### Раскрытие неопределённости 0/0\n\n'
     'lim(x→2) (x² − 4)/(x − 2)\n\n'
     '= lim(x→2) (x−2)(x+2)/(x−2)\n\n'
     '= lim(x→2) (x+2) = **4**\n\n'
     '### Предел на бесконечности\n\n'
     'lim(x→∞) (3x² + 2x)/(x² − 1)\n\n'
     'Делим числитель и знаменатель на x²:\n\n'
     '= lim(x→∞) (3 + 2/x)/(1 − 1/x²) = **3**',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Пределы функций и непрерывность';

-- Урок 9: Производная
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Производная функции\n\n'
     '**Определение:** f''(x) = lim(Δx→0) [f(x+Δx) − f(x)] / Δx\n\n'
     'Геометрический смысл: **угловой коэффициент касательной** к графику в точке x.\n\n'
     '### Таблица производных\n'
     '| Функция | Производная |\n'
     '|---------|------------|\n'
     '| C (константа) | 0 |\n'
     '| xⁿ | n·xⁿ⁻¹ |\n'
     '| eˣ | eˣ |\n'
     '| ln(x) | 1/x |\n'
     '| sin(x) | cos(x) |\n'
     '| cos(x) | −sin(x) |\n\n'
     '### Правила дифференцирования\n'
     '- **(u + v)'' = u'' + v''**\n'
     '- **(u · v)'' = u''v + uv''** (правило произведения)\n'
     '- **(u/v)'' = (u''v − uv'') / v²** (правило частного)\n'
     '- **(f(g(x)))'' = f''(g(x)) · g''(x)** (цепное правило)',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Производная функции. Правила дифференцирования.',
     'https://www.youtube.com/watch?v=ANyVpMS3HL4', 1),
    ('IMAGE',
     'Касательная к кривой — геометрический смысл производной',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Tangent_to_a_curve.svg/600px-Tangent_to_a_curve.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Производная: правила и приложения';

-- Урок 10: Интегралы
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Интегралы\n\n'
     '### Неопределённый интеграл\n'
     '∫f(x)dx = F(x) + C, где F''(x) = f(x) — первообразная\n\n'
     '### Таблица интегралов\n'
     '| f(x) | ∫f(x)dx |\n'
     '|------|--------|\n'
     '| xⁿ (n ≠ −1) | xⁿ⁺¹/(n+1) + C |\n'
     '| 1/x | ln|x| + C |\n'
     '| eˣ | eˣ + C |\n'
     '| sin(x) | −cos(x) + C |\n'
     '| cos(x) | sin(x) + C |\n\n'
     '### Определённый интеграл\n'
     '**Формула Ньютона–Лейбница:**\n'
     '∫ₐᵇ f(x)dx = F(b) − F(a)\n\n'
     'Геометрический смысл: **площадь под кривой** y=f(x) от a до b.',
     NULL, 0),
    ('VIDEO',
     'Видеолекция: Неопределённый и определённый интеграл. Формула Ньютона–Лейбница.',
     'https://www.youtube.com/watch?v=rfG8ce4nNh0', 1),
    ('IMAGE',
     'Геометрический смысл определённого интеграла — площадь под кривой',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Integral_as_region_under_curve.svg/600px-Integral_as_region_under_curve.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Интегралы: неопределённый и определённый';

-- ============================================================
-- 6. ЗАДАНИЯ (3 на каждый урок = 30 задач)
-- ============================================================

-- Урок 1: Функции
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Дана функция f(x) = 2x² − 3x + 1. Найдите f(−2).', '15', 75, 0),
    ('Определите область определения: f(x) = √(x − 3) / (x − 7). Запишите ответ в виде неравенств.', 'x >= 3, x != 7', 90, 1),
    ('Является ли функция f(x) = x⁴ − 2x² чётной, нечётной или общей? Обоснуйте через определение.', 'чётной', 90, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Функции и их свойства';

-- Урок 2: Квадратные уравнения
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Решите методом дискриминанта: x² − 7x + 10 = 0', 'x = 2, x = 5', 75, 0),
    ('Найдите корни уравнения: 2x² + 5x − 3 = 0', 'x = 0.5, x = -3', 90, 1),
    ('При каком значении k уравнение kx² − 4x + 1 = 0 имеет ровно один корень?', 'k = 4', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Квадратные уравнения и дискриминант';

-- Урок 3: Системы уравнений
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Решите систему методом подстановки: x + 2y = 7 и 3x − y = 7', 'x = 3, y = 2', 75, 0),
    ('Решите систему методом сложения: 2x + 3y = 12 и 4x − 3y = 6', 'x = 3, y = 2', 75, 1),
    ('Определите тип системы (совместная/несовместная): 2x − 4y = 6 и x − 2y = 4', 'несовместная', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Системы линейных уравнений';

-- Урок 4: Степени и корни
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Упростите: (3² · 3⁵) / 3⁴', '27', 75, 0),
    ('Вычислите ⁴√(81 · x⁸) при x > 0. Запишите в виде степени.', '3x²', 90, 1),
    ('Решите уравнение: 4^x = 128. Подсказка: представьте обе части как степени двойки.', 'x = 3.5', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Степени и корни: свойства и вычисления';

-- Урок 5: Логарифмы
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Вычислите: log₃(243)', '5', 75, 0),
    ('Решите уравнение: log₂(x − 1) = 4', '17', 90, 1),
    ('Упростите: log₅(25) + log₅(5) − log₅(1)', '3', 90, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Логарифмы и их свойства';

-- Урок 6: Тригонометрические функции
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Вычислите точно: sin(π/6) + cos(π/3). Запишите числом.', '1', 75, 0),
    ('Докажите/упростите: sin²(x) + cos²(x) + tg(x)·ctg(x). Запишите результат.', '2', 90, 1),
    ('Найдите точное значение sin(210°). Используйте формулы приведения.', '-1/2', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Тригонометрические функции и единичная окружность';

-- Урок 7: Тригонометрические уравнения
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Найдите все решения уравнения sin(x) = √3/2 на отрезке [0; 2π]. Перечислите через запятую.', 'x = π/3, x = 2π/3', 90, 0),
    ('Запишите общее решение уравнения: cos(x) = 0', 'x = π/2 + πn', 75, 1),
    ('Решите уравнение 2cos(x) + √3 = 0 на [0; 2π]. Перечислите решения.', 'x = 5π/6, x = 7π/6', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Тригонометрические уравнения';

-- Урок 8: Пределы
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Вычислите предел, раскрыв неопределённость: lim(x→3) (x² − 9)/(x − 3)', '6', 75, 0),
    ('Используя первый замечательный предел, найдите: lim(x→0) sin(5x)/(3x)', '5/3', 100, 1),
    ('Найдите предел: lim(x→∞) (5x³ − 2x) / (2x³ + 7)', '5/2', 90, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Пределы функций и непрерывность';

-- Урок 9: Производная
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Найдите производную: f(x) = 3x⁴ − 2x² + 5x − 1', 'f''(x) = 12x³ − 4x + 5', 75, 0),
    ('Найдите производную сложной функции: f(x) = (2x + 1)⁵', 'f''(x) = 10(2x + 1)⁴', 100, 1),
    ('При каком значении x функция f(x) = x³ − 3x² имеет минимум? Найдите через производную.', '2', 110, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Производная: правила и приложения';

-- Урок 10: Интегралы
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Найдите неопределённый интеграл: ∫(4x³ − 6x + 2)dx', 'x⁴ − 3x² + 2x + C', 75, 0),
    ('Вычислите определённый интеграл: ∫₀² (3x² + 2)dx', '12', 90, 1),
    ('Найдите площадь фигуры, ограниченной кривой y = x², осью Ox и прямыми x=0, x=3.', '9', 110, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Интегралы: неопределённый и определённый';

-- ============================================================
-- 7. ПОДСКАЗКИ (2 на каждую задачу = 60 подсказок)
-- ============================================================

-- Урок 1 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Подставьте x = −2 в выражение: 2·(−2)² − 3·(−2) + 1', 0),
    ('(−2)² = 4, поэтому 2·4 = 8. Далее: 8 + 6 + 1 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Функции и их свойства'
  AND t.description = 'Дана функция f(x) = 2x² − 3x + 1. Найдите f(−2).';

-- Урок 1 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Для √(x−3) нужно x − 3 ≥ 0, то есть x ≥ 3', 0),
    ('Знаменатель не может быть нулём: x − 7 ≠ 0, значит x ≠ 7', 1)
) AS h(content, ord)
WHERE l.title = 'Функции и их свойства'
  AND t.description = 'Определите область определения: f(x) = √(x − 3) / (x − 7). Запишите ответ в виде неравенств.';

-- Урок 1 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Проверьте: f(−x) = (−x)⁴ − 2(−x)². Упростите.', 0),
    ('(−x)⁴ = x⁴ и (−x)² = x², поэтому f(−x) = x⁴ − 2x² = f(x)', 1)
) AS h(content, ord)
WHERE l.title = 'Функции и их свойства'
  AND t.description = 'Является ли функция f(x) = x⁴ − 2x² чётной, нечётной или общей? Обоснуйте через определение.';

-- Урок 2 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('D = b² − 4ac = (−7)² − 4·1·10 = 49 − 40 = 9', 0),
    ('x₁,₂ = (7 ± √9)/2 = (7 ± 3)/2. Получите два значения.', 1)
) AS h(content, ord)
WHERE l.title = 'Квадратные уравнения и дискриминант'
  AND t.description = 'Решите методом дискриминанта: x² − 7x + 10 = 0';

-- Урок 2 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('D = 5² − 4·2·(−3) = 25 + 24 = 49', 0),
    ('x₁,₂ = (−5 ± 7)/4. Значит x₁ = 2/4 = 0.5, x₂ = −12/4 = −3', 1)
) AS h(content, ord)
WHERE l.title = 'Квадратные уравнения и дискриминант'
  AND t.description = 'Найдите корни уравнения: 2x² + 5x − 3 = 0';

-- Урок 2 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Единственный корень означает D = 0. D = 16 − 4k.', 0),
    ('16 − 4k = 0 → k = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Квадратные уравнения и дискриминант'
  AND t.description = 'При каком значении k уравнение kx² − 4x + 1 = 0 имеет ровно один корень?';

-- Урок 3 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Из первого уравнения: x = 7 − 2y. Подставьте в 3x − y = 7.', 0),
    ('3(7 − 2y) − y = 7 → 21 − 7y = 7 → y = 2', 1)
) AS h(content, ord)
WHERE l.title = 'Системы линейных уравнений'
  AND t.description = 'Решите систему методом подстановки: x + 2y = 7 и 3x − y = 7';

-- Урок 3 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Сложите уравнения: (2x + 3y) + (4x − 3y) = 12 + 6 → 6x = 18', 0),
    ('x = 3. Подставьте в первое: 6 + 3y = 12 → y = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Системы линейных уравнений'
  AND t.description = 'Решите систему методом сложения: 2x + 3y = 12 и 4x − 3y = 6';

-- Урок 3 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Из второго уравнения: x = 2y + 4. Подставьте в первое.', 0),
    ('2(2y+4) − 4y = 8 ≠ 6. Противоречие — система несовместна.', 1)
) AS h(content, ord)
WHERE l.title = 'Системы линейных уравнений'
  AND t.description = 'Определите тип системы (совместная/несовместная): 2x − 4y = 6 и x − 2y = 4';

-- Урок 4 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('При умножении степеней с одним основанием показатели складываются: 3² · 3⁵ = 3⁷', 0),
    ('3⁷ / 3⁴ = 3^(7−4) = 3³ = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Степени и корни: свойства и вычисления'
  AND t.description = 'Упростите: (3² · 3⁵) / 3⁴';

-- Урок 4 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('⁴√(a·b) = ⁴√a · ⁴√b. Применяйте это свойство.', 0),
    ('⁴√81 = 3 (так как 3⁴ = 81), ⁴√x⁸ = x^(8/4) = x²', 1)
) AS h(content, ord)
WHERE l.title = 'Степени и корни: свойства и вычисления'
  AND t.description = 'Вычислите ⁴√(81 · x⁸) при x > 0. Запишите в виде степени.';

-- Урок 4 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('4 = 2², 128 = 2⁷. Запишите оба числа как степени двойки.', 0),
    ('(2²)^x = 2^(2x) = 2⁷ → 2x = 7 → x = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Степени и корни: свойства и вычисления'
  AND t.description = 'Решите уравнение: 4^x = 128. Подсказка: представьте обе части как степени двойки.';

-- Урок 5 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Вопрос: 3 в какой степени даёт 243?', 0),
    ('3¹=3, 3²=9, 3³=27, 3⁴=81, 3⁵=243', 1)
) AS h(content, ord)
WHERE l.title = 'Логарифмы и их свойства'
  AND t.description = 'Вычислите: log₃(243)';

-- Урок 5 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('log₂(x−1) = 4 означает x − 1 = 2⁴', 0),
    ('2⁴ = 16, значит x − 1 = 16 → x = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Логарифмы и их свойства'
  AND t.description = 'Решите уравнение: log₂(x − 1) = 4';

-- Урок 5 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('log₅(25) = log₅(5²) = 2, log₅(5) = 1, log₅(1) = 0', 0),
    ('2 + 1 − 0 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Логарифмы и их свойства'
  AND t.description = 'Упростите: log₅(25) + log₅(5) − log₅(1)';

-- Урок 6 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('sin(π/6) = sin(30°) = 1/2', 0),
    ('cos(π/3) = cos(60°) = 1/2. Сложите.', 1)
) AS h(content, ord)
WHERE l.title = 'Тригонометрические функции и единичная окружность'
  AND t.description = 'Вычислите точно: sin(π/6) + cos(π/3). Запишите числом.';

-- Урок 6 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('sin²x + cos²x = 1 (основное тождество)', 0),
    ('tg(x)·ctg(x) = sin(x)/cos(x) · cos(x)/sin(x) = 1. Итого: 1 + 1 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Тригонометрические функции и единичная окружность'
  AND t.description = 'Докажите/упростите: sin²(x) + cos²(x) + tg(x)·ctg(x). Запишите результат.';

-- Урок 6 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('210° = 180° + 30°. Используйте формулу: sin(180°+α) = −sin(α)', 0),
    ('sin(210°) = −sin(30°) = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Тригонометрические функции и единичная окружность'
  AND t.description = 'Найдите точное значение sin(210°). Используйте формулы приведения.';

-- Урок 7 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('sin(α) = √3/2 → опорный угол α = π/3', 0),
    ('В [0;2π] sin > 0 в I и II четвертях: x = π/3 и x = π − π/3 = 2π/3', 1)
) AS h(content, ord)
WHERE l.title = 'Тригонометрические уравнения'
  AND t.description = 'Найдите все решения уравнения sin(x) = √3/2 на отрезке [0; 2π]. Перечислите через запятую.';

-- Урок 7 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('cos(x) = 0 в точках, где x = π/2 и x = 3π/2, и т.д.', 0),
    ('Общая формула: x = π/2 + πn, где n — любое целое число', 1)
) AS h(content, ord)
WHERE l.title = 'Тригонометрические уравнения'
  AND t.description = 'Запишите общее решение уравнения: cos(x) = 0';

-- Урок 7 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('cos(x) = −√3/2. Опорный угол arccos(√3/2) = π/6. cos < 0 во II и III четвертях.', 0),
    ('II четверть: x = π − π/6 = 5π/6. III четверть: x = π + π/6 = 7π/6', 1)
) AS h(content, ord)
WHERE l.title = 'Тригонометрические уравнения'
  AND t.description = 'Решите уравнение 2cos(x) + √3 = 0 на [0; 2π]. Перечислите решения.';

-- Урок 8 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Разложите числитель: x² − 9 = (x−3)(x+3)', 0),
    ('Сократите на (x−3): lim(x→3)(x+3) = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Пределы функций и непрерывность'
  AND t.description = 'Вычислите предел, раскрыв неопределённость: lim(x→3) (x² − 9)/(x − 3)';

-- Урок 8 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Запишите sin(5x)/(3x) = (5/3) · sin(5x)/(5x)', 0),
    ('По первому замечательному пределу: lim(u→0) sin(u)/u = 1', 1)
) AS h(content, ord)
WHERE l.title = 'Пределы функций и непрерывность'
  AND t.description = 'Используя первый замечательный предел, найдите: lim(x→0) sin(5x)/(3x)';

-- Урок 8 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Разделите числитель и знаменатель на старшую степень x³', 0),
    ('После деления на x³: (5 − 2/x²)/(2 + 7/x³) → при x→∞ получите ?', 1)
) AS h(content, ord)
WHERE l.title = 'Пределы функций и непрерывность'
  AND t.description = 'Найдите предел: lim(x→∞) (5x³ − 2x) / (2x³ + 7)';

-- Урок 9 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('(xⁿ)'' = n·xⁿ⁻¹. Применяйте к каждому слагаемому.', 0),
    ('(3x⁴)'' = 12x³, (−2x²)'' = −4x, (5x)'' = 5, (−1)'' = 0', 1)
) AS h(content, ord)
WHERE l.title = 'Производная: правила и приложения'
  AND t.description = 'Найдите производную: f(x) = 3x⁴ − 2x² + 5x − 1';

-- Урок 9 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Цепное правило: [g(u)]'' = n·g(u)^(n−1) · g''(u)', 0),
    ('Внешняя функция: u⁵, внутренняя: u = 2x+1. (u⁵)'' = 5u⁴, (2x+1)'' = 2', 1)
) AS h(content, ord)
WHERE l.title = 'Производная: правила и приложения'
  AND t.description = 'Найдите производную сложной функции: f(x) = (2x + 1)⁵';

-- Урок 9 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('f''(x) = 3x² − 6x = 3x(x − 2). Приравняйте к нулю.', 0),
    ('Критические точки: x=0 и x=2. f''''(x) = 6x−6. f''''(2)=6>0 → x=2 минимум', 1)
) AS h(content, ord)
WHERE l.title = 'Производная: правила и приложения'
  AND t.description = 'При каком значении x функция f(x) = x³ − 3x² имеет минимум? Найдите через производную.';

-- Урок 10 задача 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('∫xⁿdx = xⁿ⁺¹/(n+1) + C. Применяйте к каждому члену.', 0),
    ('∫4x³dx = x⁴, ∫(−6x)dx = −3x², ∫2dx = 2x. Не забудьте +C.', 1)
) AS h(content, ord)
WHERE l.title = 'Интегралы: неопределённый и определённый'
  AND t.description = 'Найдите неопределённый интеграл: ∫(4x³ − 6x + 2)dx';

-- Урок 10 задача 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Найдите первообразную: F(x) = x³ + 2x', 0),
    ('Применяйте формулу Ньютона-Лейбница: F(2) − F(0) = (8+4) − (0+0) = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Интегралы: неопределённый и определённый'
  AND t.description = 'Вычислите определённый интеграл: ∫₀² (3x² + 2)dx';

-- Урок 10 задача 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Площадь = ∫₀³ x²dx. Найдите первообразную x²: это x³/3.', 0),
    ('[x³/3]₀³ = 3³/3 − 0 = 27/3 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Интегралы: неопределённый и определённый'
  AND t.description = 'Найдите площадь фигуры, ограниченной кривой y = x², осью Ox и прямыми x=0, x=3.';

-- ============================================================
-- 8. КВИЗЫ (1 квиз на урок = 10 квизов)
-- ============================================================

INSERT INTO quizzes (lesson_id, title, time_limit, xp_reward)
SELECT l.id, q.title, q.tlimit, q.xp
FROM lessons l
JOIN (VALUES
    ('Функции и их свойства',                                'Тест: Функции',              600, 100),
    ('Квадратные уравнения и дискриминант',                  'Тест: Квадратные уравнения', 600, 100),
    ('Системы линейных уравнений',                           'Тест: Системы уравнений',    600, 100),
    ('Степени и корни: свойства и вычисления',               'Тест: Степени и корни',      480, 100),
    ('Логарифмы и их свойства',                              'Тест: Логарифмы',            480, 100),
    ('Тригонометрические функции и единичная окружность',    'Тест: Тригонометрия',        600, 120),
    ('Тригонометрические уравнения',                         'Тест: Тrig-уравнения',       600, 120),
    ('Пределы функций и непрерывность',                      'Тест: Пределы',              720, 150),
    ('Производная: правила и приложения',                    'Тест: Производная',          720, 150),
    ('Интегралы: неопределённый и определённый',             'Тест: Интегралы',            720, 150)
) AS q(ltitle, title, tlimit, xp) ON l.title = q.ltitle;

-- ============================================================
-- 9. ВОПРОСЫ КВИЗОВ (5 на квиз = 50 вопросов)
-- ============================================================

-- Квиз 1: Функции
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('Чему равно f(2) при f(x) = x² + 3x − 1?',
     '["8", "9", "10", "5"]', '[1]', 0),
    ('Какая из функций является чётной?',
     '["y = x³ + 1", "y = x² − 4", "y = sin(x) + x", "y = x + 5"]', '[1]', 1),
    ('Область определения f(x) = 1/(x−3):',
     '["Все вещественные числа", "x ≠ 3", "x > 3", "x < 3"]', '[1]', 2),
    ('Чётная функция симметрична относительно:',
     '["Оси Ox", "Оси Oy", "Начала координат", "Прямой y = x"]', '[1]', 3),
    ('Нечётная функция симметрична относительно:',
     '["Оси Ox", "Оси Oy", "Начала координат", "Прямой y = x"]', '[2]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Функции и их свойства';

-- Квиз 2: Квадратные уравнения
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('Дискриминант уравнения x² − 6x + 5 = 0 равен:',
     '["16", "11", "4", "36"]', '[0]', 0),
    ('Сколько действительных корней имеет x² + 2x + 5 = 0?',
     '["0", "1", "2", "Бесконечно много"]', '[0]', 1),
    ('Корни уравнения x² − 5x + 6 = 0:',
     '["x=1, x=6", "x=2, x=3", "x=−2, x=−3", "x=0, x=5"]', '[1]', 2),
    ('По теореме Виета сумма корней 2x² − 6x + 4 = 0:',
     '["3", "6", "2", "−3"]', '[0]', 3),
    ('По теореме Виета произведение корней 2x² − 6x + 4 = 0:',
     '["4", "2", "3", "−2"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Квадратные уравнения и дискриминант';

-- Квиз 3: Системы уравнений
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('Сколько решений: y = 2x+1 и y = 2x−3?',
     '["0", "1", "2", "Бесконечно много"]', '[0]', 0),
    ('Решение системы x+y=5 и x−y=1:',
     '["x=3, y=2", "x=2, y=3", "x=4, y=1", "x=1, y=4"]', '[0]', 1),
    ('При каком условии система несовместна?',
     '["Прямые параллельны", "Прямые пересекаются", "Прямые совпадают", "Уравнений больше 2"]', '[0]', 2),
    ('Система называется определённой если:',
     '["Нет решений", "Единственное решение", "Бесконечно много решений", "Все коэффициенты равны"]', '[1]', 3),
    ('Метод Крамера применяется для систем:',
     '["Только нелинейных", "Линейных с ненулевым определителем", "Только с двумя уравнениями", "Несовместных"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Системы линейных уравнений';

-- Квиз 4: Степени и корни
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('a³ · a⁴ = ?',
     '["a⁷", "a¹²", "a", "2a⁷"]', '[0]', 0),
    ('(2³)² = ?',
     '["2⁵ = 32", "2⁶ = 64", "2⁷ = 128", "2⁴ = 16"]', '[1]', 1),
    ('√72 в простейшем виде:',
     '["6√2", "8√2", "3√8", "6√3"]', '[0]', 2),
    ('a⁻² = ?',
     '["1/a²", "−a²", "a²", "−1/a²"]', '[0]', 3),
    ('(a/b)³ = ?',
     '["a/b³", "a³/b³", "3a/3b", "a³/b"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Степени и корни: свойства и вычисления';

-- Квиз 5: Логарифмы
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('log₂(8) = ?',
     '["2", "3", "4", "1"]', '[1]', 0),
    ('log₁₀(1000) = ?',
     '["2", "3", "4", "10"]', '[1]', 1),
    ('log_a(a) = ?',
     '["0", "1", "a", "2"]', '[1]', 2),
    ('log_a(1) = ?',
     '["0", "1", "a", "−1"]', '[0]', 3),
    ('ln(e²) = ?',
     '["e", "2", "2e", "1"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Логарифмы и их свойства';

-- Квиз 6: Тригонометрия
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('sin(30°) = ?',
     '["√3/2", "1/2", "√2/2", "1"]', '[1]', 0),
    ('cos(60°) = ?',
     '["√3/2", "1/2", "0", "√2/2"]', '[1]', 1),
    ('tg(45°) = ?',
     '["0", "1", "√3", "1/√3"]', '[1]', 2),
    ('sin²x + cos²x = ?',
     '["0", "1", "2", "sin(2x)"]', '[1]', 3),
    ('Период функции y = sin(x):',
     '["π", "2π", "π/2", "4π"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Тригонометрические функции и единичная окружность';

-- Квиз 7: Тригонометрические уравнения
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('Общее решение sin(x) = 0:',
     '["x = πn", "x = π/2 + πn", "x = 2πn", "x = π/4 + πn"]', '[0]', 0),
    ('Общее решение cos(x) = 1:',
     '["x = πn", "x = 2πn", "x = π/2 + πn", "x = π + 2πn"]', '[1]', 1),
    ('Уравнение 2sin(x) − 1 = 0 эквивалентно:',
     '["sin(x) = −1/2", "sin(x) = 1/2", "sin(x) = 2", "sin(x) = 1"]', '[1]', 2),
    ('Уравнение sin(x) = 2:',
     '["Бесконечно много решений", "Ровно два решения", "Не имеет решений", "x = 2"]', '[2]', 3),
    ('Сколько решений у cos(x) = −1 на [0; 2π]?',
     '["0", "1", "2", "Бесконечно много"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Тригонометрические уравнения';

-- Квиз 8: Пределы
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('lim(x→∞) 1/x = ?',
     '["1", "∞", "0", "−1"]', '[2]', 0),
    ('lim(x→0) sin(x)/x = ?',
     '["0", "∞", "sin(0)", "1"]', '[3]', 1),
    ('f непрерывна в x₀ если:',
     '["lim f(x) = 0", "lim f(x) = f(x₀)", "f(x₀) = 0", "f определена везде"]', '[1]', 2),
    ('lim(x→2) (x² − 4)/(x − 2) = ?',
     '["0", "∞", "4", "2"]', '[2]', 3),
    ('lim(x→∞) (3x² + 2)/(x² − 1) = ?',
     '["0", "1", "3", "∞"]', '[2]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Пределы функций и непрерывность';

-- Квиз 9: Производная
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('Производная константы:',
     '["1", "0", "Сама константа", "Не определена"]', '[1]', 0),
    ('(x³)'' = ?',
     '["3x", "x²", "3x²", "3x³"]', '[2]', 1),
    ('(sin(x))'' = ?',
     '["−cos(x)", "cos(x)", "−sin(x)", "1/cos(x)"]', '[1]', 2),
    ('Если f''(x₀) = 0 и f''''(x₀) > 0, то x₀ — это:',
     '["Точка максимума", "Точка минимума", "Точка перегиба", "Разрыв"]', '[1]', 3),
    ('(u·v)'' = ?',
     '["u''·v''", "u''·v + u·v''", "u·v + u''·v''", "u''/v''"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Производная: правила и приложения';

-- Квиз 10: Интегралы
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('∫x dx = ?',
     '["x", "x²/2 + C", "x² + C", "2x + C"]', '[1]', 0),
    ('∫cos(x) dx = ?',
     '["−sin(x) + C", "sin(x) + C", "−cos(x) + C", "cos(x) + C"]', '[1]', 1),
    ('∫₀¹ x dx = ?',
     '["1", "1/2", "2", "0"]', '[1]', 2),
    ('∫k dx (k — константа) = ?',
     '["k/x + C", "kx + C", "k + C", "0"]', '[1]', 3),
    ('Формула Ньютона–Лейбница: ∫ₐᵇ f(x)dx = ?',
     '["F(a) − F(b)", "F(b) + F(a)", "F(b) − F(a)", "f(b) − f(a)"]', '[2]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Интегралы: неопределённый и определённый';

-- ============================================================
-- 10. ДОПОЛНИТЕЛЬНЫЕ БЕЙДЖИ
-- ============================================================

INSERT INTO badge_definitions (name, description, icon_url, condition_type, condition_value) VALUES
    ('Первые шаги',        'Завершить 1 урок',                    NULL, 'LESSONS_COMPLETED',  1),
    ('Почемучка',          'Завершить 3 урока',                   NULL, 'LESSONS_COMPLETED',  3),
    ('Уравновешенный',     'Завершить 5 уроков',                  NULL, 'LESSONS_COMPLETED',  5),
    ('Прилежный ученик',   'Завершить 10 уроков',                 NULL, 'LESSONS_COMPLETED', 10),
    ('Мастер курса',       'Завершить любой курс',                NULL, 'COURSES_COMPLETED',  1),
    ('Математик',          'Решить 15 задач',                     NULL, 'TASKS_SOLVED',       15),
    ('Решатель',           'Решить 50 задач',                     NULL, 'TASKS_SOLVED',       50),
    ('Отличник',           'Сдать 3 теста на 100%',               NULL, 'PERFECT_QUIZZES',    3),
    ('Снайпер',            'Сдать 10 тестов на 100%',             NULL, 'PERFECT_QUIZZES',   10),
    ('Уровень 3',          'Достичь 3 уровня',                    NULL, 'LEVEL_REACHED',      3),
    ('Уровень 5',          'Достичь 5 уровня',                    NULL, 'LEVEL_REACHED',      5),
    ('Уровень 10',         'Достичь 10 уровня',                   NULL, 'LEVEL_REACHED',     10),
    ('Уровень 25',         'Достичь 25 уровня',                   NULL, 'LEVEL_REACHED',     25),
    ('XP Охотник',         'Набрать 1000 XP',                     NULL, 'XP_EARNED',        1000),
    ('Стрик ×5',           '5 дней подряд',                       NULL, 'STREAK',             5),
    ('Стрик ×30',          '30 дней подряд',                      NULL, 'STREAK',            30),
    ('Без подсказок',      'Завершить курс без подсказок',        NULL, 'COURSE_NO_HINTS',    1)
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- 11. ЗАПИСИ НА КУРС (enrollment)
-- ============================================================

INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
SELECT u.id, c.id, 'ACTIVE', now() - interval '30 days'
FROM users u, courses c
WHERE u.email = 'daniyar.bekzhanov@eduquest.kz'
  AND c.title = 'Высшая математика: от алгебры до анализа'
ON CONFLICT (user_id, course_id) DO NOTHING;

INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
SELECT u.id, c.id, 'ACTIVE', now() - interval '20 days'
FROM users u, courses c
WHERE u.email = 'zarina.alibekova@eduquest.kz'
  AND c.title = 'Высшая математика: от алгебры до анализа'
ON CONFLICT (user_id, course_id) DO NOTHING;

INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
SELECT u.id, c.id, 'ACTIVE', now() - interval '10 days'
FROM users u, courses c
WHERE u.email = 'timur.seitkali@eduquest.kz'
  AND c.title = 'Высшая математика: от алгебры до анализа'
ON CONFLICT (user_id, course_id) DO NOTHING;

-- ============================================================
-- 12. ПРОГРЕСС, САБМИТЫ, ПОПЫТКИ КВИЗОВ, XP, УРОВНИ, БЕЙДЖИ
-- Используем DO $$ для работы с динамическими ID
-- ============================================================

DO $$
DECLARE
    v_daniyar   BIGINT;
    v_zarina    BIGINT;
    v_timur     BIGINT;
    v_temp      BIGINT;  -- промежуточная переменная для SELECT INTO

    -- ID всех 10 уроков
    v_l  BIGINT[10];
    -- ID всех 10 квизов
    v_q  BIGINT[10];
    -- ID всех 30 задач (3 на урок)
    v_t  BIGINT[30];

    i INT;
    j INT;
    v_lesson_titles TEXT[] := ARRAY[
        'Функции и их свойства',
        'Квадратные уравнения и дискриминант',
        'Системы линейных уравнений',
        'Степени и корни: свойства и вычисления',
        'Логарифмы и их свойства',
        'Тригонометрические функции и единичная окружность',
        'Тригонометрические уравнения',
        'Пределы функций и непрерывность',
        'Производная: правила и приложения',
        'Интегралы: неопределённый и определённый'
    ];
    v_quiz_titles TEXT[] := ARRAY[
        'Тест: Функции',
        'Тест: Квадратные уравнения',
        'Тест: Системы уравнений',
        'Тест: Степени и корни',
        'Тест: Логарифмы',
        'Тест: Тригонометрия',
        'Тест: Тrig-уравнения',
        'Тест: Пределы',
        'Тест: Производная',
        'Тест: Интегралы'
    ];
    -- XP rewards per lesson
    v_lesson_xp INT[] := ARRAY[60,80,90,70,100,100,120,120,150,150];
    -- XP per quiz
    v_quiz_xp   INT[] := ARRAY[100,100,100,100,100,120,120,150,150,150];

    -- Данияр завершил уроки 1-7 (индексы 1..7)
    v_daniyar_lessons INT := 7;
    -- Зарина завершила уроки 1-4
    v_zarina_lessons  INT := 4;
    -- Тимур завершил 1 урок
    v_timur_lessons   INT := 1;

    v_daniyar_xp INT := 0;
    v_zarina_xp  INT := 0;
    v_timur_xp   INT := 0;

    v_answers JSONB;
    v_qids    BIGINT[];
BEGIN
    -- Получаем ID пользователей
    SELECT id INTO v_daniyar FROM users WHERE email = 'daniyar.bekzhanov@eduquest.kz';
    SELECT id INTO v_zarina  FROM users WHERE email = 'zarina.alibekova@eduquest.kz';
    SELECT id INTO v_timur   FROM users WHERE email = 'timur.seitkali@eduquest.kz';

    -- Загружаем ID уроков и квизов
    -- SELECT INTO array_var[i] не поддерживается в PL/pgSQL — используем v_temp
    FOR i IN 1..10 LOOP
        SELECT id INTO v_temp FROM lessons WHERE title = v_lesson_titles[i];
        v_l[i] := v_temp;
        SELECT id INTO v_temp FROM quizzes WHERE title = v_quiz_titles[i];
        v_q[i] := v_temp;
    END LOOP;

    -- Загружаем ID задач (3 на урок, по sort_order)
    FOR i IN 1..10 LOOP
        FOR j IN 0..2 LOOP
            SELECT id INTO v_temp FROM tasks WHERE lesson_id = v_l[i] AND sort_order = j;
            v_t[(i-1)*3 + j + 1] := v_temp;
        END LOOP;
    END LOOP;

    -- -------------------------------------------------------
    -- ДАНИЯР: уроки 1-7 завершены полностью
    -- -------------------------------------------------------
    FOR i IN 1..v_daniyar_lessons LOOP
        -- Прогресс урока: COMPLETED
        INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used, completed_at)
        VALUES (v_daniyar, v_l[i], 'COMPLETED', 100, 0,
                now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3))
        ON CONFLICT (user_id, lesson_id) DO NOTHING;

        -- XP за урок
        INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
        VALUES (v_daniyar, 'LESSON_COMPLETE', v_lesson_xp[i], v_l[i],
                now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3));
        v_daniyar_xp := v_daniyar_xp + v_lesson_xp[i];

        -- Задачи: все 3 решены верно
        FOR j IN 1..3 LOOP
            INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
            SELECT v_daniyar,
                   v_t[(i-1)*3 + j],
                   sol.solution,
                   true,
                   t.xp_reward,
                   now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3) + make_interval(hours := j)
            FROM tasks t
            JOIN (SELECT id, solution FROM tasks WHERE id = v_t[(i-1)*3 + j]) sol ON sol.id = t.id
            WHERE t.id = v_t[(i-1)*3 + j];

            INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
            SELECT v_daniyar, 'TASK_SOLVED', xp_reward, v_t[(i-1)*3 + j],
                   now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3) + make_interval(hours := j)
            FROM tasks WHERE id = v_t[(i-1)*3 + j];

            SELECT v_daniyar_xp + xp_reward INTO v_daniyar_xp FROM tasks WHERE id = v_t[(i-1)*3 + j];
        END LOOP;

        -- Квиз: попытка с максимальным баллом
        SELECT array_agg(id ORDER BY sort_order) INTO v_qids
        FROM quiz_questions WHERE quiz_id = v_q[i];

        SELECT jsonb_object_agg(qid::text, '[0]'::jsonb)
        INTO v_answers
        FROM unnest(v_qids) AS qid;

        INSERT INTO quiz_attempts (user_id, quiz_id, answers, score, max_score, xp_earned, started_at, finished_at)
        VALUES (v_daniyar, v_q[i], COALESCE(v_answers, '{}'),
                5, 5, v_quiz_xp[i],
                now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3) + interval '2 hours',
                now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3) + interval '2 hours 15 minutes');

        INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
        VALUES (v_daniyar, 'QUIZ_PASSED', v_quiz_xp[i], v_q[i],
                now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3) + interval '2 hours 15 minutes');
        v_daniyar_xp := v_daniyar_xp + v_quiz_xp[i];
    END LOOP;

    -- Урок 8 для Данияра: in_progress
    INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used)
    VALUES (v_daniyar, v_l[8], 'IN_PROGRESS', 0, 0)
    ON CONFLICT (user_id, lesson_id) DO NOTHING;

    -- -------------------------------------------------------
    -- ЗАРИНА: уроки 1-4 завершены, на 5-м in_progress
    -- -------------------------------------------------------
    FOR i IN 1..v_zarina_lessons LOOP
        INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used, completed_at)
        VALUES (v_zarina, v_l[i], 'COMPLETED', 95, 1,
                now() - make_interval(days := (v_zarina_lessons - i + 1) * 4))
        ON CONFLICT (user_id, lesson_id) DO NOTHING;

        INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
        VALUES (v_zarina, 'LESSON_COMPLETE', v_lesson_xp[i], v_l[i],
                now() - make_interval(days := (v_zarina_lessons - i + 1) * 4));
        v_zarina_xp := v_zarina_xp + v_lesson_xp[i];

        -- Задача 1 — верно, задача 2 — верно, задача 3 — с подсказкой (с первой попытки)
        FOR j IN 1..3 LOOP
            INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
            SELECT v_zarina,
                   v_t[(i-1)*3 + j],
                   sol.solution,
                   true,
                   CASE WHEN j < 3 THEN t.xp_reward ELSE t.xp_reward - 15 END,
                   now() - make_interval(days := (v_zarina_lessons - i + 1) * 4) + make_interval(hours := j)
            FROM tasks t
            JOIN (SELECT id, solution FROM tasks WHERE id = v_t[(i-1)*3 + j]) sol ON sol.id = t.id
            WHERE t.id = v_t[(i-1)*3 + j];

            INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
            SELECT v_zarina, 'TASK_SOLVED',
                   CASE WHEN j < 3 THEN xp_reward ELSE xp_reward - 15 END,
                   v_t[(i-1)*3 + j],
                   now() - make_interval(days := (v_zarina_lessons - i + 1) * 4) + make_interval(hours := j)
            FROM tasks WHERE id = v_t[(i-1)*3 + j];

            SELECT v_zarina_xp + CASE WHEN j < 3 THEN xp_reward ELSE xp_reward - 15 END INTO v_zarina_xp
            FROM tasks WHERE id = v_t[(i-1)*3 + j];
        END LOOP;

        -- Квиз: 4 из 5 правильных
        SELECT array_agg(id ORDER BY sort_order) INTO v_qids
        FROM quiz_questions WHERE quiz_id = v_q[i];

        SELECT jsonb_object_agg(qid::text, '[0]'::jsonb)
        INTO v_answers
        FROM unnest(v_qids) AS qid;

        INSERT INTO quiz_attempts (user_id, quiz_id, answers, score, max_score, xp_earned, started_at, finished_at)
        VALUES (v_zarina, v_q[i], COALESCE(v_answers, '{}'),
                4, 5, (v_quiz_xp[i] * 4 / 5),
                now() - make_interval(days := (v_zarina_lessons - i + 1) * 4) + interval '2 hours',
                now() - make_interval(days := (v_zarina_lessons - i + 1) * 4) + interval '2 hours 20 minutes');

        INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
        VALUES (v_zarina, 'QUIZ_PASSED', (v_quiz_xp[i] * 4 / 5), v_q[i],
                now() - make_interval(days := (v_zarina_lessons - i + 1) * 4) + interval '2 hours 20 minutes');
        v_zarina_xp := v_zarina_xp + (v_quiz_xp[i] * 4 / 5);
    END LOOP;

    -- Урок 5 для Зарины: in_progress + одна задача решена
    INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used)
    VALUES (v_zarina, v_l[5], 'IN_PROGRESS', 0, 1)
    ON CONFLICT (user_id, lesson_id) DO NOTHING;

    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    SELECT v_zarina, v_t[13], solution, true, xp_reward, now() - interval '1 day'
    FROM tasks WHERE id = v_t[13];

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    SELECT v_zarina, 'TASK_SOLVED', xp_reward, v_t[13], now() - interval '1 day'
    FROM tasks WHERE id = v_t[13];
    SELECT v_zarina_xp + xp_reward INTO v_zarina_xp FROM tasks WHERE id = v_t[13];

    -- -------------------------------------------------------
    -- ТИМУР: урок 1 завершён, на уроке 2 in_progress
    -- -------------------------------------------------------
    INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used, completed_at)
    VALUES (v_timur, v_l[1], 'COMPLETED', 80, 2, now() - interval '8 days')
    ON CONFLICT (user_id, lesson_id) DO NOTHING;

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    VALUES (v_timur, 'LESSON_COMPLETE', v_lesson_xp[1], v_l[1], now() - interval '8 days');
    v_timur_xp := v_timur_xp + v_lesson_xp[1];

    -- Задача 1: правильно со 2-й попытки (сначала неверно)
    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    VALUES (v_timur, v_t[1], 'Wrong answer', false, 0, now() - interval '9 days');

    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    SELECT v_timur, v_t[1], solution, true, xp_reward - 10, now() - interval '8 days 22 hours'
    FROM tasks WHERE id = v_t[1];

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    SELECT v_timur, 'TASK_SOLVED', xp_reward - 10, v_t[1], now() - interval '8 days 22 hours'
    FROM tasks WHERE id = v_t[1];
    SELECT v_timur_xp + xp_reward - 10 INTO v_timur_xp FROM tasks WHERE id = v_t[1];

    -- Задача 2: неверно
    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    VALUES (v_timur, v_t[2], 'wrong', false, 0, now() - interval '8 days 20 hours');

    -- Задача 3: верно
    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    SELECT v_timur, v_t[3], solution, true, xp_reward, now() - interval '8 days 18 hours'
    FROM tasks WHERE id = v_t[3];

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    SELECT v_timur, 'TASK_SOLVED', xp_reward, v_t[3], now() - interval '8 days 18 hours'
    FROM tasks WHERE id = v_t[3];
    SELECT v_timur_xp + xp_reward INTO v_timur_xp FROM tasks WHERE id = v_t[3];

    -- Квиз 1 для Тимура: 3 из 5
    SELECT array_agg(id ORDER BY sort_order) INTO v_qids
    FROM quiz_questions WHERE quiz_id = v_q[1];

    SELECT jsonb_object_agg(qid::text, '[0]'::jsonb)
    INTO v_answers
    FROM unnest(v_qids) AS qid;

    INSERT INTO quiz_attempts (user_id, quiz_id, answers, score, max_score, xp_earned, started_at, finished_at)
    VALUES (v_timur, v_q[1], COALESCE(v_answers, '{}'),
            3, 5, 60,
            now() - interval '8 days' + interval '3 hours',
            now() - interval '8 days' + interval '3 hours 30 minutes');

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    VALUES (v_timur, 'QUIZ_PASSED', 60, v_q[1],
            now() - interval '8 days' + interval '3 hours 30 minutes');
    v_timur_xp := v_timur_xp + 60;

    -- Тимур: урок 2 in_progress
    INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used)
    VALUES (v_timur, v_l[2], 'IN_PROGRESS', 0, 0)
    ON CONFLICT (user_id, lesson_id) DO NOTHING;

    -- -------------------------------------------------------
    -- USER LEVELS (уровни)
    -- -------------------------------------------------------
    INSERT INTO user_levels (user_id, current_level, total_xp, updated_at)
    VALUES (v_daniyar, 8, v_daniyar_xp, now())
    ON CONFLICT (user_id) DO UPDATE
        SET current_level = 8, total_xp = v_daniyar_xp, updated_at = now();

    INSERT INTO user_levels (user_id, current_level, total_xp, updated_at)
    VALUES (v_zarina, 5, v_zarina_xp, now())
    ON CONFLICT (user_id) DO UPDATE
        SET current_level = 5, total_xp = v_zarina_xp, updated_at = now();

    INSERT INTO user_levels (user_id, current_level, total_xp, updated_at)
    VALUES (v_timur, 2, v_timur_xp, now())
    ON CONFLICT (user_id) DO UPDATE
        SET current_level = 2, total_xp = v_timur_xp, updated_at = now();

    -- -------------------------------------------------------
    -- БЕЙДЖИ
    -- -------------------------------------------------------

    -- Данияр (уровень 8, 7 уроков, 21 задача, 7 идеальных квизов, >1000 XP)
    INSERT INTO user_badges (user_id, badge_id, awarded_at)
    SELECT v_daniyar, id, now() - interval '20 days'
    FROM badge_definitions
    WHERE name IN ('Первые шаги', 'Почемучка', 'Уравновешенный',
                   'Математик', 'Отличник', 'Уровень 3', 'Уровень 5', 'XP Охотник')
    ON CONFLICT (user_id, badge_id) DO NOTHING;

    -- Зарина (уровень 5, 4 урока, 12 задач, 4 квиза по 4/5, >1000 XP)
    INSERT INTO user_badges (user_id, badge_id, awarded_at)
    SELECT v_zarina, id, now() - interval '10 days'
    FROM badge_definitions
    WHERE name IN ('Первые шаги', 'Почемучка', 'Уровень 3', 'Уровень 5', 'XP Охотник')
    ON CONFLICT (user_id, badge_id) DO NOTHING;

    -- Тимур (уровень 2, 1 урок)
    INSERT INTO user_badges (user_id, badge_id, awarded_at)
    SELECT v_timur, id, now() - interval '7 days'
    FROM badge_definitions
    WHERE name = 'Первые шаги'
    ON CONFLICT (user_id, badge_id) DO NOTHING;

END $$;