
-- Sukoon AI Clinical & Support Schema

-- THERAPIST APPLICATIONS
CREATE TABLE IF NOT EXISTS therapist_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    years_experience INTEGER DEFAULT 0,
    specialization TEXT,
    license_number TEXT,
    cv_file TEXT, -- Path in storage
    degree_file TEXT, -- Path in storage
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- REVIEWS
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    therapist_id UUID REFERENCES users(id) ON DELETE CASCADE,
    client_name TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SESSION RATINGS
CREATE TABLE IF NOT EXISTS session_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES chat_sessions(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    remark TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- BUG REPORTS
CREATE TABLE IF NOT EXISTS bug_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES chat_sessions(id) ON DELETE SET NULL,
    issue_type TEXT NOT NULL,
    description TEXT,
    device_info TEXT,
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'investigating', 'resolved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- USER FEEDBACK
CREATE TABLE IF NOT EXISTS user_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    feedback_type TEXT NOT NULL CHECK (feedback_type IN ('Positive', 'Neutral', 'Negative')),
    category TEXT NOT NULL,
    note TEXT,
    status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Resolved')),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SUPPORT TICKETS
CREATE TABLE IF NOT EXISTS support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    user_email TEXT,
    user_name TEXT,
    type TEXT NOT NULL CHECK (type IN ('Bug', 'Feature', 'Feedback', 'Billing')),
    subject TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved')),
    admin_response TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RISK ALERTS
CREATE TABLE IF NOT EXISTS risk_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    client_name TEXT,
    trigger_keyword TEXT,
    message TEXT,
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Handling', 'Resolved'))
);

-- SAFETY INCIDENTS
CREATE TABLE IF NOT EXISTS safety_incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    therapist_id UUID REFERENCES users(id) ON DELETE CASCADE,
    client_name TEXT,
    incident_type TEXT NOT NULL,
    description TEXT,
    time_of_incident TEXT,
    status TEXT DEFAULT 'Reported' CHECK (status IN ('Reported', 'Under Review', 'Resolved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- EMERGENCY SESSIONS
CREATE TABLE IF NOT EXISTS emergency_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_id UUID REFERENCES risk_alerts(id) ON DELETE CASCADE,
    client_id UUID REFERENCES users(id) ON DELETE CASCADE,
    therapist_id UUID REFERENCES users(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CALENDAR SLOTS
CREATE TABLE IF NOT EXISTS calendar_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    therapist_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date TEXT NOT NULL, -- YYYY-MM-DD
    time TEXT NOT NULL, -- HH:MM
    duration INTEGER DEFAULT 60,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'booked', 'pending')),
    client_name TEXT,
    session_type TEXT DEFAULT 'Standard',
    meeting_link TEXT
);

-- TEAM MEMBERS
CREATE TABLE IF NOT EXISTS team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL,
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Suspended', 'Expired')),
    permissions JSONB DEFAULT '{}',
    access_expires_at TIMESTAMP WITH TIME ZONE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- BROADCASTS
CREATE TABLE IF NOT EXISTS broadcasts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    audience TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- DIRECT MESSAGES
CREATE TABLE IF NOT EXISTS direct_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- THERAPIST CONNECTIONS
CREATE TABLE IF NOT EXISTS therapist_connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES users(id) ON DELETE CASCADE,
    therapist_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'disputed', 'ended')),
    notes TEXT,
    config JSONB DEFAULT '{}',
    meeting_link TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- THERAPY NOTES
CREATE TABLE IF NOT EXISTS therapy_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    therapist_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT,
    details TEXT,
    mark_type TEXT CHECK (mark_type IN ('Progress', 'Warning', 'Needs Follow-up')),
    date_of_note TEXT,
    next_reminder TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CHECK-IN EVENTS
CREATE TABLE IF NOT EXISTS check_in_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL,
    response TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('meeting', 'chat', 'system', 'alert')),
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS POLICIES (Clinical & Support)
ALTER TABLE therapist_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bug_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE safety_incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE broadcasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE direct_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE therapist_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE therapy_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_in_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Admins can view all
CREATE POLICY "Admins can view all clinical" ON therapist_applications FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all reviews" ON reviews FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all support" ON support_tickets FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all alerts" ON risk_alerts FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all incidents" ON safety_incidents FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all team" ON team_members FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all connections" ON therapist_connections FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all direct messages" ON direct_messages FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all notes" ON therapy_notes FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

-- Notifications Policies
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "System can create notifications" ON notifications FOR INSERT WITH CHECK (true); -- Simplified for now, in real app restrict to service role or specific logic

-- Direct Messages Policies
CREATE POLICY "Users can view their own messages" ON direct_messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send messages" ON direct_messages FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Therapists can view their own clinical data
CREATE POLICY "Therapists can view own connections" ON therapist_connections FOR SELECT USING (auth.uid() = therapist_id);
CREATE POLICY "Therapists can view own notes" ON therapy_notes FOR SELECT USING (auth.uid() = therapist_id);
CREATE POLICY "Therapists can view own slots" ON calendar_slots FOR ALL USING (auth.uid() = therapist_id);

-- Clients can view their own clinical data
CREATE POLICY "Clients can view own connections" ON therapist_connections FOR SELECT USING (auth.uid() = client_id);
CREATE POLICY "Students can view own notes" ON therapy_notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own feedback" ON user_feedback FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own tickets" ON support_tickets FOR SELECT USING (auth.uid() = user_id);
