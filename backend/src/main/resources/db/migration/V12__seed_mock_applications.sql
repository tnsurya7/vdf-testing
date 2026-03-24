-- ─────────────────────────────────────────────────────────────────────────────
-- V12: Seed mock applications covering every workflow stage for testing
-- All applications belong to applicant@demo.com
-- Assigned to: sidbi-maker@demo.com, sidbi-checker@demo.com,
--              sidbi-convenor@demo.com, sidbi-approving@demo.com
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Prelim submitted → waiting for Maker review ───────────────────────────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000001'::uuid,
  'applicant@demo.com', 'pending_review', 'prelim', 'prelim_submitted',
  'sidbi-maker@demo.com', NULL, NULL, NULL,
  NULL,
  '{
    "aifName": "Alpha Capital Fund I",
    "businessModel": "B2B SaaS platform providing supply chain financing solutions to MSMEs",
    "amountInvestedPast": "25", "investmentAsOnDate": "40", "additionalInvestment": "15",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  NULL, NULL, NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Preliminary application submitted","timestamp":"2026-03-01T10:00:00Z"}]'::jsonb,
  '2026-03-01T10:00:00Z', '2026-03-01T10:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 2. Detailed form open → waiting for Applicant to fill detailed form ───────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000002'::uuid,
  'applicant@demo.com', 'approved', 'detailed', 'detailed_form_open',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL,
  NULL,
  '{
    "aifName": "Beta Innovations Fund",
    "businessModel": "Deep-tech hardware startup focused on IoT sensors for agriculture",
    "amountInvestedPast": "10", "investmentAsOnDate": "18", "additionalInvestment": "8",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  NULL, NULL, NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Prelim submitted","timestamp":"2026-02-15T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"approve_prelim","remark":"Prelim approved. Detailed form opened.","timestamp":"2026-02-18T11:00:00Z"}]'::jsonb,
  '2026-02-15T09:00:00Z', '2026-02-18T11:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 3. Detailed maker review → Maker reviewing detailed application ───────────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000003'::uuid,
  'applicant@demo.com', 'pending_review', 'detailed', 'detailed_maker_review',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL,
  NULL,
  '{
    "aifName": "Gamma Growth Fund",
    "businessModel": "Fintech lending platform for SME working capital",
    "amountInvestedPast": "50", "investmentAsOnDate": "75", "additionalInvestment": "25",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  '{
    "companyProfile": "Gamma Manufacturing Pvt Ltd is a leading fintech company providing working capital solutions to SMEs across India.",
    "capitalTable": [{"shareholder":"Promoter A","shareType":"Equity","percentHolding":"45","amountInvested":"45"},{"shareholder":"VC Fund X","shareType":"Preference","percentHolding":"35","amountInvested":"35"},{"shareholder":"Angel Investors","shareType":"Equity","percentHolding":"20","amountInvested":"20"}],
    "financialPerformance": [],
    "revenueTrends": [],
    "unitEconomics": {"description":"Strong unit economics with CAC payback of 8 months","grid":[]},
    "cashBalance": "12", "cashRunway": "18", "arrears": "none", "enterpriseValue": "150",
    "fundingRequirement": {"totalRequirement":"25","sidbiAmount":"20","repaymentPeriod":"36","securities":"Charge on receivables and personal guarantee"},
    "facilitiesAvailed": {"flag":"no","details":""},
    "eligibilityChecklist": {},
    "declarations": {"declaration1":true,"declaration2":true,"declaration3":true},
    "signature": {"place":"Mumbai","date":"2026-03-05","name":"Rajesh Kumar","designation":"CEO","email":"applicant@demo.com"},
    "aifConfirmation": {}
  }'::jsonb,
  NULL, NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Prelim submitted","timestamp":"2026-02-01T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"approve_prelim","remark":"Approved","timestamp":"2026-02-05T10:00:00Z"},{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_detailed","remark":"Detailed application submitted","timestamp":"2026-03-05T14:00:00Z"}]'::jsonb,
  '2026-02-01T09:00:00Z', '2026-03-05T14:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 4. Detailed checker review → Checker reviewing (maker recommended pursual) ─
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000004'::uuid,
  'applicant@demo.com', 'recommend_pursual', 'detailed', 'detailed_checker_review',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL,
  'pursual',
  '{
    "aifName": "Delta Ventures Fund II",
    "businessModel": "EV charging infrastructure network across Tier-2 cities",
    "amountInvestedPast": "30", "investmentAsOnDate": "55", "additionalInvestment": "20",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  '{
    "companyProfile": "Delta Services is building EV charging infrastructure across India.",
    "capitalTable": [{"shareholder":"Promoter","shareType":"Equity","percentHolding":"60","amountInvested":"60"},{"shareholder":"PE Fund","shareType":"Preference","percentHolding":"40","amountInvested":"40"}],
    "financialPerformance": [],
    "revenueTrends": [],
    "unitEconomics": {"description":"Improving unit economics with 14-month CAC payback","grid":[]},
    "cashBalance": "8", "cashRunway": "12", "arrears": "none", "enterpriseValue": "200",
    "fundingRequirement": {"totalRequirement":"20","sidbiAmount":"15","repaymentPeriod":"48","securities":"Charge on assets and promoter guarantee"},
    "facilitiesAvailed": {"flag":"no","details":""},
    "eligibilityChecklist": {},
    "declarations": {"declaration1":true,"declaration2":true,"declaration3":true},
    "signature": {"place":"Delhi","date":"2026-03-08","name":"Priya Sharma","designation":"MD","email":"applicant@demo.com"},
    "aifConfirmation": {}
  }'::jsonb,
  NULL, NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"recommend_pursual","remark":"Strong business case. Recommend for IC-VD review.","timestamp":"2026-03-10T11:00:00Z"}]'::jsonb,
  '2026-01-20T09:00:00Z', '2026-03-10T11:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 5. IC-VD maker review → Maker preparing IC-VD note ───────────────────────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000005'::uuid,
  'applicant@demo.com', 'pending_review', 'icvd', 'icvd_maker_review',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL,
  'pursual',
  '{
    "aifName": "Epsilon Health Fund",
    "businessModel": "Digital health platform connecting patients with specialists",
    "amountInvestedPast": "20", "investmentAsOnDate": "35", "additionalInvestment": "12",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  '{
    "companyProfile": "Epsilon Health is a digital health platform with 500K+ registered patients.",
    "capitalTable": [{"shareholder":"Founders","shareType":"Equity","percentHolding":"55","amountInvested":"55"},{"shareholder":"Series A Fund","shareType":"Preference","percentHolding":"45","amountInvested":"45"}],
    "financialPerformance": [],
    "revenueTrends": [],
    "unitEconomics": {"description":"Positive unit economics with 10-month payback","grid":[]},
    "cashBalance": "15", "cashRunway": "20", "arrears": "none", "enterpriseValue": "180",
    "fundingRequirement": {"totalRequirement":"12","sidbiAmount":"10","repaymentPeriod":"36","securities":"Charge on IP and receivables"},
    "facilitiesAvailed": {"flag":"no","details":""},
    "eligibilityChecklist": {},
    "declarations": {"declaration1":true,"declaration2":true,"declaration3":true},
    "signature": {"place":"Bengaluru","date":"2026-02-20","name":"Anil Verma","designation":"CTO","email":"applicant@demo.com"},
    "aifConfirmation": {}
  }'::jsonb,
  NULL, NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"recommend_icvd","remark":"Forwarded to IC-VD stage for committee review.","timestamp":"2026-03-12T09:00:00Z"}]'::jsonb,
  '2026-01-10T09:00:00Z', '2026-03-12T09:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 6. IC-VD convenor scheduling → Convenor needs to schedule meeting ─────────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000006'::uuid,
  'applicant@demo.com', 'pending_review', 'icvd', 'icvd_convenor_scheduling',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL,
  'pursual',
  '{
    "aifName": "Zeta Agri Fund",
    "businessModel": "Precision agriculture platform using satellite imagery and AI",
    "amountInvestedPast": "15", "investmentAsOnDate": "28", "additionalInvestment": "10",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  '{
    "companyProfile": "Zeta Agri uses satellite data and AI to help farmers optimize yields.",
    "capitalTable": [{"shareholder":"Founders","shareType":"Equity","percentHolding":"65","amountInvested":"65"},{"shareholder":"Agri VC","shareType":"Preference","percentHolding":"35","amountInvested":"35"}],
    "financialPerformance": [],
    "revenueTrends": [],
    "unitEconomics": {"description":"Positive unit economics","grid":[]},
    "cashBalance": "6", "cashRunway": "10", "arrears": "none", "enterpriseValue": "120",
    "fundingRequirement": {"totalRequirement":"10","sidbiAmount":"8","repaymentPeriod":"36","securities":"Charge on receivables"},
    "facilitiesAvailed": {"flag":"no","details":""},
    "eligibilityChecklist": {},
    "declarations": {"declaration1":true,"declaration2":true,"declaration3":true},
    "signature": {"place":"Hyderabad","date":"2026-02-25","name":"Suresh Reddy","designation":"CEO","email":"applicant@demo.com"},
    "aifConfirmation": {}
  }'::jsonb,
  '{"summary":"Strong agri-tech play with proven technology. Recommend for IC-VD committee review.","recommendation":"pursual","attachments":[]}'::jsonb,
  NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"icvd_maker_forward","remark":"IC-VD note prepared and forwarded to checker.","timestamp":"2026-03-13T10:00:00Z"},{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"icvd_checker_assign_convenor","remark":"Assigned convenor for IC-VD meeting scheduling.","timestamp":"2026-03-14T11:00:00Z"}]'::jsonb,
  '2026-01-05T09:00:00Z', '2026-03-14T11:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 7. CCIC maker refine → Maker preparing CCIC note ─────────────────────────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000007'::uuid,
  'applicant@demo.com', 'pending_review', 'ccic', 'ccic_maker_refine',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', 'sidbi-approving@demo.com',
  'pursual',
  '{
    "aifName": "Eta Logistics Fund",
    "businessModel": "Last-mile logistics platform for e-commerce in Tier-3 cities",
    "amountInvestedPast": "40", "investmentAsOnDate": "65", "additionalInvestment": "20",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  '{
    "companyProfile": "Eta Logistics operates 200+ delivery hubs across Tier-3 cities.",
    "capitalTable": [{"shareholder":"Founders","shareType":"Equity","percentHolding":"50","amountInvested":"50"},{"shareholder":"Growth Fund","shareType":"Preference","percentHolding":"50","amountInvested":"50"}],
    "financialPerformance": [],
    "revenueTrends": [],
    "unitEconomics": {"description":"Hub-and-spoke model with strong unit economics","grid":[]},
    "cashBalance": "20", "cashRunway": "24", "arrears": "none", "enterpriseValue": "300",
    "fundingRequirement": {"totalRequirement":"20","sidbiAmount":"18","repaymentPeriod":"48","securities":"Charge on fleet and receivables"},
    "facilitiesAvailed": {"flag":"no","details":""},
    "eligibilityChecklist": {},
    "declarations": {"declaration1":true,"declaration2":true,"declaration3":true},
    "signature": {"place":"Chennai","date":"2026-02-10","name":"Meena Iyer","designation":"CFO","email":"applicant@demo.com"},
    "aifConfirmation": {}
  }'::jsonb,
  '{"summary":"IC-VD committee reviewed and referred to CCIC-CGM for final sanction.","recommendation":"pursual","attachments":[]}'::jsonb,
  NULL, NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"committee_member","actorId":"sidbi-committee@demo.com","actionType":"icvd_committee_refer","remark":"IC-VD committee recommends referral to CCIC-CGM.","timestamp":"2026-03-15T15:00:00Z"}]'::jsonb,
  '2025-12-01T09:00:00Z', '2026-03-15T15:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 8. Final approval → Approving Authority to sanction ──────────────────────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000008'::uuid,
  'applicant@demo.com', 'pending_review', 'final_', 'final_approval',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', 'sidbi-approving@demo.com',
  'pursual',
  '{
    "aifName": "Theta CleanTech Fund",
    "businessModel": "Solar energy solutions for industrial and commercial clients",
    "amountInvestedPast": "60", "investmentAsOnDate": "90", "additionalInvestment": "30",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  '{
    "companyProfile": "Theta CleanTech installs and operates solar plants for industrial clients.",
    "capitalTable": [{"shareholder":"Promoters","shareType":"Equity","percentHolding":"55","amountInvested":"55"},{"shareholder":"Climate Fund","shareType":"Preference","percentHolding":"45","amountInvested":"45"}],
    "financialPerformance": [],
    "revenueTrends": [],
    "unitEconomics": {"description":"Long-term PPAs ensure stable cash flows","grid":[]},
    "cashBalance": "25", "cashRunway": "30", "arrears": "none", "enterpriseValue": "400",
    "fundingRequirement": {"totalRequirement":"30","sidbiAmount":"25","repaymentPeriod":"60","securities":"Charge on solar assets and PPAs"},
    "facilitiesAvailed": {"flag":"no","details":""},
    "eligibilityChecklist": {},
    "declarations": {"declaration1":true,"declaration2":true,"declaration3":true},
    "signature": {"place":"Pune","date":"2026-01-15","name":"Vikram Nair","designation":"Director","email":"applicant@demo.com"},
    "aifConfirmation": {}
  }'::jsonb,
  '{"summary":"IC-VD committee approved. Strong clean energy play.","recommendation":"pursual","attachments":[]}'::jsonb,
  '{"summary":"CCIC-CGM committee reviewed and recommends sanction of INR 25 Cr venture debt.","recommendation":"pursual","attachments":[]}'::jsonb,
  NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"committee_member","actorId":"sidbi-committee@demo.com","actionType":"ccic_committee_refer","remark":"CCIC-CGM recommends sanction. Forwarded to Approving Authority.","timestamp":"2026-03-16T14:00:00Z"}]'::jsonb,
  '2025-11-01T09:00:00Z', '2026-03-16T14:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- ── 9. Sanctioned (completed flow example) ───────────────────────────────────
