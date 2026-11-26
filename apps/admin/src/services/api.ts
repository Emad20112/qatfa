import { AppUpdateType, Currency, StockStatus, UserRole } from "@qatfa/shared-types";

let inMemoryToken: string | null = null;

export function setApiToken(token: string | null) {
  inMemoryToken = token;
}

export function getApiToken(): string | null {
  return inMemoryToken;
}

export class ApiError extends Error {
  constructor(
    public readonly statusCode: number,
    message: string,
  ) {
    super(message);
  }
}

export async function apiFetch<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const headers: Record<string, string> = {
    ...(options.body ? { "Content-Type": "application/json" } : {}),
    ...(options.headers as Record<string, string> | undefined),
  };

  if (inMemoryToken) {
    headers["Authorization"] = `Bearer ${inMemoryToken}`;
  }

  const response = await fetch(`/api/v1${path}`, {
    ...options,
    headers,
  });

  const payload = await response.json().catch(() => ({}));

  if (!response.ok || payload?.success === false) {
    throw new ApiError(
      response.status,
      payload?.message || "تعذر إتمام الطلب، يرجى المحاولة مرة أخرى",
    );
  }

  return (payload?.data !== undefined ? payload.data : payload) as T;
}

export interface AuthStatusResponse {
  isClaimed: boolean;
  hasEnvPasscode: boolean;
  adminProfile: {
    fullName: string;
    roleLabel: string;
    avatarUrl: string;
  };
}

export interface AdminUserSession {
  id: string;
  fullName: string;
  role: UserRole;
  roleLabel: string;
  avatarUrl: string;
}

export interface AdminLoginResponse {
  token: string;
  user: AdminUserSession;
}

export interface VerificationItem {
  id: string;
  requestNumber: string;
  entityName: string;
  locationLabel: string;
  governorate: string;
  district: string;
  requestType: "توثيق تاجر" | "توثيق سوق";
  status: "PENDING_AMBER" | "PENDING_BLUE" | "APPROVED" | "REJECTED";
  submittedDate: string;
  relativeTime: string;
  thumbnail: string;
  ownerName: string;
  phoneNumber: string;
  stallNumber: string;
  documents: string[];
  notes: string;
  reviewedBy?: string;
  reviewedAt?: string;
}

export interface VerificationsResponse {
  data: VerificationItem[];
  summary: {
    total: number;
    pending: number;
    approved: number;
    rejected: number;
    exactTotal: number;
  };
  meta: {
    page: number;
    limit: number;
    totalItems: number;
    totalPages: number;
  };
}

export interface AdminReportItem {
  id: string;
  title: string;
  reporterName: string;
  reporterPhone: string;
  targetType: "PRODUCT" | "STORE" | "SYSTEM";
  targetName: string;
  targetId?: string;
  reason: string;
  uniqueReporters: number;
  status: "OPEN" | "IN_PROGRESS" | "CLOSED";
  relativeTime: string;
  createdAt: string;
  notes: string;
  actionTaken?: string;
}

export interface DashboardResponse {
  kpis: {
    totalUsers: number;
    totalUsersTrend: number;
    pendingRequests: number;
    pendingRequestsTrend: number;
    verifiedSellers: number;
    verifiedSellersTrend: number;
    totalBookings: number;
    totalBookingsTrend: number;
  };
  sidebarBadgeCount: number;
  notificationCount: number;
  analyticsSeries: Array<{ label: string; value: number }>;
  peakValue: number;
  requestBreakdown: {
    total: number;
    approved: number;
    rejected: number;
    pending: number;
  };
  activeMarketsCount: number;
  marketPins: Array<{
    id: number;
    name: string;
    x: number;
    y: number;
    storesCount: number;
  }>;
  quickStats: {
    registeredSellers: number;
    activeUsers: number;
    monthlyBookings: number;
    reportsAndIssues: number;
    activeProducts: number;
  };
  recentVerifications: VerificationItem[];
  recentReports: AdminReportItem[];
}

