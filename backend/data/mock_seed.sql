-- Mock seed data using lowercase table names (actual Postgres tables)

-- REGISTRATIONS
INSERT INTO vdf_registration (id, email, name_of_applicant, registered_office, location_of_facilities,
  date_of_incorporation, date_of_commencement, pan_no, gst_no, cin, msme_status, status, submitted_at)
VALUES
  ('c0000001-0000-0000-0000-000000000001', 'applicant@demo.com', 'Nexus Innovations Pvt Ltd',
   '14th Floor, Cyber Tower, Hitech City, Hyderabad - 500081', 'Plot 22, Industrial Area, Pune - 411019',
   '2018-04-12', '2018-07-01', 'AABCN1234F', '36AABCN1234F1Z5', 'U72900TG2018PTC123456',
   'small', 'approved', '2026-01-10T08:30:00Z'),
  ('c0000001-0000-0000-0000-000000000002', 'applicant@demo.com', 'Kappa Robotics Pvt Ltd',
   '5th Floor, DLF Cyber City, Gurugram - 122002', 'Sector 63, Noida - 201301',
   '2019-09-20', '2020-01-15', 'AABCK5678G', '06AABCK5678G1Z2', 'U29309HR2019PTC234567',
   'medium', 'pending', '2026-03-05T10:00:00Z'),
  ('c0000001-0000-0000-0000-000000000003', 'applicant@demo.com', 'Lambda BioTech Ltd',
   '3rd Floor, Prestige Tech Park, Bengaluru - 560066', 'KIADB Industrial Area, Bengaluru - 562149',
   '2017-06-30', '2017-10-01', 'AABCL9012H', '29AABCL9012H1Z8', 'U24230KA2017PLC345678',
   'micro', 'rejected', '2026-02-20T14:00:00Z')
ON CONFLICT (id) DO NOTHING;

-- APPLICATIONS (all stages)

