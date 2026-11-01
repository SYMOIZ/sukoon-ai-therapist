
-- Sukoon AI Finance & Operations Schema

-- MARKETING EXPENSES
CREATE TABLE IF NOT EXISTS marketing_expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform TEXT NOT NULL CHECK (platform IN ('Facebook', 'Google', 'Instagram', 'Influencer', 'Server', 'Other')),
    amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    description TEXT,
    date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- WALLET TRANSACTIONS
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    therapist_id UUID REFERENCES users(id) ON DELETE SET NULL, -- For payouts
    client_id UUID REFERENCES users(id) ON DELETE SET NULL, -- For revenue
    amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    type TEXT NOT NULL CHECK (type IN ('Credit', 'Debit')),
    status TEXT DEFAULT 'Pending' CHECK (status IN ('Verified', 'Pending', 'Processed', 'Rejected')),
    description TEXT,
    therapist_payout DECIMAL(12,2) DEFAULT 0.00,
    date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PAYOUT REQUESTS
CREATE TABLE IF NOT EXISTS payout_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    therapist_id UUID REFERENCES users(id) ON DELETE CASCADE,
    therapist_name TEXT,
    amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Rejected')),
    request_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    method TEXT,
    processed_at TIMESTAMP WITH TIME ZONE
);

-- ADMIN ACTIONS (Logging)
CREATE TABLE IF NOT EXISTS admin_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action_type TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS POLICIES (Finance)
ALTER TABLE marketing_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payout_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_actions ENABLE ROW LEVEL SECURITY;

-- Admins can see everything
CREATE POLICY "Admins can view all expenses" ON marketing_expenses FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all transactions" ON wallet_transactions FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all payouts" ON payout_requests FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Admins can view all logs" ON admin_actions FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON wallet_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Therapists can view own payouts" ON payout_requests FOR SELECT USING (auth.uid() = therapist_id);
