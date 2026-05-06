-- 002_rls_policies.sql
-- Row Level Security policies for Medlingo

-- ============================================================
-- HELPER: get current user's role from JWT
-- ============================================================
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS text AS $$
    SELECT coalesce(
        current_setting('request.jwt.claims', true)::json->>'role',
        'anon'
    );
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid AS $$
    SELECT coalesce(
        (current_setting('request.jwt.claims', true)::json->>'sub')::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid
    );
$$ LANGUAGE sql STABLE;

-- ============================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE learner_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE attempt_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- ADMIN: full access on all tables
-- ============================================================
CREATE POLICY admin_all_users ON users FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_learner_profiles ON learner_profiles FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_tutor_profiles ON tutor_profiles FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_chapters ON chapters FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_lessons ON lessons FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_exercises ON exercises FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_question_items ON question_items FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_attempts ON attempts FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_attempt_items ON attempt_items FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_sessions ON sessions FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_bookings ON bookings FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_messages ON messages FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_products ON products FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_purchases ON purchases FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_entitlements ON entitlements FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_media_assets ON media_assets FOR ALL USING (auth.user_role() = 'admin');
CREATE POLICY admin_all_audit_logs ON audit_logs FOR ALL USING (auth.user_role() = 'admin');

-- ============================================================
-- USERS
-- ============================================================
CREATE POLICY users_read_own ON users
    FOR SELECT USING (id = auth.uid());

CREATE POLICY users_update_own ON users
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- ============================================================
-- LEARNER PROFILES
-- ============================================================
CREATE POLICY learner_profiles_read_own ON learner_profiles
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY learner_profiles_write_own ON learner_profiles
    FOR ALL USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ============================================================
-- TUTOR PROFILES
-- ============================================================
CREATE POLICY tutor_profiles_read_all ON tutor_profiles
    FOR SELECT USING (true);

CREATE POLICY tutor_profiles_write_own ON tutor_profiles
    FOR ALL USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ============================================================
-- CHAPTERS: all authenticated users can read
-- ============================================================
CREATE POLICY chapters_read_authenticated ON chapters
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================================
-- LESSONS: all authenticated users can read
-- ============================================================
CREATE POLICY lessons_read_authenticated ON lessons
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================================
-- EXERCISES: all authenticated users can read
-- ============================================================
CREATE POLICY exercises_read_authenticated ON exercises
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================================
-- QUESTION ITEMS: all authenticated users can read
-- ============================================================
CREATE POLICY question_items_read_authenticated ON question_items
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================================
-- ATTEMPTS: learners CRUD their own
-- ============================================================
CREATE POLICY attempts_read_own ON attempts
    FOR SELECT USING (learner_id = auth.uid());

CREATE POLICY attempts_insert_own ON attempts
    FOR INSERT WITH CHECK (learner_id = auth.uid());

CREATE POLICY attempts_update_own ON attempts
    FOR UPDATE USING (learner_id = auth.uid())
    WITH CHECK (learner_id = auth.uid());

CREATE POLICY attempts_delete_own ON attempts
    FOR DELETE USING (learner_id = auth.uid());

-- ============================================================
-- ATTEMPT ITEMS: accessible via own attempts
-- ============================================================
CREATE POLICY attempt_items_read_own ON attempt_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM attempts WHERE attempts.id = attempt_items.attempt_id AND attempts.learner_id = auth.uid()
        )
    );

CREATE POLICY attempt_items_insert_own ON attempt_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM attempts WHERE attempts.id = attempt_items.attempt_id AND attempts.learner_id = auth.uid()
        )
    );

-- ============================================================
-- SESSIONS: readable by all authenticated, writable by tutor owner
-- ============================================================
CREATE POLICY sessions_read_authenticated ON sessions
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY sessions_write_tutor ON sessions
    FOR ALL USING (tutor_id = auth.uid())
    WITH CHECK (tutor_id = auth.uid());

-- ============================================================
-- BOOKINGS: learners CRUD their own
-- ============================================================
CREATE POLICY bookings_read_own ON bookings
    FOR SELECT USING (learner_id = auth.uid());

CREATE POLICY bookings_insert_own ON bookings
    FOR INSERT WITH CHECK (learner_id = auth.uid());

CREATE POLICY bookings_update_own ON bookings
    FOR UPDATE USING (learner_id = auth.uid())
    WITH CHECK (learner_id = auth.uid());

CREATE POLICY bookings_delete_own ON bookings
    FOR DELETE USING (learner_id = auth.uid());

-- Tutors can read bookings for their sessions
CREATE POLICY bookings_read_tutor ON bookings
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM sessions WHERE sessions.id = bookings.session_id AND sessions.tutor_id = auth.uid()
        )
    );

-- ============================================================
-- MESSAGES: sender and recipient can read; sender can insert
-- ============================================================
CREATE POLICY messages_read_own ON messages
    FOR SELECT USING (sender_id = auth.uid() OR recipient_id = auth.uid());

CREATE POLICY messages_insert_own ON messages
    FOR INSERT WITH CHECK (sender_id = auth.uid());

CREATE POLICY messages_update_own ON messages
    FOR UPDATE USING (recipient_id = auth.uid())
    WITH CHECK (recipient_id = auth.uid());

-- ============================================================
-- PRODUCTS: readable by all authenticated
-- ============================================================
CREATE POLICY products_read_authenticated ON products
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================================
-- PURCHASES: readable only by owner
-- ============================================================
CREATE POLICY purchases_read_own ON purchases
    FOR SELECT USING (user_id = auth.uid());

-- ============================================================
-- ENTITLEMENTS: readable only by owner or admin
-- ============================================================
CREATE POLICY entitlements_read_own ON entitlements
    FOR SELECT USING (user_id = auth.uid());

-- ============================================================
-- MEDIA ASSETS: readable by all authenticated
-- ============================================================
CREATE POLICY media_assets_read_authenticated ON media_assets
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================================
-- AUDIT LOGS: readable only by admin (covered by admin policy)
-- ============================================================
-- No additional policies needed; admin policy covers read/write.

-- ============================================================
-- TUTORS: can read learner profiles for their booked sessions
-- ============================================================
CREATE POLICY tutor_read_learner_profiles ON learner_profiles
    FOR SELECT USING (
        auth.user_role() = 'tutor' AND
        EXISTS (
            SELECT 1 FROM bookings b
            JOIN sessions s ON s.id = b.session_id
            WHERE b.learner_id = learner_profiles.user_id
              AND s.tutor_id = auth.uid()
        )
    );

CREATE POLICY tutor_read_learner_users ON users
    FOR SELECT USING (
        auth.user_role() = 'tutor' AND
        EXISTS (
            SELECT 1 FROM bookings b
            JOIN sessions s ON s.id = b.session_id
            WHERE b.learner_id = users.id
              AND s.tutor_id = auth.uid()
        )
    );
