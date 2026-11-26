import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import {
  ArrowLeft,
  BarChart2,
  CalendarCheck,
  Clock,
  Headphones,
  Lightbulb,
  Megaphone,
  MessageSquare,
  RotateCcw,
  ShieldCheck,
  Store,
  TrendingUp,
  Users,
} from "lucide-react";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";
import { YemenMarketsMap } from "../../components/ui/YemenMarketsMap";

const RANGE_OPTIONS = [
  { key: "week", label: "أسبوع" },
  { key: "month", label: "شهر" },
  { key: "quarter", label: "3 أشهر" },
  { key: "year", label: "سنة" },
];

export const DashboardPage: React.FC = () => {
  const navigate = useNavigate();
  const [range, setRange] = useState("week");
  const [hoveredIdx, setHoveredIdx] = useState<number | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin-dashboard", range],
    queryFn: () => adminApi.getDashboard(range),
  });

  const kpis = data?.kpis || {
    totalUsers: 248750,
    totalUsersTrend: 14,
    pendingRequests: 36,
    pendingRequestsTrend: 25,
    verifiedSellers: 843,
    verifiedSellersTrend: 8,
    totalBookings: 12480,
    totalBookingsTrend: 12,
  };

  const series = data?.analyticsSeries || [
    { label: "السبت", value: 4800 },
    { label: "الأحد", value: 7100 },
    { label: "الاثنين", value: 8050 },
    { label: "الثلاثاء", value: 8900 },
    { label: "الأربعاء", value: 11800 },
    { label: "الخميس", value: 14250 },
    { label: "الجمعة", value: 12100 },
  ];

  // Build SVG coordinates for Platform Analytics chart
  const chartW = 460;
  const chartH = 155;
  const padX = 22;
  const padTop = 24;
  const padBottom = 14;
  const maxVal = 15500;

  const chartPoints = series.map((item, idx) => {
    const x =
      padX +
      (idx / Math.max(1, series.length - 1)) * (chartW - padX * 2);
    const y =
      chartH -
      padBottom -
      (Math.min(item.value, maxVal) / maxVal) * (chartH - padTop - padBottom);
    return { ...item, x, y };
  });

  const linePath = chartPoints.reduce((acc, pt, idx) => {
    if (idx === 0) return `M ${pt.x} ${pt.y}`;
    const prev = chartPoints[idx - 1];
    const cx = (prev.x + pt.x) / 2;
    return `${acc} C ${cx} ${prev.y}, ${cx} ${pt.y}, ${pt.x} ${pt.y}`;
  }, "");

  const areaPath =
    chartPoints.length > 0
      ? `${linePath} L ${chartPoints[chartPoints.length - 1].x} ${chartH - padBottom} L ${chartPoints[0].x} ${chartH - padBottom} Z`
      : "";

  const defaultPeakIdx = chartPoints.reduce(
    (best, pt, idx, arr) => (pt.value > arr[best].value ? idx : best),
    0,
  );
  const activePointIdx = hoveredIdx !== null ? hoveredIdx : defaultPeakIdx;
  const activePoint = chartPoints[activePointIdx] || chartPoints[0];

  const breakdown = data?.requestBreakdown || {
    total: 120,
    approved: 82,
    rejected: 10,
    pending: 28,
  };
  const breakdownSum =
    breakdown.approved + breakdown.rejected + breakdown.pending || 1;
  const approvedPct = (breakdown.approved / breakdownSum) * 100;
  const pendingPct = (breakdown.pending / breakdownSum) * 100;
  const rejectedPct = (breakdown.rejected / breakdownSum) * 100;

  const radius = 48;
  const circumference = 2 * Math.PI * radius;
  const approvedLen = (approvedPct / 100) * circumference;
  const pendingLen = (pendingPct / 100) * circumference;
  const rejectedLen = (rejectedPct / 100) * circumference;

  return (
    <div className="space-y-5">
      {/* Row 1: 4 Pastel KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={kpis.totalUsers}
          label="إجمالي المستخدمين"
          trendPercent={kpis.totalUsersTrend}
          tone="mint"
          icon={<Users className="w-5 h-5" />}
          points={[20, 26, 24, 34, 31, 42, 46]}
        />
        <SparklineCard
          value={kpis.pendingRequests}
          label="طلبات بانتظار المراجعة"
          trendPercent={kpis.pendingRequestsTrend}
          tone="amber"
          icon={<Clock className="w-5 h-5" />}
          points={[12, 18, 16, 28, 25, 38, 42]}
        />
        <SparklineCard
          value={kpis.verifiedSellers}
          label="البائعين المعتمدين"
          trendPercent={kpis.verifiedSellersTrend}
          tone="blue"
          icon={<Store className="w-5 h-5" />}
          points={[18, 22, 20, 29, 27, 36, 39]}
        />
        <SparklineCard
          value={kpis.totalBookings}
          label="إجمالي الحجوزات"
          trendPercent={kpis.totalBookingsTrend}
          tone="mint"
          icon={<TrendingUp className="w-5 h-5" />}
          points={[16, 24, 21, 31, 33, 41, 45]}
        />
      </div>

      {/* Row 2: Yemen Map + Platform Analytics + Request Status Donut */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        {/* Markets Map */}
        <div className="lg:col-span-4 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)]">
          <YemenMarketsMap
            pins={data?.marketPins || []}
            activeMarketsCount={data?.activeMarketsCount ?? 8}
            compact
          />
        </div>

        {/* Platform Analytics */}
        <div className="lg:col-span-5 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] flex flex-col justify-between">
          <div className="flex flex-wrap items-center justify-between gap-2 mb-3">
            <h3 className="text-base font-bold text-[#111827]">
              إحصائيات المنصة
            </h3>
            <div className="flex items-center gap-1 bg-[#F4F6F8] p-1 rounded-full">
              {RANGE_OPTIONS.map((opt) => (
                <button
                  key={opt.key}
                  type="button"
                  onClick={() => setRange(opt.key)}
                  className={`px-3 py-1 rounded-full text-xs font-bold transition-colors cursor-pointer whitespace-nowrap ${
                    range === opt.key
                      ? "bg-[#115E31] text-white shadow-xs"
                      : "text-slate-600 hover:text-slate-900"
                  }`}
                >
                  {opt.label}
                </button>
              ))}
            </div>
          </div>

          <div className="relative w-full">
            <div className="flex">
              <div className="flex-1">
                <svg
                  viewBox={`0 0 ${chartW} ${chartH}`}
                  className="w-full h-[175px] overflow-visible"
                >
                  <defs>
                    <linearGradient id="qatfaArea" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#16A34A" stopOpacity="0.24" />
                      <stop offset="100%" stopColor="#16A34A" stopOpacity="0.01" />
                    </linearGradient>
                  </defs>

                  {/* Horizontal Grid Lines */}
                  {[0, 5000, 10000, 15000].map((tick) => {
                    const y =
                      chartH -
                      padBottom -
                      (tick / maxVal) * (chartH - padTop - padBottom);
                    return (
                      <line
                        key={tick}
                        x1={padX}
                        x2={chartW - padX}
                        y1={y}
                        y2={y}
                        stroke="#EEF2F6"
                        strokeDasharray="3 3"
                      />
                    );
                  })}

                  {areaPath && <path d={areaPath} fill="url(#qatfaArea)" />}
                  {linePath && (
                    <path
                      d={linePath}
                      fill="none"
                      stroke="#116932"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                    />
                  )}

                  {chartPoints.map((pt, idx) => {
                    const isActive = idx === activePointIdx;
                    return (
                      <g
                        key={pt.label}
                        className="cursor-pointer"
                        onMouseEnter={() => setHoveredIdx(idx)}
                        onMouseLeave={() => setHoveredIdx(null)}
                      >
                        <circle
                          cx={pt.x}
                          cy={pt.y}
                          r={isActive ? 5 : 3.8}
                          fill="#116932"
                          stroke="#FFFFFF"
                          strokeWidth="2"
                        />
                        <circle cx={pt.x} cy={pt.y} r="14" fill="transparent" />
                      </g>
                    );
                  })}

                  {/* Active Value Pill */}
                  {activePoint && (
                    <g
                      transform={`translate(${Math.min(
                        Math.max(activePoint.x, 42),
                        chartW - 42,
                      )}, ${Math.max(activePoint.y - 16, 14)})`}
                    >
                      <rect
                        x="-28"
                        y="-16"
                        width="56"
                        height="22"
                        rx="6"
                        fill="#0F522B"
                      />
                      <text
                        x="0"
                        y="-1"
                        textAnchor="middle"
                        fill="#FFFFFF"
                        fontSize="11"
                        fontWeight="700"
                      >
                        {activePoint.value.toLocaleString("en-US")}
                      </text>
                    </g>
                  )}
                </svg>

                {/* X-Axis Labels */}
                <div className="flex items-center justify-between px-3 text-[11px] font-semibold text-slate-500 -mt-1">
                  {series.map((s) => (
                    <span key={s.label}>{s.label}</span>
                  ))}
                </div>
              </div>

              {/* Y-Axis Labels on Left in RTL */}
              <div className="flex flex-col justify-between py-3 pr-2 text-[11px] font-semibold text-slate-400 tabular-nums">
                <span>15k</span>
                <span>10k</span>
                <span>5k</span>
                <span>0</span>
              </div>
            </div>
          </div>
        </div>

        {/* Request Status Donut */}
        <div className="lg:col-span-3 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <h3 className="text-base font-bold text-[#111827]">حالة الطلبات</h3>
            <button
              type="button"
              onClick={() => navigate("/verifications")}
              className="inline-flex items-center gap-1 text-xs font-bold text-[#115E31] bg-[#F4F8F5] hover:bg-[#E7F4EC] px-2.5 py-1 rounded-full transition-colors cursor-pointer"
            >
              <span>عرض الكل</span>
              <ArrowLeft className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="flex items-center justify-between gap-4 my-auto py-3">
            {/* Legend */}
            <div className="space-y-3 text-xs font-bold text-slate-700">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-[#16A34A]" />
                <span>مقبولة</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-[#EF4444]" />
                <span>مرفوضة</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-[#F59E0B]" />
                <span>قيد المراجعة</span>
              </div>
            </div>

            {/* SVG Donut */}
            <div className="relative w-32 h-32 shrink-0 flex items-center justify-center">
              <svg viewBox="0 0 120 120" className="w-full h-full -rotate-90">
                <circle
                  cx="60"
                  cy="60"
                  r={radius}
                  fill="none"
                  stroke="#F1F5F9"
                  strokeWidth="15"
                />
                <circle
                  cx="60"
                  cy="60"
                  r={radius}
                  fill="none"
                  stroke="#16A34A"
                  strokeWidth="15"
                  strokeDasharray={`${approvedLen} ${circumference}`}
                  strokeDashoffset={0}
                />
                <circle
                  cx="60"
                  cy="60"
                  r={radius}
                  fill="none"
                  stroke="#EF4444"
                  strokeWidth="15"
                  strokeDasharray={`${rejectedLen} ${circumference}`}
                  strokeDashoffset={-approvedLen}
                />
                <circle
                  cx="60"
                  cy="60"
                  r={radius}
                  fill="none"
                  stroke="#F59E0B"
                  strokeWidth="15"
                  strokeDasharray={`${pendingLen} ${circumference}`}
                  strokeDashoffset={-(approvedLen + rejectedLen)}
                />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                <span className="text-xl font-extrabold text-[#111827] tabular-nums leading-none">
                  {breakdown.total}
                </span>
                <span className="text-[11px] font-semibold text-slate-500 mt-1">
                  طلب إجمالي
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Row 3: Quick Stats + Recent Verifications + Recent Reports */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        {/* Quick Stats */}
        <div className="lg:col-span-4 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)]">
          <div className="flex items-center gap-2 mb-4">
            <BarChart2 className="w-4.5 h-4.5 text-[#115E31]" />
            <h3 className="text-base font-bold text-[#111827]">
              إحصائيات سريعة
            </h3>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-xl bg-[#FFF6EB] p-3.5 text-center">
              <div className="flex justify-center text-[#15803D] mb-1">
                <Store className="w-5 h-5" />
              </div>
              <div className="text-lg font-extrabold text-[#111827] tabular-nums">
                {(data?.quickStats.registeredSellers ?? 892).toLocaleString(
                  "en-US",
                )}
              </div>
              <div className="text-xs font-semibold text-slate-500">
                بائع مسجل
              </div>
            </div>

            <div className="rounded-xl bg-[#EFF5FF] p-3.5 text-center">
              <div className="flex justify-center text-[#15803D] mb-1">
                <Users className="w-5 h-5" />
              </div>
              <div className="text-lg font-extrabold text-[#111827] tabular-nums">
                {(data?.quickStats.activeUsers ?? 5240).toLocaleString("en-US")}
              </div>
              <div className="text-xs font-semibold text-slate-500">
                مستخدم نشط
              </div>
            </div>

            <div className="rounded-xl bg-[#ECF9F1] p-3.5 text-center">
              <div className="flex justify-center text-[#15803D] mb-1">
                <CalendarCheck className="w-5 h-5" />
              </div>
              <div className="text-lg font-extrabold text-[#111827] tabular-nums">
                {(data?.quickStats.monthlyBookings ?? 1850).toLocaleString(
                  "en-US",
                )}
              </div>
              <div className="text-xs font-semibold text-slate-500">
                حجز هذا الشهر
              </div>
            </div>

            <div className="rounded-xl bg-[#EFF5FF] p-3.5 text-center">
              <div className="flex justify-center text-[#0F4C2A] mb-1">
                <Headphones className="w-5 h-5" />
              </div>
              <div className="text-lg font-extrabold text-[#111827] tabular-nums">
                {(data?.quickStats.reportsAndIssues ?? 320).toLocaleString(
                  "en-US",
                )}
              </div>
              <div className="text-xs font-semibold text-slate-500">
                بلاغ ومشكلة
              </div>
            </div>
          </div>
        </div>

        {/* Recent Verifications */}
        <div className="lg:col-span-4 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)]">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <ShieldCheck className="w-4.5 h-4.5 text-[#115E31]" />
              <h3 className="text-base font-bold text-[#111827]">
                طلبات التوثيق الأخيرة
              </h3>
            </div>
            <button
              type="button"
              onClick={() => navigate("/verifications")}
              className="inline-flex items-center gap-1 text-xs font-bold text-[#115E31] hover:underline cursor-pointer"
            >
              <span>عرض الكل</span>
              <ArrowLeft className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="space-y-3">
            {(isLoading ? [] : data?.recentVerifications || []).map((item) => {
              const badge =
                item.status === "APPROVED"
                  ? {
                      text: "مقبول",
                      cls: "bg-[#E6F6EC] text-[#15803D]",
                    }
                  : item.status === "REJECTED"
                    ? {
                        text: "مرفوض",
                        cls: "bg-[#FEECEC] text-[#DC2626]",
                      }
                    : {
                        text: "قيد المراجعة",
                        cls: "bg-[#E6F1FE] text-[#1D4ED8]",
                      };

              return (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => navigate("/verifications")}
                  className="w-full flex items-center justify-between gap-3 p-2.5 rounded-xl hover:bg-slate-50 transition-colors cursor-pointer text-right"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-10 h-10 rounded-xl bg-[#ECF7F0] text-[#15803D] flex items-center justify-center shrink-0">
                      <Store className="w-5 h-5" />
                    </div>
                    <div className="min-w-0">
                      <div className="text-[13.5px] font-bold text-[#111827] truncate">
                        {item.entityName}
                      </div>
                      <div className="text-[11.5px] text-slate-400 font-medium">
                        {item.relativeTime}
                      </div>
                    </div>
                  </div>
                  <span
                    className={`px-3 py-1 rounded-full text-[11.5px] font-bold whitespace-nowrap shrink-0 ${badge.cls}`}
                  >
                    {badge.text}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Recent Reports */}
        <div className="lg:col-span-4 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)]">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Megaphone className="w-4.5 h-4.5 text-[#115E31]" />
              <h3 className="text-base font-bold text-[#111827]">
                أحدث البلاغات
              </h3>
            </div>
            <button
              type="button"
              onClick={() => navigate("/reports")}
              className="inline-flex items-center gap-1 text-xs font-bold text-[#115E31] hover:underline cursor-pointer"
            >
              <span>عرض الكل</span>
              <ArrowLeft className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="space-y-3">
            {(isLoading ? [] : data?.recentReports || []).map((rep, idx) => {
              const badge =
                rep.status === "OPEN"
                  ? { text: "مفتوح", cls: "bg-[#FEECEC] text-[#DC2626]" }
                  : rep.status === "IN_PROGRESS"
                    ? {
                        text: "قيد المعالجة",
                        cls: "bg-[#FEF3C7] text-[#D97706]",
                      }
                    : { text: "مغلق", cls: "bg-[#E6F6EC] text-[#15803D]" };

              const IconComp =
                idx === 0
                  ? MessageSquare
                  : idx === 1
                    ? RotateCcw
                    : Lightbulb;

              return (
                <button
                  key={rep.id}
                  type="button"
                  onClick={() => navigate("/reports")}
                  className="w-full flex items-center justify-between gap-3 p-2.5 rounded-xl hover:bg-slate-50 transition-colors cursor-pointer text-right"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-10 h-10 rounded-full bg-slate-100 text-slate-600 flex items-center justify-center shrink-0">
                      <IconComp className="w-4.5 h-4.5" />
                    </div>
                    <div className="min-w-0">
                      <div className="text-[13.5px] font-bold text-[#111827] truncate">
                        {rep.title}
                      </div>
                      <div className="text-[11.5px] text-slate-400 font-medium truncate">
                        من: {rep.reporterName} - {rep.relativeTime}
                      </div>
                    </div>
                  </div>
                  <span
                    className={`px-3 py-1 rounded-full text-[11.5px] font-bold whitespace-nowrap shrink-0 ${badge.cls}`}
                  >
                    {badge.text}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
};
