-- Store reference to uploaded minutes document for a committee meeting
ALTER TABLE committee_meeting
  ADD COLUMN IF NOT EXISTS minutes_file_id UUID REFERENCES application_file(id) ON DELETE SET NULL;
ALTER TABLE committee_meeting
  ADD COLUMN IF NOT EXISTS minutes_file_name VARCHAR(500);
