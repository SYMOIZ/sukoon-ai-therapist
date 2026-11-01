
-- Sukoon AI Seed Data

-- 1. Insert Admin User
INSERT INTO users (id, email, display_name, role, is_admin, account_status)
VALUES ('00000000-0000-0000-0000-000000000000', 'admin@sukoon.ai', 'Super Admin', 'admin', true, 'active')
ON CONFLICT (id) DO NOTHING;

-- 2. Insert Test Therapist
INSERT INTO users (id, email, display_name, role, account_status)
VALUES ('11111111-1111-1111-1111-111111111111', 'therapist@sukoon.ai', 'Dr. Sarah Khan', 'therapist', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO therapist_profiles (user_id, specialty, bio, experience, rating, review_count, is_crisis_certified)
VALUES ('11111111-1111-1111-1111-111111111111', 'CBT Specialist', 'Experienced therapist focusing on anxiety and depression.', 8, 4.9, 120, true)
ON CONFLICT (user_id) DO NOTHING;

-- 3. Insert Test Client
INSERT INTO users (id, email, display_name, role, account_status)
VALUES ('22222222-2222-2222-2222-222222222222', 'client@sukoon.ai', 'Ahmed Ali', 'patient', 'active')
ON CONFLICT (id) DO NOTHING;

-- 4. Insert Marketing Expenses
INSERT INTO marketing_expenses (platform, amount, description)
VALUES 
('Facebook', 500.00, 'Ad campaign for mental health awareness'),
('Google', 300.00, 'Search ads for therapy keywords'),
('Instagram', 200.00, 'Influencer partnership');

-- 5. Insert Team Members
INSERT INTO team_members (name, email, role, status)
VALUES 
('Zainab Bibi', 'zainab@sukoon.ai', 'Moderator', 'Active'),
('Omar Farooq', 'omar@sukoon.ai', 'Accountant', 'Active');

-- 6. Insert Broadcasts
INSERT INTO broadcasts (title, message, type, audience)
VALUES 
('System Maintenance', 'Scheduled maintenance on Sunday at 2 AM.', 'info', 'all'),
('New Feature', 'Voice chat is now available for premium users.', 'marketing', 'clients');

-- 7. Insert Support Tickets
INSERT INTO support_tickets (user_id, user_email, user_name, type, subject, description, status)
VALUES 
('22222222-2222-2222-2222-222222222222', 'client@sukoon.ai', 'Ahmed Ali', 'Bug', 'App crashes on login', 'The app crashes when I try to login from my iPhone.', 'Open');

-- 8. Insert System Settings
INSERT INTO system_settings (key, value)
VALUES ('monetization', '{"commissionRate": 20, "payoutCycleDays": 29}')
ON CONFLICT (key) DO NOTHING;

-- 9. More Therapists
INSERT INTO users (id, email, display_name, role, account_status)
VALUES 
('33333333-3333-3333-3333-333333333333', 'dr.james@sukoon.ai', 'Dr. James Wilson', 'therapist', 'active'),
('44444444-4444-4444-4444-444444444444', 'dr.maya@sukoon.ai', 'Dr. Maya Sharma', 'therapist', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO therapist_profiles (user_id, specialty, bio, experience, rating, review_count, is_crisis_certified)
VALUES 
('33333333-3333-3333-3333-333333333333', 'Trauma Specialist', 'Helping individuals overcome PTSD and trauma.', 12, 4.8, 85, true),
('44444444-4444-4444-4444-444444444444', 'Child Psychologist', 'Dedicated to supporting children and adolescents.', 6, 4.7, 45, false)
ON CONFLICT (user_id) DO NOTHING;

-- 10. Direct Messages (Chat Section)
INSERT INTO direct_messages (sender_id, receiver_id, content)
VALUES 
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Hello Dr. Sarah, I am feeling a bit anxious today.'),
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Hi Ahmed, I am here for you. Can you tell me more about what is triggering it?'),
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'It is mostly work-related stress.');

-- 11. Therapist Connections
INSERT INTO therapist_connections (client_id, therapist_id, status, notes)
VALUES 
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'active', 'Initial connection for anxiety management.');

-- 12. Notifications
INSERT INTO notifications (user_id, title, message, type)
VALUES 
('22222222-2222-2222-2222-222222222222', 'New Message', 'Dr. Sarah Khan sent you a message.', 'chat'),
('22222222-2222-2222-2222-222222222222', 'Session Reminder', 'Your session with Dr. Sarah is in 30 minutes.', 'meeting');

-- 13. Journal Entries
INSERT INTO journal_entries (user_id, title, content, mood)
VALUES 
('22222222-2222-2222-2222-222222222222', 'Morning Reflection', 'I woke up feeling refreshed today.', 'Happy'),
('22222222-2222-2222-2222-222222222222', 'Midday Stress', 'Work is getting a bit overwhelming.', 'Stressed');

-- 14. Risk Alerts
INSERT INTO risk_alerts (user_id, client_name, trigger_keyword, message, status)
VALUES 
('22222222-2222-2222-2222-222222222222', 'Ahmed Ali', 'hopeless', 'User mentioned feeling hopeless in chat.', 'Resolved');

-- 15. More Support Tickets
INSERT INTO support_tickets (user_id, user_email, user_name, type, subject, description, status)
VALUES 
('22222222-2222-2222-2222-222222222222', 'client@sukoon.ai', 'Ahmed Ali', 'Billing', 'Double charge on subscription', 'I was charged twice for the premium plan.', 'In Progress');

-- 16. Wallet Transactions
INSERT INTO wallet_transactions (user_id, client_id, amount, type, status, description)
VALUES 
('22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 50.00, 'Debit', 'Verified', 'Subscription payment'),
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 40.00, 'Credit', 'Processed', 'Payout for session with Ahmed Ali');

-- 17. More Marketing Expenses
INSERT INTO marketing_expenses (platform, amount, description)
VALUES 
('Influencer', 1500.00, 'Partnership with mental health advocate on YouTube'),
('Server', 120.00, 'Monthly hosting and database costs'),
('Other', 50.00, 'Community outreach flyers');

-- 18. More Team Members
INSERT INTO team_members (name, email, role, status)
VALUES 
('Fatima Zahra', 'fatima@sukoon.ai', 'Support Lead', 'Active'),
('Ali Raza', 'ali@sukoon.ai', 'Developer', 'Active');
