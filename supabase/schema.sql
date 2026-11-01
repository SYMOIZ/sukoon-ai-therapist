
-- Sukoon AI Core Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    role TEXT DEFAULT 'patient' CHECK (role IN ('patient', 'therapist', 'admin', 'staff', 'client')),
    account_status TEXT DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'pending', 'banned')),
    age INTEGER,
    gender TEXT,
    region TEXT,
    profession TEXT,
    preferred_language TEXT DEFAULT 'English',
    tone_preference TEXT DEFAULT 'Friendly',
    voice_enabled BOOLEAN DEFAULT false,
    auto_play_audio BOOLEAN DEFAULT false,
    memory_enabled BOOLEAN DEFAULT true,
    therapist_style TEXT DEFAULT 'gentle',
    personality_mode TEXT DEFAULT 'introvert',
    dark_mode BOOLEAN DEFAULT true,
    is_admin BOOLEAN DEFAULT false,
    suspension_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- THERAPIST PROFILES
CREATE TABLE IF NOT EXISTS therapist_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialty TEXT,
    bio TEXT,
    languages TEXT[] DEFAULT '{English}',
    experience INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 5.0,
    review_count INTEGER DEFAULT 0,
    booking_url TEXT,
    is_crisis_certified BOOLEAN DEFAULT false,
    license_number TEXT,
    bank_details JSONB DEFAULT '{}',
    notification_prefs JSONB DEFAULT '{"email": true, "sms": false}',
    clinical_specializations TEXT[] DEFAULT '{}',
    loyalty_points INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CHAT SESSIONS
CREATE TABLE IF NOT EXISTS chat_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    mood TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CHAT MESSAGES
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES chat_sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- JOURNAL ENTRIES
CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT,
    content TEXT NOT NULL,
    mood TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- USER MEMORY (Vector Store for RAG)
CREATE TABLE IF NOT EXISTS user_memory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    embedding VECTOR(768), -- text-embedding-004 dimensions
    source_type TEXT DEFAULT 'chat_log',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- VECTOR SEARCH FUNCTION
CREATE OR REPLACE FUNCTION match_user_memory (
  query_embedding VECTOR(768),
  match_threshold FLOAT,
  match_count INT,
  filter_user_id UUID
)
RETURNS TABLE (
  id UUID,
  content TEXT,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    user_memory.id,
    user_memory.content,
    1 - (user_memory.embedding <=> query_embedding) AS similarity
  FROM user_memory
  WHERE user_memory.user_id = filter_user_id
    AND 1 - (user_memory.embedding <=> query_embedding) > match_threshold
  ORDER BY similarity DESC
  LIMIT match_count;
END;
$$;

-- SYSTEM SETTINGS
CREATE TABLE IF NOT EXISTS system_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS POLICIES (Basic)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE therapist_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_memory ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- Simple policies: Users can read/write their own data
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own chat sessions" ON chat_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own chat sessions" ON chat_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own chat messages" ON chat_messages FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own chat messages" ON chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own journal" ON journal_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own journal" ON journal_entries FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own memory" ON user_memory FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own memory" ON user_memory FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view system settings" ON system_settings FOR SELECT USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND is_admin = true));
CREATE POLICY "Admins can update system settings" ON system_settings FOR ALL USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND is_admin = true));
