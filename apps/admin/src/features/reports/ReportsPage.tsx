import React, { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  AlertTriangle,
  Ban,
  Bell,
  CheckCircle2,
  ChevronDown,
  Clock,
  EyeOff,
  ListFilter,
  MessageSquareWarning,
  RefreshCw,
  Search,
  ShieldAlert,
  ShieldCheck,
  Store,
  UserX,
  X,
  XCircle,
} from "lucide-react";
import { adminApi, AdminReportItem } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

type ModerationAction =
  | "START_REVIEW"
  | "HIDE_OFFER"
  | "WARN_SELLER"
  | "BAN_SELLER"
  | "DISMISS"
  | "RESOLVE";

export const ReportsPage: React.FC = () => {
  const queryClient = useQueryClient();

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [selectedReport, setSelectedReport] = useState<AdminReportItem | null>(
    null,
  );
  const [notes, setNotes] = useState("");

  const { data: reports = [], isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-reports", search, statusFilter],
    queryFn: () => adminApi.getReports({ search, status: statusFilter }),
  });

  const mutation = useMutation({
    mutationFn: ({
      id,
      action,
      notes: actionNotes,
    }: {
      id: string;
      action: ModerationAction;
      notes?: string;
    }) => adminApi.moderateReport(id, { action, notes: actionNotes }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-reports"] });
      void queryClient.invalidateQueries({ queryKey: ["admin-dashboard"] });
      setSelectedReport(null);
      setNotes("");
    },
  });

  const openCount = reports.filter((r) => r.status === "OPEN").length;
  const inProgressCount = reports.filter(
    (r) => r.status === "IN_PROGRESS",
  ).length;
  const closedCount = reports.filter((r) => r.status === "CLOSED").length;

  const renderStatusPill = (status: AdminReportItem["status"]) => {
    if (status === "OPEN") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#FEE2E2] text-[#DC2626] text-xs font-bold whitespace-nowrap">
          <AlertTriangle className="w-3.5 h-3.5" />
          <span>مفتوح</span>
        </span>
      );
    }
    if (status === "IN_PROGRESS") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#FEF3C7] text-[#D97706] text-xs font-bold whitespace-nowrap">
          <Clock className="w-3.5 h-3.5" />
          <span>قيد المعالجة</span>
        </span>
      );
    }
    return (
      <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#DCFCE7] text-[#15803D] text-xs font-bold whitespace-nowrap">
        <CheckCircle2 className="w-3.5 h-3.5" />
        <span>مغلق</span>
      </span>
    );
  };

  const renderTargetBadge = (targetType: AdminReportItem["targetType"]) => {
    if (targetType === "PRODUCT") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F1FAF4] border border-[#CDEBD7] text-[#115E31] text-xs font-bold whitespace-nowrap">
          <MessageSquareWarning className="w-3.5 h-3.5" />
          <span>عرض / منتج</span>
        </span>
      );
    }
    if (targetType === "STORE") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#EFF5FF] border border-[#BFDBFE] text-[#1D4ED8] text-xs font-bold whitespace-nowrap">
          <Store className="w-3.5 h-3.5" />
          <span>متجر / مفرش</span>
        </span>
      );
    }
    return (
      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-100 border border-slate-200 text-slate-700 text-xs font-bold whitespace-nowrap">
        <Bell className="w-3.5 h-3.5" />
        <span>ملاحظة نظام</span>
      </span>
    );
  };

  return (
    <div className="space-y-5">
      {/* Header + Breadcrumb */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2.5">
            <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
              <Bell className="w-5 h-5" />
            </span>
            <h1 className="text-2xl font-extrabold text-[#111827]">
              الشكاوى والبلاغات
            </h1>
          </div>
          <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
            الرئيسية <span className="mx-1">‹</span> الشكاوى والبلاغات
          </div>
        </div>

        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-bold">
          <ShieldCheck className="w-4 h-4" />
          <span>المراجعة البشرية إلزامية — لا يوجد حظر تلقائي</span>
        </div>
      </div>

      {/* 4 Sparkline KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={315 + reports.length}
          label="إجمالي البلاغات"
          trendPercent={6}
          tone="mint"
          icon={<Bell className="w-5 h-5" />}
        />
        <SparklineCard
          value={openCount}
          label="بلاغات مفتوحة بانتظار الفحص"
          trendPercent={14}
          tone="rose"
          icon={<AlertTriangle className="w-5 h-5" />}
        />
        <SparklineCard
          value={inProgressCount}
          label="قيد المعالجة والتحقق"
          trendPercent={9}
          tone="amber"
          icon={<Clock className="w-5 h-5" />}
        />
        <SparklineCard
          value={312 + closedCount}
          label="بلاغات مغلقة ومعالجة"
          trendPercent={18}
          tone="blue"
          icon={<CheckCircle2 className="w-5 h-5" />}
        />
      </div>

      {/* Filter Toolbar */}
      <div className="bg-white rounded-2xl p-3 border border-slate-100 shadow-[0_2px_10px_rgba(15,23,42,0.03)] flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute right-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="ابحث بعنوان البلاغ أو اسم المبلغ أو المتجر..."
            className="w-full h-10 pr-10 pl-3 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-medium focus:outline-none focus:border-[#115E31]"
          />
        </div>

        <div className="relative min-w-[170px]">
          <ListFilter className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع الحالات</option>
            <option value="OPEN">مفتوح</option>
            <option value="IN_PROGRESS">قيد المعالجة</option>
            <option value="CLOSED">مغلق</option>
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

      {/* Reports Queue Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <table className="w-full min-w-[900px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3.5 px-5">البلاغ والتفاصيل</th>
              <th className="py-3.5 px-4 text-center">الجهة المستهدفة</th>
              <th className="py-3.5 px-4 text-center">المُبلِّغون</th>
              <th className="py-3.5 px-4 text-center">الحالة</th>
              <th className="py-3.5 px-4 text-center">التوقيت</th>
              <th className="py-3.5 px-5 text-center">إجراءات المعالجة</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {isLoading ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-400">
                  جاري تحميل طابور البلاغات...
                </td>
              </tr>
            ) : reports.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-500">
                  لا توجد شكاوى أو بلاغات مطابقة للبحث
                </td>
              </tr>
            ) : (
              reports.map((report) => (
                <tr
                  key={report.id}
                  className="hover:bg-[#F8FBF9] transition-colors"
                >
                  <td className="py-3.5 px-5">
                    <div className="font-bold text-[#111827]">
                      {report.title}
                    </div>
                    <div className="text-xs text-slate-500 mt-0.5">
                      الهدف: <span className="font-semibold">{report.targetName}</span>{" "}
                      · السبب: {report.reason}
                    </div>
                    {report.actionTaken && (
                      <div className="text-[11px] font-bold text-[#15803D] mt-1">
                        القرار المتخذ: {report.actionTaken}
                      </div>
                    )}
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    {renderTargetBadge(report.targetType)}
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    <div className="text-xs font-bold text-slate-700">
                      {report.reporterName}
                    </div>
                    <div className="text-[11px] text-slate-400 mt-0.5 tabular-nums">
                      {report.uniqueReporters} مبلّغ فريد
                    </div>
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    {renderStatusPill(report.status)}
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    <div className="text-xs font-bold text-slate-700">
                      {report.createdAt}
                    </div>
                    <div className="text-[11px] text-slate-400 mt-0.5">
                      {report.relativeTime}
                    </div>
                  </td>

                  <td className="py-3.5 px-5">
                    <div className="flex items-center justify-center gap-2">
                      {report.status === "OPEN" && (
                        <button
                          type="button"
                          onClick={() =>
                            mutation.mutate({
                              id: report.id,
                              action: "START_REVIEW",
                            })
                          }
                          className="px-3 py-1.5 rounded-full bg-[#FEF3C7] text-[#D97706] hover:bg-amber-200 text-xs font-bold cursor-pointer whitespace-nowrap"
                        >
                          بدء الفحص
                        </button>
                      )}
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedReport(report);
                          setNotes(report.notes || "");
                        }}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-bold hover:bg-[#E1F5E8] cursor-pointer whitespace-nowrap"
                      >
                        <ShieldAlert className="w-3.5 h-3.5" />
                        <span>مراجعة واتخاذ قرار</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Human Moderation Decision Modal */}
      {selectedReport && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-2xl p-6 shadow-2xl border border-slate-100 space-y-5">
            <div className="flex items-start justify-between gap-4">
              <div>
                <div className="flex items-center gap-2">
                  {renderTargetBadge(selectedReport.targetType)}
                  {renderStatusPill(selectedReport.status)}
                </div>
                <h3 className="text-lg font-extrabold text-[#111827] mt-2">
                  {selectedReport.title}
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  المستهدف: {selectedReport.targetName} · المبلّغ:{" "}
                  {selectedReport.reporterName} ({selectedReport.reporterPhone})
                </p>
              </div>
              <button
                type="button"
                onClick={() => setSelectedReport(null)}
                className="w-9 h-9 rounded-xl bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-600 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 bg-[#F8FAFC] p-4 rounded-2xl border border-slate-100 text-xs">
              <div>
                <span className="text-slate-400 font-semibold">تصنيف البلاغ:</span>
                <div className="font-bold text-slate-800 mt-0.5">
                  {selectedReport.reason}
                </div>
              </div>
              <div>
                <span className="text-slate-400 font-semibold">عدد المبلّغين الفريدين:</span>
                <div className="font-bold text-slate-800 mt-0.5 tabular-nums">
                  {selectedReport.uniqueReporters} مستخدمين
                </div>
              </div>
              <div>
                <span className="text-slate-400 font-semibold">تاريخ البلاغ:</span>
                <div className="font-bold text-slate-800 mt-0.5">
                  {selectedReport.createdAt} ({selectedReport.relativeTime})
                </div>
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                ملاحظات المراقب وتفاصيل التحقق اليدوي
              </label>
              <textarea
                rows={3}
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                className="w-full rounded-xl bg-[#F8FAFC] border border-slate-200 p-3 text-xs focus:outline-none focus:border-[#115E31]"
                placeholder="وثّق نتيجة التواصل أو التحقق قبل اتخاذ القرار..."
              />
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2.5 pt-2 border-t border-slate-100">
              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedReport.id,
                    action: "HIDE_OFFER",
                    notes,
                  })
                }
                className="px-3 py-2.5 rounded-xl bg-amber-50 hover:bg-amber-100 text-amber-800 text-xs font-bold inline-flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <EyeOff className="w-3.5 h-3.5" />
                <span>إخفاء العرض المضلل</span>
              </button>

              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedReport.id,
                    action: "WARN_SELLER",
                    notes,
                  })
                }
                className="px-3 py-2.5 rounded-xl bg-orange-50 hover:bg-orange-100 text-orange-700 text-xs font-bold inline-flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <AlertTriangle className="w-3.5 h-3.5" />
                <span>إنذار وسحب الشارة</span>
              </button>

              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedReport.id,
                    action: "BAN_SELLER",
                    notes,
                  })
                }
                className="px-3 py-2.5 rounded-xl bg-red-50 hover:bg-red-100 text-red-700 text-xs font-bold inline-flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <UserX className="w-3.5 h-3.5" />
                <span>تجميد المتجر يدوياً</span>
              </button>

              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedReport.id,
                    action: "DISMISS",
                    notes,
                  })
                }
                className="px-3 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold inline-flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <XCircle className="w-3.5 h-3.5" />
                <span>رفض البلاغ (كيدي)</span>
              </button>

              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedReport.id,
                    action: "START_REVIEW",
                    notes,
                  })
                }
                className="px-3 py-2.5 rounded-xl bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-bold inline-flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <Clock className="w-3.5 h-3.5" />
                <span>إبقاء قيد المعالجة</span>
              </button>

              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedReport.id,
                    action: "RESOLVE",
                    notes,
                  })
                }
                className="px-3 py-2.5 rounded-xl bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>حل وإغلاق البلاغ</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
