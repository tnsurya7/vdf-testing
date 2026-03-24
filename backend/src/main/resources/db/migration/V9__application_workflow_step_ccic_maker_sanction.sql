-- Allow workflow_step 'ccic_maker_sanction'. Drop any existing check constraint on workflow_step
-- (Hibernate may have created it with a different name), then add one with all current values.
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT c.conname
    FROM pg_constraint c
    JOIN pg_attribute a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
    WHERE c.conrelid = 'application'::regclass
      AND c.contype = 'c'
      AND a.attname = 'workflow_step'
      AND NOT a.attisdropped
  LOOP
    EXECUTE format('ALTER TABLE application DROP CONSTRAINT %I', r.conname);
  END LOOP;
END $$;

ALTER TABLE application ADD CONSTRAINT application_workflow_step_check CHECK (workflow_step IN (
  'prelim_review', 'prelim_submitted', 'prelim_revision', 'prelim_rejected',
  'detailed_form', 'detailed_form_open', 'detailed_revision', 'detailed_maker_review',
  'detailed_checker_review', 'detailed_rejected',
  'icvd_maker_review', 'icvd_checker_review', 'icvd_convenor_scheduling', 'icvd_committee_review',
  'icvd_referred', 'icvd_note_preparation',
  'ccic_maker_refine', 'ccic_checker_review', 'ccic_second_checker_review', 'ccic_convenor_scheduling',
  'ccic_committee_review', 'ccic_referred', 'ccic_maker_sanction', 'ccic_note_preparation',
  'final_approval', 'final_rejected', 'sanctioned', 'completed'
));
