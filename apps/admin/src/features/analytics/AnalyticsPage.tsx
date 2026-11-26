import React, { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import {
  BarChart3,
  Download,
  Leaf,
  MapPin,
  MessageCircle,
  PhoneCall,
  RefreshCw,
  TrendingUp,
} from "lucide-react";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

const RANGES = [
  { key: "week", label: "أسبوع" },
  { key: "month", label: "شهر" },
  { key: "quarter", label: "3 أشهر" },
  { key: "year", label: "سنة" },
];

export const AnalyticsPage: React.FC = () => {
  const [range, setRange] = useState("week");

  const { data, isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-analytics", range],
    queryFn: () => adminApi.getAnalytics(range),
  });

  const leadBreakdown = data?.leadBreakdown || {
    whatsappClicks: 18420,
    phoneCalls: 9340,
    conversionRate: 34.8,
  };
  const topVarieties: Array<{ name: string; share: number; listings: number }> =
    data?.topVarieties || [];
  const governoratePerformance: Array<{
    name: string;
    activeStores: number;
    leads: number;
  }> = data?.governoratePerformance || [];
  const hourlyPeak: Array<{ hour: string; value: number }> =
    data?.hourlyPeak || [];

  const totalLeads = leadBreakdown.whatsappClicks + leadBreakdown.phoneCalls;
  const whatsappPct = totalLeads
    ? Math.round((leadBreakdown.whatsappClicks / totalLeads) * 100)
    : 66;
  const phonePct = 100 - whatsappPct;

  const chartW = 540;
  const chartH = 185;
  const padX = 26;
  const padTop = 24;
  const padBottom = 18;
  const maxPeak = Math.max(
    15000,
    ...hourlyPeak.map((h) => h.value || 0),
  );

  const peakPoints = hourlyPeak.map((pt, idx) => {
    const x =
      padX + (idx / Math.max(1, hourlyPeak.length - 1)) * (chartW - padX * 2);
    const y =
      chartH -
      padBottom -
      (pt.value / maxPeak) * (chartH - padTop - padBottom);
    return { ...pt, x, y };
  });

  const linePath = peakPoints.reduce((acc, pt, idx) => {
    if (idx === 0) return `M ${pt.x} ${pt.y}`;
    const prev = peakPoints[idx - 1];
    const cx = (prev.x + pt.x) / 2;
    return `${acc} C ${cx} ${prev.y}, ${cx} ${pt.y}, ${pt.x} ${pt.y}`;
  }, "");

  const areaPath =
    peakPoints.length > 0
      ? `${linePath} L ${peakPoints[peakPoints.length - 1].x} ${chartH - padBottom} L ${peakPoints[0].x} ${chartH - padBottom} Z`
      : "";

  const handleExportCsv = () => {
    const rows = [
      ["المحافظة", "عدد المتاجر النشطة", "نقرات التواصل (Leads)"],
      ...governoratePerformance.map((g) => [
        g.name,
        String(g.activeStores),
        String(g.leads),
      ]),
    ];
    const csvContent =
      "\uFEFF" + rows.map((r) => r.map((c) => `"${c}"`).join(",")).join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `qatfa-analytics-${range}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-5">
      {/* Header + Actions */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2.5">
            <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
              <BarChart3 className="w-5 h-5" />
            </span>
            <h1 className="text-2xl font-extrabold text-[#111827]">
              التقارير والإحصائيات
            </h1>
          </div>
          <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
            الرئيسية <span className="mx-1">‹</span> التقارير والإحصائيات
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          <div className="flex items-center gap-1 bg-white p-1 rounded-full border border-slate-200">
            {RANGES.map((opt) => (
              <button
                key={opt.key}
                type="button"
                onClick={() => setRange(opt.key)}
                className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition-colors cursor-pointer ${
                  range === opt.key
                    ? "bg-[#0C5A2C] text-white"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                {opt.label}
              </button>
            ))}
          </div>

          <button
            type="button"
            onClick={handleExportCsv}
            className="h-10 px-4 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] hover:bg-[#E1F5E8] text-xs font-bold inline-flex items-center gap-2 cursor-pointer"
          >
            <Download className="w-3.5 h-3.5" />
            <span>تصدير CSV</span>
          </button>

          <button
            type="button"
            onClick={() => void refetch()}
            className="h-10 px-4 rounded-full bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center gap-2 cursor-pointer"
          >
            <RefreshCw
              className={`w-3.5 h-3.5 ${isFetching ? "animate-spin" : ""}`}
            />
            <span>تحديث</span>
          </button>
        </div>
      </div>

      {/* 4 Sparkline KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={totalLeads}
          label="إجمالي نقرات التواصل (Leads)"
          trendPercent={22}
          tone="mint"
          icon={<TrendingUp className="w-5 h-5" />}
        />
        <SparklineCard
          value={leadBreakdown.whatsappClicks}
          label="نقرات واتساب المباشرة"
          trendPercent={18}
          tone="blue"
          icon={<MessageCircle className="w-5 h-5" />}
        />
        <SparklineCard
          value={leadBreakdown.phoneCalls}
          label="مكالمات هاتفية مباشرة"
          trendPercent={11}
          tone="amber"
          icon={<PhoneCall className="w-5 h-5" />}
        />
        <SparklineCard
          value={`${leadBreakdown.conversionRate}%`}
          label="معدل التحويل من الزيارة للتواصل"
          trendPercent={7}
          tone="rose"
          icon={<BarChart3 className="w-5 h-5" />}
        />
      </div>

      {/* Row 2: Hourly Peak Chart + Lead Split & Varieties */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        {/* Hourly Peak Traffic Chart (Peak 1 PM - 3 PM) */}
        <div className="lg:col-span-7 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)]">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-base font-bold text-[#111827]">
                ساعات الذروة اليومية (Peak Hours)
              </h3>
              <p className="text-xs text-slate-400 mt-0.5">
                أعلى نشاط للطلب والتصفح يتركز بين 1:00 م و 3:00 م
              </p>
            </div>
            <span className="px-3 py-1 rounded-full bg-[#E6F6EC] text-[#15803D] text-xs font-bold">
              ذروة النشاط: 2 م
            </span>
          </div>

          <div className="flex">
            <div className="flex-1">
              <svg
                viewBox={`0 0 ${chartW} ${chartH}`}
                className="w-full h-[200px] overflow-visible"
              >
                <defs>
                  <linearGradient id="peakArea" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#16A34A" stopOpacity="0.25" />
                    <stop offset="100%" stopColor="#16A34A" stopOpacity="0.02" />
                  </linearGradient>
                </defs>

                {[0, 5000, 10000, 15000].map((tick) => {
                  const y =
                    chartH -
                    padBottom -
                    (tick / maxPeak) * (chartH - padTop - padBottom);
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

                {areaPath && <path d={areaPath} fill="url(#peakArea)" />}
                {linePath && (
                  <path
                    d={linePath}
                    fill="none"
                    stroke="#116932"
                    strokeWidth="2.5"
                    strokeLinecap="round"
                  />
                )}

                {peakPoints.map((pt) => (
                  <g key={pt.hour}>
                    <circle
                      cx={pt.x}
                      cy={pt.y}
                      r={pt.value >= 13000 ? 5 : 3.5}
                      fill="#116932"
                      stroke="#FFFFFF"
                      strokeWidth="2"
                    />
                  </g>
                ))}
              </svg>

              <div className="flex items-center justify-between px-4 text-[11px] font-semibold text-slate-500">
                {hourlyPeak.map((h) => (
                  <span key={h.hour}>{h.hour}</span>
                ))}
              </div>
            </div>

            <div className="flex flex-col justify-between py-4 pr-2 text-[11px] font-semibold text-slate-400 tabular-nums">
              <span>15k</span>
              <span>10k</span>
              <span>5k</span>
              <span>0</span>
            </div>
          </div>
        </div>

        {/* Top Qat Varieties + Lead Channel Split */}
        <div className="lg:col-span-5 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] space-y-5">
          <div>
            <h3 className="text-base font-bold text-[#111827] mb-3">
              توزيع قنوات التواصل (واتساب مقابل الاتصال)
            </h3>
            <div className="h-4 rounded-full bg-slate-100 overflow-hidden flex">
              <div
                style={{ width: `${whatsappPct}%` }}
                className="bg-[#16A34A] h-full transition-all"
              />
              <div
                style={{ width: `${phonePct}%` }}
                className="bg-[#3B82F6] h-full transition-all"
              />
            </div>
            <div className="flex items-center justify-between text-xs font-bold mt-2">
              <span className="text-[#15803D]">
                واتساب: {whatsappPct}% ({leadBreakdown.whatsappClicks.toLocaleString("en-US")})
              </span>
              <span className="text-[#1D4ED8]">
                اتصال هاتفي: {phonePct}% ({leadBreakdown.phoneCalls.toLocaleString("en-US")})
              </span>
            </div>
          </div>

          <div className="pt-3 border-t border-slate-100">
            <div className="flex items-center gap-2 mb-3">
              <Leaf className="w-4 h-4 text-[#115E31]" />
              <h3 className="text-base font-bold text-[#111827]">
                أكثر أصناف القات طلباً
              </h3>
            </div>

            <div className="space-y-3">
              {isLoading ? (
                <div className="text-xs text-slate-400">جاري التحميل...</div>
              ) : (
                topVarieties.map((v) => (
                  <div key={v.name} className="space-y-1">
                    <div className="flex items-center justify-between text-xs font-bold">
                      <span className="text-slate-800">{v.name}</span>
                      <span className="text-[#115E31] tabular-nums">
                        {v.share}% ({v.listings.toLocaleString("en-US")} عرض)
                      </span>
                    </div>
                    <div className="h-2.5 rounded-full bg-[#F1F5F9] overflow-hidden">
                      <div
                        style={{ width: `${v.share}%` }}
                        className="h-full rounded-full bg-gradient-to-l from-[#2EA44F] to-[#115E31]"
                      />
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Row 3: Governorate Performance Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <div className="px-5 py-4 border-b border-slate-100 flex items-center gap-2">
          <MapPin className="w-4.5 h-4.5 text-[#115E31]" />
          <h3 className="text-base font-bold text-[#111827]">
            أداء المحافظات والأسواق النشطة
          </h3>
        </div>
        <table className="w-full min-w-[640px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3 px-5">المحافظة</th>
              <th className="py-3 px-4 text-center">المتاجر النشطة</th>
              <th className="py-3 px-4 text-center">نقرات التواصل (Leads)</th>
              <th className="py-3 px-5 text-center">نسبة المساهمة</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {governoratePerformance.map((gov) => {
              const totalGovLeads =
                governoratePerformance.reduce((s, g) => s + g.leads, 0) || 1;
              const sharePct = Math.round((gov.leads / totalGovLeads) * 100);
              return (
                <tr key={gov.name} className="hover:bg-[#F8FBF9]">
                  <td className="py-3.5 px-5 font-bold text-[#111827]">
                    {gov.name}
                  </td>
                  <td className="py-3.5 px-4 text-center font-bold text-slate-700 tabular-nums">
                    {gov.activeStores.toLocaleString("en-US")}
                  </td>
                  <td className="py-3.5 px-4 text-center font-extrabold text-[#115E31] tabular-nums">
                    {gov.leads.toLocaleString("en-US")}
                  </td>
                  <td className="py-3.5 px-5">
                    <div className="flex items-center justify-center gap-2">
                      <div className="w-28 h-2 rounded-full bg-slate-100 overflow-hidden">
                        <div
                          style={{ width: `${sharePct}%` }}
                          className="h-full bg-[#16A34A] rounded-full"
                        />
                      </div>
                      <span className="text-xs font-bold text-slate-600 tabular-nums">
                        {sharePct}%
                      </span>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};
