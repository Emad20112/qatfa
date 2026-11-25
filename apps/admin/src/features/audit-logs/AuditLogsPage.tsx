import React, { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import {
  CheckCircle2,
  ChevronDown,
  History,
  ListFilter,
  PlusCircle,
  RefreshCw,
  Search,
  ShieldAlert,
  ShieldCheck,
  XCircle,
} from "lucide-react";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

const BADGE_STYLE: Record<string, { label: string; cls: string }> = {
  APPROVE: {
    label: "اعتماد",
    cls: "bg-[#DCFCE7] text-[#15803D]",
  },
  REJECT: {
    label: "رفض",
    cls: "bg-[#FEE2E2] text-[#DC2626]",
  },
  UPDATE: {
    label: "تحديث",
    cls: "bg-[#DBEAFE] text-[#1D4ED8]",
  },
  CREATE: {
    label: "إنشاء",
    cls: "bg-[#E6F6EC] text-[#115E31]",
  },
  MODERATION: {
    label: "إجراء رقابي",
    cls: "bg-[#FEF3C7] text-[#D97706]",
  },
  SECURITY: {
    label: "أمان",
    cls: "bg-slate-800 text-white",
  },
};

export const AuditLogsPage: React.FC = () => {
  const [search, setSearch] = useState("");
  const [badgeFilter, setBadgeFilter] = useState("ALL");

  const { data: logs = [], isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-audit-logs", search, badgeFilter],
    queryFn: () => adminApi.getAuditLogs({ search, badge: badgeFilter }),
  });

  const approveCount = logs.filter((l) => l.actionBadge === "APPROVE").length;
  const modCount = logs.filter((l) => l.actionBadge === "MODERATION").length;
  const securityCount = logs.filter((l) => l.actionBadge === "SECURITY").length;

  return (
    <div className="space-y-5">
      <div>
        <div className="flex items-center gap-2.5">
          <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
            <History className="w-5 h-5" />
          </span>
          <h1 className="text-2xl font-extrabold text-[#111827]">
            سجل العمليات
          </h1>
        </div>
        <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
          الرئيسية <span className="mx-1">‹</span> سجل العمليات
        </div>
      </div>

      {/* 4 KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={logs.length}
          label="إجمالي العمليات المسجلة"
          trendPercent={16}
          tone="mint"
          icon={<History className="w-5 h-5" />}
        />
        <SparklineCard
          value={approveCount}
          label="عمليات الاعتماد والتوثيق"
          trendPercent={12}
          tone="blue"
          icon={<CheckCircle2 className="w-5 h-5" />}
        />
        <SparklineCard
          value={modCount}
          label="إجراءات الرقابة والبلاغات"
          trendPercent={5}
          tone="amber"
          icon={<ShieldAlert className="w-5 h-5" />}
        />
        <SparklineCard
          value={securityCount}
          label="أحداث الأمان والصلاحيات"
          trendPercent={4}
          tone="rose"
          icon={<ShieldCheck className="w-5 h-5" />}
        />
      </div>

      {/* Filter Bar */}
      <div className="bg-white rounded-2xl p-3 border border-slate-100 shadow-[0_2px_10px_rgba(15,23,42,0.03)] flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[230px]">
          <Search className="w-4 h-4 text-slate-400 absolute right-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="ابحث باسم المشرف أو نوع العملية أو الهدف..."
            className="w-full h-10 pr-10 pl-3 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-medium focus:outline-none focus:border-[#115E31]"
          />
        </div>

        <div className="relative min-w-[175px]">
          <ListFilter className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={badgeFilter}
            onChange={(e) => setBadgeFilter(e.target.value)}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع التصنيفات</option>
            <option value="APPROVE">اعتماد</option>
            <option value="REJECT">رفض</option>
            <option value="MODERATION">إجراء رقابي</option>
            <option value="UPDATE">تحديث</option>
            <option value="CREATE">إنشاء</option>
            <option value="SECURITY">أمان</option>
          </select>
          <ChevronDown className="w-3.5 h-3.5 text-slate-500 absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
        </div>

        <button
          type="button"
          onClick={() => void refetch()}
          className="h-10 px-5 rounded-full bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center gap-2 transition-colors cursor-pointer"
        >
          <RefreshCw
            className={`w-3.5 h-3.5 ${isFetching ? "animate-spin" : ""}`}
          />
          <span>تحديث</span>
        </button>
      </div>

      {/* Audit Log Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <table className="w-full min-w-[860px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3.5 px-5">المسؤول</th>
              <th className="py-3.5 px-4">الإجراء المنفذ</th>
              <th className="py-3.5 px-4 text-center">التصنيف</th>
              <th className="py-3.5 px-4">الجهة المستهدفة</th>
              <th className="py-3.5 px-4 text-center">عنوان IP</th>
              <th className="py-3.5 px-5 text-center">الوقت والتاريخ</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {isLoading ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-400">
                  جاري تحميل سجل العمليات...
                </td>
              </tr>
            ) : logs.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-500">
                  لا توجد عمليات مسجلة مطابقة للبحث
                </td>
              </tr>
            ) : (
              logs.map((log) => {
                const badge = BADGE_STYLE[log.actionBadge] || {
                  label: log.actionBadge,
                  cls: "bg-slate-100 text-slate-700",
                };
                return (
                  <tr
                    key={log.id}
                    className="hover:bg-[#F8FBF9] transition-colors"
                  >
                    <td className="py-3.5 px-5 font-bold text-[#111827]">
                      {log.adminName}
                    </td>
                    <td className="py-3.5 px-4">
                      <div className="font-bold text-slate-800 text-xs">
                        {log.action}
                      </div>
                      <div className="text-[11px] text-slate-400 mt-0.5">
                        {log.details}
                      </div>
                    </td>
                    <td className="py-3.5 px-4 text-center">
                      <span
                        className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-[11px] font-bold ${badge.cls}`}
                      >
                        {log.actionBadge === "CREATE" && (
                          <PlusCircle className="w-3 h-3" />
                        )}
                        {log.actionBadge === "REJECT" && (
                          <XCircle className="w-3 h-3" />
                        )}
                        <span>{badge.label}</span>
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-xs font-semibold text-slate-700">
                      {log.target}
                    </td>
                    <td
                      className="py-3.5 px-4 text-center text-xs font-mono text-slate-500"
                      dir="ltr"
                    >
                      {log.ipAddress}
                    </td>
                    <td className="py-3.5 px-5 text-center text-xs font-semibold text-slate-600 tabular-nums">
                      {log.timestamp}
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