-- 1. prelim_submitted
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000001', 'applicant@demo.com', 'pending_review', 'prelim', 'prelim_submitted', 'sidbi-maker@demo.com', NULL, NULL, NULL, NULL,
'{"aifName":"Alpha Capital Fund I","businessModel":"B2B SaaS platform providing supply chain financing solutions to MSMEs","amountInvestedPast":"25","investmentAsOnDate":"40","additionalInvestment":"15","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
NULL, NULL, NULL, NULL, NULL, '{}',
'[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Preliminary application submitted","timestamp":"2026-03-01T10:00:00Z"}]',
'2026-03-01T10:00:00Z', '2026-03-01T10:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 2. detailed_form_open
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000002', 'applicant@demo.com', 'approved', 'detailed', 'detailed_form_open', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, NULL,
'{"aifName":"Beta Innovations Fund","businessModel":"Deep-tech hardware startup focused on IoT sensors for agriculture","amountInvestedPast":"10","investmentAsOnDate":"18","additionalInvestment":"8","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
NULL, NULL, NULL, NULL, NULL, '{}',
'[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Prelim submitted","timestamp":"2026-02-15T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"approve_prelim","remark":"Prelim approved. Detailed form opened.","timestamp":"2026-02-18T11:00:00Z"}]',
'2026-02-15T09:00:00Z', '2026-02-18T11:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 3. detailed_maker_review
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000003', 'applicant@demo.com', 'pending_review', 'detailed', 'detailed_maker_review', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, NULL,
'{"aifName":"Gamma Growth Fund","businessModel":"Fintech lending platform for SME working capital","amountInvestedPast":"50","investmentAsOnDate":"75","additionalInvestment":"25","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Gamma Manufacturing Pvt Ltd is a leading fintech company providing working capital solutions to SMEs across India.","capitalTable":[{"shareholder":"Promoter A","shareType":"Equity","percentHolding":"45","amountInvested":"45"},{"shareholder":"VC Fund X","shareType":"Preference","percentHolding":"35","amountInvested":"35"},{"shareholder":"Angel Investors","shareType":"Equity","percentHolding":"20","amountInvested":"20"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Strong unit economics with CAC payback of 8 months","grid":[]},"cashBalance":"12","cashRunway":"18","arrears":"none","enterpriseValue":"150","fundingRequirement":{"totalRequirement":"25","sidbiAmount":"20","repaymentPeriod":"36","securities":"Charge on receivables and personal guarantee"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Mumbai","date":"2026-03-05","name":"Rajesh Kumar","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}',
NULL, NULL, NULL, NULL, '{}',
'[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Prelim submitted","timestamp":"2026-02-01T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"approve_prelim","remark":"Approved","timestamp":"2026-02-05T10:00:00Z"},{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_detailed","remark":"Detailed application submitted","timestamp":"2026-03-05T14:00:00Z"}]',
'2026-02-01T09:00:00Z', '2026-03-05T14:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 4. detailed_checker_review (recommend_pursual)
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000004', 'applicant@demo.com', 'recommend_pursual', 'detailed', 'detailed_checker_review', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, 'pursual',
'{"aifName":"Delta Ventures Fund II","businessModel":"EV charging infrastructure network across Tier-2 cities","amountInvestedPast":"30","investmentAsOnDate":"55","additionalInvestment":"20","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Delta Services is building EV charging infrastructure across India.","capitalTable":[{"shareholder":"Promoter","shareType":"Equity","percentHolding":"60","amountInvested":"60"},{"shareholder":"PE Fund","shareType":"Preference","percentHolding":"40","amountInvested":"40"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Improving unit economics with 14-month CAC payback","grid":[]},"cashBalance":"8","cashRunway":"12","arrears":"none","enterpriseValue":"200","fundingRequirement":{"totalRequirement":"20","sidbiAmount":"15","repaymentPeriod":"48","securities":"Charge on assets and promoter guarantee"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Delhi","date":"2026-03-08","name":"Priya Sharma","designation":"MD","email":"applicant@demo.com"},"aifConfirmation":{}}',
NULL, NULL, NULL, NULL, '{}',
'[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"recommend_pursual","remark":"Strong business case. Recommend for IC-VD review.","timestamp":"2026-03-10T11:00:00Z"}]',
'2026-01-20T09:00:00Z', '2026-03-10T11:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 5. icvd_maker_review
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000005', 'applicant@demo.com', 'pending_review', 'icvd', 'icvd_maker_review', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
'{"aifName":"Epsilon Health Fund","businessModel":"Digital health platform connecting patients with specialists","amountInvestedPast":"20","investmentAsOnDate":"35","additionalInvestment":"12","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Epsilon Health is a digital health platform with 500K+ registered patients.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"55","amountInvested":"55"},{"shareholder":"Series A Fund","shareType":"Preference","percentHolding":"45","amountInvested":"45"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Positive unit economics with 10-month payback","grid":[]},"cashBalance":"15","cashRunway":"20","arrears":"none","enterpriseValue":"180","fundingRequirement":{"totalRequirement":"12","sidbiAmount":"10","repaymentPeriod":"36","securities":"Charge on IP and receivables"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Bengaluru","date":"2026-02-20","name":"Anil Verma","designation":"CTO","email":"applicant@demo.com"},"aifConfirmation":{}}',
NULL, NULL, NULL, NULL, '{}',
'[{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"recommend_icvd","remark":"Forwarded to IC-VD stage for committee review.","timestamp":"2026-03-12T09:00:00Z"}]',
'2026-01-10T09:00:00Z', '2026-03-12T09:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 6. icvd_convenor_scheduling
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000006', 'applicant@demo.com', 'pending_review', 'icvd', 'icvd_convenor_scheduling', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
'{"aifName":"Zeta Agri Fund","businessModel":"Precision agriculture platform using satellite imagery and AI","amountInvestedPast":"15","investmentAsOnDate":"28","additionalInvestment":"10","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Zeta Agri uses satellite data and AI to help farmers optimize yields.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"65","amountInvested":"65"},{"shareholder":"Agri VC","shareType":"Preference","percentHolding":"35","amountInvested":"35"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Positive unit economics","grid":[]},"cashBalance":"6","cashRunway":"10","arrears":"none","enterpriseValue":"120","fundingRequirement":{"totalRequirement":"10","sidbiAmount":"8","repaymentPeriod":"36","securities":"Charge on receivables"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Hyderabad","date":"2026-02-25","name":"Suresh Reddy","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}',
'{"summary":"Strong agri-tech play with proven technology. Recommend for IC-VD committee review.","recommendation":"pursual","attachments":[]}',
NULL, NULL, NULL, '{}',
'[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"icvd_maker_forward","remark":"IC-VD note prepared and forwarded to checker.","timestamp":"2026-03-13T10:00:00Z"},{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"icvd_checker_assign_convenor","remark":"Assigned convenor for IC-VD meeting scheduling.","timestamp":"2026-03-14T11:00:00Z"}]',
'2026-01-05T09:00:00Z', '2026-03-14T11:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 7. ccic_maker_refine
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000007', 'applicant@demo.com', 'pending_review', 'ccic', 'ccic_maker_refine', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
'{"aifName":"Eta Logistics Fund","businessModel":"Last-mile logistics platform for e-commerce in Tier-3 cities","amountInvestedPast":"40","investmentAsOnDate":"65","additionalInvestment":"20","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Eta Logistics operates 200+ delivery hubs across Tier-3 cities.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"50","amountInvested":"50"},{"shareholder":"Growth Fund","shareType":"Preference","percentHolding":"50","amountInvested":"50"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Hub-and-spoke model with strong unit economics","grid":[]},"cashBalance":"20","cashRunway":"24","arrears":"none","enterpriseValue":"300","fundingRequirement":{"totalRequirement":"20","sidbiAmount":"18","repaymentPeriod":"48","securities":"Charge on fleet and receivables"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Chennai","date":"2026-02-10","name":"Meena Iyer","designation":"CFO","email":"applicant@demo.com"},"aifConfirmation":{}}',
'{"summary":"IC-VD committee reviewed and referred to CCIC-CGM for final sanction.","recommendation":"pursual","attachments":[]}',
NULL, 'd0000001-0000-0000-0000-000000000002', NULL, '{}',
'[{"actorRole":"committee_member","actorId":"sidbi-icvd@demo.com","actionType":"icvd_committee_refer","remark":"IC-VD committee recommends referral to CCIC-CGM.","timestamp":"2026-03-10T12:00:00Z"}]',
'2025-12-01T09:00:00Z', '2026-03-10T12:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 8. final_approval
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000008', 'applicant@demo.com', 'pending_review', 'final', 'final_approval', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
'{"aifName":"Theta CleanTech Fund","businessModel":"Solar energy solutions for industrial and commercial clients","amountInvestedPast":"60","investmentAsOnDate":"90","additionalInvestment":"30","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Theta CleanTech installs and operates solar plants for industrial clients.","capitalTable":[{"shareholder":"Promoters","shareType":"Equity","percentHolding":"55","amountInvested":"55"},{"shareholder":"Climate Fund","shareType":"Preference","percentHolding":"45","amountInvested":"45"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Long-term PPAs ensure stable cash flows","grid":[]},"cashBalance":"25","cashRunway":"30","arrears":"none","enterpriseValue":"400","fundingRequirement":{"totalRequirement":"30","sidbiAmount":"25","repaymentPeriod":"60","securities":"Charge on solar assets and PPAs"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Pune","date":"2026-01-15","name":"Vikram Nair","designation":"Director","email":"applicant@demo.com"},"aifConfirmation":{}}',
'{"summary":"IC-VD committee approved. Strong clean energy play.","recommendation":"pursual","attachments":[]}',
'{"summary":"CCIC-CGM committee reviewed and recommends sanction of INR 25 Cr venture debt.","recommendation":"pursual","attachments":[]}',
NULL, 'd0000001-0000-0000-0000-000000000003', '{}',
'[{"actorRole":"committee_member","actorId":"sidbi-ccic@demo.com","actionType":"ccic_committee_refer","remark":"CCIC-CGM recommends sanction. Forwarded to Approving Authority.","timestamp":"2026-03-16T14:00:00Z"}]',
'2025-11-01T09:00:00Z', '2026-03-16T14:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 9. sanctioned
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000009', 'applicant@demo.com', 'sanctioned', 'post_sanction', 'sanctioned', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
'{"aifName":"Iota EdTech Fund","businessModel":"Online skilling platform for blue-collar workers","amountInvestedPast":"18","investmentAsOnDate":"30","additionalInvestment":"10","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Iota EdTech has trained 1M+ blue-collar workers across India.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"70","amountInvested":"70"},{"shareholder":"Impact Fund","shareType":"Preference","percentHolding":"30","amountInvested":"30"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Scalable digital delivery with low marginal cost","grid":[]},"cashBalance":"10","cashRunway":"15","arrears":"none","enterpriseValue":"100","fundingRequirement":{"totalRequirement":"10","sidbiAmount":"8","repaymentPeriod":"36","securities":"Charge on receivables"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Mumbai","date":"2025-10-01","name":"Ravi Gupta","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}',
'{"summary":"IC-VD approved.","recommendation":"pursual","attachments":[]}',
'{"summary":"CCIC-CGM approved.","recommendation":"pursual","attachments":[]}',
NULL, 'd0000001-0000-0000-0000-000000000004', '{}',
'[{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"approve_sanction","remark":"Sanction approved. INR 8 Cr venture debt sanctioned.","timestamp":"2026-02-28T16:00:00Z"}]',
'2025-09-01T09:00:00Z', '2026-02-28T16:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 10. prelim_revision (reverted)
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000010', 'applicant@demo.com', 'reverted', 'prelim', 'prelim_revision', 'sidbi-maker@demo.com', NULL, NULL, NULL, NULL,
'{"aifName":"Mu Fintech Fund","businessModel":"BNPL platform for rural consumers","amountInvestedPast":"5","investmentAsOnDate":"12","additionalInvestment":"5","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
NULL, NULL, NULL, NULL, NULL,
'{"_global":{"needsChange":true,"comment":"Please clarify the AIF registration number and provide audited financials for FY2024-25."}}',
'[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Preliminary application submitted","timestamp":"2026-03-10T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"revert_prelim","remark":"Please clarify the AIF registration number and provide audited financials for FY2024-25.","timestamp":"2026-03-12T11:00:00Z"}]',
'2026-03-10T09:00:00Z', '2026-03-12T11:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 11. prelim_rejected
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000011', 'applicant@demo.com', 'rejected', 'prelim', 'prelim_rejected', 'sidbi-maker@demo.com', NULL, NULL, NULL, NULL,
'{"aifName":"Nu Crypto Fund","businessModel":"Crypto trading platform","amountInvestedPast":"2","investmentAsOnDate":"3","additionalInvestment":"2","entityType":"no","vintage":"no","recentEquity":"no","operatingIncome":"no","revenueGrowth":"no","positiveNetWorth":"no","noDefaultHistory":"no","noLegalProceedings":"no","noRelatedParty":"no","noNPA":"no","msmeRegistration":"no","gstCompliance":"no","itCompliance":"no","environmentalCompliance":"no","cibilScore":"no","remarks":{}}',
NULL, NULL, NULL, NULL, NULL, '{}',
'[{"actorRole":"applicant","actorId":"applicant@demo.com","actionType":"submit_prelim","remark":"Preliminary application submitted","timestamp":"2026-02-28T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"reject_prelim","remark":"Application does not meet eligibility criteria. Business model not aligned with VDF mandate.","timestamp":"2026-03-02T10:00:00Z"}]',
'2026-02-28T09:00:00Z', '2026-03-02T10:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 12. detailed_revision (reverted)
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000012', 'applicant@demo.com', 'reverted', 'detailed', 'detailed_revision', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, NULL,
'{"aifName":"Xi Mobility Fund","businessModel":"EV two-wheeler subscription platform","amountInvestedPast":"22","investmentAsOnDate":"38","additionalInvestment":"14","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Xi Mobility operates EV subscription services in 5 cities.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"60","amountInvested":"60"},{"shareholder":"Mobility VC","shareType":"Preference","percentHolding":"40","amountInvested":"40"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Subscription model with 18-month payback","grid":[]},"cashBalance":"9","cashRunway":"14","arrears":"none","enterpriseValue":"160","fundingRequirement":{"totalRequirement":"14","sidbiAmount":"12","repaymentPeriod":"36","securities":"Charge on fleet and receivables"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Bengaluru","date":"2026-03-01","name":"Kiran Rao","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}',
NULL, NULL, NULL, NULL,
'{"_global":{"needsChange":true,"comment":"Please provide fleet insurance details and updated CIBIL report."}}',
'[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"revert_detailed","remark":"Please provide fleet insurance details and updated CIBIL report.","timestamp":"2026-03-14T10:00:00Z"}]',
'2026-02-10T09:00:00Z', '2026-03-14T10:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 13. detailed_rejected
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000013', 'applicant@demo.com', 'rejected', 'detailed', 'detailed_rejected', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, 'rejection',
'{"aifName":"Omicron Retail Fund","businessModel":"Offline retail chain expansion","amountInvestedPast":"35","investmentAsOnDate":"50","additionalInvestment":"18","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"no","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Omicron Retail operates 50+ stores across South India.","capitalTable":[{"shareholder":"Promoters","shareType":"Equity","percentHolding":"70","amountInvested":"70"},{"shareholder":"PE Fund","shareType":"Preference","percentHolding":"30","amountInvested":"30"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Declining same-store sales growth","grid":[]},"cashBalance":"5","cashRunway":"8","arrears":"significant","enterpriseValue":"90","fundingRequirement":{"totalRequirement":"18","sidbiAmount":"15","repaymentPeriod":"36","securities":"Charge on inventory"},"facilitiesAvailed":{"flag":"yes","details":"Existing term loan of INR 10 Cr from SBI"},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Chennai","date":"2026-02-15","name":"Ramesh Babu","designation":"MD","email":"applicant@demo.com"},"aifConfirmation":{}}',
NULL, NULL, NULL, NULL, '{}',
'[{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"recommend_rejection","remark":"Declining revenue growth and high arrears. Not suitable for VDF.","timestamp":"2026-03-08T11:00:00Z"},{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"reject_final","remark":"Concur with maker. Application rejected.","timestamp":"2026-03-09T10:00:00Z"}]',
'2026-01-25T09:00:00Z', '2026-03-09T10:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 14. icvd_checker_review
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000014', 'applicant@demo.com', 'submitted', 'icvd', 'icvd_checker_review', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', NULL, NULL, 'pursual',
'{"aifName":"Pi Pharma Fund","businessModel":"Generic pharmaceutical manufacturer for export markets","amountInvestedPast":"45","investmentAsOnDate":"70","additionalInvestment":"22","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Pi Pharma manufactures 200+ generic formulations exported to 30 countries.","capitalTable":[{"shareholder":"Promoters","shareType":"Equity","percentHolding":"65","amountInvested":"65"},{"shareholder":"Healthcare PE","shareType":"Preference","percentHolding":"35","amountInvested":"35"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Strong export margins with 22% EBITDA","grid":[]},"cashBalance":"18","cashRunway":"22","arrears":"none","enterpriseValue":"350","fundingRequirement":{"totalRequirement":"22","sidbiAmount":"20","repaymentPeriod":"48","securities":"Charge on plant and machinery"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Ahmedabad","date":"2026-02-28","name":"Dinesh Patel","designation":"CEO","email":"applicant@demo.com"},"aifConfirmation":{}}',
'{"summary":"Pi Pharma has strong export credentials and consistent revenue growth. IC-VD note prepared recommending pursual.","recommendation":"pursual","attachments":[]}',
NULL, NULL, NULL, '{}',
'[{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"recommend_icvd","remark":"Forwarded to IC-VD stage.","timestamp":"2026-03-11T09:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"icvd_maker_forward","remark":"IC-VD note prepared and forwarded to checker.","timestamp":"2026-03-16T10:00:00Z"}]',
'2026-01-15T09:00:00Z', '2026-03-16T10:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 15. ccic_checker_review
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000015', 'applicant@demo.com', 'submitted', 'ccic', 'ccic_checker_review', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
'{"aifName":"Rho Water Fund","businessModel":"Water treatment and recycling solutions for industrial clients","amountInvestedPast":"28","investmentAsOnDate":"45","additionalInvestment":"16","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Rho Water provides zero-liquid-discharge solutions to 100+ industrial clients.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"55","amountInvested":"55"},{"shareholder":"ESG Fund","shareType":"Preference","percentHolding":"45","amountInvested":"45"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Long-term O&M contracts ensure stable recurring revenue","grid":[]},"cashBalance":"14","cashRunway":"20","arrears":"none","enterpriseValue":"220","fundingRequirement":{"totalRequirement":"16","sidbiAmount":"14","repaymentPeriod":"48","securities":"Charge on equipment and contracts"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Surat","date":"2026-02-05","name":"Hetal Shah","designation":"MD","email":"applicant@demo.com"},"aifConfirmation":{}}',
'{"summary":"IC-VD committee approved. Strong ESG credentials.","recommendation":"pursual","attachments":[]}',
'{"summary":"CCIC-CGM note prepared. Recommend sanction of INR 14 Cr venture debt for water treatment expansion.","recommendation":"pursual","attachments":[]}',
'd0000001-0000-0000-0000-000000000002', NULL, '{}',
'[{"actorRole":"committee_member","actorId":"sidbi-icvd@demo.com","actionType":"icvd_committee_refer","remark":"IC-VD committee recommends referral to CCIC-CGM.","timestamp":"2026-03-10T12:00:00Z"},{"actorRole":"maker","actorId":"sidbi-maker@demo.com","actionType":"ccic_maker_upload","remark":"CCIC note uploaded.","timestamp":"2026-03-17T10:00:00Z"}]',
'2025-12-15T09:00:00Z', '2026-03-17T10:00:00Z') ON CONFLICT (id) DO NOTHING;

