export type SidbiRole =
  | "admin"
  | "maker"
  | "checker"
  | "convenor"
  | "icvd_committee_member"
  | "ccic_committee_member"
  | "committee_member"         // legacy
  | "approving_authority";     // legacy

export interface AuthSession {
  email: string;
  sidbiRole?: SidbiRole;
  roles: SidbiRole[];
}

// Helpers
export const isAdmin = (session: AuthSession | null): boolean =>
  session?.roles?.includes("admin") ?? false;

export const isApplicant = (session: AuthSession | null): boolean =>
  !session || session.roles.length === 0;

export const isSidbi = (session: AuthSession | null): boolean =>
  session !== null && session.roles.length > 0 && !session.roles.includes("admin");

const AUTH_KEY = "venture_debt_auth";
const TOKEN_KEY = "venture_debt_token";

export function getSession(): AuthSession | null {
  try {
    const data = localStorage.getItem(AUTH_KEY);
    return data ? JSON.parse(data) : null;
  } catch {
    return null;
  }
}

export function setSession(session: AuthSession): void {
  localStorage.setItem(AUTH_KEY, JSON.stringify(session));
}

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token);
}

export function clearSession(): void {
  localStorage.removeItem(AUTH_KEY);
  localStorage.removeItem(TOKEN_KEY);
}
