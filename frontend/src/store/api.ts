// ─────────────────────────────────────────────────────────────────────────────
// RTK Query API — Real backend (vdf-backend) with JWT
// ─────────────────────────────────────────────────────────────────────────────

import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import type { AuthSession, SidbiRole } from "@/lib/authStore";
import { getToken, clearSession } from "@/lib/authStore";
import type { Registration } from "@/lib/registrationStore";
import type { Application, WorkflowAction } from "@/lib/applicationStore";
import type { PrelimApplicationData, DetailedApplicationData } from "@/lib/types";
import type { CommitteeMeeting, MeetingType, MeetingVote } from "@/lib/meetingStore";


const baseUrl = import.meta.env.VITE_API_BASE_URL ?? "";

console.log("baseUrl", import.meta.env.VITE_API_BASE_URL);

/** Backend login response (POST /auth/login). */
export interface LoginResponse {
  accessToken: string;
  user: AuthSession;
}

export interface UserAccountDto {
  id: string;
  email: string;
  enabled: boolean;
  passwordSet: boolean;
  roles: string[];
  setupLink?: string | null;
}

const baseQuery = fetchBaseQuery({
  baseUrl,
  prepareHeaders: (headers) => {
    const token = getToken();
    if (token) headers.set("Authorization", `Bearer ${token}`);
    headers.set("Content-Type", "application/json");
    return headers;
  },
});

const baseQueryWithAuth = async (
  args: Parameters<typeof baseQuery>[0],
  api: Parameters<typeof baseQuery>[1],
  extraOptions: Parameters<typeof baseQuery>[2]
) => {
  const result = await baseQuery(args, api, extraOptions);
  if (result.error?.status === 401) {
    // Only redirect for GET queries (session expiry), not mutations —
    // mutations have their own error handling in the component.
    const method = typeof args === "string" ? "GET" : (args as { method?: string }).method ?? "GET";
    if (method === "GET") {
      clearSession();
      window.location.hash = "#/login";
    }
  }
  return result;
};