export const adminApi = {
  getAuthStatus: () => apiFetch<AuthStatusResponse>("/admin/auth/status"),
  claimAdmin: (password: string) =>
    apiFetch<AdminLoginResponse>("/admin/auth/claim", {
      method: "POST",
      body: JSON.stringify({ password }),
    }),
  loginAdmin: (password: string) =>
    apiFetch<AdminLoginResponse>("/admin/auth/login", {
      method: "POST",
      body: JSON.stringify({ password }),
    }),
  getDashboard: (range = "week") =>
    apiFetch<DashboardResponse>(`/admin/dashboard?range=${encodeURIComponent(range)}`),
  getVerifications: (params: Record<string, string | number>) => {
    const qs = new URLSearchParams(
      Object.entries(params).map(([k, v]) => [k, String(v)]),
    ).toString();
    return apiFetch<VerificationsResponse>(`/admin/verifications?${qs}`);
  },
  updateVerification: (
    id: string,
    payload: {
      action: "APPROVE" | "REJECT" | "RE_REVIEW" | "REQUEST_INFO";
      notes?: string;
    },
  ) =>
    apiFetch<VerificationItem>(`/admin/verifications/${id}`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  getUsers: (params: { search?: string; role?: string; status?: string }) => {
    const qs = new URLSearchParams(
      Object.entries(params).filter(([, v]) => Boolean(v)) as Array<[string, string]>,
    ).toString();
    return apiFetch<any[]>(`/admin/users?${qs}`);
  },
  updateUser: (
    id: string,
    payload: { isActive?: boolean; role?: UserRole; fullName?: string },
  ) =>
    apiFetch<any>(`/admin/users/${id}`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  getSellers: (params: { search?: string; verified?: string }) => {
    const qs = new URLSearchParams(
      Object.entries(params).filter(([, v]) => Boolean(v)) as Array<[string, string]>,
    ).toString();
    return apiFetch<any[]>(`/admin/sellers?${qs}`);
  },
  updateSeller: (
    id: string,
    payload: {
      isVerifiedBadge?: boolean;
      isOpenNow?: boolean;
      stallNumber?: string;
      stallLandmark?: string;
    },
  ) =>
    apiFetch<any>(`/admin/sellers/${id}`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  getGeoOverview: () => apiFetch<any[]>("/admin/geo"),
  createGovernorate: (payload: {
    nameAr: string;
    nameEn?: string;
    defaultCurrency: Currency;
  }) =>
    apiFetch<any[]>("/admin/geo/governorates", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  createMarket: (payload: {
    districtId: number;
    nameAr: string;
    nameEn?: string;
    centerLatitude?: number;
    centerLongitude?: number;
  }) =>
    apiFetch<any[]>("/admin/geo/markets", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  toggleMarket: (id: number, isActive: boolean) =>
    apiFetch<any[]>(`/admin/geo/markets/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ isActive }),
    }),
  getBookings: (params: { search?: string; status?: string }) => {
    const qs = new URLSearchParams(
      Object.entries(params).filter(([, v]) => Boolean(v)) as Array<[string, string]>,
    ).toString();
    return apiFetch<any[]>(`/admin/bookings?${qs}`);
  },
  updateBooking: (
    id: string,
    payload: {
      bookingStatus?: "CONFIRMED" | "PENDING" | "COMPLETED" | "CANCELLED";
      stockStatus?: StockStatus;
    },
  ) =>
    apiFetch<any>(`/admin/bookings/${id}`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  getReports: (params: { search?: string; status?: string }) => {
    const qs = new URLSearchParams(
      Object.entries(params).filter(([, v]) => Boolean(v)) as Array<[string, string]>,
    ).toString();
    return apiFetch<AdminReportItem[]>(`/admin/reports?${qs}`);
  },
  moderateReport: (
    id: string,
    payload: {
      action:
        | "START_REVIEW"
        | "HIDE_OFFER"
        | "WARN_SELLER"
        | "BAN_SELLER"
        | "DISMISS"
        | "RESOLVE";
      notes?: string;
    },
  ) =>
    apiFetch<AdminReportItem>(`/admin/reports/${id}`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  getAnalytics: (range = "week") =>
    apiFetch<any>(`/admin/analytics?range=${encodeURIComponent(range)}`),
  getSettings: () => apiFetch<any>("/admin/settings"),
  updateSettings: (payload: {
    latestVersion?: string;
    latestBuildNumber?: number;
    minSupportedVersion?: string;
    minSupportedBuildNumber?: number;
    updateType?: AppUpdateType;
    downloadUrl?: string;
    telegramChannelUrl?: string;
    releaseNotes?: string;
  }) =>
    apiFetch<any>("/admin/settings", {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  sendBroadcast: (payload: {
    title: string;
    body: string;
    audience: "ALL" | "CUSTOMERS" | "SELLERS" | "GOVERNORATE";
    deepLink?: string;
  }) =>
    apiFetch<any>("/admin/notifications/broadcast", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  getAuditLogs: (params: { search?: string; badge?: string }) => {
    const qs = new URLSearchParams(
      Object.entries(params).filter(([, v]) => Boolean(v)) as Array<[string, string]>,
    ).toString();
    return apiFetch<any[]>(`/admin/audit-logs?${qs}`);
  },
  getSupportTickets: (params: { search?: string; status?: string }) => {
    const qs = new URLSearchParams(
      Object.entries(params).filter(([, v]) => Boolean(v)) as Array<[string, string]>,
    ).toString();
    return apiFetch<any[]>(`/admin/support?${qs}`);
  },
  updateSupportTicket: (
    id: string,
    payload: { status?: "OPEN" | "IN_PROGRESS" | "RESOLVED"; reply?: string },
  ) =>
    apiFetch<any>(`/admin/support/${id}`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
};
