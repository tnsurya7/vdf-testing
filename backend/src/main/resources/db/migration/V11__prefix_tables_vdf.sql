-- Prefix all tables with VDF_ for namespacing (e.g. shared database).
-- Indexes and constraints move with the table; FKs remain valid after rename.

ALTER TABLE user_account RENAME TO VDF_user_account;
ALTER TABLE registration RENAME TO VDF_registration;
ALTER TABLE application RENAME TO VDF_application;
ALTER TABLE committee_meeting RENAME TO VDF_committee_meeting;
ALTER TABLE application_file RENAME TO VDF_application_file;
