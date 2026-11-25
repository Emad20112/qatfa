import React, { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  CalendarCheck,
  CheckCircle2,
  ChevronDown,
  Clock,
  ListFilter,
  PackageCheck,
  RefreshCw,
  Search,
  TrendingUp,
  XCircle,
} from "lucide-react";
import { StockStatus } from "@qatfa/shared-types";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

export const BookingsPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  const { data: bookings = [], isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-bookings", search, statusFilter],
    queryFn: () => adminApi.getBookings({ search, status: statusFilter }),
  });

  const mutation = useMutation({
    mutationFn: ({
      id,
      payload,
    }: {
      id: string;
      payload: {
        bookingStatus?: "CONFIRMED" | "PENDING" | "COMPLETED" | "CANCELLED";
        stockStatus?: StockStatus;
      };
    }) => adminApi.updateBooking(id, payload),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-bookings"] });
      void queryClient.invalidateQueries({ queryKey: ["admin-dashboard"] });
    },
  });

  const renderBookingStatus = (status: string) => {
    if (status === "CONFIRMED") {
      return (
        <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#DCFCE7] text-[#15803D] text-xs font-bold">
          <CheckCircle2 className="w-3.5 h-3.5" />
          <span>مؤكد</span>
        </span>
      );
    }
    if (status === "PENDING") {
      return (
        <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#FEF3C7] text-[#D97706] text-xs font-bold">
          <Clock className="w-3.5 h-3.5" />
          <span>قيد الانتظار</span>
        </span>
      );
    }
    if (status === "COMPLETED") {
      return (
        <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#DBEAFE] text-[#1D4ED8] text-xs font-bold">
          <PackageCheck className="w-3.5 h-3.5" />
          <span>مكتمل</span>
        </span>
      );
    }
    return (
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#FEE2E2] text-[#DC2626] text-xs font-bold">
        <XCircle className="w-3.5 h-3.5" />
        <span>ملغي</span>
      </span>
    );
  };

  return (
    <div className="space-y-5">
      <div>
        <div className="flex items-center gap-2.5">
          <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
            <CalendarCheck className="w-5 h-5" />
          </span>
          <h1 className="text-2xl font-extrabold text-[#111827]">
            إدارة الحجوزات والقطفات اليومية
          </h1>
        </div>
        <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
          الرئيسية <span className="mx-1">‹</span> إدارة الحجوزات
        </div>
      </div>

      {/* 4 Sparkline KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={12476 + bookings.length}
          label="إجمالي الحجوزات"
          trendPercent={12}
          tone="mint"
          icon={<TrendingUp className="w-5 h-5" />}
        />
        <SparklineCard
          value={bookings.filter((b) => b.bookingStatus === "PENDING").length}
          label="بانتظار التأكيد"
          trendPercent={6}
          tone="amber"
          icon={<Clock className="w-5 h-5" />}
        />
        <SparklineCard
          value={
            bookings.filter(
              (b) =>
                b.bookingStatus === "CONFIRMED" ||
                b.bookingStatus === "COMPLETED",
            ).length
          }
          label="حجوزات مؤكدة ومكتملة"
          trendPercent={18}
          tone="blue"
          icon={<CheckCircle2 className="w-5 h-5" />}
        />
        <SparklineCard
          value={bookings.filter((b) => b.stockStatus === StockStatus.SOLD_OUT).length}
          label="عروض نفدت كميتها"
          trendPercent={4}
          tone="rose"
          icon={<XCircle className="w-5 h-5" />}
        />
      </div>

      {/* Filter Bar */}
      <div className="bg-white rounded-2xl p-3 border border-slate-100 shadow-[0_2px_10px_rgba(15,23,42,0.03)] flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="w-4 h-4 text-slate-400 absolute right-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="ابحث برقم الحجز، اسم القطفة، البائع، أو العميل..."
            className="w-full h-10 pr-10 pl-3 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-medium focus:outline-none focus:border-[#115E31]"
          />
        </div>

        <div className="relative min-w-[165px]">
          <ListFilter className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع الحالات</option>
            <option value="PENDING">قيد الانتظار</option>
            <option value="CONFIRMED">مؤكد</option>
            <option value="COMPLETED">مكتمل</option>
            <option value="CANCELLED">ملغي</option>
          </select>
          <ChevronDown className="w-3.5 h-3.5 text-slate-500 absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
        </div>

        <button
          type="button"
          onClick={() => void refetch()}
          className="h-10 px-5 rounded-full bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center gap-2 cursor-pointer"
        >
          <RefreshCw
            className={`w-3.5 h-3.5 ${isFetching ? "animate-spin" : ""}`}
          />
          <span>تحديث</span>
        </button>
      </div>

      {/* Bookings Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <table className="w-full min-w-[900px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3.5 px-5">#</th>
              <th className="py-3.5 px-4">القطفة والنوع</th>
              <th className="py-3.5 px-4">البائع والسوق</th>
              <th className="py-3.5 px-4">العميل</th>
              <th className="py-3.5 px-4 text-center">السعر</th>
              <th className="py-3.5 px-4 text-center">الحالة</th>
              <th className="py-3.5 px-5 text-center">إجراءات</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {isLoading ? (
              <tr>
                <td colSpan={7} className="py-12 text-center text-slate-400">
                  جاري التحميل...
                </td>
              </tr>
            ) : (
              bookings.map((b) => (
                <tr key={b.id} className="hover:bg-[#F8FBF9]">
                  <td className="py-3.5 px-5 font-bold text-slate-700 tabular-nums">
                    {b.bookingCode}
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="font-bold text-[#111827]">{b.title}</div>
                    <div className="text-xs text-slate-500">
                      {b.qatType} · {b.qualityGrade} · {b.createdAtLabel}
                    </div>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="text-xs font-bold text-slate-800">
                      {b.storeName}
                    </div>
                    <div className="text-[11px] text-slate-500">
                      {b.marketName}
                    </div>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="text-xs font-bold text-slate-800">
                      {b.customerName}
                    </div>
                    <div className="text-[11px] text-slate-500 tabular-nums" dir="ltr">
                      {b.customerPhone}
                    </div>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    <div className="text-sm font-extrabold text-[#115E31] tabular-nums">
                      {Number(b.price).toLocaleString("en-US")} ر.ي
                    </div>
                    <div className="text-[11px] text-slate-400">
                      {b.priceUnit} ({b.currency === "YER_NEW" ? "جديد" : "قديم"})
                    </div>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    {renderBookingStatus(b.bookingStatus)}
                  </td>
                  <td className="py-3.5 px-5">
                    <div className="flex items-center justify-center gap-1.5">
                      <button
                        type="button"
                        onClick={() =>
                          mutation.mutate({
                            id: b.id,
                            payload: { bookingStatus: "CONFIRMED" },
                          })
                        }
                        className="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 hover:bg-emerald-100 text-xs font-bold cursor-pointer"
                      >
                        تأكيد
                      </button>
                      <button
                        type="button"
                        onClick={() =>
                          mutation.mutate({
                            id: b.id,
                            payload: { bookingStatus: "COMPLETED" },
                          })
                        }
                        className="px-2.5 py-1 rounded-full bg-blue-50 text-blue-700 hover:bg-blue-100 text-xs font-bold cursor-pointer"
                      >
                        إتمام
                      </button>
                      <button
                        type="button"
                        onClick={() =>
                          mutation.mutate({
                            id: b.id,
                            payload: {
                              bookingStatus: "CANCELLED",
                              stockStatus: StockStatus.SOLD_OUT,
                            },
                          })
                        }
                        className="px-2.5 py-1 rounded-full bg-red-50 text-red-700 hover:bg-red-100 text-xs font-bold cursor-pointer"
                      >
                        إلغاء
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
