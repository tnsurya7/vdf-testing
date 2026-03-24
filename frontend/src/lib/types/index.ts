// ─────────────────────────────────────────────────────────────────────────────
// types/index.ts — Re-export application data types
// ─────────────────────────────────────────────────────────────────────────────

export type {
  PrelimApplicationData,
  PrelimEligibilityFlags,
  PrelimEligibilityRemarks,
  PrelimDocuments,
} from "./prelim";

export type {
  DetailedApplicationData,
  CapitalTableRow,
  FinancialPerformanceGrid,
  RevenueTrends,
  UnitEconomicsGrid,
  UnitEconomicsSection,
  FundingWithdrawnSection,
  FacilitiesAvailedSection,
  FundingSection,
  SignatureSection,
  AifConfirmationSection,
} from "./detailed";

export type { CommitteeNoteData } from "./committeeNote";
