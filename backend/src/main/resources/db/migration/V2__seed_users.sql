-- Seed demo users (password: password)
-- BCrypt hash for "password" (rounds=10)
INSERT INTO user_account (id, email, password_hash, user_type, sidbi_role, enabled)
VALUES
    ('a0000001-0000-0000-0000-000000000001'::uuid, 'applicant@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'applicant', NULL, true),
    ('a0000001-0000-0000-0000-000000000002'::uuid, 'sidbi-maker@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sidbi', 'maker', true),
    ('a0000001-0000-0000-0000-000000000003'::uuid, 'sidbi-checker@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sidbi', 'checker', true),
    ('a0000001-0000-0000-0000-000000000004'::uuid, 'sidbi-convenor@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sidbi', 'convenor', true),
    ('a0000001-0000-0000-0000-000000000005'::uuid, 'sidbi-committee@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sidbi', 'committee_member', true),
    ('a0000001-0000-0000-0000-000000000006'::uuid, 'sidbi-approving@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sidbi', 'approving_authority', true),
    ('a0000001-0000-0000-0000-000000000007'::uuid, 'admin@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin', NULL, true)
ON CONFLICT (email) DO NOTHING;
