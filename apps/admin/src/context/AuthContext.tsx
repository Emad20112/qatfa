import React, { createContext, useContext, useEffect, useState } from "react";
import {
  adminApi,
  AdminUserSession,
  AuthStatusResponse,
  setApiToken,
} from "../services/api";

interface AuthContextValue {
  user: AdminUserSession | null;
  token: string | null;
  authStatus: AuthStatusResponse | null;
  isLoadingStatus: boolean;
  login: (password: string) => Promise<void>;
  claim: (password: string) => Promise<void>;
  logout: () => void;
  refreshStatus: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [user, setUser] = useState<AdminUserSession | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [authStatus, setAuthStatus] = useState<AuthStatusResponse | null>(null);
  const [isLoadingStatus, setIsLoadingStatus] = useState(true);

  const refreshStatus = async () => {
    setIsLoadingStatus(true);
    try {
      const status = await adminApi.getAuthStatus();
      setAuthStatus(status);
    } catch {
      setAuthStatus({
        isClaimed: false,
        hasEnvPasscode: false,
        adminProfile: {
          fullName: "أحمد محمد",
          roleLabel: "مدير النظام",
          avatarUrl: "/images/avatar-ahmed.jpg",
        },
      });
    } finally {
      setIsLoadingStatus(false);
    }
  };

  useEffect(() => {
    void refreshStatus();
  }, []);

  const login = async (password: string) => {
    const res = await adminApi.loginAdmin(password);
    setApiToken(res.token);
    setToken(res.token);
    setUser(res.user);
  };

  const claim = async (password: string) => {
    const res = await adminApi.claimAdmin(password);
    setApiToken(res.token);
    setToken(res.token);
    setUser(res.user);
    await refreshStatus();
  };

  const logout = () => {
    setApiToken(null);
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        authStatus,
        isLoadingStatus,
        login,
        claim,
        logout,
        refreshStatus,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used inside AuthProvider");
  }
  return ctx;
}
