-- V6: Add enrollment:self permission (students self-enrolling in courses)
INSERT INTO permissions (code, description) VALUES
    ('enrollment:self', 'Enroll yourself in a course')
ON CONFLICT (code) DO NOTHING;

-- Assign to STUDENT and TEACHER
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'enrollment:self'
WHERE r.name IN ('STUDENT', 'TEACHER')
ON CONFLICT DO NOTHING;
