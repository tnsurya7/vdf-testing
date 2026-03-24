-- Add sidbi_roles column to track multiple SIDBI roles per user

ALTER TABLE user_account
  ADD COLUMN IF NOT EXISTS sidbi_roles VARCHAR(255);

-- Seed existing single-role users into sidbi_roles for backward compatibility
UPDATE user_account
SET sidbi_roles = sidbi_role::text
WHERE sidbi_role IS NOT NULL
  AND (sidbi_roles IS NULL OR sidbi_roles = '');

