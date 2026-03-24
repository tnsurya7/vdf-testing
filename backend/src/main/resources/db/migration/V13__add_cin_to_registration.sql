-- V13: Add CIN (Corporate Identification Number) to registration table
ALTER TABLE vdf_registration ADD COLUMN IF NOT EXISTS cin VARCHAR(21);
