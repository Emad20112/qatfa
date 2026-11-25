import React, { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  CheckCircle2,
  ChevronDown,
  Eye,
  MapPin,
  RefreshCw,
  Search,
  ShieldCheck,
  Star,
  Store,
  X,
  XCircle,
} from "lucide-react";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

export const SellersPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState("");
  const [verifiedFilter, setVerifiedFilter] = useState("ALL");
  const [selectedStore, setSelectedStore] = useState<any | null>(null);
  const [stallNumber, setStallNumber] = useState("");
  const [stallLandmark, setStallLandmark] = useState("");

  const { data: stores = [], isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-sellers", search, verifiedFilter],
    queryFn: () =>
      adminApi.getSellers({ search, verified: verifiedFilter }),
  });

  const mutation = useMutation({
    mutationFn: ({
      id,
      payload,
    }: {
      id: string;
      payload: {
        isVerifiedBadge?: boolean;
        isOpenNow?: boolean;
        stallNumber?: string;
        stallLandmark?: string;
      };
    }) => adminApi.updateSeller(id, payload),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-sellers"] });
      void queryClient.invalidateQueries({ queryKey: ["admin-dashboard"] });
      setSelectedStore(null);
    },
  });

  const verifiedCount = stores.filter((s) => s.isVerifiedBadge).length;
  const openCount = stores.filter((s) => s.isOpenNow).length;

  return (
    <div className="space-y-5">
      <div>
        <div className="flex items-center gap-2.5">
          <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
            <Store className="w-5 h-5" />
          </span>
          <h1 className="text-2xl font-extrabold text-[#111827]">
            إدارة البائعين والمتاجر
          </h1>
        </div>
        <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
          الرئيسية <span className="mx-1">‹</span> إدارة البائعين
        </div>
      </div>

      {/* 4 Sparkline KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={890 + stores.length}
          label="إجمالي البائعين"
          trendPercent={12}
          tone="mint"
          icon={<Store className="w-5 h-5" />}
        />
        <SparklineCard
          value={841 + verifiedCount}
          label="متاجر موثقة"
          trendPercent={8}
          tone="blue"
          icon={<ShieldCheck className="w-5 h-5" />}
        />
        <SparklineCard
          value={612 + openCount}
          label="مفتوحة الآن بالأسواق"
          trendPercent={16}
          tone="amber"
          icon={<MapPin className="w-5 h-5" />}
        />
        <SparklineCard
          value={stores.filter((s) => !s.isOpenNow).length}
          label="متاجر مغلقة / مجمدة"
          trendPercent={3}
          tone="rose"
          icon={<XCircle className="w-5 h-5" />}
        />
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl p-3 border border-slate-100 shadow-[0_2px_10px_rgba(15,23,42,0.03)] flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="w-4 h-4 text-slate-400 absolute right-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="ابحث باسم المتجر، السوق، أو رقم المفرش..."
            className="w-full h-10 pr-10 pl-3 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-medium focus:outline-none focus:border-[#115E31]"
          />
        </div>

        <div className="relative min-w-[165px]">
          <ShieldCheck className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={verifiedFilter}
            onChange={(e) => setVerifiedFilter(e.target.value)}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع المتاجر</option>
            <option value="VERIFIED">موثق فقط</option>
            <option value="UNVERIFIED">غير موثق</option>
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

      {/* Sellers Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <table className="w-full min-w-[860px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3.5 px-5">المتجر والمقاوتي</th>
              <th className="py-3.5 px-4 text-center">السوق والمفرش</th>
              <th className="py-3.5 px-4 text-center">التقييم</th>
              <th className="py-3.5 px-4 text-center">التوثيق</th>
              <th className="py-3.5 px-4 text-center">حالة العمل</th>
              <th className="py-3.5 px-5 text-center">إجراءات</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {isLoading ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-400">
                  جاري تحميل المتاجر...
                </td>
              </tr>
            ) : stores.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-500">
                  لا توجد متاجر مطابقة للبحث
                </td>
              </tr>
            ) : (
              stores.map((s, idx) => (
                <tr key={s.id} className="hover:bg-[#F8FBF9] transition-colors">
                  <td className="py-3.5 px-5">
                    <div className="flex items-center gap-3">
                      <img
                        src={
                          idx % 2 === 0
                            ? "/images/thumb-market.jpg"
                            : "/images/thumb-harvest.jpg"
                        }
                        alt={s.storeName}
                        referrerPolicy="no-referrer"
                        className="w-11 h-11 rounded-full object-cover border border-slate-200 shrink-0"
                      />
                      <div>
                        <div className="font-bold text-[#111827]">
                          {s.storeName}
                        </div>
                        <div className="text-xs text-slate-500">
                          {s.products?.length || 0} قطفة منشورة ·{" "}
                          {s.followersCount} متابع
                        </div>
                      </div>
                    </div>
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    <div className="text-xs font-bold text-slate-800">
                      {s.market?.nameAr || "سوق غير محدد"}
                    </div>
                    <div className="text-[11px] text-slate-400 mt-0.5">
                      مفرش {s.stallNumber || "—"}
                    </div>
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    <span className="inline-flex items-center gap-1 text-xs font-bold text-amber-600 tabular-nums">
                      <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                      {Number(s.averageRating || 0).toFixed(1)} (
                      {s.ratingsCount || 0})
                    </span>
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    {s.isVerifiedBadge ? (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#DCFCE7] text-[#15803D] text-xs font-bold">
                        <ShieldCheck className="w-3.5 h-3.5" />
                        <span>متجر معتمد</span>
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-bold">
                        <span>غير موثق</span>
                      </span>
                    )}
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    {s.isOpenNow ? (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#E6F6EC] text-[#15803D] text-xs font-bold">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        <span>مفتوح</span>
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#FEE2E2] text-[#DC2626] text-xs font-bold">
                        <XCircle className="w-3.5 h-3.5" />
                        <span>مغلق / مجمد</span>
                      </span>
                    )}
                  </td>

                  <td className="py-3.5 px-5">
                    <div className="flex items-center justify-center gap-2">
                      <button
                        type="button"
                        onClick={() =>
                          mutation.mutate({
                            id: s.id,
                            payload: { isVerifiedBadge: !s.isVerifiedBadge },
                          })
                        }
                        className="px-3 py-1.5 rounded-full bg-blue-50 text-blue-700 hover:bg-blue-100 text-xs font-bold cursor-pointer"
                      >
                        {s.isVerifiedBadge ? "سحب الشارة" : "منح التوثيق"}
                      </button>
                      <button
                        type="button"
                        onClick={() =>
                          mutation.mutate({
                            id: s.id,
                            payload: { isOpenNow: !s.isOpenNow },
                          })
                        }
                        className={`px-3 py-1.5 rounded-full text-xs font-bold cursor-pointer ${
                          s.isOpenNow
                            ? "bg-red-50 text-red-700 hover:bg-red-100"
                            : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"
                        }`}
                      >
                        {s.isOpenNow ? "تجميد" : "تفعيل"}
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedStore(s);
                          setStallNumber(s.stallNumber || "");
                          setStallLandmark(s.stallLandmark || "");
                        }}
                        className="inline-flex items-center gap-1 px-3 py-1.5 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-bold cursor-pointer"
                      >
                        <Eye className="w-3.5 h-3.5" />
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

      {/* Store Details Modal */}
      {selectedStore && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-lg p-6 shadow-2xl border border-slate-100 space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-lg font-extrabold text-[#111827]">
                  {selectedStore.storeName}
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  {selectedStore.bio}
                </p>
              </div>
              <button
                type="button"
                onClick={() => setSelectedStore(null)}
                className="w-8 h-8 rounded-xl bg-slate-100 flex items-center justify-center cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  رقم المفرش
                </label>
                <input
                  type="text"
                  value={stallNumber}
                  onChange={(e) => setStallNumber(e.target.value)}
                  className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  أقرب معلم بارز
                </label>
                <input
                  type="text"
                  value={stallLandmark}
                  onChange={(e) => setStallLandmark(e.target.value)}
                  className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
                />
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-2 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setSelectedStore(null)}
                className="px-4 py-2 rounded-xl bg-slate-100 text-slate-700 text-xs font-bold cursor-pointer"
              >
                إغلاق
              </button>
              <button
                type="button"
                onClick={() =>
                  mutation.mutate({
                    id: selectedStore.id,
                    payload: { stallNumber, stallLandmark },
                  })
                }
                className="px-5 py-2 rounded-xl bg-[#0C5A2C] text-white text-xs font-bold cursor-pointer"
              >
                حفظ بيانات المفرش
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
