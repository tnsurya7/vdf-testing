-- Rename tables from VDF_* to vdf_* (lowercase) for PostgreSQL compatibility
-- Run this in Neon SQL Editor

-- First, check what tables exist
SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE '%user_account%';

-- Rename tables if they exist with capital VDF
DO $$
BEGIN
    -- Rename VDF_user_account to vdf_user_account
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'VDF_user_account') THEN
        ALTER TABLE "VDF_user_account" RENAME TO vdf_user_account;
        RAISE NOTICE 'Renamed VDF_user_account to vdf_user_account';
    END IF;

    -- Rename VDF_application to vdf_application
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'VDF_application') THEN
        ALTER TABLE "VDF_application" RENAME TO vdf_application;
        RAISE NOTICE 'Renamed VDF_application to vdf_application';
    END IF;

    -- Rename VDF_registration to vdf_registration
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'VDF_registration') THEN
        ALTER TABLE "VDF_registration" RENAME TO vdf_registration;
        RAISE NOTICE 'Renamed VDF_registration to vdf_registration';
    END IF;

    -- Rename VDF_committee_meeting to vdf_committee_meeting
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'VDF_committee_meeting') THEN
        ALTER TABLE "VDF_committee_meeting" RENAME TO vdf_committee_meeting;
        RAISE NOTICE 'Renamed VDF_committee_meeting to vdf_committee_meeting';
    END IF;

    -- Rename VDF_application_file to vdf_application_file
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'VDF_application_file') THEN
        ALTER TABLE "VDF_application_file" RENAME TO vdf_application_file;
        RAISE NOTICE 'Renamed VDF_application_file to vdf_application_file';
    END IF;
END $$;

-- Verify the rename worked
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

-- Verify users still exist
SELECT email, enabled, password_set FROM vdf_user_account WHERE email LIKE '%@demo.com' ORDER BY email;
