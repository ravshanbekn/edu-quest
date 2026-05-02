-- ============================================================
-- V7: Full demo dataset | Higher Mathematics
-- "Algebra, Trigonometry and Introduction to Calculus"
-- 4 blocks · 10 lessons · 30 tasks · 60 hints
-- 10 quizzes · 50 questions · 3 students with progress
-- ============================================================

-- ============================================================
-- 1. USERS
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
     'EduQuest Administrator',
     'System administrator of the EduQuest platform.',
     false),
    ((SELECT id FROM users WHERE email = 'asyl.nurlanovna@eduquest.kz'),
     'Dr. Asel Nurlanova',
     'Professor of Mathematics, KazNU. Candidate of Physical and Mathematical Sciences. Author of 3 textbooks on higher mathematics. Specialization: mathematical analysis and linear algebra.',
     true),
    ((SELECT id FROM users WHERE email = 'daniyar.bekzhanov@eduquest.kz'),
     'Daniyar Bekzhanov',
     'Third-year IT student. Interested in applied mathematics and machine learning. Goal: graduate studies in Data Science.',
     true),
    ((SELECT id FROM users WHERE email = 'zarina.alibekova@eduquest.kz'),
     'Zarina Alibekova',
     'Economics faculty student. Studying mathematics for financial modelling and Data Science.',
     true),
    ((SELECT id FROM users WHERE email = 'timur.seitkali@eduquest.kz'),
     'Timur Seitkali',
     'First-year physics student. Just starting to study higher mathematics.',
     true)
ON CONFLICT (user_id) DO NOTHING;

-- Roles
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

-- enrollment:self for ADMIN
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.code = 'enrollment:self'
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. COURSE
-- ============================================================

INSERT INTO courses (teacher_id, title, description, cover_url, is_published) VALUES
    ((SELECT id FROM users WHERE email = 'asyl.nurlanovna@eduquest.kz'),
     'Higher Mathematics: from Algebra to Calculus',
     'A fundamental course for students of technical specialties. '
     'Covers: algebra of functions, trigonometry, limits, derivatives and integrals. '
     'Each topic includes theory, a video lecture, tasks with hints, and a quiz. '
     'Level: advanced (school-level mathematics required).',
     'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&auto=format&fit=crop',
     true);

-- ============================================================
-- 3. BLOCKS (4 blocks)
-- ============================================================

INSERT INTO blocks (course_id, title, sort_order)
SELECT c.id, b.title, b.ord
FROM courses c
CROSS JOIN (VALUES
    ('Block 1: Algebra and Functions',                  0),
    ('Block 2: Exponents, Logarithms and Exponentials', 1),
    ('Block 3: Trigonometry',                           2),
    ('Block 4: Introduction to Calculus',               3)
) AS b(title, ord)
WHERE c.title = 'Higher Mathematics: from Algebra to Calculus';

-- ============================================================
-- 4. LESSONS (10 lessons)
-- ============================================================

-- Block 1: 3 lessons
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Functions and Their Properties',          'THEORY',   0,  60),
    ('Quadratic Equations and the Discriminant','PRACTICE', 1,  80),
    ('Systems of Linear Equations',             'MIXED',    2,  90)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Block 1: Algebra and Functions';

-- Block 2: 2 lessons
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Powers and Roots: Properties and Calculations', 'THEORY',   0,  70),
    ('Logarithms and Their Properties',               'MIXED',    1, 100)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Block 2: Exponents, Logarithms and Exponentials';

-- Block 3: 2 lessons
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Trigonometric Functions and the Unit Circle', 'THEORY',   0, 100),
    ('Trigonometric Equations',                     'PRACTICE', 1, 120)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Block 3: Trigonometry';

-- Block 4: 3 lessons
INSERT INTO lessons (block_id, title, type, sort_order, xp_reward)
SELECT b.id, l.title, l.ltype, l.ord, l.xp
FROM blocks b
CROSS JOIN (VALUES
    ('Limits of Functions and Continuity',    'THEORY',   0, 120),
    ('Derivatives: Rules and Applications',   'MIXED',    1, 150),
    ('Integrals: Indefinite and Definite',    'PRACTICE', 2, 150)
) AS l(title, ltype, ord, xp)
WHERE b.title = 'Block 4: Introduction to Calculus';

-- ============================================================
-- 5. LESSON CONTENT (TEXT + VIDEO + IMAGE per lesson)
-- ============================================================

