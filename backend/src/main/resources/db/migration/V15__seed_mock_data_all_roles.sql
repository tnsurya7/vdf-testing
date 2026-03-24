-- ─────────────────────────────────────────────────────────────────────────────
-- V15: Comprehensive mock data for all demo accounts
-- Covers: registrations, committee meetings (icvd + ccic), applications at
--         every workflow stage, votes, and audit trails.
-- Demo users:
--   applicant@demo.com  (applicant)
--   sidbi-maker@demo.com (maker)
--   sidbi-checker@demo.com (checker)
--   sidbi-convenor@demo.com (convenor)
--   sidbi-icvd@demo.com (icvd_committee_member)
--   sidbi-ccic@demo.com (ccic_committee_member)
--   admin@demo.com (admin)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── REGISTRATIONS ─────────────────────────────────────────────────────────────

INSERT INTO "VDF_registration" (id, email, name_of_applicant, registered_office, location_of_facilities,
  date_of_incorporation, date_of_commencement, pan_no, gst_no, cin, msme_status, status, submitted_at)
VALUES
  ('c0000001-0000-0000-0000-000000000001'::uuid,
   'applicant@demo.com', 'Nexus Innovations Pvt Ltd',
   '14th Floor, Cyber Tower, Hitech City, Hyderabad - 500081',
   'Plot 22, Industrial Area, Pune - 411019',
   '2018-04-12', '2018-07-01', 'AABCN1234F', '36AABCN1234F1Z5', 'U72900TG2018PTC123456',
   'small', 'approved', '2026-01-10T08:30:00Z'),

  ('c0000001-0000-0000-0000-000000000002'::uuid,
   'applicant@demo.com', 'Kappa Robotics Pvt Ltd',
   '5th Floor, DLF Cyber City, Gurugram - 122002',
   'Sector 63, Noida - 201301',
   '2019-09-20', '2020-01-15', 'AABCK5678G', '06AABCK5678G1Z2', 'U29309HR2019PTC234567',
   'medium', 'pending', '2026-03-05T10:00:00Z'),

  ('c0000001-0000-0000-0000-000000000003'::uuid,
   'applicant@demo.com', 'Lambda BioTech Ltd',
   '3rd Floor, Prestige Tech Park, Bengaluru - 560066',
   'KIADB Industrial Area, Bengaluru - 562149',
   '2017-06-30', '2017-10-01', 'AABCL9012H', '29AABCL9012H1Z8', 'U24230KA2017PLC345678',
   'micro', 'rejected', '2026-02-20T14:00:00Z')
ON CONFLICT (id) DO NOTHING;

-- ── IC-VD COMMITTEE MEETING (scheduled, with linked application) ──────────────

