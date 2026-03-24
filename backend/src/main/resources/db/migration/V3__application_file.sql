-- Application file attachments (uploaded documents per application)
CREATE TABLE IF NOT EXISTS application_file (
    id UUID PRIMARY KEY,
    application_id UUID NOT NULL REFERENCES application(id) ON DELETE CASCADE,
    scope VARCHAR(50) NOT NULL,
    label VARCHAR(255),
    original_name VARCHAR(500) NOT NULL,
    stored_name VARCHAR(255) NOT NULL UNIQUE,
    content_type VARCHAR(100),
    size_bytes BIGINT,
    uploaded_at TIMESTAMP NOT NULL,
    uploaded_by VARCHAR(255) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_application_file_application_id ON application_file(application_id);
CREATE INDEX IF NOT EXISTS idx_application_file_scope ON application_file(application_id, scope);
