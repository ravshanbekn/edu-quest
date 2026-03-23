-- ============================================================
-- V4: Block 5.4 — Gamification: XP, Levels, Badges
-- ============================================================

-- user_xp_log
CREATE TABLE user_xp_log (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID         NOT NULL REFERENCES users (id),
    action_type  VARCHAR(100) NOT NULL,
    xp_amount    INT          NOT NULL,
    reference_id UUID,
    created_at   TIMESTAMP    NOT NULL DEFAULT now()
);

-- user_levels
CREATE TABLE user_levels (
    id            UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID      NOT NULL UNIQUE REFERENCES users (id),
    current_level INT       NOT NULL DEFAULT 1,
    total_xp      INT       NOT NULL DEFAULT 0,
    updated_at    TIMESTAMP NOT NULL DEFAULT now()
);

-- badge_definitions
CREATE TABLE badge_definitions (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    icon_url        VARCHAR(500),
    condition_type  VARCHAR(100) NOT NULL,
    condition_value INT          NOT NULL,
    is_active       BOOLEAN      NOT NULL DEFAULT true
);

-- user_badges
CREATE TABLE user_badges (
    id         UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID      NOT NULL REFERENCES users (id),
    badge_id   UUID      NOT NULL REFERENCES badge_definitions (id),
    awarded_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE (user_id, badge_id)
);

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX idx_xp_log_user        ON user_xp_log (user_id, created_at DESC);
CREATE INDEX idx_user_badges_user   ON user_badges (user_id);
CREATE INDEX idx_user_levels_xp     ON user_levels (total_xp DESC);
