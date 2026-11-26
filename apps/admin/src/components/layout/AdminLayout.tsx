import React, { useState } from "react";
import { NavLink, useLocation, useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import {
  BarChart3,
  Bell,
  Calendar,
  CalendarCheck,
  ChevronDown,
  Headphones,
  History,
  Home,
  LogOut,
  MapPin,
  Maximize2,
  Menu,
  Minimize2,
  Search,
  Settings,
  ShieldCheck,
  Store,
  Users,
  X,
} from "lucide-react";
import { adminApi } from "../../services/api";
import { useAuth } from "../../context/AuthContext";

interface NavItem {
  path: string;
  label: string;
  icon: React.ReactNode;
  hasBadge?: boolean;
}

const NAV_ITEMS: NavItem[] = [
  { path: "/", label: "الرئيسية", icon: <Home className="w-4 h-4" /> },
  {
    path: "/users",
    label: "إدارة المستخدمين",
    icon: <Users className="w-4 h-4" />,
  },
  {
    path: "/sellers",
    label: "إدارة البائعين",
    icon: <Store className="w-4 h-4" />,
  },
  {
    path: "/verifications",
    label: "طلبات التوثيق",
    icon: <ShieldCheck className="w-4 h-4" />,
    hasBadge: true,
  },
  {
    path: "/markets",
    label: "إدارة الأسواق",
    icon: <MapPin className="w-4 h-4" />,
  },
  {
    path: "/bookings",
    label: "إدارة الحجوزات",
    icon: <CalendarCheck className="w-4 h-4" />,
  },
  {
    path: "/reports",
    label: "الشكاوى والبلاغات",
    icon: <Bell className="w-4 h-4" />,
  },
  {
    path: "/analytics",
    label: "التقارير والإحصائيات",
    icon: <BarChart3 className="w-4 h-4" />,
  },
  {
    path: "/settings",
    label: "إعدادات النظام",
    icon: <Settings className="w-4 h-4" />,
  },
  {
    path: "/audit-logs",
    label: "سجل العمليات",
    icon: <History className="w-4 h-4" />,
  },
  {
    path: "/support",
    label: "الدعم الفني",
    icon: <Headphones className="w-4 h-4" />,
  },
];

export const AdminLayout: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [profileMenuOpen, setProfileMenuOpen] = useState(false);
  const [globalSearch, setGlobalSearch] = useState("");
  const [isFullscreen, setIsFullscreen] = useState(false);

  const { data: dashboard } = useQuery({
    queryKey: ["admin-dashboard", "week"],
    queryFn: () => adminApi.getDashboard("week"),
    staleTime: 30_000,
  });

  const pendingBadgeCount = dashboard?.sidebarBadgeCount ?? 3;
  const notificationCount = dashboard?.notificationCount ?? 5;

  const toggleFullscreen = async () => {
    try {
      if (!document.fullscreenElement) {
        await document.documentElement.requestFullscreen();
        setIsFullscreen(true);
      } else {
        await document.exitFullscreen();
        setIsFullscreen(false);
      }
    } catch {
      // Ignore fullscreen denial in embedded iframes
    }
  };

  const handleGlobalSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const q = globalSearch.trim();
    if (!q) return;
    if (q.startsWith("QT-") || q.includes("توثيق")) {
      navigate(`/verifications?search=${encodeURIComponent(q)}`);
    } else if (q.startsWith("+967") || q.startsWith("7")) {
      navigate(`/users?search=${encodeURIComponent(q)}`);
    } else {
      navigate(`/verifications?search=${encodeURIComponent(q)}`);
    }
  };

  const searchPlaceholder =
    location.pathname === "/verifications"
      ? "البحث في الطلبات أو المستخدمين..."
      : "البحث في النظام ...";

  const sidebarContent = (
    <div className="flex flex-col h-full justify-between bg-gradient-to-b from-[#073619] via-[#093E1D] to-[#062913] text-white select-none">
      <div>
        {/* Brand Logo Header */}
        <div className="flex flex-col items-center justify-center pt-5 pb-4 px-4">
          <div className="flex items-center gap-2">
            {/* Two vibrant green Qat leaves SVG */}
            <svg
              width="28"
              height="28"
              viewBox="0 0 32 32"
              fill="none"
              aria-hidden="true"
            >
              <path
                d="M15 26C15 17 19 9 28 6C27 15 22 22 15 26Z"
                fill="#4ADE80"
              />
              <path
                d="M15 26C14 19 9 13 3 12C5 20 9 24 15 26Z"
                fill="#22C55E"
              />
            </svg>
            <span className="text-[28px] font-extrabold tracking-tight text-white leading-none">
              قطفة
            </span>
          </div>
          <div className="flex items-center gap-2 mt-1.5 text-[11px] font-bold tracking-[0.22em] text-emerald-100/85">
            <span className="w-4 h-[1px] bg-emerald-200/40" />
            <span>QATFA</span>
            <span className="w-4 h-[1px] bg-emerald-200/40" />
          </div>
        </div>

        {/* Navigation Links */}
        <nav className="px-3 space-y-1 mt-1">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === "/"}
              onClick={() => setMobileMenuOpen(false)}
              className={({ isActive }) =>
                `flex items-center justify-between px-3.5 py-2.5 rounded-xl text-[13.5px] font-semibold transition-all duration-150 whitespace-nowrap ${
                  isActive
                    ? "bg-gradient-to-l from-[#2EA44F] to-[#1D7E36] text-white shadow-[0_4px_12px_rgba(34,197,94,0.28)]"
                    : "text-emerald-50/85 hover:bg-white/[0.07] hover:text-white"
                }`
              }
            >
              <span className="flex items-center gap-3">
                <span className="shrink-0 opacity-95">{item.icon}</span>
                <span>{item.label}</span>
              </span>
              {item.hasBadge && pendingBadgeCount > 0 && (
                <span className="w-5 h-5 rounded-full bg-[#EF4444] text-white text-[11px] font-extrabold flex items-center justify-center tabular-nums shadow-xs">
                  {pendingBadgeCount}
                </span>
              )}
            </NavLink>
          ))}
        </nav>
      </div>

      {/* Bottom Terraced Hills Growth Card */}
      <div className="p-3.5 mt-4">
        <div className="relative h-[106px] rounded-2xl overflow-hidden shadow-md border border-white/10">
          <img
            src="/images/sidebar-hills.jpg"
            alt="مزارع اليمن الخضراء"
            referrerPolicy="no-referrer"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#052410]/90 via-[#073619]/45 to-[#073619]/30 flex flex-col items-center justify-center text-center px-3">
            <span className="text-[15px] font-extrabold text-white leading-snug">
              معاً ..
            </span>
            <span className="text-[15px] font-extrabold text-white leading-snug">
              لننمو أكثر
            </span>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen flex bg-[#F6F8FA] text-[#1A202C]">
      {/* Fixed Right Sidebar on Desktop */}
      <aside className="hidden lg:block w-[252px] shrink-0 sticky top-0 h-screen overflow-y-auto shadow-lg z-30">
        {sidebarContent}
      </aside>

      {/* Mobile Drawer Sidebar */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 lg:hidden flex">
          <div className="w-[260px] h-full overflow-y-auto shadow-2xl">
            {sidebarContent}
          </div>
          <div
            className="flex-1 bg-black/45"
            onClick={() => setMobileMenuOpen(false)}
          />
        </div>
      )}

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top White Bar */}
        <header className="sticky top-0 z-20 bg-white border-b border-[#EDF2F7] px-4 lg:px-7 h-[70px] flex items-center justify-between gap-4">
          {/* Right Zone (Date + Mobile Menu) */}
          <div className="flex items-center gap-3 shrink-0">
            <button
              type="button"
              onClick={() => setMobileMenuOpen((v) => !v)}
              className="lg:hidden w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-700 cursor-pointer"
              aria-label="فتح القائمة"
            >
              {mobileMenuOpen ? (
                <X className="w-5 h-5" />
              ) : (
                <Menu className="w-5 h-5" />
              )}
            </button>
            <div className="hidden sm:flex items-center gap-2 text-[13.5px] font-semibold text-[#374151] whitespace-nowrap">
              <Calendar className="w-4 h-4 text-slate-500" />
              <span>الإثنين، 24 نوفمبر 2025</span>
            </div>
          </div>

          {/* Center Search Pill */}
          <form
            onSubmit={handleGlobalSearchSubmit}
            className="flex-1 max-w-md mx-auto"
          >
            <div className="relative flex items-center">
              <Search className="w-4 h-4 text-slate-400 absolute right-4 pointer-events-none" />
              <input
                type="text"
                value={globalSearch}
                onChange={(e) => setGlobalSearch(e.target.value)}
                placeholder={searchPlaceholder}
                className="w-full h-10 pr-10 pl-4 rounded-full bg-[#F4F6F8] text-sm text-slate-800 placeholder:text-slate-400 border border-transparent focus:border-[#1B5E20]/30 focus:bg-white focus:outline-none transition-all"
              />
            </div>
          </form>

          {/* Left Zone (Fullscreen + Notifications + Admin Profile) */}
          <div className="flex items-center gap-2.5 shrink-0">
            <button
              type="button"
              onClick={toggleFullscreen}
              className="hidden sm:flex w-10 h-10 rounded-full bg-[#F4F6F8] hover:bg-slate-200/70 text-slate-600 items-center justify-center transition-colors cursor-pointer"
              title="ملء الشاشة"
            >
              {isFullscreen ? (
                <Minimize2 className="w-4 h-4" />
              ) : (
                <Maximize2 className="w-4 h-4" />
              )}
            </button>

            {/* Notifications Dropdown */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setNotifOpen((v) => !v);
                  setProfileMenuOpen(false);
                }}
                className="relative w-10 h-10 rounded-full bg-[#F4F6F8] hover:bg-slate-200/70 text-slate-600 flex items-center justify-center transition-colors cursor-pointer"
                title="الإشعارات"
              >
                <Bell className="w-4 h-4" />
                {notificationCount > 0 && (
                  <span className="absolute -top-0.5 -left-0.5 w-4.5 h-4.5 rounded-full bg-[#EF4444] text-white text-[10px] font-bold flex items-center justify-center tabular-nums">
                    {notificationCount}
                  </span>
                )}
              </button>

              {notifOpen && (
                <div className="absolute left-0 mt-2 w-80 bg-white rounded-2xl shadow-xl border border-slate-100 p-3 z-40">
                  <div className="flex items-center justify-between pb-2 mb-2 border-b border-slate-100">
                    <span className="text-sm font-bold text-[#111827]">
                      تنبيهات النظام العاجلة
                    </span>
                    <button
                      type="button"
                      onClick={() => setNotifOpen(false)}
                      className="text-xs text-[#15803D] font-bold hover:underline cursor-pointer"
                    >
                      إغلاق
                    </button>
                  </div>
                  <div className="space-y-2 max-h-64 overflow-y-auto">
                    {(dashboard?.recentVerifications || []).map((v) => (
                      <button
                        key={v.id}
                        type="button"
                        onClick={() => {
                          setNotifOpen(false);
                          navigate("/verifications");
                        }}
                        className="w-full text-right p-2 rounded-xl hover:bg-slate-50 transition-colors cursor-pointer"
                      >
                        <div className="text-xs font-bold text-slate-800">
                          طلب توثيق: {v.entityName}
                        </div>
                        <div className="text-[11px] text-slate-500 mt-0.5">
                          {v.locationLabel} · {v.relativeTime}
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <div className="hidden sm:block w-px h-7 bg-slate-200 mx-1" />

            {/* Admin Profile Dropdown */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setProfileMenuOpen((v) => !v);
                  setNotifOpen(false);
                }}
                className="flex items-center gap-2.5 py-1 px-1.5 rounded-xl hover:bg-slate-50 transition-colors cursor-pointer"
              >
                <img
                  src={user?.avatarUrl || "/images/avatar-ahmed.jpg"}
                  alt={user?.fullName || "أحمد محمد"}
                  referrerPolicy="no-referrer"
                  className="w-10 h-10 rounded-full object-cover border border-emerald-100"
                />
                <div className="hidden md:block text-right">
                  <div className="flex items-center gap-1.5">
                    <span className="text-[13.5px] font-extrabold text-[#111827] whitespace-nowrap">
                      {user?.fullName || "أحمد محمد"}
                    </span>
                    <span className="w-5 h-5 rounded-md bg-[#E6F6EC] text-[#15803D] flex items-center justify-center">
                      <ShieldCheck className="w-3.5 h-3.5" />
                    </span>
                  </div>
                  <div className="text-[11.5px] text-slate-500 font-medium">
                    {user?.roleLabel || "مدير النظام"}
                  </div>
                </div>
                <ChevronDown className="w-4 h-4 text-slate-400 hidden md:block" />
              </button>

              {profileMenuOpen && (
                <div className="absolute left-0 mt-2 w-52 bg-white rounded-2xl shadow-xl border border-slate-100 p-2 z-40">
                  <button
                    type="button"
                    onClick={() => {
                      setProfileMenuOpen(false);
                      navigate("/settings");
                    }}
                    className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-slate-700 hover:bg-slate-50 cursor-pointer"
                  >
                    <Settings className="w-4 h-4 text-slate-500" />
                    <span>إعدادات النظام</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setProfileMenuOpen(false);
                      logout();
                    }}
                    className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-red-600 hover:bg-red-50 cursor-pointer mt-1"
                  >
                    <LogOut className="w-4 h-4" />
                    <span>تسجيل الخروج</span>
                  </button>
                </div>
              )}
            </div>
          </div>
        </header>

        {/* Page Viewport */}
        <main className="flex-1 p-4 lg:p-6 max-w-[1440px] w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
};
