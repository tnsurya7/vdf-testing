// ─────────────────────────────────────────────────────────────────────────────
// detailed.ts — Strict types for detailed application data
// ─────────────────────────────────────────────────────────────────────────────

import type { FacilityRow } from "@/components/detailed-app/FacilitiesApplicant";
import type { Concern } from "@/components/detailed-app/FacilitiesAssociate";
import type { EligibilityItem } from "@/components/detailed-app/EligibilityCheck";

/** Capital table row (matches DetailedApplication state) */
export interface CapitalTableRow {
  id: string;
  shareholders: string;
  shareholderType: string;
  shareholderTypeOther: string;
  typeOfShare: string;
  noOfShares: string;
  noOfEquityShares: string;
  noOfPrefShares: string;
  percentHolding: string;
  amountInvested: string;
}

/** Financial performance grid: row name → { fy_key → value } */
export type FinancialPerformanceGrid = Record<string, Record<string, string>>;

/** Revenue trends: month label → value */
export type RevenueTrends = Record<string, string>;

/** Unit economics: row → { monthCol → value } */
export type UnitEconomicsGrid = Record<string, Record<string, string>>;

export interface UnitEconomicsSection {
  description?: string;
  data?: UnitEconomicsGrid;
}

export interface FundingWithdrawnSection {
  flag: boolean;
  details?: string;
}

export interface FacilitiesAvailedSection {
  flag: boolean;
  details?: string;
}

export interface FundingSection {
  totalFunding?: string;
  amountFromSidbi?: string;
  balanceSources?: string;
  proposedUse?: string;
  repaymentPeriod?: string;
  moratorium?: string;
  securitiesOffered?: string;
  rightsDocument?: string;
}

export interface SignatureSection {
  place?: string;
  date?: string;
  name?: string;
  designation?: string;
  email?: string;
  signFile?: string;
}

export interface AifConfirmationSection {
  name?: string;
  place?: string;
  date?: string;
  signatory?: string;
  signFile?: string;
}

/**
 * Detailed application payload (matches DetailedApplication submit shape).
 * Nested sections are optional for partial/draft data.
 */
export interface DetailedApplicationData {
  id?: string;
  companyProfile?: string;
  capitalTable?: CapitalTableRow[];
  financialPerformance?: FinancialPerformanceGrid;
  revenueTrends?: RevenueTrends;
  arrears?: string;
  enterpriseValue?: string;
  unitEconomics?: UnitEconomicsSection;
  cashBalance?: string;
  cashRunway?: string;
  fundingWithdrawn?: FundingWithdrawnSection;
  facilitiesAvailed?: FacilitiesAvailedSection;
  facilitiesApplicant?: FacilityRow[];
  facilitiesAssociate?: Concern[];
  funding?: FundingSection;
  eligibility?: Record<string, EligibilityItem>;
  pendingLitigations?: string;
  declarations?: boolean[];
  detailedDocs?: string[];
  sanctionLetterFile?: string;
  signature?: SignatureSection;
  aifConfirmation?: AifConfirmationSection;
  submittedAt?: string;
  /** Allow extra keys from drafts / legacy payloads */
  [key: string]: unknown;
}
