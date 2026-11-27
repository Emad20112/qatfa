import React from "react";
import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthProvider, useAuth } from "./context/AuthContext";
import { AdminLayout } from "./components/layout/AdminLayout";
import { AdminLoginView } from "./features/auth/AdminLoginView";
import { DashboardPage } from "./features/dashboard/DashboardPage";
import { VerificationsPage } from "./features/verifications/VerificationsPage";
import { UsersPage } from "./features/users/UsersPage";
import { SellersPage } from "./features/sellers/SellersPage";
import { MarketsPage } from "./features/markets/MarketsPage";
import { BookingsPage } from "./features/bookings/BookingsPage";
import { ReportsPage } from "./features/reports/ReportsPage";
import { AnalyticsPage } from "./features/analytics/AnalyticsPage";
import { SettingsPage } from "./features/settings/SettingsPage";
import { AuditLogsPage } from "./features/audit-logs/AuditLogsPage";
import { SupportPage } from "./features/support/SupportPage";
import { OtpMonitorPage } from "./features/otp/OtpMonitorPage";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

const AdminRouterShell: React.FC = () => {
  const { user } = useAuth();

  if (!user) {
    return <AdminLoginView />;
  }

  return (
    <AdminLayout>
      <Routes>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/users" element={<UsersPage />} />
        <Route path="/sellers" element={<SellersPage />} />
        <Route path="/verifications" element={<VerificationsPage />} />
        <Route path="/markets" element={<MarketsPage />} />
        <Route path="/bookings" element={<BookingsPage />} />
        <Route path="/reports" element={<ReportsPage />} />
        <Route path="/analytics" element={<AnalyticsPage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="/audit-logs" element={<AuditLogsPage />} />
        <Route path="/otp-monitor" element={<OtpMonitorPage />} />
        <Route path="/support" element={<SupportPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AdminLayout>
  );
};

export const App: React.FC = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <AdminRouterShell />
        </BrowserRouter>
      </AuthProvider>
    </QueryClientProvider>
  );
};

export default App;
