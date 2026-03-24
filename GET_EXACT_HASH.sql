-- Get the EXACT password hash (no truncation)
SELECT 
    email,
    password_hash,
    LENGTH(password_hash) as len,
    enabled,
    password_set,
    user_type,
    sidbi_role
FROM vdf_user_account 
WHERE email = 'admin@demo.com';

-- Also check if there are any hidden characters or spaces
SELECT 
    email,
    LENGTH(TRIM(password_hash)) as trimmed_length,
    password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' as hash_matches_expected
FROM vdf_user_account 
WHERE email = 'admin@demo.com';