-- 16. ccic_convenor_scheduling
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step, assigned_maker, assigned_checker, assigned_convenor, assigned_approver, recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note, icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES ('b0000001-0000-0000-0000-000000000016', 'applicant@demo.com', 'submitted', 'ccic', 'ccic_convenor_scheduling', 'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
'{"aifName":"Sigma Space Fund","businessModel":"Satellite data analytics for defence and agriculture","amountInvestedPast":"55","investmentAsOnDate":"80","additionalInvestment":"25","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
'{"companyProfile":"Sigma Space provides satellite analytics to government and enterprise clients.","capitalTable":[{"shareholder":"Founders","shareType":"Equity","percentHolding":"50","amountInvested":"50"},{"shareholder":"Deep Tech VC","shareType":"Preference","percentHolding":"50","amountInvested":"50"}],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"High-margin SaaS with government contracts","grid":[]},"cashBalance":"22","cashRunway":"28","arrears":"none","enterpriseValue":"500","fundingRequirement":{"totalRequirement":"25","sidbiAmount":"22","repaymentPeriod":"60","securities":"Charge on IP and government contracts"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Bengaluru","date":"2026-01-20","name":"Arjun Menon","designation":"CTO","email":"applicant@demo.com"},"aifConfirmation":{}}',
'{"summary":"IC-VD approved. Strategic deep-tech play.","recommendation":"pursual","attachments":[]}',
'{"summary":"CCIC note prepared. Recommend sanction of INR 22 Cr for satellite analytics expansion.","recommendation":"pursual","attachments":[]}',
NULL, NULL, '{}',
'[{"actorRole":"checker","actorId":"sidbi-checker@demo.com","actionType":"ccic_checker_assign_convenor","remark":"Assigned convenor for CCIC-CGM meeting scheduling.","timestamp":"2026-03-19T11:00:00Z"}]',
'2025-11-10T09:00:00Z', '2026-03-19T11:00:00Z') ON CONFLICT (id) DO NOTHING;

