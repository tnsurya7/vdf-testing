-- Verify the password hash for admin user
SELECT 
    email,
    password_hash,
    LENGTH(password_hash) as hash_length,
    SUBSTRING(password_hash, 1, 10) as hash_preview,
    user_type,
    sidbi_role,
    enabled,
    password_set
FROM vdf_user_account 
WHERE email = 'admin@demo.com';

-- Expected hash for password "password":
-- $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- Length should be 60 characters
