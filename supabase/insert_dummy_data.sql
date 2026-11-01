
-- REALISTIC DUMMY DATA FOR SUKOON AI
-- This script populates the database with a rich set of realistic data for testing and demonstration.

-- 1. USERS (Diverse Roles)
INSERT INTO users (id, email, display_name, role, is_admin, account_status, age, gender, region, profession)
VALUES 
('00000000-0000-0000-0000-000000000000', 'admin@sukoon.ai', 'Super Admin', 'admin', true, 'active', 35, 'Male', 'Global', 'System Administrator'),
('11111111-1111-1111-1111-111111111111', 'dr.sarah@sukoon.ai', 'Dr. Sarah Khan', 'therapist', false, 'active', 42, 'Female', 'South Asia', 'Clinical Psychologist'),
('33333333-3333-3333-3333-333333333333', 'dr.james@sukoon.ai', 'Dr. James Wilson', 'therapist', false, 'active', 50, 'Male', 'North America', 'Psychiatrist'),
('44444444-4444-4444-4444-444444444444', 'dr.maya@sukoon.ai', 'Dr. Maya Sharma', 'therapist', false, 'active', 38, 'Female', 'Europe', 'Child Psychologist'),
('22222222-2222-2222-2222-222222222222', 'ahmed.ali@example.com', 'Ahmed Ali', 'patient', false, 'active', 24, 'Male', 'Middle East', 'Software Engineer'),
('66666666-6666-6666-6666-666666666666', 'sara.j@example.com', 'Sara Johnson', 'patient', false, 'active', 29, 'Female', 'North America', 'Marketing Executive'),
('77777777-7777-7777-7777-777777777777', 'mike.r@example.com', 'Mike Ross', 'patient', false, 'active', 31, 'Male', 'Europe', 'Legal Consultant'),
('88888888-8888-8888-8888-888888888888', 'priya.v@example.com', 'Priya Verma', 'patient', false, 'active', 22, 'Female', 'South Asia', 'University Student'),
('99999999-9999-9999-9999-999999999999', 'staff.moderator@sukoon.ai', 'Zainab Bibi', 'staff', false, 'active', 28, 'Female', 'South Asia', 'Community Moderator')
ON CONFLICT (id) DO NOTHING;

-- 2. THERAPIST PROFILES (Detailed)
INSERT INTO therapist_profiles (user_id, specialty, bio, experience, rating, review_count, is_crisis_certified, license_number, clinical_specializations)
VALUES 
('11111111-1111-1111-1111-111111111111', 'CBT & Anxiety', 'Specializing in Cognitive Behavioral Therapy for anxiety and depression with over 10 years of clinical experience.', 10, 4.9, 156, true, 'PSY-123456', '{"Anxiety", "Depression", "CBT"}'),
('33333333-3333-3333-3333-333333333333', 'Trauma & PTSD', 'Board-certified psychiatrist focused on trauma-informed care and EMDR therapy for veterans and survivors.', 15, 4.8, 92, true, 'MD-987654', '{"PTSD", "Trauma", "EMDR"}'),
('44444444-4444-4444-4444-444444444444', 'Child & Adolescent', 'Dedicated child psychologist helping children navigate developmental challenges and family transitions.', 8, 4.7, 64, false, 'CP-456789', '{"Child Psychology", "Family Therapy", "ADHD"}')
ON CONFLICT (user_id) DO NOTHING;

-- 3. THERAPIST CONNECTIONS (Active & Past)
INSERT INTO therapist_connections (client_id, therapist_id, status, notes, meeting_link)
VALUES 
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'active', 'Focusing on workplace stress and social anxiety.', 'https://zoom.us/j/123456789'),
('66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', 'active', 'Trauma recovery following a major life event.', 'https://meet.google.com/abc-defg-hij'),
('88888888-8888-8888-8888-888888888888', '44444444-4444-4444-4444-444444444444', 'active', 'Managing academic pressure and self-esteem issues.', 'https://zoom.us/j/987654321');

-- 4. DIRECT MESSAGES (Realistic Conversations)
INSERT INTO direct_messages (sender_id, receiver_id, content)
VALUES 
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Hello Dr. Sarah, I had a bit of a setback today at work. Feeling quite overwhelmed.'),
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'I am sorry to hear that, Ahmed. Remember the grounding techniques we discussed? Try the 5-4-3-2-1 method now.'),
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Yes, I am trying it now. It helps a little. Thank you.'),
('66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', 'Dr. James, I was wondering if we could move our session to 4 PM tomorrow?'),
('33333333-3333-3333-3333-333333333333', '66666666-6666-6666-6666-666666666666', 'Hi Sara, let me check my schedule. Yes, 4 PM works for me. See you then.');

-- 5. AI CHAT SESSIONS & MESSAGES
INSERT INTO chat_sessions (id, user_id, mood)
VALUES 
('s1-2222', '22222222-2222-2222-2222-222222222222', 'Anxious'),
('s2-6666', '66666666-6666-6666-6666-666666666666', 'Sad'),
('s3-8888', '88888888-8888-8888-8888-888888888888', 'Stressed')
ON CONFLICT (id) DO NOTHING;