INSERT INTO vdf_application (
  id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail,
  submitted_at, updated_at
) VALUES (
  'b0000001-0000-0000-0000-000000000009'::uuid,
  'applicant@demo.com', 'sanctioned', 'final_', 'sanctioned',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', 'sidbi-approving@demo.com',
  'pursual',
  '{
    "aifName": "Iota EdTech Fund",
    "businessModel": "Online skilling platform for blue-collar workers",
    "amountInvestedPast": "18", "investmentAsOnDate": "30", "additionalInvestment": "10",
    "entityType": "yes", "vintage": "yes", "recentEquity": "yes", "operatingIncome": "yes",
    "revenueGrowth": "yes", "positiveNetWorth": "yes", "noDefaultHistory": "yes",
    "noLegalProceedings": "yes", "noRelatedParty": "yes", "noNPA": "yes",
    "msmeRegistration": "yes", "gstCompliance": "yes", "itCompliance": "yes",
    "environmentalCompliance": "yes", "cibilScore": "yes",
    "remarks": {}
  }'::jsonb,
  '{
    "companyProfile": "Iota EdTech has trained 1M+ blue-collar workers across India.",
    "capitalTable": [{"shareholder":"Founders","shareType":"Equity","percentHolding":"70","amountInvested":"70"},{"shareholder":"Impact Fund","shareType":"Preference","percentHolding":"30","amountInvested":"30"}],
    "financialPerformance": [],
    "revenueTrends": [],
    "unitEconomics": {"description":"Scalable digital delivery with low marginal cost","grid":[]},
    "cashBalance": "10", "cashRunway": "15", "arrears": "none", "enterpriseValue": "100",
    "fundingRequirement": {"totalRequirement":"10","sidbiAmount":"8","repaymentPeriod":"36","securities":"Charge on receivables"},
    "facilitiesAvailed": {"flag":"no","details":""},
    "eligibilityChecklist": {},
    "declarations": {"declaration1":true,"declaration2":true,"declaration3":true},
    "signature": {"place":"Mumbai","date":"2025-10-01","name":"Ravi Gupta","designation":"CEO","email":"applicant@demo.com"},
    "aifConfirmation": {}
  }'::jsonb,
  '{"summary":"IC-VD approved.","recommendation":"pursual","attachments":[]}'::jsonb,
  '{"summary":"CCIC-CGM approved.","recommendation":"pursual","attachments":[]}'::jsonb,
  NULL, NULL,
  '{}'::jsonb,
  '[{"actorRole":"approving_authority","actorId":"sidbi-approving@demo.com","actionType":"approve_sanction","remark":"Sanction approved. INR 8 Cr venture debt sanctioned.","timestamp":"2026-02-28T16:00:00Z"}]'::jsonb,
  '2025-09-01T09:00:00Z', '2026-02-28T16:00:00Z'
) ON CONFLICT (id) DO NOTHING;