-- COMMITTEE MEETINGS

-- IC-VD Meeting #3 (scheduled, linked to apps 5 & 6)
INSERT INTO vdf_committee_meeting (id, type, subject, meeting_number, date_time, total_members, selected_members, maker_email, checker_email, convenor_email, approver_email, chair_person_email, minutes_file_id, minutes_file_name, application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES ('d0000001-0000-0000-0000-000000000001', 'icvd', 'IC-VD Meeting #3 – Epsilon Health Fund & Zeta Agri Fund', 3, '2026-03-25T10:00:00+05:30',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"},{"id":"m003","name":"Mr. Suresh Nair","email":"sidbi-checker@demo.com"}]',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'sidbi-icvd@demo.com',
NULL, NULL,
'["b0000001-0000-0000-0000-000000000005","b0000001-0000-0000-0000-000000000006"]',
'[]', 'scheduled', '[]', NULL,
'2026-03-18T09:00:00Z', '2026-03-18T09:00:00Z') ON CONFLICT (id) DO NOTHING;

-- IC-VD Meeting #2 (completed, referred – linked to app 7)
INSERT INTO vdf_committee_meeting (id, type, subject, meeting_number, date_time, total_members, selected_members, maker_email, checker_email, convenor_email, approver_email, chair_person_email, minutes_file_id, minutes_file_name, application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES ('d0000001-0000-0000-0000-000000000002', 'icvd', 'IC-VD Meeting #2 – Eta Logistics Fund', 2, '2026-03-10T10:00:00+05:30',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'sidbi-icvd@demo.com',
NULL, NULL,
'["b0000001-0000-0000-0000-000000000007"]',
'[{"applicationId":"b0000001-0000-0000-0000-000000000007","approved":true,"approvedAmount":18000000}]',
'completed',
'[{"memberId":"sidbi-icvd@demo.com","vote":"approve","comment":"Strong logistics play with proven unit economics. Recommend referral to CCIC-CGM.","timestamp":"2026-03-10T11:30:00Z"},{"memberId":"sidbi-ccic@demo.com","vote":"approve","comment":"Agree with recommendation.","timestamp":"2026-03-10T11:45:00Z"}]',
'referred',
'2026-03-05T09:00:00Z', '2026-03-10T12:00:00Z') ON CONFLICT (id) DO NOTHING;

-- CCIC Meeting #4 (in_progress – linked to app 8)
INSERT INTO vdf_committee_meeting (id, type, subject, meeting_number, date_time, total_members, selected_members, maker_email, checker_email, convenor_email, approver_email, chair_person_email, minutes_file_id, minutes_file_name, application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES ('d0000001-0000-0000-0000-000000000003', 'ccic', 'CCIC-CGM Meeting #4 – Theta CleanTech Fund', 4, '2026-03-20T14:00:00+05:30',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"},{"id":"m003","name":"Mr. Suresh Nair","email":"sidbi-checker@demo.com"}]',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'sidbi-ccic@demo.com',
NULL, NULL,
'["b0000001-0000-0000-0000-000000000008"]',
'[{"applicationId":"b0000001-0000-0000-0000-000000000008","approved":true,"approvedAmount":25000000}]',
'in_progress',
'[{"memberId":"sidbi-ccic@demo.com","vote":"approve","comment":"Clean energy sector with strong PPA-backed cash flows. Recommend sanction of INR 25 Cr.","timestamp":"2026-03-20T15:00:00Z"}]',
NULL,
'2026-03-15T09:00:00Z', '2026-03-20T15:00:00Z') ON CONFLICT (id) DO NOTHING;

-- CCIC Meeting #3 (completed, referred – linked to app 9)
INSERT INTO vdf_committee_meeting (id, type, subject, meeting_number, date_time, total_members, selected_members, maker_email, checker_email, convenor_email, approver_email, chair_person_email, minutes_file_id, minutes_file_name, application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES ('d0000001-0000-0000-0000-000000000004', 'ccic', 'CCIC-CGM Meeting #3 – Iota EdTech Fund', 3, '2026-02-20T14:00:00+05:30',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'sidbi-ccic@demo.com',
NULL, NULL,
'["b0000001-0000-0000-0000-000000000009"]',
'[{"applicationId":"b0000001-0000-0000-0000-000000000009","approved":true,"approvedAmount":8000000}]',
'completed',
'[{"memberId":"sidbi-ccic@demo.com","vote":"approve","comment":"EdTech with strong social impact. Recommend sanction.","timestamp":"2026-02-20T15:30:00Z"},{"memberId":"sidbi-icvd@demo.com","vote":"approve","comment":"Agree.","timestamp":"2026-02-20T15:45:00Z"}]',
'referred',
'2026-02-15T09:00:00Z', '2026-02-20T16:00:00Z') ON CONFLICT (id) DO NOTHING;

-- IC-VD Meeting #1 (completed, for historical reference)
INSERT INTO vdf_committee_meeting (id, type, subject, meeting_number, date_time, total_members, selected_members, maker_email, checker_email, convenor_email, approver_email, chair_person_email, minutes_file_id, minutes_file_name, application_ids, application_decisions, status, votes, outcome, created_at, updated_at)
VALUES ('d0000001-0000-0000-0000-000000000005', 'icvd', 'IC-VD Meeting #1 – Iota EdTech Fund', 1, '2026-02-05T10:00:00+05:30',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'[{"id":"m001","name":"Dr. Anand Krishnan","email":"sidbi-icvd@demo.com"},{"id":"m002","name":"Ms. Rekha Pillai","email":"sidbi-ccic@demo.com"}]',
'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'sidbi-icvd@demo.com',
NULL, NULL,
'["b0000001-0000-0000-0000-000000000009"]',
'[{"applicationId":"b0000001-0000-0000-0000-000000000009","approved":true,"approvedAmount":8000000}]',
'completed',
'[{"memberId":"sidbi-icvd@demo.com","vote":"approve","comment":"Strong social impact EdTech. Recommend referral to CCIC.","timestamp":"2026-02-05T11:30:00Z"},{"memberId":"sidbi-ccic@demo.com","vote":"approve","comment":"Agree.","timestamp":"2026-02-05T11:45:00Z"}]',
'referred',
'2026-01-30T09:00:00Z', '2026-02-05T12:00:00Z') ON CONFLICT (id) DO NOTHING;

-- Update app 5 & 6 with icvd meeting id
UPDATE vdf_application SET icvd_meeting_id = 'd0000001-0000-0000-0000-000000000001' WHERE id IN ('b0000001-0000-0000-0000-000000000005','b0000001-0000-0000-0000-000000000006');
UPDATE vdf_application SET icvd_meeting_id = 'd0000001-0000-0000-0000-000000000002' WHERE id = 'b0000001-0000-0000-0000-000000000007';
UPDATE vdf_application SET ccic_meeting_id = 'd0000001-0000-0000-0000-000000000003' WHERE id = 'b0000001-0000-0000-0000-000000000008';
UPDATE vdf_application SET icvd_meeting_id = 'd0000001-0000-0000-0000-000000000005', ccic_meeting_id = 'd0000001-0000-0000-0000-000000000004' WHERE id = 'b0000001-0000-0000-0000-000000000009';
UPDATE vdf_application SET icvd_meeting_id = 'd0000001-0000-0000-0000-000000000002' WHERE id = 'b0000001-0000-0000-0000-000000000015';