INSERT INTO chat_messages (session_id, user_id, role, content)
VALUES 
('s1-2222', '22222222-2222-2222-2222-222222222222', 'user', 'I feel like I am failing at everything.'),
('s1-2222', '22222222-2222-2222-2222-222222222222', 'assistant', 'It sounds like you are being very hard on yourself. Can we look at one specific thing that feels like a failure and see if there is another perspective?'),
('s2-6666', '66666666-6666-6666-6666-666666666666', 'user', 'I just want to stay in bed all day.'),
('s2-6666', '66666666-6666-6666-6666-666666666666', 'assistant', 'It is okay to have low energy days. Sometimes resting is what the body needs. Is there one small thing, like drinking a glass of water, that you feel you could do?');

-- 6. JOURNAL ENTRIES
INSERT INTO journal_entries (user_id, title, content, mood)
VALUES 
('22222222-2222-2222-2222-222222222222', 'Work Stress', 'Today was tough. The deadline is looming and I feel behind. Need to breathe.', 'Anxious'),
('66666666-6666-6666-6666-666666666666', 'Small Wins', 'I managed to go for a 10-minute walk today. It felt good to see the sun.', 'Hopeful'),
('88888888-8888-8888-8888-888888888888', 'Exam Prep', 'Studying for finals is draining. I feel like I am not retaining anything.', 'Stressed');

-- 7. CALENDAR SLOTS (Availability)
INSERT INTO calendar_slots (therapist_id, date, time, status)
VALUES 
('11111111-1111-1111-1111-111111111111', '2026-04-01', '09:00', 'available'),
('11111111-1111-1111-1111-111111111111', '2026-04-01', '10:00', 'booked'),
('11111111-1111-1111-1111-111111111111', '2026-04-01', '11:00', 'available'),
('33333333-3333-3333-3333-333333333333', '2026-04-01', '14:00', 'available'),
('33333333-3333-3333-3333-333333333333', '2026-04-01', '15:00', 'available'),
('44444444-4444-4444-4444-444444444444', '2026-04-02', '10:00', 'available');

-- 8. SUPPORT TICKETS & FEEDBACK
INSERT INTO support_tickets (user_id, user_email, user_name, type, subject, description, status)
VALUES 
('22222222-2222-2222-2222-222222222222', 'ahmed.ali@example.com', 'Ahmed Ali', 'Bug', 'Audio not playing', 'The voice responses from the AI are not playing on my Android device.', 'Open'),
('77777777-7777-7777-7777-777777777777', 'mike.r@example.com', 'Mike Ross', 'Billing', 'Subscription Query', 'I want to know if my insurance covers the premium plan.', 'In Progress');

INSERT INTO user_feedback (user_id, feedback_type, category, note, status)
VALUES 
('66666666-6666-6666-6666-666666666666', 'Positive', 'Features', 'The journaling feature has really helped me track my progress.', 'Resolved'),
('88888888-8888-8888-8888-888888888888', 'Neutral', 'UI/UX', 'The dark mode is great, but some text is hard to read.', 'Pending');

-- 9. WALLET & FINANCE
INSERT INTO marketing_expenses (platform, amount, description)
VALUES 
('Google Ads', 1200.00, 'Search campaign for "online therapy" keywords'),
('Instagram', 800.00, 'Influencer partnership for mental health month'),
('Server', 250.00, 'Monthly AWS and Supabase hosting fees');

INSERT INTO wallet_transactions (user_id, client_id, amount, type, status, description)
VALUES 
('22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 45.00, 'Debit', 'Verified', 'Monthly Premium Subscription'),
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 36.00, 'Credit', 'Processed', 'Payout for session with Ahmed Ali (80% share)');

-- 10. NOTIFICATIONS
INSERT INTO notifications (user_id, title, message, type, is_read)
VALUES 
('22222222-2222-2222-2222-222222222222', 'New Message', 'Dr. Sarah Khan sent you a message.', 'chat', false),
('11111111-1111-1111-1111-111111111111', 'New Booking', 'Ahmed Ali booked a session for April 1st.', 'meeting', true),
('66666666-6666-6666-6666-666666666666', 'System Update', 'We have added new breathing exercises to the dashboard.', 'system', false);

-- 11. RISK ALERTS
INSERT INTO risk_alerts (user_id, client_name, trigger_keyword, message, status)
VALUES 
('22222222-2222-2222-2222-222222222222', 'Ahmed Ali', 'hopeless', 'User mentioned "feeling hopeless" in AI chat.', 'Resolved'),
('88888888-8888-8888-8888-888888888888', 'Priya Verma', 'end it all', 'Crisis keyword detected in journal entry.', 'Active');

-- 12. REVIEWS
INSERT INTO reviews (therapist_id, client_name, rating, comment)
VALUES 
('11111111-1111-1111-1111-111111111111', 'Ahmed Ali', 5, 'Dr. Sarah is incredibly patient and has helped me manage my anxiety effectively.'),
('33333333-3333-3333-3333-333333333333', 'Sara Johnson', 5, 'Very professional and trauma-informed. Highly recommend.'),
('44444444-4444-4444-4444-444444444444', 'Anonymous', 4, 'Great with kids. My son felt very comfortable.');
