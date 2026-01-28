-- ═══════════════════════════════════════════════════════════════
-- LonePengu PostgreSQL Database Schema
-- Database: lonepengu_db
-- ═══════════════════════════════════════════════════════════════

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ═══════════════════════════════════════════════════════════════
-- USERS TABLE
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    avatar_url TEXT,
    auth_provider TEXT NOT NULL CHECK (auth_provider IN ('google', 'email', 'apple')),
    provider_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Index for faster email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_provider ON users(auth_provider);

-- ═══════════════════════════════════════════════════════════════
-- SESSIONS TABLE
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token TEXT NOT NULL UNIQUE,
    refresh_token TEXT UNIQUE,
    device_info TEXT,
    ip_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT TRUE
);

-- Index for faster token lookups
CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(access_token);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_valid ON sessions(is_valid) WHERE is_valid = TRUE;

-- ═══════════════════════════════════════════════════════════════
-- USER PREFERENCES TABLE
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    theme_mode TEXT DEFAULT 'system' CHECK (theme_mode IN ('light', 'dark', 'system')),
    notifications_enabled BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    last_active_route TEXT DEFAULT '/home',
    app_state JSONB DEFAULT '{}'::jsonb,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_preferences_user ON user_preferences(user_id);

-- ═══════════════════════════════════════════════════════════════
-- FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Function to upsert user on login
CREATE OR REPLACE FUNCTION upsert_user_on_login(
    p_email TEXT,
    p_name TEXT,
    p_auth_provider TEXT,
    p_provider_id TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL
) RETURNS TABLE(user_id UUID, is_new_user BOOLEAN) AS $$
DECLARE
    v_user_id UUID;
    v_is_new BOOLEAN := FALSE;
BEGIN
    -- Check if user exists
    SELECT id INTO v_user_id FROM users WHERE email = p_email;
    
    IF v_user_id IS NULL THEN
        -- Insert new user
        INSERT INTO users (email, name, auth_provider, provider_id, avatar_url, last_login)
        VALUES (p_email, p_name, p_auth_provider, p_provider_id, p_avatar_url, CURRENT_TIMESTAMP)
        RETURNING id INTO v_user_id;
        
        -- Create default preferences for new user
        INSERT INTO user_preferences (user_id) VALUES (v_user_id);
        
        v_is_new := TRUE;
    ELSE
        -- Update existing user's last_login
        UPDATE users 
        SET last_login = CURRENT_TIMESTAMP,
            name = COALESCE(p_name, name),
            avatar_url = COALESCE(p_avatar_url, avatar_url)
        WHERE id = v_user_id;
    END IF;
    
    RETURN QUERY SELECT v_user_id, v_is_new;
END;
$$ LANGUAGE plpgsql;

-- Function to create session
CREATE OR REPLACE FUNCTION create_session(
    p_user_id UUID,
    p_access_token TEXT,
    p_refresh_token TEXT DEFAULT NULL,
    p_device_info TEXT DEFAULT NULL,
    p_ip_address TEXT DEFAULT NULL,
    p_expires_hours INTEGER DEFAULT 720 -- 30 days default
) RETURNS UUID AS $$
DECLARE
    v_session_id UUID;
BEGIN
    -- Invalidate any existing sessions for this user (optional: keep multiple)
    -- UPDATE sessions SET is_valid = FALSE WHERE user_id = p_user_id AND is_valid = TRUE;
    
    INSERT INTO sessions (user_id, access_token, refresh_token, device_info, ip_address, expires_at)
    VALUES (p_user_id, p_access_token, p_refresh_token, p_device_info, p_ip_address, 
            CURRENT_TIMESTAMP + (p_expires_hours || ' hours')::INTERVAL)
    RETURNING id INTO v_session_id;
    
    RETURN v_session_id;
END;
$$ LANGUAGE plpgsql;

-- Function to validate session
CREATE OR REPLACE FUNCTION validate_session(p_access_token TEXT)
RETURNS TABLE(user_id UUID, email TEXT, name TEXT, is_valid BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.email, u.name, 
           (s.is_valid AND s.expires_at > CURRENT_TIMESTAMP) AS is_valid
    FROM sessions s
    JOIN users u ON s.user_id = u.id
    WHERE s.access_token = p_access_token;
    
    -- Update last used
    UPDATE sessions SET last_used_at = CURRENT_TIMESTAMP
    WHERE access_token = p_access_token AND is_valid = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to invalidate session (logout)
CREATE OR REPLACE FUNCTION invalidate_session(p_access_token TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE sessions SET is_valid = FALSE WHERE access_token = p_access_token;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Function to save app state
CREATE OR REPLACE FUNCTION save_app_state(
    p_user_id UUID,
    p_last_route TEXT,
    p_app_state JSONB
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE user_preferences 
    SET last_active_route = p_last_route,
        app_state = p_app_state,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP JOB (Run periodically via pg_cron or external scheduler)
-- ═══════════════════════════════════════════════════════════════
-- DELETE FROM sessions WHERE expires_at < CURRENT_TIMESTAMP - INTERVAL '7 days';
