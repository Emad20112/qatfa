import React, { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Building2,
  CheckCircle2,
  Globe,
  MapPin,
  Plus,
  Store,
  X,
  XCircle,
} from "lucide-react";
import { Currency } from "@qatfa/shared-types";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";
import { YemenMarketsMap } from "../../components/ui/YemenMarketsMap";

export const MarketsPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [showAddGov, setShowAddGov] = useState(false);
  const [showAddMarket, setShowAddMarket] = useState(false);

  const [govName, setGovName] = useState("");
  const [govCurrency, setGovCurrency] = useState<Currency>(Currency.YER_OLD);

  const [marketName, setMarketName] = useState("");
  const [selectedDistrictId, setSelectedDistrictId] = useState<number>(1);
  const [lat, setLat] = useState("15.3547");
  const [lng, setLng] = useState("44.2066");

  const { data: govs = [], isLoading } = useQuery({
    queryKey: ["admin-geo"],
    queryFn: () => adminApi.getGeoOverview(),
  });

  const { data: dashboard } = useQuery({
    queryKey: ["admin-dashboard", "week"],
    queryFn: () => adminApi.getDashboard("week"),
  });

  const addGovMutation = useMutation({
    mutationFn: () =>
      adminApi.createGovernorate({
        nameAr: govName,
        defaultCurrency: govCurrency,
      }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-geo"] });
      void queryClient.invalidateQueries({ queryKey: ["admin-dashboard"] });
      setGovName("");
      setShowAddGov(false);
    },
  });

  const addMarketMutation = useMutation({
    mutationFn: () =>
      adminApi.createMarket({
        districtId: selectedDistrictId,
        nameAr: marketName,
        centerLatitude: parseFloat(lat),
        centerLongitude: parseFloat(lng),
      }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-geo"] });
      void queryClient.invalidateQueries({ queryKey: ["admin-dashboard"] });
      setMarketName("");
      setShowAddMarket(false);
    },
  });

  const toggleMarketMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: number; isActive: boolean }) =>
      adminApi.toggleMarket(id, isActive),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-geo"] });
    },
  });

  const allDistricts = govs.flatMap((g) =>
    (g.districts || []).map((d: any) => ({
      ...d,
      govName: g.nameAr,
    })),
  );
  const allMarkets = allDistricts.flatMap((d) =>
    (d.markets || []).map((m: any) => ({
      ...m,
      districtName: d.nameAr,
      govName: d.govName,
    })),
  );

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2.5">
            <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
              <MapPin className="w-5 h-5" />
            </span>
            <h1 className="text-2xl font-extrabold text-[#111827]">
              إدارة الأسواق والدليل الجغرافي
            </h1>
          </div>
          <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
            الرئيسية <span className="mx-1">‹</span> إدارة الأسواق
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            type="button"
            onClick={() => setShowAddGov(true)}
            className="h-10 px-4 rounded-full bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 text-xs font-bold inline-flex items-center gap-1.5 cursor-pointer"
          >
            <Plus className="w-4 h-4" />
            <span>إضافة محافظة</span>
          </button>
          <button
            type="button"
            onClick={() => {
              if (allDistricts.length > 0) {
                setSelectedDistrictId(allDistricts[0].id);
              }
              setShowAddMarket(true);
            }}
            className="h-10 px-5 rounded-full bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center gap-1.5 cursor-pointer"
          >
            <Plus className="w-4 h-4" />
            <span>إضافة سوق شعبي</span>
          </button>
        </div>
      </div>

      {/* 4 Sparkline KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={govs.length}
          label="المحافظات المغطاة"
          trendPercent={10}
          tone="mint"
          icon={<Globe className="w-5 h-5" />}
        />
        <SparklineCard
          value={allDistricts.length}
          label="المديريات النشطة"
          trendPercent={12}
          tone="blue"
          icon={<Building2 className="w-5 h-5" />}
        />
        <SparklineCard
          value={allMarkets.length}
          label="الأسواق الشعبية"
          trendPercent={18}
          tone="amber"
          icon={<MapPin className="w-5 h-5" />}
        />
        <SparklineCard
          value={allMarkets.filter((m) => m.isActive).length}
          label="أسواق متاحة بالخريطة"
          trendPercent={15}
          tone="mint"
          icon={<Store className="w-5 h-5" />}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        {/* Yemen Interactive Map */}
        <div className="lg:col-span-5 bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)]">
          <YemenMarketsMap
            pins={dashboard?.marketPins || []}
            activeMarketsCount={Math.max(
              allMarkets.filter((m) => m.isActive).length,
              dashboard?.activeMarketsCount ?? 8,
            )}
            compact={false}
          />
        </div>

        {/* Markets Table */}
        <div className="lg:col-span-7 bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
          <div className="p-4 border-b border-slate-100 flex items-center justify-between">
            <h3 className="text-base font-bold text-[#111827]">
              قائمة الأسواق الشعبية والإحداثيات
            </h3>
            <span className="text-xs font-bold text-slate-400 tabular-nums">
              {allMarkets.length} سوق مسجل
            </span>
          </div>
          <table className="w-full text-right">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
                <th className="py-3 px-4">السوق</th>
                <th className="py-3 px-4">المحافظة والمديرية</th>
                <th className="py-3 px-4 text-center">الإحداثيات</th>
                <th className="py-3 px-4 text-center">الحالة</th>
                <th className="py-3 px-4 text-center">إجراء</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-sm">
              {isLoading ? (
                <tr>
                  <td colSpan={5} className="py-10 text-center text-slate-400">
                    جاري التحميل...
                  </td>
                </tr>
              ) : (
                allMarkets.map((m) => (
                  <tr key={m.id} className="hover:bg-[#F8FBF9]">
                    <td className="py-3 px-4 font-bold text-[#111827]">
                      {m.nameAr}
                    </td>
                    <td className="py-3 px-4 text-xs text-slate-500">
                      {m.govName} · {m.districtName}
                    </td>
                    <td className="py-3 px-4 text-center text-xs text-slate-500 tabular-nums" dir="ltr">
                      {Number(m.centerLatitude || 0).toFixed(3)},{" "}
                      {Number(m.centerLongitude || 0).toFixed(3)}
                    </td>
                    <td className="py-3 px-4 text-center">
                      {m.isActive ? (
                        <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-[#DCFCE7] text-[#15803D] text-xs font-bold">
                          <CheckCircle2 className="w-3.5 h-3.5" />
                          <span>نشط</span>
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-[#FEE2E2] text-[#DC2626] text-xs font-bold">
                          <XCircle className="w-3.5 h-3.5" />
                          <span>معطل</span>
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4 text-center">
                      <button
                        type="button"
                        onClick={() =>
                          toggleMarketMutation.mutate({
                            id: m.id,
                            isActive: !m.isActive,
                          })
                        }
                        className="px-3 py-1 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-bold cursor-pointer"
                      >
                        {m.isActive ? "تعطيل" : "تفعيل"}
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Governorate Modal */}
      {showAddGov && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-extrabold text-[#111827]">
                إضافة محافظة جديدة
              </h3>
              <button
                type="button"
                onClick={() => setShowAddGov(false)}
                className="w-8 h-8 rounded-xl bg-slate-100 flex items-center justify-center cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">
                اسم المحافظة بالعربية
              </label>
              <input
                type="text"
                value={govName}
                onChange={(e) => setGovName(e.target.value)}
                placeholder="مثال: تعز"
                className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">
                العملة المعتمدة (طبعة قديمة / جديدة)
              </label>
              <select
                value={govCurrency}
                onChange={(e) => setGovCurrency(e.target.value as Currency)}
                className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
              >
                <option value={Currency.YER_OLD}>ريال يمني - طبعة قديمة (صنعاء)</option>
                <option value={Currency.YER_NEW}>ريال يمني - طبعة جديدة (عدن)</option>
              </select>
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setShowAddGov(false)}
                className="px-4 py-2 rounded-xl bg-slate-100 text-xs font-bold cursor-pointer"
              >
                إلغاء
              </button>
              <button
                type="button"
                disabled={!govName.trim()}
                onClick={() => addGovMutation.mutate()}
                className="px-5 py-2 rounded-xl bg-[#0C5A2C] text-white text-xs font-bold cursor-pointer disabled:opacity-50"
              >
                حفظ المحافظة
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add Market Modal */}
      {showAddMarket && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-extrabold text-[#111827]">
                إضافة سوق شعبي جديد
              </h3>
              <button
                type="button"
                onClick={() => setShowAddMarket(false)}
                className="w-8 h-8 rounded-xl bg-slate-100 flex items-center justify-center cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">
                المديرية التابعة
              </label>
              <select
                value={selectedDistrictId}
                onChange={(e) => setSelectedDistrictId(Number(e.target.value))}
                className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
              >
                {allDistricts.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.govName} - {d.nameAr}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">
                اسم السوق الشعبي
              </label>
              <input
                type="text"
                value={marketName}
                onChange={(e) => setMarketName(e.target.value)}
                placeholder="مثال: سوق عنقاد الشعبي"
                className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
              />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  خط العرض (Lat)
                </label>
                <input
                  type="text"
                  value={lat}
                  onChange={(e) => setLat(e.target.value)}
                  className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs tabular-nums"
                  dir="ltr"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  خط الطول (Lng)
                </label>
                <input
                  type="text"
                  value={lng}
                  onChange={(e) => setLng(e.target.value)}
                  className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs tabular-nums"
                  dir="ltr"
                />
              </div>
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setShowAddMarket(false)}
                className="px-4 py-2 rounded-xl bg-slate-100 text-xs font-bold cursor-pointer"
              >
                إلغاء
              </button>
              <button
                type="button"
                disabled={!marketName.trim()}
                onClick={() => addMarketMutation.mutate()}
                className="px-5 py-2 rounded-xl bg-[#0C5A2C] text-white text-xs font-bold cursor-pointer disabled:opacity-50"
              >
                حفظ السوق
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