-- Lesson 1: Functions and Their Properties
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## The Concept of a Function\n\n'
     'A function is a rule that assigns to every element of set X (domain) '
     'exactly one element of set Y (range).\n\n'
     '**Notation:** y = f(x), where x is the argument, y is the function value.\n\n'
     '### Key Characteristics\n'
     '- **Domain D(f)** — all permissible values of x\n'
     '- **Range E(f)** — all possible values of y\n'
     '- **Even:** f(-x) = f(x); **Odd:** f(-x) = -f(x)\n'
     '- **Increasing/Decreasing** — monotonicity of the function\n\n'
     '### Examples\n'
     '| Function | D(f) | Type |\n'
     '|----------|------|------|\n'
     '| f(x) = x² | ℝ | even |\n'
     '| f(x) = x³ | ℝ | odd |\n'
     '| f(x) = √x | [0; +∞) | general |\n'
     '| f(x) = 1/x | ℝ \\ {0} | odd |',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Introduction to the concept of a function. Domain, range, even and odd functions.',
     'https://www.youtube.com/watch?v=kvGsIo1TmsM', 1),
    ('IMAGE',
     'Cartesian coordinate system and examples of basic function graphs',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Cartesian-coordinate-system.svg/600px-Cartesian-coordinate-system.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Functions and Their Properties';

-- Lesson 2: Quadratic Equations
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Quadratic Equation\n\n'
     'An equation of the form **ax² + bx + c = 0**, where a ≠ 0.\n\n'
     '### Discriminant Formula\n'
     '**D = b² − 4ac**\n\n'
     '### Discriminant Analysis\n'
     '| Condition | Number of roots |\n'
     '|-----------|-----------------|\n'
     '| D > 0 | 2 real roots |\n'
     '| D = 0 | 1 root (repeated) |\n'
     '| D < 0 | No real roots |\n\n'
     '### Root Formula\n'
     'x₁,₂ = (−b ± √D) / (2a)\n\n'
     '### Vieta''s Theorem\n'
     'x₁ + x₂ = −b/a &emsp; x₁ · x₂ = c/a',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Solving quadratic equations. Discriminant and Vieta''s theorem.',
     'https://www.youtube.com/watch?v=2ZzuZvz33X0', 1),
    ('IMAGE',
     'Parabola y = ax² + bx + c and its position relative to the x-axis depending on the sign of D',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Parabola_with_focus_and_directrix.svg/600px-Parabola_with_focus_and_directrix.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Quadratic Equations and the Discriminant';

-- Lesson 3: Systems of Linear Equations
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Systems of Linear Equations\n\n'
     'A system of two equations with two unknowns:\n'
     '{ a₁x + b₁y = c₁\n'
     '{ a₂x + b₂y = c₂\n\n'
     '### Solution Methods\n\n'
     '**1. Substitution method:**\n'
     'Express one variable in terms of the other from one equation and substitute into the second.\n\n'
     '**2. Elimination method (addition):**\n'
     'Multiply equations by coefficients so that one variable cancels when added.\n\n'
     '### Types of Systems\n'
     '- **Consistent** (has a solution): lines intersect or coincide\n'
     '- **Inconsistent** (no solution): lines are parallel\n'
     '- **Determinate**: unique solution\n'
     '- **Indeterminate**: infinitely many solutions',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Systems of equations — substitution method and elimination method.',
     'https://www.youtube.com/watch?v=nok99JOhcjo', 1),
    ('TEXT',
     E'### Example: solving by the elimination method\n\n'
     'System: { 2x + 3y = 12; 4x − 3y = 6 }\n\n'
     'Add the equations: 6x = 18 → x = 3\n'
     'Substitute: 2(3) + 3y = 12 → 3y = 6 → y = 2\n\n'
     '**Answer:** x = 3, y = 2\n\n'
     'Check: 2·3 + 3·2 = 12 ✓; 4·3 − 3·2 = 6 ✓',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Systems of Linear Equations';

-- Lesson 4: Powers and Roots
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Powers and Roots\n\n'
     '### Properties of Powers (a > 0)\n'
     '| Rule | Formula |\n'
     '|------|---------|\n'
     '| Product | aᵐ · aⁿ = aᵐ⁺ⁿ |\n'
     '| Quotient | aᵐ / aⁿ = aᵐ⁻ⁿ |\n'
     '| Power of a power | (aᵐ)ⁿ = aᵐⁿ |\n'
     '| Zero exponent | a⁰ = 1 |\n'
     '| Negative exponent | a⁻ⁿ = 1/aⁿ |\n'
     '| Fractional exponent | aᵐ/ⁿ = ⁿ√aᵐ |\n\n'
     '### Simplifying Roots\n'
     '√72 = √(36·2) = 6√2\n'
     '³√54 = ³√(27·2) = 3·³√2',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Properties of powers and roots. Simplifying expressions.',
     'https://www.youtube.com/watch?v=XZRQhkii0h0', 1),
    ('TEXT',
     E'### Exponential Equations\n\n'
     'An equation of the form **aˣ = aⁿ** is solved by equating the exponents: x = n.\n\n'
     '**Example:** 2ˣ = 32 → 2ˣ = 2⁵ → x = 5\n\n'
     '**Example:** 3^(2x-1) = 27 → 3^(2x-1) = 3³ → 2x−1 = 3 → x = 2',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Powers and Roots: Properties and Calculations';

-- Lesson 5: Logarithms
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Logarithms\n\n'
     '**Definition:** log_a(b) = x means aˣ = b (a > 0, a ≠ 1, b > 0)\n\n'
     '### Key Properties\n'
     '| Property | Formula |\n'
     '|----------|---------|\n'
     '| Log of 1 | log_a(1) = 0 |\n'
     '| Log of base | log_a(a) = 1 |\n'
     '| Product | log_a(bc) = log_a(b) + log_a(c) |\n'
     '| Quotient | log_a(b/c) = log_a(b) − log_a(c) |\n'
     '| Power | log_a(bⁿ) = n·log_a(b) |\n'
     '| Change of base | log_a(b) = log_c(b) / log_c(a) |\n\n'
     '### Special Logarithms\n'
     '- **lg(x)** = log₁₀(x) — common logarithm\n'
     '- **ln(x)** = log_e(x) — natural logarithm, e ≈ 2.718',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Logarithms — definition, properties, calculation.',
     'https://www.youtube.com/watch?v=Z5myJ8dg_rM', 1),
    ('IMAGE',
     'Graphs of logarithmic functions with different bases',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Log_different_bases.svg/600px-Log_different_bases.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Logarithms and Their Properties';

-- Lesson 6: Trigonometric Functions
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Trigonometric Functions\n\n'
     '### Definitions via the Unit Circle\n'
     'For angle x (in radians): the point on the unit circle is (cos x, sin x)\n\n'
     '### Values at Key Angles\n'
     '| Angle | sin | cos | tan |\n'
     '|-------|-----|-----|-----|\n'
     '| 0° | 0 | 1 | 0 |\n'
     '| 30° = π/6 | 1/2 | √3/2 | 1/√3 |\n'
     '| 45° = π/4 | √2/2 | √2/2 | 1 |\n'
     '| 60° = π/3 | √3/2 | 1/2 | √3 |\n'
     '| 90° = π/2 | 1 | 0 | — |\n\n'
     '### Fundamental Identities\n'
     '- sin²x + cos²x = 1 (Pythagorean identity)\n'
     '- tan(x) = sin(x)/cos(x)\n'
     '- sin(2x) = 2·sin(x)·cos(x)\n'
     '- cos(2x) = cos²x − sin²x',
     NULL, 0),
    ('VIDEO',
     'Video lecture: The unit circle and trigonometric functions.',
     'https://www.youtube.com/watch?v=yBw67Fb31Cs', 1),
    ('IMAGE',
     'Unit circle with angles and sin/cos values',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Unit_circle_angles_color.svg/600px-Unit_circle_angles_color.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Trigonometric Functions and the Unit Circle';

-- Lesson 7: Trigonometric Equations
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Trigonometric Equations\n\n'
     '### General Solutions\n'
     '| Equation | General solution |\n'
     '|----------|------------------|\n'
     '| sin(x) = 0 | x = πn, n ∈ ℤ |\n'
     '| cos(x) = 0 | x = π/2 + πn |\n'
     '| sin(x) = a, |a| ≤ 1 | x = (−1)ⁿ·arcsin(a) + πn |\n'
     '| cos(x) = a, |a| ≤ 1 | x = ±arccos(a) + 2πn |\n'
     '| tan(x) = a | x = arctan(a) + πn |\n\n'
     '### Important!\n'
     'The equation sin(x) = a or cos(x) = a **has no solutions** if |a| > 1.',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Solving trigonometric equations. General solution formulas.',
     'https://www.youtube.com/watch?v=FhD9GBdVGXQ', 1),
    ('TEXT',
     E'### Example: solve 2sin(x) − 1 = 0 on [0; 2π]\n\n'
     '1. sin(x) = 1/2\n'
     '2. Reference angle: arcsin(1/2) = π/6\n'
     '3. Solutions in [0; 2π]: x = π/6 and x = π − π/6 = 5π/6\n\n'
     '**Answer:** x = π/6, x = 5π/6',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Trigonometric Equations';

-- Lesson 8: Limits
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Limits of Functions\n\n'
     '**Definition:** lim(x→a) f(x) = L means that as x → a, the values f(x) '
     'get arbitrarily close to L.\n\n'
     '### Properties of Limits\n'
     '- lim(c) = c (limit of a constant)\n'
     '- lim(x→a) [f + g] = lim f + lim g\n'
     '- lim(x→a) [f · g] = lim f · lim g\n\n'
     '### Remarkable Limits\n'
     '1. **First:** lim(x→0) sin(x)/x = **1**\n'
     '2. **Second:** lim(x→∞) (1 + 1/x)ˣ = **e ≈ 2.718**\n\n'
     '### Continuity\n'
     'f(x) is continuous at x₀ if lim(x→x₀) f(x) = f(x₀)',
     NULL, 0),
    ('VIDEO',
     'Video lecture: The concept of a limit. Remarkable limits. Continuity.',
     'https://www.youtube.com/watch?v=riXcZT2ICjA', 1),
    ('TEXT',
     E'### Resolving the 0/0 Indeterminate Form\n\n'
     'lim(x→2) (x² − 4)/(x − 2)\n\n'
     '= lim(x→2) (x−2)(x+2)/(x−2)\n\n'
     '= lim(x→2) (x+2) = **4**\n\n'
     '### Limit at Infinity\n\n'
     'lim(x→∞) (3x² + 2x)/(x² − 1)\n\n'
     'Divide numerator and denominator by x²:\n\n'
     '= lim(x→∞) (3 + 2/x)/(1 − 1/x²) = **3**',
     NULL, 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Limits of Functions and Continuity';

-- Lesson 9: Derivative
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Derivative of a Function\n\n'
     '**Definition:** f''(x) = lim(Δx→0) [f(x+Δx) − f(x)] / Δx\n\n'
     'Geometric meaning: **the slope of the tangent line** to the graph at point x.\n\n'
     '### Table of Derivatives\n'
     '| Function | Derivative |\n'
     '|----------|------------|\n'
     '| C (constant) | 0 |\n'
     '| xⁿ | n·xⁿ⁻¹ |\n'
     '| eˣ | eˣ |\n'
     '| ln(x) | 1/x |\n'
     '| sin(x) | cos(x) |\n'
     '| cos(x) | −sin(x) |\n\n'
     '### Differentiation Rules\n'
     '- **(u + v)'' = u'' + v''**\n'
     '- **(u · v)'' = u''v + uv''** (product rule)\n'
     '- **(u/v)'' = (u''v − uv'') / v²** (quotient rule)\n'
     '- **(f(g(x)))'' = f''(g(x)) · g''(x)** (chain rule)',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Derivative of a function. Differentiation rules.',
     'https://www.youtube.com/watch?v=ANyVpMS3HL4', 1),
    ('IMAGE',
     'Tangent to a curve — geometric meaning of the derivative',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Tangent_to_a_curve.svg/600px-Tangent_to_a_curve.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Derivatives: Rules and Applications';

-- Lesson 10: Integrals
INSERT INTO lesson_content (lesson_id, content_type, body, video_url, sort_order)
SELECT l.id, c.ctype, c.body, c.vurl, c.ord
FROM lessons l
CROSS JOIN (VALUES
    ('TEXT',
     E'## Integrals\n\n'
     '### Indefinite Integral\n'
     '∫f(x)dx = F(x) + C, where F''(x) = f(x) — antiderivative\n\n'
     '### Table of Integrals\n'
     '| f(x) | ∫f(x)dx |\n'
     '|------|----------|\n'
     '| xⁿ (n ≠ −1) | xⁿ⁺¹/(n+1) + C |\n'
     '| 1/x | ln|x| + C |\n'
     '| eˣ | eˣ + C |\n'
     '| sin(x) | −cos(x) + C |\n'
     '| cos(x) | sin(x) + C |\n\n'
     '### Definite Integral\n'
     '**Newton–Leibniz formula:**\n'
     '∫ₐᵇ f(x)dx = F(b) − F(a)\n\n'
     'Geometric meaning: **area under the curve** y=f(x) from a to b.',
     NULL, 0),
    ('VIDEO',
     'Video lecture: Indefinite and definite integrals. The Newton–Leibniz formula.',
     'https://www.youtube.com/watch?v=rfG8ce4nNh0', 1),
    ('IMAGE',
     'Geometric meaning of the definite integral — area under the curve',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Integral_as_region_under_curve.svg/600px-Integral_as_region_under_curve.svg.png', 2)
) AS c(ctype, body, vurl, ord)
WHERE l.title = 'Integrals: Indefinite and Definite';

-- ============================================================
-- 6. TASKS (3 per lesson = 30 tasks)
-- ============================================================

-- Lesson 1: Functions
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Given f(x) = 2x² − 3x + 1. Find f(−2).', '15', 75, 0),
    ('Find the domain of f(x) = √(x − 3) / (x − 7). Write the answer as inequalities.', 'x >= 3, x != 7', 90, 1),
    ('Is f(x) = x⁴ − 2x² even, odd, or neither? Justify using the definition.', 'even', 90, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Functions and Their Properties';

-- Lesson 2: Quadratic Equations
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Solve using the discriminant: x² − 7x + 10 = 0', 'x = 2, x = 5', 75, 0),
    ('Find the roots of the equation: 2x² + 5x − 3 = 0', 'x = 0.5, x = -3', 90, 1),
    ('For what value of k does kx² − 4x + 1 = 0 have exactly one root?', 'k = 4', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Quadratic Equations and the Discriminant';

-- Lesson 3: Systems of Equations
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Solve the system by substitution: x + 2y = 7 and 3x − y = 7', 'x = 3, y = 2', 75, 0),
    ('Solve the system by elimination: 2x + 3y = 12 and 4x − 3y = 6', 'x = 3, y = 2', 75, 1),
    ('Determine the type of system (consistent/inconsistent): 2x − 4y = 6 and x − 2y = 4', 'inconsistent', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Systems of Linear Equations';

-- Lesson 4: Powers and Roots
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Simplify: (3² · 3⁵) / 3⁴', '27', 75, 0),
    ('Compute ⁴√(81 · x⁸) for x > 0. Write as a power.', '3x²', 90, 1),
    ('Solve the equation: 4^x = 128. Hint: express both sides as powers of two.', 'x = 3.5', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Powers and Roots: Properties and Calculations';

-- Lesson 5: Logarithms
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Compute: log₃(243)', '5', 75, 0),
    ('Solve the equation: log₂(x − 1) = 4', '17', 90, 1),
    ('Simplify: log₅(25) + log₅(5) − log₅(1)', '3', 90, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Logarithms and Their Properties';

-- Lesson 6: Trigonometric Functions
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Compute exactly: sin(π/6) + cos(π/3). Write as a number.', '1', 75, 0),
    ('Simplify: sin²(x) + cos²(x) + tan(x)·cot(x). Write the result.', '2', 90, 1),
    ('Find the exact value of sin(210°). Use reduction formulas.', '-1/2', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Trigonometric Functions and the Unit Circle';

-- Lesson 7: Trigonometric Equations
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Find all solutions of sin(x) = √3/2 on [0; 2π]. List them separated by a comma.', 'x = π/3, x = 2π/3', 90, 0),
    ('Write the general solution of the equation: cos(x) = 0', 'x = π/2 + πn', 75, 1),
    ('Solve 2cos(x) + √3 = 0 on [0; 2π]. List all solutions.', 'x = 5π/6, x = 7π/6', 100, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Trigonometric Equations';

-- Lesson 8: Limits
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Compute the limit by resolving the indeterminate form: lim(x→3) (x² − 9)/(x − 3)', '6', 75, 0),
    ('Using the first remarkable limit, find: lim(x→0) sin(5x)/(3x)', '5/3', 100, 1),
    ('Find the limit: lim(x→∞) (5x³ − 2x) / (2x³ + 7)', '5/2', 90, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Limits of Functions and Continuity';

-- Lesson 9: Derivative
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Find the derivative: f(x) = 3x⁴ − 2x² + 5x − 1', 'f''(x) = 12x³ − 4x + 5', 75, 0),
    ('Find the derivative of the composite function: f(x) = (2x + 1)⁵', 'f''(x) = 10(2x + 1)⁴', 100, 1),
    ('At what value of x does f(x) = x³ − 3x² have a minimum? Find it using the derivative.', '2', 110, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Derivatives: Rules and Applications';

-- Lesson 10: Integrals
INSERT INTO tasks (lesson_id, description, solution, task_type, xp_reward, sort_order)
SELECT l.id, t.descr, t.sol, 'TEXT', t.xp, t.ord
FROM lessons l
CROSS JOIN (VALUES
    ('Find the indefinite integral: ∫(4x³ − 6x + 2)dx', 'x⁴ − 3x² + 2x + C', 75, 0),
    ('Compute the definite integral: ∫₀² (3x² + 2)dx', '12', 90, 1),
    ('Find the area of the region bounded by y = x², the x-axis, and the lines x=0, x=3.', '9', 110, 2)
) AS t(descr, sol, xp, ord)
WHERE l.title = 'Integrals: Indefinite and Definite';

-- ============================================================
-- 7. HINTS (2 per task = 60 hints)
-- ============================================================

-- Lesson 1 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Substitute x = −2: 2·(−2)² − 3·(−2) + 1', 0),
    ('(−2)² = 4, so 2·4 = 8. Then: 8 + 6 + 1 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Functions and Their Properties'
  AND t.description = 'Given f(x) = 2x² − 3x + 1. Find f(−2).';

-- Lesson 1 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('For √(x−3) we need x − 3 ≥ 0, i.e. x ≥ 3', 0),
    ('The denominator cannot be zero: x − 7 ≠ 0, so x ≠ 7', 1)
) AS h(content, ord)
WHERE l.title = 'Functions and Their Properties'
  AND t.description = 'Find the domain of f(x) = √(x − 3) / (x − 7). Write the answer as inequalities.';

-- Lesson 1 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Check: f(−x) = (−x)⁴ − 2(−x)². Simplify.', 0),
    ('(−x)⁴ = x⁴ and (−x)² = x², so f(−x) = x⁴ − 2x² = f(x)', 1)
) AS h(content, ord)
WHERE l.title = 'Functions and Their Properties'
  AND t.description = 'Is f(x) = x⁴ − 2x² even, odd, or neither? Justify using the definition.';

-- Lesson 2 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('D = b² − 4ac = (−7)² − 4·1·10 = 49 − 40 = 9', 0),
    ('x₁,₂ = (7 ± √9)/2 = (7 ± 3)/2. Find two values.', 1)
) AS h(content, ord)
WHERE l.title = 'Quadratic Equations and the Discriminant'
  AND t.description = 'Solve using the discriminant: x² − 7x + 10 = 0';

-- Lesson 2 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('D = 5² − 4·2·(−3) = 25 + 24 = 49', 0),
    ('x₁,₂ = (−5 ± 7)/4. So x₁ = 2/4 = 0.5, x₂ = −12/4 = −3', 1)
) AS h(content, ord)
WHERE l.title = 'Quadratic Equations and the Discriminant'
  AND t.description = 'Find the roots of the equation: 2x² + 5x − 3 = 0';

-- Lesson 2 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('One root means D = 0. D = 16 − 4k.', 0),
    ('16 − 4k = 0 → k = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Quadratic Equations and the Discriminant'
  AND t.description = 'For what value of k does kx² − 4x + 1 = 0 have exactly one root?';

-- Lesson 3 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('From the first equation: x = 7 − 2y. Substitute into 3x − y = 7.', 0),
    ('3(7 − 2y) − y = 7 → 21 − 7y = 7 → y = 2', 1)
) AS h(content, ord)
WHERE l.title = 'Systems of Linear Equations'
  AND t.description = 'Solve the system by substitution: x + 2y = 7 and 3x − y = 7';

-- Lesson 3 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Add the equations: (2x + 3y) + (4x − 3y) = 12 + 6 → 6x = 18', 0),
    ('x = 3. Substitute into the first: 6 + 3y = 12 → y = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Systems of Linear Equations'
  AND t.description = 'Solve the system by elimination: 2x + 3y = 12 and 4x − 3y = 6';

-- Lesson 3 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('From the second equation: x = 2y + 4. Substitute into the first.', 0),
    ('2(2y+4) − 4y = 8 ≠ 6. Contradiction — the system is inconsistent.', 1)
) AS h(content, ord)
WHERE l.title = 'Systems of Linear Equations'
  AND t.description = 'Determine the type of system (consistent/inconsistent): 2x − 4y = 6 and x − 2y = 4';

-- Lesson 4 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('When multiplying powers with the same base, add exponents: 3² · 3⁵ = 3⁷', 0),
    ('3⁷ / 3⁴ = 3^(7−4) = 3³ = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Powers and Roots: Properties and Calculations'
  AND t.description = 'Simplify: (3² · 3⁵) / 3⁴';

-- Lesson 4 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('⁴√(a·b) = ⁴√a · ⁴√b. Apply this property.', 0),
    ('⁴√81 = 3 (since 3⁴ = 81), ⁴√x⁸ = x^(8/4) = x²', 1)
) AS h(content, ord)
WHERE l.title = 'Powers and Roots: Properties and Calculations'
  AND t.description = 'Compute ⁴√(81 · x⁸) for x > 0. Write as a power.';

-- Lesson 4 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('4 = 2², 128 = 2⁷. Write both numbers as powers of two.', 0),
    ('(2²)^x = 2^(2x) = 2⁷ → 2x = 7 → x = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Powers and Roots: Properties and Calculations'
  AND t.description = 'Solve the equation: 4^x = 128. Hint: express both sides as powers of two.';

-- Lesson 5 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Question: 3 to what power gives 243?', 0),
    ('3¹=3, 3²=9, 3³=27, 3⁴=81, 3⁵=243', 1)
) AS h(content, ord)
WHERE l.title = 'Logarithms and Their Properties'
  AND t.description = 'Compute: log₃(243)';

-- Lesson 5 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('log₂(x−1) = 4 means x − 1 = 2⁴', 0),
    ('2⁴ = 16, so x − 1 = 16 → x = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Logarithms and Their Properties'
  AND t.description = 'Solve the equation: log₂(x − 1) = 4';

-- Lesson 5 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('log₅(25) = log₅(5²) = 2, log₅(5) = 1, log₅(1) = 0', 0),
    ('2 + 1 − 0 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Logarithms and Their Properties'
  AND t.description = 'Simplify: log₅(25) + log₅(5) − log₅(1)';

-- Lesson 6 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('sin(π/6) = sin(30°) = 1/2', 0),
    ('cos(π/3) = cos(60°) = 1/2. Add them.', 1)
) AS h(content, ord)
WHERE l.title = 'Trigonometric Functions and the Unit Circle'
  AND t.description = 'Compute exactly: sin(π/6) + cos(π/3). Write as a number.';

-- Lesson 6 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('sin²x + cos²x = 1 (Pythagorean identity)', 0),
    ('tan(x)·cot(x) = sin(x)/cos(x) · cos(x)/sin(x) = 1. Total: 1 + 1 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Trigonometric Functions and the Unit Circle'
  AND t.description = 'Simplify: sin²(x) + cos²(x) + tan(x)·cot(x). Write the result.';

-- Lesson 6 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('210° = 180° + 30°. Use the formula: sin(180°+α) = −sin(α)', 0),
    ('sin(210°) = −sin(30°) = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Trigonometric Functions and the Unit Circle'
  AND t.description = 'Find the exact value of sin(210°). Use reduction formulas.';

-- Lesson 7 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('sin(α) = √3/2 → reference angle α = π/3', 0),
    ('In [0;2π] sin > 0 in quadrants I and II: x = π/3 and x = π − π/3 = 2π/3', 1)
) AS h(content, ord)
WHERE l.title = 'Trigonometric Equations'
  AND t.description = 'Find all solutions of sin(x) = √3/2 on [0; 2π]. List them separated by a comma.';

-- Lesson 7 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('cos(x) = 0 at points x = π/2 and x = 3π/2, etc.', 0),
    ('General formula: x = π/2 + πn, where n is any integer', 1)
) AS h(content, ord)
WHERE l.title = 'Trigonometric Equations'
  AND t.description = 'Write the general solution of the equation: cos(x) = 0';

-- Lesson 7 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('cos(x) = −√3/2. Reference angle arccos(√3/2) = π/6. cos < 0 in quadrants II and III.', 0),
    ('Quadrant II: x = π − π/6 = 5π/6. Quadrant III: x = π + π/6 = 7π/6', 1)
) AS h(content, ord)
WHERE l.title = 'Trigonometric Equations'
  AND t.description = 'Solve 2cos(x) + √3 = 0 on [0; 2π]. List all solutions.';

-- Lesson 8 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Factor the numerator: x² − 9 = (x−3)(x+3)', 0),
    ('Cancel (x−3): lim(x→3)(x+3) = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Limits of Functions and Continuity'
  AND t.description = 'Compute the limit by resolving the indeterminate form: lim(x→3) (x² − 9)/(x − 3)';

-- Lesson 8 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Write sin(5x)/(3x) = (5/3) · sin(5x)/(5x)', 0),
    ('By the first remarkable limit: lim(u→0) sin(u)/u = 1', 1)
) AS h(content, ord)
WHERE l.title = 'Limits of Functions and Continuity'
  AND t.description = 'Using the first remarkable limit, find: lim(x→0) sin(5x)/(3x)';

-- Lesson 8 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Divide numerator and denominator by the highest power x³', 0),
    ('After dividing by x³: (5 − 2/x²)/(2 + 7/x³) → as x→∞ you get ?', 1)
) AS h(content, ord)
WHERE l.title = 'Limits of Functions and Continuity'
  AND t.description = 'Find the limit: lim(x→∞) (5x³ − 2x) / (2x³ + 7)';

-- Lesson 9 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('(xⁿ)'' = n·xⁿ⁻¹. Apply to each term.', 0),
    ('(3x⁴)'' = 12x³, (−2x²)'' = −4x, (5x)'' = 5, (−1)'' = 0', 1)
) AS h(content, ord)
WHERE l.title = 'Derivatives: Rules and Applications'
  AND t.description = 'Find the derivative: f(x) = 3x⁴ − 2x² + 5x − 1';

-- Lesson 9 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Chain rule: [g(u)]'' = n·g(u)^(n−1) · g''(u)', 0),
    ('Outer function: u⁵, inner: u = 2x+1. (u⁵)'' = 5u⁴, (2x+1)'' = 2', 1)
) AS h(content, ord)
WHERE l.title = 'Derivatives: Rules and Applications'
  AND t.description = 'Find the derivative of the composite function: f(x) = (2x + 1)⁵';

-- Lesson 9 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('f''(x) = 3x² − 6x = 3x(x − 2). Set equal to zero.', 0),
    ('Critical points: x=0 and x=2. f''''(x) = 6x−6. f''''(2)=6>0 → x=2 is minimum', 1)
) AS h(content, ord)
WHERE l.title = 'Derivatives: Rules and Applications'
  AND t.description = 'At what value of x does f(x) = x³ − 3x² have a minimum? Find it using the derivative.';

-- Lesson 10 task 1
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('∫xⁿdx = xⁿ⁺¹/(n+1) + C. Apply to each term.', 0),
    ('∫4x³dx = x⁴, ∫(−6x)dx = −3x², ∫2dx = 2x. Don''t forget +C.', 1)
) AS h(content, ord)
WHERE l.title = 'Integrals: Indefinite and Definite'
  AND t.description = 'Find the indefinite integral: ∫(4x³ − 6x + 2)dx';

-- Lesson 10 task 2
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Find the antiderivative: F(x) = x³ + 2x', 0),
    ('Apply the Newton–Leibniz formula: F(2) − F(0) = (8+4) − (0+0) = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Integrals: Indefinite and Definite'
  AND t.description = 'Compute the definite integral: ∫₀² (3x² + 2)dx';

-- Lesson 10 task 3
INSERT INTO hints (task_id, content, sort_order, xp_penalty)
SELECT t.id, h.content, h.ord, 15
FROM tasks t JOIN lessons l ON l.id = t.lesson_id
CROSS JOIN (VALUES
    ('Area = ∫₀³ x²dx. Find the antiderivative of x²: it is x³/3.', 0),
    ('[x³/3]₀³ = 3³/3 − 0 = 27/3 = ?', 1)
) AS h(content, ord)
WHERE l.title = 'Integrals: Indefinite and Definite'
  AND t.description = 'Find the area of the region bounded by y = x², the x-axis, and the lines x=0, x=3.';

-- ============================================================
-- 8. QUIZZES (1 per lesson = 10 quizzes)
-- ============================================================

INSERT INTO quizzes (lesson_id, title, time_limit, xp_reward)
SELECT l.id, q.title, q.tlimit, q.xp
FROM lessons l
JOIN (VALUES
    ('Functions and Their Properties',                  'Quiz: Functions',              600, 100),
    ('Quadratic Equations and the Discriminant',        'Quiz: Quadratic Equations',    600, 100),
    ('Systems of Linear Equations',                     'Quiz: Systems of Equations',   600, 100),
    ('Powers and Roots: Properties and Calculations',   'Quiz: Powers and Roots',       480, 100),
    ('Logarithms and Their Properties',                 'Quiz: Logarithms',             480, 100),
    ('Trigonometric Functions and the Unit Circle',     'Quiz: Trigonometry',           600, 120),
    ('Trigonometric Equations',                         'Quiz: Trig Equations',         600, 120),
    ('Limits of Functions and Continuity',              'Quiz: Limits',                 720, 150),
    ('Derivatives: Rules and Applications',             'Quiz: Derivatives',            720, 150),
    ('Integrals: Indefinite and Definite',              'Quiz: Integrals',              720, 150)
) AS q(ltitle, title, tlimit, xp) ON l.title = q.ltitle;

-- ============================================================
-- 9. QUIZ QUESTIONS (5 per quiz = 50 questions)
-- ============================================================

-- Quiz 1: Functions
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('What is f(2) if f(x) = x² + 3x − 1?',
     '["8", "9", "10", "5"]', '[1]', 0),
    ('Which of the following functions is even?',
     '["y = x³ + 1", "y = x² − 4", "y = sin(x) + x", "y = x + 5"]', '[1]', 1),
    ('Domain of f(x) = 1/(x−3):',
     '["All real numbers", "x ≠ 3", "x > 3", "x < 3"]', '[1]', 2),
    ('An even function is symmetric about:',
     '["The x-axis", "The y-axis", "The origin", "The line y = x"]', '[1]', 3),
    ('An odd function is symmetric about:',
     '["The x-axis", "The y-axis", "The origin", "The line y = x"]', '[2]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Functions and Their Properties';

-- Quiz 2: Quadratic Equations
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('The discriminant of x² − 6x + 5 = 0 equals:',
     '["16", "11", "4", "36"]', '[0]', 0),
    ('How many real roots does x² + 2x + 5 = 0 have?',
     '["0", "1", "2", "Infinitely many"]', '[0]', 1),
    ('The roots of x² − 5x + 6 = 0 are:',
     '["x=1, x=6", "x=2, x=3", "x=−2, x=−3", "x=0, x=5"]', '[1]', 2),
    ('By Vieta''s theorem, the sum of roots of 2x² − 6x + 4 = 0 is:',
     '["3", "6", "2", "−3"]', '[0]', 3),
    ('By Vieta''s theorem, the product of roots of 2x² − 6x + 4 = 0 is:',
     '["4", "2", "3", "−2"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Quadratic Equations and the Discriminant';

-- Quiz 3: Systems of Equations
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('How many solutions: y = 2x+1 and y = 2x−3?',
     '["0", "1", "2", "Infinitely many"]', '[0]', 0),
    ('Solution of x+y=5 and x−y=1:',
     '["x=3, y=2", "x=2, y=3", "x=4, y=1", "x=1, y=4"]', '[0]', 1),
    ('Under what condition is a system inconsistent?',
     '["Lines are parallel", "Lines intersect", "Lines coincide", "More than 2 equations"]', '[0]', 2),
    ('A system is called determinate if it has:',
     '["No solutions", "A unique solution", "Infinitely many solutions", "All coefficients equal"]', '[1]', 3),
    ('Cramer''s rule applies to systems:',
     '["Only nonlinear", "Linear with nonzero determinant", "Only with two equations", "Inconsistent"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Systems of Linear Equations';

-- Quiz 4: Powers and Roots
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('a³ · a⁴ = ?',
     '["a⁷", "a¹²", "a", "2a⁷"]', '[0]', 0),
    ('(2³)² = ?',
     '["2⁵ = 32", "2⁶ = 64", "2⁷ = 128", "2⁴ = 16"]', '[1]', 1),
    ('√72 in simplest form:',
     '["6√2", "8√2", "3√8", "6√3"]', '[0]', 2),
    ('a⁻² = ?',
     '["1/a²", "−a²", "a²", "−1/a²"]', '[0]', 3),
    ('(a/b)³ = ?',
     '["a/b³", "a³/b³", "3a/3b", "a³/b"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Powers and Roots: Properties and Calculations';

-- Quiz 5: Logarithms
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
WHERE l.title = 'Logarithms and Their Properties';

-- Quiz 6: Trigonometry
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('sin(30°) = ?',
     '["√3/2", "1/2", "√2/2", "1"]', '[1]', 0),
    ('cos(60°) = ?',
     '["√3/2", "1/2", "0", "√2/2"]', '[1]', 1),
    ('tan(45°) = ?',
     '["0", "1", "√3", "1/√3"]', '[1]', 2),
    ('sin²x + cos²x = ?',
     '["0", "1", "2", "sin(2x)"]', '[1]', 3),
    ('The period of y = sin(x) is:',
     '["π", "2π", "π/2", "4π"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Trigonometric Functions and the Unit Circle';

-- Quiz 7: Trigonometric Equations
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('General solution of sin(x) = 0:',
     '["x = πn", "x = π/2 + πn", "x = 2πn", "x = π/4 + πn"]', '[0]', 0),
    ('General solution of cos(x) = 1:',
     '["x = πn", "x = 2πn", "x = π/2 + πn", "x = π + 2πn"]', '[1]', 1),
    ('The equation 2sin(x) − 1 = 0 is equivalent to:',
     '["sin(x) = −1/2", "sin(x) = 1/2", "sin(x) = 2", "sin(x) = 1"]', '[1]', 2),
    ('The equation sin(x) = 2:',
     '["Has infinitely many solutions", "Has exactly two solutions", "Has no solutions", "x = 2"]', '[2]', 3),
    ('How many solutions does cos(x) = −1 have on [0; 2π]?',
     '["0", "1", "2", "Infinitely many"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Trigonometric Equations';

-- Quiz 8: Limits
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('lim(x→∞) 1/x = ?',
     '["1", "∞", "0", "−1"]', '[2]', 0),
    ('lim(x→0) sin(x)/x = ?',
     '["0", "∞", "sin(0)", "1"]', '[3]', 1),
    ('f is continuous at x₀ if:',
     '["lim f(x) = 0", "lim f(x) = f(x₀)", "f(x₀) = 0", "f is defined everywhere"]', '[1]', 2),
    ('lim(x→2) (x² − 4)/(x − 2) = ?',
     '["0", "∞", "4", "2"]', '[2]', 3),
    ('lim(x→∞) (3x² + 2)/(x² − 1) = ?',
     '["0", "1", "3", "∞"]', '[2]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Limits of Functions and Continuity';

-- Quiz 9: Derivatives
INSERT INTO quiz_questions (quiz_id, question, options, correct, sort_order)
SELECT qz.id, q.question, q.options::jsonb, q.correct::jsonb, q.ord
FROM quizzes qz
JOIN lessons l ON l.id = qz.lesson_id
CROSS JOIN (VALUES
    ('The derivative of a constant is:',
     '["1", "0", "The constant itself", "Undefined"]', '[1]', 0),
    ('(x³)'' = ?',
     '["3x", "x²", "3x²", "3x³"]', '[2]', 1),
    ('(sin(x))'' = ?',
     '["−cos(x)", "cos(x)", "−sin(x)", "1/cos(x)"]', '[1]', 2),
    ('If f''(x₀) = 0 and f''''(x₀) > 0, then x₀ is:',
     '["A maximum", "A minimum", "An inflection point", "A discontinuity"]', '[1]', 3),
    ('(u·v)'' = ?',
     '["u''·v''", "u''·v + u·v''", "u·v + u''·v''", "u''/v''"]', '[1]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Derivatives: Rules and Applications';

-- Quiz 10: Integrals
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
    ('∫k dx (k — constant) = ?',
     '["k/x + C", "kx + C", "k + C", "0"]', '[1]', 3),
    ('Newton–Leibniz formula: ∫ₐᵇ f(x)dx = ?',
     '["F(a) − F(b)", "F(b) + F(a)", "F(b) − F(a)", "f(b) − f(a)"]', '[2]', 4)
) AS q(question, options, correct, ord)
WHERE l.title = 'Integrals: Indefinite and Definite';

-- ============================================================
-- 10. ADDITIONAL BADGES
-- ============================================================

INSERT INTO badge_definitions (name, description, icon_url, condition_type, condition_value) VALUES
    ('First Steps',      'Complete 1 lesson',                    NULL, 'LESSONS_COMPLETED',  1),
    ('Curious Mind',     'Complete 3 lessons',                   NULL, 'LESSONS_COMPLETED',  3),
    ('Balanced',         'Complete 5 lessons',                   NULL, 'LESSONS_COMPLETED',  5),
    ('Diligent Student', 'Complete 10 lessons',                  NULL, 'LESSONS_COMPLETED', 10),
    ('Course Master',    'Complete any course',                  NULL, 'COURSES_COMPLETED',  1),
    ('Mathematician',    'Solve 15 tasks',                       NULL, 'TASKS_SOLVED',       15),
    ('Problem Solver',   'Solve 50 tasks',                       NULL, 'TASKS_SOLVED',       50),
    ('Top Student',      'Pass 3 quizzes with 100%',             NULL, 'PERFECT_QUIZZES',    3),
    ('Sharpshooter',     'Pass 10 quizzes with 100%',            NULL, 'PERFECT_QUIZZES',   10),
    ('Level 3',          'Reach level 3',                        NULL, 'LEVEL_REACHED',      3),
    ('Level 5',          'Reach level 5',                        NULL, 'LEVEL_REACHED',      5),
    ('Level 10',         'Reach level 10',                       NULL, 'LEVEL_REACHED',     10),
    ('Level 25',         'Reach level 25',                       NULL, 'LEVEL_REACHED',     25),
    ('XP Hunter',        'Earn 1000 XP',                         NULL, 'XP_EARNED',        1000),
    ('Streak ×5',        '5 consecutive days',                   NULL, 'STREAK',             5),
    ('Streak ×30',       '30 consecutive days',                  NULL, 'STREAK',            30),
    ('No Hints',         'Complete a course without any hints',  NULL, 'COURSE_NO_HINTS',    1)
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- 11. ENROLLMENTS
-- ============================================================

INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
SELECT u.id, c.id, 'ACTIVE', now() - interval '30 days'
FROM users u, courses c
WHERE u.email = 'daniyar.bekzhanov@eduquest.kz'
  AND c.title = 'Higher Mathematics: from Algebra to Calculus'
ON CONFLICT (user_id, course_id) DO NOTHING;

INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
SELECT u.id, c.id, 'ACTIVE', now() - interval '20 days'
FROM users u, courses c
WHERE u.email = 'zarina.alibekova@eduquest.kz'
  AND c.title = 'Higher Mathematics: from Algebra to Calculus'
ON CONFLICT (user_id, course_id) DO NOTHING;

INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
SELECT u.id, c.id, 'ACTIVE', now() - interval '10 days'
FROM users u, courses c
WHERE u.email = 'timur.seitkali@eduquest.kz'
  AND c.title = 'Higher Mathematics: from Algebra to Calculus'
ON CONFLICT (user_id, course_id) DO NOTHING;

-- ============================================================
-- 12. PROGRESS, SUBMISSIONS, QUIZ ATTEMPTS, XP, LEVELS, BADGES
-- Using DO $$ to work with dynamic IDs
-- ============================================================

DO $$
DECLARE
    v_daniyar   BIGINT;
    v_zarina    BIGINT;
    v_timur     BIGINT;
    v_temp      BIGINT;

    -- IDs of all 10 lessons
    v_l  BIGINT[10];
    -- IDs of all 10 quizzes
    v_q  BIGINT[10];
    -- IDs of all 30 tasks (3 per lesson)
    v_t  BIGINT[30];

    i INT;
    j INT;
    v_lesson_titles TEXT[] := ARRAY[
        'Functions and Their Properties',
        'Quadratic Equations and the Discriminant',
        'Systems of Linear Equations',
        'Powers and Roots: Properties and Calculations',
        'Logarithms and Their Properties',
        'Trigonometric Functions and the Unit Circle',
        'Trigonometric Equations',
        'Limits of Functions and Continuity',
        'Derivatives: Rules and Applications',
        'Integrals: Indefinite and Definite'
    ];
    v_quiz_titles TEXT[] := ARRAY[
        'Quiz: Functions',
        'Quiz: Quadratic Equations',
        'Quiz: Systems of Equations',
        'Quiz: Powers and Roots',
        'Quiz: Logarithms',
        'Quiz: Trigonometry',
        'Quiz: Trig Equations',
        'Quiz: Limits',
        'Quiz: Derivatives',
        'Quiz: Integrals'
    ];
    -- XP rewards per lesson
    v_lesson_xp INT[] := ARRAY[60,80,90,70,100,100,120,120,150,150];
    -- XP per quiz
    v_quiz_xp   INT[] := ARRAY[100,100,100,100,100,120,120,150,150,150];

    -- Daniyar completed lessons 1-7
    v_daniyar_lessons INT := 7;
    -- Zarina completed lessons 1-4
    v_zarina_lessons  INT := 4;
    -- Timur completed 1 lesson
    v_timur_lessons   INT := 1;

    v_daniyar_xp INT := 0;
    v_zarina_xp  INT := 0;
    v_timur_xp   INT := 0;

    v_answers JSONB;
    v_qids    BIGINT[];
BEGIN
    -- Get user IDs
    SELECT id INTO v_daniyar FROM users WHERE email = 'daniyar.bekzhanov@eduquest.kz';
    SELECT id INTO v_zarina  FROM users WHERE email = 'zarina.alibekova@eduquest.kz';
    SELECT id INTO v_timur   FROM users WHERE email = 'timur.seitkali@eduquest.kz';

    -- Load lesson and quiz IDs
    FOR i IN 1..10 LOOP
        SELECT id INTO v_temp FROM lessons WHERE title = v_lesson_titles[i];
        v_l[i] := v_temp;
        SELECT id INTO v_temp FROM quizzes WHERE title = v_quiz_titles[i];
        v_q[i] := v_temp;
    END LOOP;

    -- Load task IDs (3 per lesson, by sort_order)
    FOR i IN 1..10 LOOP
        FOR j IN 0..2 LOOP
            SELECT id INTO v_temp FROM tasks WHERE lesson_id = v_l[i] AND sort_order = j;
            v_t[(i-1)*3 + j + 1] := v_temp;
        END LOOP;
    END LOOP;

    -- -------------------------------------------------------
    -- DANIYAR: lessons 1-7 fully completed
    -- -------------------------------------------------------
    FOR i IN 1..v_daniyar_lessons LOOP
        INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used, completed_at)
        VALUES (v_daniyar, v_l[i], 'COMPLETED', 100, 0,
                now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3))
        ON CONFLICT (user_id, lesson_id) DO NOTHING;

        INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
        VALUES (v_daniyar, 'LESSON_COMPLETE', v_lesson_xp[i], v_l[i],
                now() - make_interval(days := (v_daniyar_lessons - i + 1) * 3));
        v_daniyar_xp := v_daniyar_xp + v_lesson_xp[i];

        -- All 3 tasks solved correctly
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

        -- Quiz: perfect score
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

    -- Lesson 8 for Daniyar: in_progress
    INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used)
    VALUES (v_daniyar, v_l[8], 'IN_PROGRESS', 0, 0)
    ON CONFLICT (user_id, lesson_id) DO NOTHING;

    -- -------------------------------------------------------
    -- ZARINA: lessons 1-4 completed, lesson 5 in_progress
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

        -- Task 1 — correct, task 2 — correct, task 3 — with hint
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

        -- Quiz: 4 out of 5 correct
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

    -- Lesson 5 for Zarina: in_progress + one task solved
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
    -- TIMUR: lesson 1 completed, lesson 2 in_progress
    -- -------------------------------------------------------
    INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used, completed_at)
    VALUES (v_timur, v_l[1], 'COMPLETED', 80, 2, now() - interval '8 days')
    ON CONFLICT (user_id, lesson_id) DO NOTHING;

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    VALUES (v_timur, 'LESSON_COMPLETE', v_lesson_xp[1], v_l[1], now() - interval '8 days');
    v_timur_xp := v_timur_xp + v_lesson_xp[1];

    -- Task 1: correct on 2nd attempt (first wrong)
    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    VALUES (v_timur, v_t[1], 'Wrong answer', false, 0, now() - interval '9 days');

    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    SELECT v_timur, v_t[1], solution, true, xp_reward - 10, now() - interval '8 days 22 hours'
    FROM tasks WHERE id = v_t[1];

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    SELECT v_timur, 'TASK_SOLVED', xp_reward - 10, v_t[1], now() - interval '8 days 22 hours'
    FROM tasks WHERE id = v_t[1];
    SELECT v_timur_xp + xp_reward - 10 INTO v_timur_xp FROM tasks WHERE id = v_t[1];

    -- Task 2: wrong
    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    VALUES (v_timur, v_t[2], 'wrong', false, 0, now() - interval '8 days 20 hours');

    -- Task 3: correct
    INSERT INTO task_submissions (user_id, task_id, answer, is_correct, xp_earned, submitted_at)
    SELECT v_timur, v_t[3], solution, true, xp_reward, now() - interval '8 days 18 hours'
    FROM tasks WHERE id = v_t[3];

    INSERT INTO user_xp_log (user_id, action_type, xp_amount, reference_id, created_at)
    SELECT v_timur, 'TASK_SOLVED', xp_reward, v_t[3], now() - interval '8 days 18 hours'
    FROM tasks WHERE id = v_t[3];
    SELECT v_timur_xp + xp_reward INTO v_timur_xp FROM tasks WHERE id = v_t[3];

    -- Quiz 1 for Timur: 3 out of 5
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

    -- Timur: lesson 2 in_progress
    INSERT INTO user_progress (user_id, lesson_id, status, score, hints_used)
    VALUES (v_timur, v_l[2], 'IN_PROGRESS', 0, 0)
    ON CONFLICT (user_id, lesson_id) DO NOTHING;

    -- -------------------------------------------------------
    -- USER LEVELS
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
    -- BADGES
    -- -------------------------------------------------------

    -- Daniyar (level 8, 7 lessons, 21 tasks, 7 perfect quizzes, >1000 XP)
    INSERT INTO user_badges (user_id, badge_id, awarded_at)
    SELECT v_daniyar, id, now() - interval '20 days'
    FROM badge_definitions
    WHERE name IN ('First Steps', 'Curious Mind', 'Balanced',
                   'Mathematician', 'Top Student', 'Level 3', 'Level 5', 'XP Hunter')
    ON CONFLICT (user_id, badge_id) DO NOTHING;

    -- Zarina (level 5, 4 lessons, 12 tasks, 4 quizzes at 4/5, >1000 XP)
    INSERT INTO user_badges (user_id, badge_id, awarded_at)
    SELECT v_zarina, id, now() - interval '10 days'
    FROM badge_definitions
    WHERE name IN ('First Steps', 'Curious Mind', 'Level 3', 'Level 5', 'XP Hunter')
    ON CONFLICT (user_id, badge_id) DO NOTHING;

    -- Timur (level 2, 1 lesson)
    INSERT INTO user_badges (user_id, badge_id, awarded_at)
    SELECT v_timur, id, now() - interval '7 days'
    FROM badge_definitions
    WHERE name = 'First Steps'
    ON CONFLICT (user_id, badge_id) DO NOTHING;

END $$;
