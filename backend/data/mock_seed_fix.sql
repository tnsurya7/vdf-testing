-- Fix app 8 with correct stage 'final_'
INSERT INTO vdf_application (id, applicant_email, status, stage, workflow_step,
  assigned_maker, assigned_checker, assigned_convenor, assigned_approver,
  recommended_outcome, prelim_data, detailed_data, icvd_note, ccic_note,
  icvd_meeting_id, ccic_meeting_id, comments, audit_trail, submitted_at, updated_at)
VALUES (
  'b0000001-0000-0000-0000-000000000008',
  'applicant@demo.com', 'pending_review', 'final_', 'final_approval',
  'sidbi-maker@demo.com', 'sidbi-checker@demo.com', 'sidbi-convenor@demo.com', NULL, 'pursual',
  '{"aifName":"Theta CleanTech Fund","businessModel":"Solar energy solutions for industrial and commercial clients","amountInvestedPast":"60","investmentAsOnDate":"90","additionalInvestment":"30","entityType":"yes","vintage":"yes","recentEquity":"yes","operatingIncome":"yes","revenueGrowth":"yes","positiveNetWorth":"yes","noDefaultHistory":"yes","noLegalProceedings":"yes","noRelatedParty":"yes","noNPA":"yes","msmeRegistration":"yes","gstCompliance":"yes","itCompliance":"yes","environmentalCompliance":"yes","cibilScore":"yes","remarks":{}}',
  '{"companyProfile":"Theta CleanTech installs and operates solar plants for industrial clients.","capitalTable":[],"financialPerformance":[],"revenueTrends":[],"unitEconomics":{"description":"Long-term PPAs ensure stable cash flows","grid":[]},"cashBalance":"25","cashRunway":"30","arrears":"none","enterpriseValue":"400","fundingRequirement":{"totalRequirement":"30","sidbiAmount":"25","repaymentPeriod":"60","securities":"Charge on solar assets and PPAs"},"facilitiesAvailed":{"flag":"no","details":""},"eligibilityChecklist":{},"declarations":{"declaration1":true,"declaration2":true,"declaration3":true},"signature":{"place":"Pune","date":"2026-01-15","name":"Vikram Nair","designation":"Director","email":"applicant@demo.com"},"aifConfirmation":{}}',
  '{"summary":"IC-VD committee approved. Strong clean energy play.","recommendation":"pursual","attachments":[]}',
  '{"summary":"CCIC-CGM committee reviewed and recommends sanction of INR 25 Cr venture debt.","recommendation":"pursual","attachments":[]}',
  NULL, 'd0000001-0000-0000-0000-000000000003',
  '{}',
  '[{"actorRole":"committee_member","actorId":"sidbi-ccic@demo.com","actionType":"ccic_committee_refer","remark":"CCIC-CGM recommends sanction. Forwarded to Approving Authority.","timestamp":"2026-03-16T14:00:00Z"}]',
  '2025-11-01T09:00:00Z', '2026-03-16T14:00:00Z'
) ON CONFLICT (id) DO NOTHING;

-- Also fix app 9 stage to post_sanction
UPDATE vdf_application SET stage = 'post_sanction' WHERE id = 'b0000001-0000-0000-0000-000000000009' AND stage != 'post_sanction';