INSERT INTO "VDF_committee_meeting" (id, type, subject, meeting_number, date_time,
  total_members, selected_members,
  maker_email, checker_email, convenor_email, approver_email, chair_person_email,
  minutes_file_id, minutes_file_name,
  application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES (
  'd0000001-0000-0000-0000-000000000001'::uuid,
  'icvd',
  'IC-VD Meeting #3 – Epsilon Health Fund & Zeta Agri Fund',
  3,
  '2026-03-25T10:00:00+05:30',
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"},{"id":"m003","name":"Mr. Suresh Nair","email":"sidbi-checker@demo.com"}]'::jsonb,
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]'::jsonb,
  'sidbi-maker@demo.com',
  'sidbi-checker@demo.com',
  'sidbi-convenor@demo.com',
  NULL,
  'sidbi-icvd@demo.com',
  NULL, NULL,
  '["b0000001-0000-0000-0000-000000000005","b0000001-0000-0000-0000-000000000006"]'::jsonb,
  '[]'::jsonb,
  'scheduled',
  '[]'::jsonb,
  NULL,
  '2026-03-18T09:00:00Z', '2026-03-18T09:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── IC-VD MEETING (completed, referred to CCIC) ───────────────────────────────

INSERT INTO "VDF_committee_meeting" (id, type, subject, meeting_number, date_time,
  total_members, selected_members,
  maker_email, checker_email, convenor_email, approver_email, chair_person_email,
  minutes_file_id, minutes_file_name,
  application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES (
  'd0000001-0000-0000-0000-000000000002'::uuid,
  'icvd',
  'IC-VD Meeting #2 – Eta Logistics Fund',
  2,
  '2026-03-10T10:00:00+05:30',
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]'::jsonb,
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]'::jsonb,
  'sidbi-maker@demo.com',
  'sidbi-checker@demo.com',
  'sidbi-convenor@demo.com',
  NULL,
  'sidbi-icvd@demo.com',
  NULL, NULL,
  '["b0000001-0000-0000-0000-000000000007"]'::jsonb,
  '[{"applicationId":"b0000001-0000-0000-0000-000000000007","approved":true,"approvedAmount":18000000}]'::jsonb,
  'completed',
  '[{"memberId":"sidbi-icvd@demo.com","vote":"approve","comment":"Strong logistics play with proven unit economics. Recommend referral to CCIC-CGM.","timestamp":"2026-03-10T11:30:00Z"},{"memberId":"sidbi-ccic@demo.com","vote":"approve","comment":"Agree with recommendation.","timestamp":"2026-03-10T11:45:00Z"}]'::jsonb,
  'referred',
  '2026-03-05T09:00:00Z', '2026-03-10T12:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── CCIC COMMITTEE MEETING (in_progress – sent for consent) ──────────────────

INSERT INTO "VDF_committee_meeting" (id, type, subject, meeting_number, date_time,
  total_members, selected_members,
  maker_email, checker_email, convenor_email, approver_email, chair_person_email,
  minutes_file_id, minutes_file_name,
  application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES (
  'd0000001-0000-0000-0000-000000000003'::uuid,
  'ccic',
  'CCIC-CGM Meeting #4 – Theta CleanTech Fund',
  4,
  '2026-03-20T14:00:00+05:30',
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"},{"id":"m003","name":"Mr. Suresh Nair","email":"sidbi-checker@demo.com"}]'::jsonb,
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]'::jsonb,
  'sidbi-maker@demo.com',
  'sidbi-checker@demo.com',
  'sidbi-convenor@demo.com',
  NULL,
  'sidbi-ccic@demo.com',
  NULL, NULL,
  '["b0000001-0000-0000-0000-000000000008"]'::jsonb,
  '[{"applicationId":"b0000001-0000-0000-0000-000000000008","approved":true,"approvedAmount":25000000}]'::jsonb,
  'in_progress',
  '[{"memberId":"sidbi-ccic@demo.com","vote":"approve","comment":"Clean energy sector with strong PPA-backed cash flows. Recommend sanction of INR 25 Cr.","timestamp":"2026-03-20T15:00:00Z"}]'::jsonb,
  NULL,
  '2026-03-15T09:00:00Z', '2026-03-20T15:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── CCIC MEETING (completed, referred) ───────────────────────────────────────

INSERT INTO "VDF_committee_meeting" (id, type, subject, meeting_number, date_time,
  total_members, selected_members,
  maker_email, checker_email, convenor_email, approver_email, chair_person_email,
  minutes_file_id, minutes_file_name,
  application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES (
  'd0000001-0000-0000-0000-000000000004'::uuid,
  'ccic',
  'CCIC-CGM Meeting #3 – Iota EdTech Fund',
  3,
  '2026-02-20T14:00:00+05:30',
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]'::jsonb,
  '[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]'::jsonb,
  'sidbi-maker@demo.com',
  'sidbi-checker@demo.com',
  'sidbi-convenor@demo.com',
  NULL,
  'sidbi-ccic@demo.com',
  NULL, NULL,
  '["b0000001-0000-0000-0000-000000000009"]'::jsonb,
  '[{"applicationId":"b0000001-0000-0000-0000-000000000009","approved":true,"approvedAmount":8000000}]'::jsonb,
  'completed',
  '[{"memberId":"sidbi-ccic@demo.com","vote":"approve","comment":"EdTech with strong social impact. Recommend sanction.","timestamp":"2026-02-20T15:30:00Z"},{"memberId":"sidbi-icvd@demo.com","vote":"approve","comment":"Agree.","timestamp":"2026-02-20T15:45:00Z"}]'::jsonb,
  'referred',
  '2026-02-15T09:00:00Z', '2026-02-20T16:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── UPDATE EXISTING APPLICATIONS WITH MEETING IDs ────────────────────────────

-- App 5 (icvd_maker_review) and App 6 (icvd_convenor_scheduling) linked to IC-VD meeting #3
UPDATE "VDF_application"
SET icvd_meeting_id = 'd0000001-0000-0000-0000-000000000001'::uuid,
    updated_at = '2026-03-18T09:00:00Z'
WHERE id IN (
  'b0000001-0000-0000-0000-000000000005'::uuid,
  'b0000001-0000-0000-0000-000000000006'::uuid
);

-- App 7 (ccic_maker_refine) linked to completed IC-VD meeting #2
UPDATE "VDF_application"
SET icvd_meeting_id = 'd0000001-0000-0000-0000-000000000002'::uuid,
    updated_at = '2026-03-15T15:00:00Z'
WHERE id = 'b0000001-0000-0000-0000-000000000007'::uuid;

-- App 8 (final_approval) linked to CCIC meeting #4 (in_progress)
UPDATE "VDF_application"
SET ccic_meeting_id = 'd0000001-0000-0000-0000-000000000003'::uuid,
    updated_at = '2026-03-20T15:00:00Z'
WHERE id = 'b0000001-0000-0000-0000-000000000008'::uuid;

-- App 9 (sanctioned) linked to completed CCIC meeting #3
UPDATE "VDF_application"
SET ccic_meeting_id = 'd0000001-0000-0000-0000-000000000004'::uuid,
    updated_at = '2026-02-28T16:00:00Z'
WHERE id = 'b0000001-0000-0000-0000-000000000009'::uuid;

-- ── ADDITIONAL APPLICATIONS (more variety for each role's queue) ──────────────

-- App 10: prelim_revision (reverted to applicant for changes)
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000010'::uuid,
  'applicant@demo.com', 'reverted', 'prelim', 'prelim_revision',
  'sidbi-maker@demo.com', NULL, NULL, NULL, NULL,
  '{"aifName":"Mu Fintech Fund","businessModel":"BNPL platform for rural consumers","amountInvestedPast":"5","investmentAsOnDate":"12","additionalInvestment":"5","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}'::jsonb,
  NULL, NULL, NULL, NULL, NULL,
  '{"_global":{"needsChange":true,"comment":"Please clarify the AIF registration number and provide audited financials for FY2024-25."}}'::jsonb,
  '[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Preliminary application submitted","timestamp":"2026-03-10T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"revert_prelim","remark":"Please clarify the AIF registration number and provide audited financials for FY2024-25.","timestamp":"2026-03-12T11:00:00Z"}]'::jsonb,
  '2026-03-10T09:00:00Z', '2026-03-12T11:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- App 11: prelim_rejected
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000011'::uuid,
  'applicant@demo.com', 'rejected', 'prelim', 'prelim_rejected',
  'sidbi-maker@demo.com', NULL, NULL, NULL, NULL,
  '{"aifName":"Nu Crypto Fund","businessModel":"Crypto trading platform","amountInvestedPast":"2","investmentAsOnDate":"3","additionalInvestment":"2","entityType":"no","vintage":"no","recentEquity":"no","operatingIncome":"no","revenueGrowth":"no","positiveNetWorth":"no","noDefaultHistory":"no","noLegalProceedings":"no","noRelatedParty":"no","noNPA":"no","msmeRegistration":"no","gstCompliance":"no","itCompliance":"no","environmentalCompliance":"no","cibilScore":"no","remarks":{}}'::jsonb,
  NULL, NULL, NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Preliminary application submitted","timestamp":"2026-02-28T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"reject_prelim","remark":"Application does not meet eligibility criteria. Business model not aligned with VDF mandate.","timestamp":"2026-03-02T10:00:00Z"}]'::jsonb,
  '2026-02-28T09:00:00Z', '2026-03-02T10:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- App 12: detailed_revision (reverted to applicant)
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000012'::uuid,
  'applicant@demo.com', 'reverted', 'detailed', 'detailed_revision',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, NULL,
  '{"aifName":"Xi Mobility Fund","businessModel":"EV two-wheeler subscription platform","amountInvestedPast":"22","investmentAsOnDate":"38","additionalInvestment":"14","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}'::jsonb,
  '{"companyProfile":"Xi Mobility operates EV subscription services in 5 cities.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"60","amountInvested":"60"},{"shareholder":"Mobility VC","shareType":"Preference","percentHolding":"40","amountInvested":"40"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Subscription model with 18-month payback","grid":[]},"cashBalance":"9","cashRunway":"14","arrears":"none","enterpriseValue":"160","fundingRequirement":{"totalRequirement":"14","sidbiAmount":"12","repaymentPeriod":"36","securities":"Charge on fleet and receivables"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Bengaluru","date":"2026-03-01","name":"Kiran Rao","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}'::jsonb,
  NULL, NULL, NULL, NULL,
  '{"_global":{"needsChange":true,"comment":"Please provide fleet insurance details and updated CIBIL report."}}'::jsonb,
  '[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"revert_detailed","remark":"Please provide fleet insurance details and updated CIBIL report.","timestamp":"2026-03-14T10:00:00Z"}]'::jsonb,
  '2026-02-10T09:00:00Z', '2026-03-14T10:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- App 13: detailed_rejected
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000013'::uuid,
  'applicant@demo.com', 'rejected', 'detailed', 'detailed_rejected',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, 'rejection',
  '{"aifName":"Omicron Retail Fund","businessModel":"Offline retail chain expansion","amountInvestedPast":"35","investmentAsOnDate":"50","additionalInvestment":"18","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"no","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}'::jsonb,
  '{"companyProfile":"Omicron Retail operates 50+ stores across South India.","capitalTable":[{"shareholder":"Promoters","shareType":"Equity","percentHolding":"70","amountInvested":"70"},{"shareholder":"PE Fund","shareType":"Preference","percentHolding":"30","amountInvested":"30"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Declining same-store sales growth","grid":[]},"cashBalance":"5","cashRunway":"8","arrears":"significant","enterpriseValue":"90","fundingRequirement":{"totalRequirement":"18","sidbiAmount":"15","repaymentPeriod":"36","securities":"Charge on inventory"},"facilitiesAvailed":{"flag":"yes","details":"Existing term loan of INR 10 Cr from SBI"},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Chennai","date":"2026-02-15","name":"Ramesh Babu","designation":"MD","email":"applicant@demo.com"},"aifConfirmation":{}}'::jsonb,
  NULL, NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"recommend_rejection","remark":"Declining revenue growth and high arrears. Not suitable for VDF.","timestamp":"2026-03-08T11:00:00Z"},{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"reject_final","remark":"Concur with maker. Application rejected.","timestamp":"2026-03-09T10:00:00Z"}]'::jsonb,
  '2026-01-25T09:00:00Z', '2026-03-09T10:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- App 14: icvd_checker_review (maker forwarded, checker to assign convenor)
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000014'::uuid,
  'applicant@demo.com', 'submitted', 'icvd', 'icvd_checker_review',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, 'pursual',
  '{"aifName":"Pi Pharma Fund","businessModel":"Generic pharmaceutical manufacturer for export markets","amountInvestedPast":"45","investmentAsOnDate":"70","additionalInvestment":"22","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}'::jsonb,
  '{"companyProfile":"Pi Pharma manufactures 200+ generic formulations exported to 30 countries.","capitalTable":[{"shareholder":"Promoters","shareType":"Equity","percentHolding":"65","amountInvested":"65"},{"shareholder":"Healthcare PE","shareType":"Preference","percentHolding":"35","amountInvested":"35"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Strong export margins with 22% EBITDA","grid":[]},"cashBalance":"18","cashRunway":"22","arrears":"none","enterpriseValue":"350","fundingRequirement":{"totalRequirement":"22","sidbiAmount":"20","repaymentPeriod":"48","securities":"Charge on plant and machinery"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Ahmedabad","date":"2026-02-28","name":"Dinesh Patel","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}'::jsonb,
  '{"summary":"Pi Pharma has strong export credentials and consistent revenue growth. IC-VD note prepared recommending pursual.","recommendation":"pursual","attachments":[]}'::jsonb,
  NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"recommend_icvd","remark":"Forwarded to IC-VD stage.","timestamp":"2026-03-11T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"icvd_maker_forward","remark":"IC-VD note prepared and forwarded to checker.","timestamp":"2026-03-16T10:00:00Z"}]'::jsonb,
  '2026-01-15T09:00:00Z', '2026-03-16T10:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- App 15: ccic_checker_review (maker uploaded CCIC note)
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000015'::uuid,
  'applicant@demo.com', 'submitted', 'ccic', 'ccic_checker_review',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
  '{"aifName":"Rho Water Fund","businessModel":"Water treatment and recycling solutions for industrial clients","amountInvestedPast":"28","investmentAsOnDate":"45","additionalInvestment":"16","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}'::jsonb,
  '{"companyProfile":"Rho Water provides zero-liquid-discharge solutions to 100+ industrial clients.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"55","amountInvested":"55"},{"shareholder":"ESG Fund","shareType":"Preference","percentHolding":"45","amountInvested":"45"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Long-term O&M contracts ensure stable recurring revenue","grid":[]},"cashBalance":"14","cashRunway":"20","arrears":"none","enterpriseValue":"220","fundingRequirement":{"totalRequirement":"16","sidbiAmount":"14","repaymentPeriod":"48","securities":"Charge on equipment and contracts"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Surat","date":"2026-02-05","name":"Hetal Shah","designation":"MD","email":"applicant@demo.com"},"aifConfirmation":{}}'::jsonb,
  '{"summary":"IC-VD committee approved. Strong ESG credentials.","recommendation":"pursual","attachments":[]}'::jsonb,
  '{"summary":"CCIC-CGM note prepared. Recommend sanction of INR 14 Cr venture debt for water treatment expansion.","recommendation":"pursual","attachments":[]}'::jsonb,
  'd0000001-0000-0000-0000-000000000002'::uuid, NULL,
  '{}'::jsonb,
  '[{"actorRole":"committee_member","actorId":"sidbi-icvd@demo.com","actionType":"icvd_committee_refer","remark":"IC-VD committee recommends referral to CCIC-CGM.","timestamp":"2026-03-10T12:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"ccic_maker_upload","remark":"CCIC note uploaded.","timestamp":"2026-03-17T10:00:00Z"}]'::jsonb,
  '2025-12-15T09:00:00Z', '2026-03-17T10:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- App 16: ccic_convenor_scheduling (checker assigned convenor)
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000016'::uuid,
  'applicant@demo.com', 'submitted', 'ccic', 'ccic_convenor_scheduling',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
  '{"aifName":"Sigma Space Fund","businessModel":"Satellite data analytics for defence and agriculture","amountInvestedPast":"55","investmentAsOnDate":"80","additionalInvestment":"25","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}'::jsonb,
  '{"companyProfile":"Sigma Space provides satellite analytics to government and enterprise clients.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"50","amountInvested":"50"},{"shareholder":"Deep Tech VC","shareType":"Preference","percentHolding":"50","amountInvested":"50"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"High-margin SaaS with government contracts","grid":[]},"cashBalance":"22","cashRunway":"28","arrears":"none","enterpriseValue":"500","fundingRequirement":{"totalRequirement":"25","sidbiAmount":"22","repaymentPeriod":"60","securities":"Charge on IP and government contracts"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Bengaluru","date":"2026-01-20","name":"Arjun Menon","designation":"CTO","email":"applicant@demo.com"},"aifConfirmation":{}}'::jsonb,
  '{"summary":"IC-VD approved. Strategic deep-tech play.","recommendation":"pursual","attachments":[]}'::jsonb,
  '{"summary":"CCIC note prepared. Recommend sanction of INR 22 Cr for satellite analytics expansion.","recommendation":"pursual","attachments":[]}'::jsonb,
  NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"ccic_checker_assign_convenor","remark":"Assigned convenor for CCIC-CGM meeting scheduling.","timestamp":"2026-03-19T11:00:00Z"}]'::jsonb,
  '2025-11-10T09:00:00Z', '2026-03-19T11:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- App 17: ccic_committee_review (meeting scheduled, committee to review)
