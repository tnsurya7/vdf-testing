// ─────────────────────────────────────────────────────────────────────────────
// prelim.ts — Strict types for preliminary application data
// ─────────────────────────────────────────────────────────────────────────────

import type { EligibilityKey, EligibilityRemarksKey, DocSlotKey } from "@/lib/prelimConfig";

/** Eligibility toggles (form: boolean; legacy/stored may use "yes"/"no" string) */
export type PrelimEligibilityFlags = Partial<Record<EligibilityKey, boolean | string>>;

/** Remarks per eligibility parameter */
export type PrelimEligibilityRemarks = Partial<Record<EligibilityRemarksKey, string>>;

/** Document slot key → file name or storage ref */
export type PrelimDocuments = Partial<Record<DocSlotKey, string>>;

/**
 * Preliminary application form data.
 * Aligns with PrelimApplication form schema and prelimConfig.
 */
export interface PrelimApplicationData
  extends PrelimEligibilityFlags,
    PrelimEligibilityRemarks,
    PrelimDocuments {
  aifName: string;
  businessModel?: string;
  /** Optional; form may use businessCompanyName */
  businessCompanyName?: string;
  otherParticulars?: string;
  otherParticularsAmt?: string;
  amountInvestedPast: string;
  investmentAsOnDate: string;
  additionalInvestment: string;
  /** Optional display name (e.g. for PublicData table) */
  companyName?: string;
  nameOfApplicant?: string;
}
