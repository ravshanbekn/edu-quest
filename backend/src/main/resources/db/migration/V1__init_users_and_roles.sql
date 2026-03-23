-- ============================================================
-- V1: Block 5.1 — Users, Profiles, Roles, Permissions (RBAC)
-- ============================================================

-- users
CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active     BOOLEAN      NOT NULL DEFAULT true,
    created_at    TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT now()
);

-- user_profiles (one-to-one with users)
CREATE TABLE user_profiles (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID         NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    display_name VARCHAR(100),
    avatar_url   VARCHAR(500),
    bio          TEXT,
    is_public    BOOLEAN      NOT NULL DEFAULT true,
    created_at   TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT now()
);

-- roles
CREATE TABLE roles (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- permissions
CREATE TABLE permissions (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- user → roles (many-to-many)
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- role → permissions (many-to-many)
CREATE TABLE role_permissions (
    role_id       UUID NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions (id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- ============================================================
-- Seed: Roles
-- ============================================================
INSERT INTO roles (name, description) VALUES
    ('ADMIN',   'Full access. Manage users, roles, and all courses.'),
    ('TEACHER', 'Create and manage own courses. View student progress.'),
    ('STUDENT', 'Take courses, submit tasks and quizzes, edit own profile.'),
    ('GUEST',   'View course catalog and public profiles only.')
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- Seed: Permissions
-- ============================================================
INSERT INTO permissions (code, description) VALUES
    ('user:manage',            'CRUD operations on any user'),
    ('role:manage',            'Assign and revoke roles'),
    ('course:create',          'Create a new course'),
    ('course:manage_own',      'Edit and delete own courses'),
    ('course:manage_all',      'Edit and delete any course'),
    ('enrollment:manage',      'Enroll / unenroll students in a course'),
    ('progress:view_students', 'View progress of students in own course'),
    ('course:view',            'Browse the course catalog'),
    ('lesson:complete',        'Mark a lesson as completed'),
    ('task:submit',            'Submit an answer for a task'),
    ('quiz:take',              'Attempt a quiz'),
    ('profile:edit_own',       'Edit own profile'),
    ('profile:view_public',    'View public user profiles')
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- Seed: Role → Permission assignments
-- ============================================================

-- ADMIN gets all permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

-- TEACHER
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'course:create',
    'course:manage_own',
    'enrollment:manage',
    'progress:view_students',
    'course:view',
    'lesson:complete',
    'task:submit',
    'quiz:take',
    'profile:edit_own',
    'profile:view_public'
)
WHERE r.name = 'TEACHER'
ON CONFLICT DO NOTHING;

-- STUDENT
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'course:view',
    'lesson:complete',
    'task:submit',
    'quiz:take',
    'profile:edit_own',
    'profile:view_public'
)
WHERE r.name = 'STUDENT'
ON CONFLICT DO NOTHING;

-- GUEST
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'course:view',
    'profile:view_public'
)
WHERE r.name = 'GUEST'
ON CONFLICT DO NOTHING;

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX idx_user_roles_user ON user_roles (user_id);
CREATE INDEX idx_user_roles_role ON user_roles (role_id);