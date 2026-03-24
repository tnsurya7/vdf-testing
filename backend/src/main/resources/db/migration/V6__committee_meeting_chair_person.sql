-- Add chair person (committee member email) to committee meetings
ALTER TABLE committee_meeting
  ADD COLUMN IF NOT EXISTS chair_person_email VARCHAR(255);
