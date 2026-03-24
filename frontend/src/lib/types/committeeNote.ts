// ─────────────────────────────────────────────────────────────────────────────
// committeeNote.ts — Types for IC-VD / CCIC committee notes
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Committee note (IC-VD or CCIC) attached to an application.
 * Shape can be extended when note UI is implemented.
 */
export interface CommitteeNoteData {
  summary?: string;
  recommendation?: "rejection" | "pursual" | null;
  attachments?: string[];
  [key: string]: unknown;
}
