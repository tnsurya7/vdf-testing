-- Fix demo users in Neon DB
-- First, delete existing demo users
DELETE FROM vdf_user_account WHERE email LIKE '%@demo.com';

-- Re-insert with correct BCrypt hash for "password"
INSERT INTO vdf_user_account (id, email, password_hash, user_type, sidbi_role, enabled, password_set)
VALUES
    ('a0000001-0000-0000-0000-000000000001'::uuid, 
     'applicant@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'applicant', 
     NULL, 
     true, 
     true),
    
    ('a0000001-0000-0000-0000-000000000007'::uuid, 
     'admin@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'admin', 
     NULL, 
     true, 
     true),
    
    ('a0000001-0000-0000-0000-000000000002'::uuid, 
     'sidbi-maker@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'maker', 
     true, 
     true),
    
    ('a0000001-0000-0000-0000-000000000003'::uuid, 
     'sidbi-checker@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'checker', 
     true, 
     true),
    
    ('a0000001-0000-0000-0000-000000000004'::uuid, 
     'sidbi-convenor@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'convenor', 
     true, 
     true),
    
    ('a0000001-0000-0000-0000-000000000008'::uuid, 
     'sidbi-icvd@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'icvd_committee_member', 
     true, 
     true),
    
    ('a0000001-0000-0000-0000-000000000009'::uuid, 
     'sidbi-ccic@demo.com', 
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
     'sidbi', 
     'ccic_committee_member', 
     true, 
     true);

-- Verify the insert
SELECT email, user_type, sidbi_role, enabled, password_set,
       length(password_hash) as hash_length,
       substring(password_hash, 1, 30) as hash_start
FROM vdf_user_account 
WHERE email LIKE '%@demo.com'
ORDER BY email;