export const api = createApi({
  reducerPath: "api",
  baseQuery: baseQueryWithAuth,
  tagTypes: ["Auth", "Applications", "Registrations", "Meetings", "Users"],

  endpoints: (builder) => ({
    // ═══════════════════════════════════════════════════════════════════════
    // AUTH
    // ═══════════════════════════════════════════════════════════════════════
    login: builder.mutation<LoginResponse, { email: string; password: string }>({
      query: (body) => ({ url: "/auth/login", method: "POST", body }),
      invalidatesTags: ["Auth"],
    }),

    logout: builder.mutation<void, void>({
      queryFn: () => ({ data: undefined }),
      invalidatesTags: ["Auth"],
    }),

    getSession: builder.query<AuthSession | null, void>({
      query: () => ({ url: "/auth/me" }),
      providesTags: ["Auth"],
    }),

    // ═══════════════════════════════════════════════════════════════════════
    // REGISTRATIONS
    // ═══════════════════════════════════════════════════════════════════════
    getRegistrations: builder.query<Registration[], void>({
      query: () => "/api/registrations",
      providesTags: ["Registrations"],
    }),

    addRegistration: builder.mutation<Registration, Omit<Registration, "id" | "status" | "submittedAt"> & { password: string }>({
      query: (body) => ({ url: "/api/registrations", method: "POST", body }),
      invalidatesTags: ["Registrations"],
    }),

    updateRegistrationStatus: builder.mutation<void, { id: string; status: "approved" | "rejected" }>({
      query: ({ id, status }) => ({
        url: `/api/registrations/${id}`,
        method: "PATCH",
        body: { status },
      }),
      invalidatesTags: ["Registrations"],
    }),

    toggleRegistrationEnabled: builder.mutation<{ enabled: boolean }, string>({
      query: (id) => ({ url: `/api/registrations/${id}/toggle-enabled`, method: "PATCH" }),
      invalidatesTags: ["Registrations", "Users"],
    }),

    // ═══════════════════════════════════════════════════════════════════════
    // APPLICATIONS
    // ═══════════════════════════════════════════════════════════════════════
    getApplications: builder.query<Application[], { email?: string; role?: SidbiRole } | undefined>({
      query: (args = {}) => {
        const params = new URLSearchParams();
        if (args?.email) params.set("email", args.email);
        if (args?.role) params.set("role", args.role);
        const q = params.toString();
        return { url: q ? `/api/applications?${q}` : "/api/applications" };
      },
      providesTags: ["Applications"],
      keepUnusedDataFor: 0,
    }),

    getApplicationById: builder.query<Application, string>({
      query: (id) => `/api/applications/${id}`,
      providesTags: (result, error, id) => [{ type: "Applications", id }],
    }),

    createPrelimApplication: builder.mutation<Application, { email?: string; prelimData: PrelimApplicationData }>({
      query: (body) => ({ url: "/api/applications/prelim", method: "POST", body }),
      invalidatesTags: ["Applications"],
    }),

    updatePrelimData: builder.mutation<void, { id: string; prelimData: PrelimApplicationData }>({
      query: ({ id, prelimData }) => ({
        url: `/api/applications/${id}/prelim`,
        method: "PUT",
        body: { prelimData },
      }),
      invalidatesTags: ["Applications"],
    }),

    submitDetailedApplication: builder.mutation<void, { appId: string; detailedData: DetailedApplicationData }>({
      query: ({ appId, detailedData }) => ({
        url: `/api/applications/${appId}/detailed`,
        method: "POST",
        body: { detailedData },
      }),
      invalidatesTags: ["Applications"],
    }),

    applyWorkflowAction: builder.mutation<
      { success: boolean; error?: string },
      {
        id: string;
        action: WorkflowAction;
        actor: { role: string; id: string };
        comment?: string;
        assignedChecker?: string;
        assignedConvenor?: string;
        assignedApprover?: string;
        recommendedOutcome?: "rejection" | "pursual";
        meetingId?: string;
      }
    >({
      query: ({ id, ...body }) => ({
        url: `/api/applications/${id}/workflow`,
        method: "POST",
        body,
      }),
      invalidatesTags: ["Applications"],
    }),

    deleteApplication: builder.mutation<void, string>({
      query: (id) => ({ url: `/api/applications/${id}`, method: "DELETE" }),
      invalidatesTags: ["Applications"],
    }),

    // ═══════════════════════════════════════════════════════════════════════
    // USERS (admin)
    // ═══════════════════════════════════════════════════════════════════════
    getUsers: builder.query<UserAccountDto[], void>({
      query: () => "/api/users",
      providesTags: ["Users"],
    }),

    getUserByEmail: builder.query<UserAccountDto | null, string>({
      query: (email) => `/api/users/by-email?email=${encodeURIComponent(email)}`,
      providesTags: ["Users"],
    }),

    createUser: builder.mutation<UserAccountDto, { email: string; roles: string[] }>({
      query: (body) => ({ url: "/api/users", method: "POST", body }),
      invalidatesTags: ["Users"],
    }),

    updateUserRoles: builder.mutation<UserAccountDto, { id: string; roles: string[] }>({
      query: ({ id, roles }) => ({ url: `/api/users/${id}/roles`, method: "PATCH", body: { roles } }),
      invalidatesTags: ["Users"],
    }),

    setUserEnabled: builder.mutation<UserAccountDto, { id: string; enabled: boolean }>({
      query: ({ id, enabled }) => ({ url: `/api/users/${id}/status`, method: "PATCH", body: { enabled } }),
      invalidatesTags: ["Users", "Registrations"],
    }),

    setPassword: builder.mutation<void, { token: string; password: string }>({
      query: (body) => ({ url: "/auth/set-password", method: "POST", body }),
    }),

    // ═══════════════════════════════════════════════════════════════════════
    // MEETINGS
    // ═══════════════════════════════════════════════════════════════════════
    getMeetings: builder.query<CommitteeMeeting[], { type?: MeetingType } | undefined>({
      query: (args = {}) => {
        const params = new URLSearchParams();
        if (args?.type) params.set("type", args.type);
        const q = params.toString();
        return { url: q ? `/api/meetings?${q}` : "/api/meetings" };
      },
      providesTags: ["Meetings"],
    }),

    getMeetingById: builder.query<CommitteeMeeting, string>({
      query: (id) => `/api/meetings/${id}`,
      providesTags: (result, error, id) => [{ type: "Meetings", id }],
    }),

    createMeeting: builder.mutation<
      CommitteeMeeting,
      Omit<CommitteeMeeting, "id" | "createdAt" | "updatedAt" | "votes" | "outcome">
    >({
      query: (body) => ({ url: "/api/meetings", method: "POST", body }),
      invalidatesTags: ["Meetings"],
    }),

    updateMeetingStatus: builder.mutation<
      void,
      { id: string; status: CommitteeMeeting["status"]; outcome?: "referred" | "rejected" }
    >({
      query: ({ id, status, outcome }) => ({
        url: `/api/meetings/${id}`,
        method: "PATCH",
        body: { status, outcome },
      }),
      invalidatesTags: ["Meetings"],
    }),

    addVote: builder.mutation<void, { meetingId: string; vote: MeetingVote }>({
      query: ({ meetingId, vote }) => ({
        url: `/api/meetings/${meetingId}/votes`,
        method: "POST",
        body: { meetingId, vote },
      }),
      invalidatesTags: ["Meetings"],
    }),
  }),
});

export const {
  useLoginMutation,
  useLogoutMutation,
  useGetSessionQuery,
  useGetRegistrationsQuery,
  useAddRegistrationMutation,
  useUpdateRegistrationStatusMutation,
  useToggleRegistrationEnabledMutation,
  useGetApplicationsQuery,
  useGetApplicationByIdQuery,
  useCreatePrelimApplicationMutation,
  useUpdatePrelimDataMutation,
  useSubmitDetailedApplicationMutation,
  useApplyWorkflowActionMutation,
  useDeleteApplicationMutation,
  useGetUsersQuery,
  useGetUserByEmailQuery,
  useCreateUserMutation,
  useUpdateUserRolesMutation,
  useSetUserEnabledMutation,
  useSetPasswordMutation,
  useGetMeetingsQuery,
  useGetMeetingByIdQuery,
  useCreateMeetingMutation,
  useUpdateMeetingStatusMutation,
  useAddVoteMutation,
} = api;
