-- 001_schema.sql
-- Full PostgreSQL schema for Medlingo

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE users (
    id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    email         text UNIQUE NOT NULL,
    display_name  text,
    role          text NOT NULL DEFAULT 'learner',
    status        text NOT NULL DEFAULT 'active',
    institution_id uuid,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- LEARNER PROFILES
-- ============================================================
CREATE TABLE learner_profiles (
    id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id              uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    study_goal           text,
    current_streak       int NOT NULL DEFAULT 0,
    longest_streak       int NOT NULL DEFAULT 0,
    onboarding_completed bool NOT NULL DEFAULT false,
    level                int NOT NULL DEFAULT 1,
    total_xp             int NOT NULL DEFAULT 0,
    created_at           timestamptz NOT NULL DEFAULT now(),
    updated_at           timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- TUTOR PROFILES
-- ============================================================
CREATE TABLE tutor_profiles (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bio             text,
    subjects        text[],
    is_verified     bool NOT NULL DEFAULT false,
    hourly_rate_cents int,
    rating          numeric NOT NULL DEFAULT 0,
    total_sessions  int NOT NULL DEFAULT 0,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- CHAPTERS (Stages)
-- ============================================================
CREATE TABLE chapters (
    id               uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    number           int UNIQUE NOT NULL,
    title            text NOT NULL,
    summary          text,
    estimated_minutes int,
    is_premium       bool NOT NULL DEFAULT false,
    cover_art_url    text,
    accent_color_hex text,
    prerequisite_ids uuid[],
    unlock_rule      text NOT NULL DEFAULT 'free',
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- LESSONS
-- ============================================================
CREATE TABLE lessons (
    id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    chapter_id        uuid NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    order_index       int NOT NULL,
    title             text NOT NULL,
    content           text,
    type              text,
    estimated_minutes int,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- EXERCISES
-- ============================================================
CREATE TABLE exercises (
    id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    chapter_id   uuid NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    lesson_id    uuid REFERENCES lessons(id) ON DELETE SET NULL,
    type         text NOT NULL,
    title        text NOT NULL,
    instructions text,
    difficulty   text,
    xp_reward    int NOT NULL DEFAULT 10,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- QUESTION ITEMS
-- ============================================================
CREATE TABLE question_items (
    id             uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    exercise_id    uuid NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    prompt         text NOT NULL,
    options        jsonb,
    correct_answer text NOT NULL,
    explanation    text,
    media_url      text,
    word_parts     jsonb,
    created_at     timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- ATTEMPTS
-- ============================================================
CREATE TABLE attempts (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id     uuid NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    chapter_id      uuid NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    score           numeric,
    total_questions int,
    correct_answers int,
    started_at      timestamptz,
    completed_at    timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- ATTEMPT ITEMS
-- ============================================================
CREATE TABLE attempt_items (
    id                 uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id         uuid NOT NULL REFERENCES attempts(id) ON DELETE CASCADE,
    question_id        uuid NOT NULL REFERENCES question_items(id) ON DELETE CASCADE,
    given_answer       text,
    is_correct         bool,
    time_taken_seconds int,
    created_at         timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- SESSIONS (Tutor sessions)
-- ============================================================
CREATE TABLE sessions (
    id               uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tutor_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title            text NOT NULL,
    description      text,
    starts_at        timestamptz NOT NULL,
    duration_minutes int NOT NULL,
    price_cents      int,
    seats_available  int NOT NULL,
    seats_booked     int NOT NULL DEFAULT 0,
    chapter_ids      uuid[],
    status           text NOT NULL DEFAULT 'scheduled',
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- BOOKINGS
-- ============================================================
CREATE TABLE bookings (
    id         uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id uuid NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    learner_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status     text NOT NULL DEFAULT 'confirmed',
    booked_at  timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- MESSAGES
-- ============================================================
CREATE TABLE messages (
    id             uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_id   uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content        text NOT NULL,
    sent_at        timestamptz NOT NULL DEFAULT now(),
    read_at        timestamptz,
    attachment_url text
);

-- ============================================================
-- PRODUCTS (IAP catalog)
-- ============================================================
CREATE TABLE products (
    id          text PRIMARY KEY,
    name        text NOT NULL,
    description text,
    type        text NOT NULL,
    price_cents int NOT NULL,
    features    text[],
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- PURCHASES
-- ============================================================
CREATE TABLE purchases (
    id             uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id        uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id     text NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    transaction_id text,
    status         text NOT NULL,
    purchased_at   timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- ENTITLEMENTS
-- ============================================================
CREATE TABLE entitlements (
    id         uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id text NOT NULL,
    status     text NOT NULL DEFAULT 'active',
    expires_at timestamptz,
    granted_at timestamptz NOT NULL DEFAULT now(),
    source     text
);

-- ============================================================
-- MEDIA ASSETS
-- ============================================================
CREATE TABLE media_assets (
    id        uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    url       text NOT NULL,
    type      text NOT NULL,
    caption   text,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- AUDIT LOGS
-- ============================================================
CREATE TABLE audit_logs (
    id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id    uuid REFERENCES users(id) ON DELETE SET NULL,
    action      text NOT NULL,
    target_type text,
    target_id   uuid,
    metadata    jsonb,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_learner_profiles_user_id ON learner_profiles(user_id);
CREATE INDEX idx_tutor_profiles_user_id ON tutor_profiles(user_id);
CREATE INDEX idx_lessons_chapter_id ON lessons(chapter_id);
CREATE INDEX idx_exercises_chapter_id ON exercises(chapter_id);
CREATE INDEX idx_exercises_lesson_id ON exercises(lesson_id);
CREATE INDEX idx_question_items_exercise_id ON question_items(exercise_id);
CREATE INDEX idx_attempts_learner_id ON attempts(learner_id);
CREATE INDEX idx_attempts_chapter_id ON attempts(chapter_id);
CREATE INDEX idx_attempt_items_attempt_id ON attempt_items(attempt_id);
CREATE INDEX idx_bookings_session_id ON bookings(session_id);
CREATE INDEX idx_bookings_learner_id ON bookings(learner_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_entitlements_user_id ON entitlements(user_id);
CREATE INDEX idx_media_assets_lesson_id ON media_assets(lesson_id);
CREATE INDEX idx_audit_logs_actor_id ON audit_logs(actor_id);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_learner_profiles BEFORE UPDATE ON learner_profiles FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_tutor_profiles BEFORE UPDATE ON tutor_profiles FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_chapters BEFORE UPDATE ON chapters FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_lessons BEFORE UPDATE ON lessons FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_exercises BEFORE UPDATE ON exercises FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_sessions BEFORE UPDATE ON sessions FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
