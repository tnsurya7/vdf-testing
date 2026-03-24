-- Per-application decisions (approved yes/no, approved amount) when convenor sends for consent
ALTER TABLE committee_meeting
  ADD COLUMN IF NOT EXISTS application_decisions JSONB DEFAULT '[]';
