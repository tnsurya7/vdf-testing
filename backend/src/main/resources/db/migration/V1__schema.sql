-- VDF backend schema (JPA will create tables if ddl-auto=create; use this with ddl-auto=validate for production)
-- For initial setup with Flyway we create tables here so ddl-auto can be validate.

CREATE TABLE IF NOT EXISTS user_account (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(50) NOT NULL,
    sidbi_role VARCHAR(50),
    enabled BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS registration (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name_of_applicant VARCHAR(500) NOT NULL,
    registered_office VARCHAR(500),
    location_of_facilities VARCHAR(500),
    date_of_incorporation VARCHAR(50),
    date_of_commencement VARCHAR(50),
    pan_no VARCHAR(50),
    gst_no VARCHAR(50),
    msme_status VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    submitted_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS application (
    id UUID PRIMARY KEY,
    applicant_email VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    stage VARCHAR(50) NOT NULL,
    workflow_step VARCHAR(50) NOT NULL,
    assigned_maker VARCHAR(255),
    assigned_checker VARCHAR(255),
    assigned_convenor VARCHAR(255),
    assigned_approver VARCHAR(255),
    recommended_outcome VARCHAR(20),
    prelim_data JSONB,
    detailed_data JSONB,
    icvd_note JSONB,
    ccic_note JSONB,
    icvd_meeting_id UUID,
    ccic_meeting_id UUID,
    comments JSONB,
    audit_trail JSONB,
    submitted_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS committee_meeting (
    id UUID PRIMARY KEY,
    type VARCHAR(20) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    meeting_number INTEGER NOT NULL,
    date_time VARCHAR(100) NOT NULL,
    total_members JSONB,
    selected_members JSONB,
    maker_email VARCHAR(255) NOT NULL,
    checker_email VARCHAR(255) NOT NULL,
    convenor_email VARCHAR(255) NOT NULL,
    approver_email VARCHAR(255),
    application_ids JSONB,
    status VARCHAR(20) NOT NULL,
    votes JSONB,
    outcome VARCHAR(20),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_application_applicant ON application(applicant_email);
CREATE INDEX IF NOT EXISTS idx_application_workflow_step ON application(workflow_step);
CREATE INDEX IF NOT EXISTS idx_registration_status ON registration(status);
CREATE INDEX IF NOT EXISTS idx_committee_meeting_type ON committee_meeting(type);
