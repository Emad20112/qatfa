import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Calendar,
  Check,
  CheckCircle2,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  Clock,
  Eye,
  LayoutGrid,
  ListFilter,
  MoreVertical,
  RefreshCw,
  RotateCcw,
  Search,
  ShieldCheck,
  Store,
  Users,
  X,
  XCircle,
} from "lucide-react";
import { adminApi, VerificationItem } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

export const VerificationsPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const queryClient = useQueryClient();

  const [search, setSearch] = useState(searchParams.get("search") || "");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [typeFilter, setTypeFilter] = useState("ALL");
  const [dateFilter, setDateFilter] = useState("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(5);
  const [selectedItem, setSelectedItem] = useState<VerificationItem | null>(
    null,
  );
  const [reviewNotes, setReviewNotes] = useState("");
  const [openMenuId, setOpenMenuId] = useState<string | null>(null);

  useEffect(() => {
    const q = searchParams.get("search");
    if (q) setSearch(q);
  }, [searchParams]);

  const { data, isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-verifications", search, statusFilter, typeFilter, page, limit],
    queryFn: () =>
      adminApi.getVerifications({
        search,
        status: statusFilter,
        type: typeFilter,
        page,
        limit,
      }),
  });

  const mutation = useMutation({
    mutationFn: ({
      id,
      action,
      notes,
    }: {
      id: string;
      action: "APPROVE" | "REJECT" | "RE_REVIEW" | "REQUEST_INFO";
      notes?: string;
    }) => adminApi.updateVerification(id, { action, notes }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-verifications"] });
      void queryClient.invalidateQueries({ queryKey: ["admin-dashboard"] });
      setSelectedItem(null);
      setReviewNotes("");
      setOpenMenuId(null);
    },
  });

  const items = data?.data || [];
  const summary = data?.summary || {
    total: 248,
    pending: 86,
    approved: 142,
    rejected: 20,
    exactTotal: items.length,
  };
  const meta = data?.meta || { page: 1, limit: 5, totalItems: 8, totalPages: 2 };

  const renderStatusPill = (status: VerificationItem["status"]) => {
    if (status === "PENDING_AMBER") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#FEF3C7] text-[#D97706] text-xs font-bold whitespace-nowrap">
          <Clock className="w-3.5 h-3.5" />
          <span>قيد المراجعة</span>
        </span>
      );
    }
    if (status === "PENDING_BLUE") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#DBEAFE] text-[#1D4ED8] text-xs font-bold whitespace-nowrap">
          <Clock className="w-3.5 h-3.5" />
          <span>قيد المراجعة</span>
        </span>
      );
    }
    if (status === "APPROVED") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#DCFCE7] text-[#15803D] text-xs font-bold whitespace-nowrap">
          <CheckCircle2 className="w-3.5 h-3.5" />
          <span>تم الاعتماد</span>
        </span>
      );
    }
    return (
      <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#FEE2E2] text-[#DC2626] text-xs font-bold whitespace-nowrap">
        <XCircle className="w-3.5 h-3.5" />
        <span>مرفوض</span>
      </span>
    );
  };

  return (
    <div className="space-y-5">
      {/* Page Title + Breadcrumb */}
      <div className="flex items-center justify-between">
        <div>
          <div className="flex items-center gap-2.5">
            <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
              <ShieldCheck className="w-5 h-5" />
            </span>
            <h1 className="text-2xl font-extrabold text-[#111827]">
              طلبات التوثيق
            </h1>
          </div>
          <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
            الرئيسية <span className="mx-1">‹</span> طلبات التوثيق
          </div>
        </div>
      </div>

      {/* Row 1: 4 Mini Pastel Sparkline KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={summary.total}
          label="إجمالي الطلبات"
          trendPercent={12}
          tone="mint"
          icon={<Users className="w-5 h-5" />}
          points={[18, 25, 22, 34, 29, 39, 44]}
        />
        <SparklineCard
          value={summary.pending}
          label="قيد المراجعة"
          trendPercent={8}
          tone="blue"
          icon={<Clock className="w-5 h-5" />}
          points={[14, 20, 24, 19, 31, 28, 34]}
        />
        <SparklineCard
          value={summary.approved}
          label="تم الاعتماد"
          trendPercent={15}
          tone="amber"
          icon={<CheckCircle2 className="w-5 h-5" />}
          points={[12, 19, 23, 27, 31, 38, 45]}
        />
        <SparklineCard
          value={summary.rejected}
          label="مرفوضة"
          trendPercent={5}
          tone="rose"
          icon={<XCircle className="w-5 h-5" />}
          points={[8, 12, 10, 16, 13, 19, 17]}
        />
      </div>

      {/* Row 2: Filter & Search Toolbar */}
      <div className="bg-white rounded-2xl p-3 border border-slate-100 shadow-[0_2px_10px_rgba(15,23,42,0.03)] flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="w-4 h-4 text-slate-400 absolute right-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            placeholder="ابحث باسم التاجر أو رقم الطلب..."
            className="w-full h-10 pr-10 pl-3 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-medium focus:outline-none focus:border-[#115E31]"
          />
        </div>

        <div className="relative min-w-[180px]">
          <Calendar className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <input
            type="text"
            value={dateFilter}
            onChange={(e) => setDateFilter(e.target.value)}
            placeholder="من تاريخ ... إلى تاريخ ..."
            className="w-full h-10 pr-10 pl-3 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-medium focus:outline-none focus:border-[#115E31]"
          />
        </div>

        <div className="relative min-w-[155px]">
          <ListFilter className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value);
              setPage(1);
            }}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع الحالات</option>
            <option value="PENDING">قيد المراجعة</option>
            <option value="APPROVED">تم الاعتماد</option>
            <option value="REJECTED">مرفوض</option>
          </select>
          <ChevronDown className="w-3.5 h-3.5 text-slate-500 absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
        </div>

        <div className="relative min-w-[155px]">
          <LayoutGrid className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={typeFilter}
            onChange={(e) => {
              setTypeFilter(e.target.value);
              setPage(1);
            }}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع الأنواع</option>
            <option value="توثيق تاجر">توثيق تاجر</option>
            <option value="توثيق سوق">توثيق سوق</option>
          </select>
          <ChevronDown className="w-3.5 h-3.5 text-slate-500 absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
        </div>

        <button
          type="button"
          onClick={() => void refetch()}
          className="h-10 px-5 rounded-full bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center gap-2 transition-colors cursor-pointer shrink-0"
        >
          <RefreshCw
            className={`w-3.5 h-3.5 ${isFetching ? "animate-spin" : ""}`}
          />
          <span>تحديث</span>
        </button>
      </div>

      {/* Row 3: Data Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <table className="w-full min-w-[860px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3.5 px-5">#</th>
              <th className="py-3.5 px-4">معلومات الطلب</th>
              <th className="py-3.5 px-4 text-center">نوع الطلب</th>
              <th className="py-3.5 px-4 text-center">الحالة</th>
              <th className="py-3.5 px-4 text-center">تاريخ التقديم</th>
              <th className="py-3.5 px-5 text-center">إجراءات</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {isLoading ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-400">
                  جاري تحميل طلبات التوثيق...
                </td>
              </tr>
            ) : items.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-500">
                  لا توجد طلبات مطابقة لخيارات البحث الحالية
                </td>
              </tr>
            ) : (
              items.map((item) => (
                <tr
                  key={item.id}
                  className="hover:bg-[#F8FBF9] transition-colors"
                >
                  <td className="py-3.5 px-5 font-bold text-slate-700 tabular-nums whitespace-nowrap">
                    {item.requestNumber}
                  </td>

                  <td className="py-3.5 px-4">
                    <div className="flex items-center gap-3">
                      <img
                        src={item.thumbnail}
                        alt={item.entityName}
                        referrerPolicy="no-referrer"
                        className="w-11 h-11 rounded-full object-cover border border-slate-200 shrink-0"
                      />
                      <div>
                        <div className="font-bold text-[#111827] text-sm">
                          {item.entityName}
                        </div>
                        <div className="text-xs text-slate-500 mt-0.5">
                          {item.locationLabel}
                        </div>
                      </div>
                    </div>
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F1FAF4] border border-[#CDEBD7] text-[#115E31] text-xs font-bold whitespace-nowrap">
                      <Store className="w-3.5 h-3.5" />
                      <span>{item.requestType}</span>
                    </span>
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    {renderStatusPill(item.status)}
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    <div className="text-xs font-bold text-slate-700">
                      {item.submittedDate}
                    </div>
                    <div className="text-[11px] text-slate-400 mt-0.5">
                      {item.relativeTime}
                    </div>
                  </td>

                  <td className="py-3.5 px-5">
                    <div className="flex items-center justify-center gap-2">
                      <div className="relative">
                        <button
                          type="button"
                          onClick={() =>
                            setOpenMenuId(
                              openMenuId === item.id ? null : item.id,
                            )
                          }
                          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-500 cursor-pointer"
                          title="المزيد"
                        >
                          <MoreVertical className="w-4 h-4" />
                        </button>
                        {openMenuId === item.id && (
                          <div className="absolute left-0 mt-1 w-44 bg-white rounded-xl shadow-lg border border-slate-100 p-1.5 z-30 text-right">
                            <button
                              type="button"
                              onClick={() =>
                                mutation.mutate({
                                  id: item.id,
                                  action: "REQUEST_INFO",
                                })
                              }
                              className="w-full px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-50 rounded-lg cursor-pointer"
                            >
                              طلب استيفاء بيانات
                            </button>
                            <button
                              type="button"
                              onClick={() =>
                                mutation.mutate({
                                  id: item.id,
                                  action: "RE_REVIEW",
                                })
                              }
                              className="w-full px-3 py-1.5 text-xs font-semibold text-amber-700 hover:bg-amber-50 rounded-lg cursor-pointer"
                            >
                              إعادة للمراجعة
                            </button>
                          </div>
                        )}
                      </div>

                      {item.status === "REJECTED" ? (
                        <>
                          <button
                            type="button"
                            onClick={() =>
                              mutation.mutate({
                                id: item.id,
                                action: "REJECT",
                              })
                            }
                            className="w-7 h-7 rounded-full bg-[#FEE2E2] text-[#DC2626] flex items-center justify-center hover:bg-red-200 cursor-pointer"
                            title="تأكيد الرفض"
                          >
                            <X className="w-3.5 h-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() =>
                              mutation.mutate({
                                id: item.id,
                                action: "RE_REVIEW",
                              })
                            }
                            className="w-7 h-7 rounded-full bg-[#FEF3C7] text-[#D97706] flex items-center justify-center hover:bg-amber-200 cursor-pointer"
                            title="إعادة المراجعة"
                          >
                            <RotateCcw className="w-3.5 h-3.5" />
                          </button>
                        </>
                      ) : item.status === "APPROVED" ? (
                        <button
                          type="button"
                          onClick={() => {
                            setSelectedItem(item);
                            setReviewNotes(item.notes);
                          }}
                          className="w-7 h-7 rounded-full bg-slate-100 text-slate-500 flex items-center justify-center hover:bg-slate-200 cursor-pointer"
                          title="معاينة"
                        >
                          <Eye className="w-3.5 h-3.5" />
                        </button>
                      ) : (
                        <>
                          <button
                            type="button"
                            onClick={() =>
                              mutation.mutate({
                                id: item.id,
                                action: "REJECT",
                              })
                            }
                            className="w-7 h-7 rounded-full bg-[#FEE2E2] text-[#DC2626] flex items-center justify-center hover:bg-red-200 cursor-pointer"
                            title="رفض الطلب"
                          >
                            <X className="w-3.5 h-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() =>
                              mutation.mutate({
                                id: item.id,
                                action: "APPROVE",
                              })
                            }
                            className="w-7 h-7 rounded-full bg-[#DCFCE7] text-[#15803D] flex items-center justify-center hover:bg-emerald-200 cursor-pointer"
                            title="اعتماد فوري"
                          >
                            <Check className="w-3.5 h-3.5" />
                          </button>
                        </>
                      )}

                      <span className="h-5 w-px bg-slate-200 mx-0.5" />

                      <button
                        type="button"
                        onClick={() => {
                          setSelectedItem(item);
                          setReviewNotes(item.notes);
                        }}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-bold hover:bg-[#E1F5E8] transition-colors cursor-pointer whitespace-nowrap"
                      >
                        <ChevronDown className="w-3.5 h-3.5" />
                        <span>عرض التفاصيل</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination Footer */}
      <div className="flex flex-wrap items-center justify-between gap-4 text-xs font-semibold text-slate-600 pt-1">
        <div className="flex items-center gap-2">
          <span>عدد العناصر في الصفحة:</span>
          <select
            value={limit}
            onChange={(e) => {
              setLimit(parseInt(e.target.value, 10));
              setPage(1);
            }}
            className="h-8 px-2.5 rounded-lg bg-white border border-slate-200 font-bold text-slate-700 cursor-pointer"
          >
            <option value={5}>5</option>
            <option value={10}>10</option>
            <option value={20}>20</option>
          </select>
        </div>

        <div className="flex items-center gap-1.5">
          <button
            type="button"
            disabled={page <= 1}
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            className="w-8 h-8 rounded-lg bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-50 disabled:opacity-40 cursor-pointer"
          >
            <ChevronRight className="w-4 h-4" />
          </button>

          {Array.from({ length: Math.max(1, meta.totalPages) }).map((_, i) => {
            const p = i + 1;
            return (
              <button
                key={p}
                type="button"
                onClick={() => setPage(p)}
                className={`w-8 h-8 rounded-lg text-xs font-bold tabular-nums cursor-pointer transition-colors ${
                  page === p
                    ? "bg-[#0C5A2C] text-white"
                    : "bg-white border border-slate-200 text-slate-700 hover:bg-slate-50"
                }`}
              >
                {p}
              </button>
            );
          })}

          <button
            type="button"
            disabled={page >= meta.totalPages}
            onClick={() => setPage((p) => Math.min(meta.totalPages, p + 1))}
            className="w-8 h-8 rounded-lg bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-50 disabled:opacity-40 cursor-pointer"
          >
            <ChevronLeft className="w-4 h-4" />
          </button>
        </div>

        <div className="tabular-nums">
          إظهار {(meta.page - 1) * meta.limit + (items.length ? 1 : 0)} -{" "}
          {(meta.page - 1) * meta.limit + items.length} من أصل{" "}
          {summary.total} طلب
        </div>
      </div>

      {/* Verification Detail & Decision Modal */}
      {selectedItem && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-xl p-6 shadow-2xl border border-slate-100 space-y-5">
            <div className="flex items-start justify-between gap-4">
              <div className="flex items-center gap-3.5">
                <img
                  src={selectedItem.thumbnail}
                  alt={selectedItem.entityName}
                  referrerPolicy="no-referrer"
                  className="w-14 h-14 rounded-2xl object-cover border border-slate-200"
                />
                <div>
                  <div className="text-xs font-bold text-[#15803D] tabular-nums">
                    {selectedItem.requestNumber} · {selectedItem.requestType}
                  </div>
                  <h3 className="text-lg font-extrabold text-[#111827] mt-0.5">
                    {selectedItem.entityName}
                  </h3>
                  <p className="text-xs text-slate-500">
                    {selectedItem.locationLabel}
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setSelectedItem(null)}
                className="w-9 h-9 rounded-xl bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-600 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3 bg-[#F8FAFC] p-4 rounded-2xl border border-slate-100 text-xs">
              <div>
                <span className="text-slate-400 font-semibold">مقدم الطلب:</span>
                <div className="font-bold text-slate-800 mt-0.5">
                  {selectedItem.ownerName}
                </div>
              </div>
              <div>
                <span className="text-slate-400 font-semibold">رقم الهاتف الموثق:</span>
                <div className="font-bold text-slate-800 mt-0.5 tabular-nums" dir="ltr">
                  {selectedItem.phoneNumber}
                </div>
              </div>
              <div>
                <span className="text-slate-400 font-semibold">رقم المفرش / المعلم:</span>
                <div className="font-bold text-slate-800 mt-0.5">
                  {selectedItem.stallNumber}
                </div>
              </div>
              <div>
                <span className="text-slate-400 font-semibold">تاريخ التقديم:</span>
                <div className="font-bold text-slate-800 mt-0.5">
                  {selectedItem.submittedDate} ({selectedItem.relativeTime})
                </div>
              </div>
            </div>

            <div>
              <div className="text-xs font-bold text-slate-700 mb-2">
                المرفقات والمستندات المتوفرة:
              </div>
              <div className="flex flex-wrap gap-2">
                {selectedItem.documents.map((doc) => (
                  <span
                    key={doc}
                    className="px-3 py-1 rounded-xl bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-semibold"
                  >
                    {doc}
                  </span>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                ملاحظات المراجع / سبب القرار
              </label>
              <textarea
                rows={3}
                value={reviewNotes}
                onChange={(e) => setReviewNotes(e.target.value)}
                className="w-full rounded-xl bg-[#F8FAFC] border border-slate-200 p-3 text-xs focus:outline-none focus:border-[#115E31]"
                placeholder="أضف ملاحظة توضيحية لصاحب الطلب..."
              />
            </div>

            <div className="flex flex-wrap items-center justify-end gap-2.5 pt-2 border-t border-slate-100">
              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedItem.id,
                    action: "REQUEST_INFO",
                    notes: reviewNotes,
                  })
                }
                className="px-4 py-2 rounded-xl bg-blue-50 text-blue-700 hover:bg-blue-100 text-xs font-bold cursor-pointer"
              >
                طلب استيفاء بيانات
              </button>
              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedItem.id,
                    action: "REJECT",
                    notes: reviewNotes,
                  })
                }
                className="px-4 py-2 rounded-xl bg-red-50 text-red-700 hover:bg-red-100 text-xs font-bold cursor-pointer"
              >
                رفض الطلب
              </button>
              <button
                type="button"
                disabled={mutation.isPending}
                onClick={() =>
                  mutation.mutate({
                    id: selectedItem.id,
                    action: "APPROVE",
                    notes: reviewNotes,
                  })
                }
                className="px-5 py-2 rounded-xl bg-[#0C5A2C] text-white hover:bg-[#094722] text-xs font-bold cursor-pointer"
              >
                اعتماد ومنح التوثيق
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