INSERT INTO "VDF_application" (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000017'::uuid,
  'applicant@demo.com', 'under_review', 'ccic', 'ccic_committee_review',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
  '{"aifName":"Tau Textile Fund","businessModel":"Technical textiles for medical and defence applications","amountInvestedPast":"38","investmentAsOnDate":"60","additionalInvestment":"20","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}'::jsonb,
  '{"companyProfile":"Tau Textiles manufactures high-performance technical fabrics for medical and defence use.","capitalTable":[{"shareholder":"Promoters","shareType":"Equity","percentHolding":"60","amountInvested":"60"},{"shareholder":"Manufacturing PE","shareType":"Preference","percentHolding":"40","amountInvested":"40"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Import substitution play with strong government demand","grid":[]},"cashBalance":"16","cashRunway":"24","arrears":"none","enterpriseValue":"280","fundingRequirement":{"totalRequirement":"20","sidbiAmount":"18","repaymentPeriod":"48","securities":"Charge on plant and export receivables"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Surat","date":"2026-01-10","name":"Bhavesh Desai","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}'::jsonb,
  '{"summary":"IC-VD approved. Strong import substitution case.","recommendation":"pursual","attachments":[]}'::jsonb,
  '{"summary":"CCIC note prepared. Recommend sanction of INR 18 Cr for technical textile capacity expansion.","recommendation":"pursual","attachments":[]}'::jsonb,
  NULL, 'd0000001-0000-0000-0000-000000000003'::uuid,
  '{}'::jsonb,
  '[{"actorRole":"convenor","actorId":"sidbi-convenor@demo.com","actionType":"ccic_schedule_meeting","remark":"CCIC-CGM meeting scheduled for 2026-03-20.","timestamp":"2026-03-19T14:00:00Z"}]'::jsonb,
  '2025-10-15T09:00:00Z', '2026-03-19T14:00:00Z'
) ON CONFLICT (id) DO NOTHING;
