-- Add password_set column; existing users already have passwords so default true
ALTER TABLE vdf_user_account ADD COLUMN IF NOT EXISTS password_set BOOLEAN NOT NULL DEFAULT TRUE;
