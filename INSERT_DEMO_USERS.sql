-- Insert Demo Users into Neon DB
-- Run this SQL in Neon SQL Editor after backend creates tables
-- Password for all users: "password"
-- BCrypt hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- Insert demo users
INSERT INTO vdf_user_account (id, email, password_hash, user_type, sidbi_role, enabled, password_set)
VALUES
    -- Applicant
    ('a0000001-0000-0000-0000-000000000001'::uuid, 
     'applicant@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'applicant', 
     NULL, 
     true, 
     true),
    
    -- Admin
    ('a0000001-0000-0000-0000-000000000007'::uuid, 
     'admin@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'admin', 
     NULL, 
     true, 
     true),
    
    -- SIDBI Maker
    ('a0000001-0000-0000-0000-000000000002'::uuid, 
     'sidbi-maker@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'maker', 
     true, 
     true),
    
    -- SIDBI Checker
    ('a0000001-0000-0000-0000-000000000003'::uuid, 
     'sidbi-checker@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'checker', 
     true, 
     true),
    
    -- SIDBI Convenor
    ('a0000001-0000-0000-0000-000000000004'::uuid, 
     'sidbi-convenor@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'convenor', 
     true, 
     true),
    
    -- SIDBI ICVD Committee Member
    ('a0000001-0000-0000-0000-000000000008'::uuid, 
     'sidbi-icvd@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'icvd_committee_member', 
     true, 
     true),
    
    -- SIDBI CCIC Committee Member
    ('a0000001-0000-0000-0000-000000000009'::uuid, 
     'sidbi-ccic@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'ccic_committee_member', 
     true, 
     true)
ON CONFLICT (email) DO NOTHING;

-- Verify users were inserted
SELECT email, user_type, sidbi_role, enabled 
FROM vdf_user_account 
WHERE email LIKE '%@demo.com'
ORDER BY email;
