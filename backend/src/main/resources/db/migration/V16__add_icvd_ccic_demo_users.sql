-- Add ICVD and CCIC demo users (password: password)
-- BCrypt hash for "password" (rounds=10): $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

INSERT INTO vdf_user_account (id, email, password_hash, user_type, sidbi_role, enabled, password_set)
VALUES
    ('a0000001-0000-0000-0000-000000000008'::uuid, 'sidbi-icvd@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sidbi', 'icvd_committee_member', true, true),
    ('a0000001-0000-0000-0000-000000000009'::uuid, 'sidbi-ccic@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sidbi', 'ccic_committee_member', true, true)
ON CONFLICT (email) DO NOTHING;
