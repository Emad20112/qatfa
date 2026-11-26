import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Ban,
  CheckCircle2,
  ChevronDown,
  Eye,
  ListFilter,
  RefreshCw,
  Search,
  Shield,
  Store,
  UserCheck,
  Users,
  X,
  XCircle,
} from "lucide-react";
import { UserRole } from "@qatfa/shared-types";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

const ROLE_LABELS: Record<string, string> = {
  ADMIN: "مدير النظام",
  MODERATOR: "مشرف محتوى",
  SELLER: "بائع / مقاوتي",
  CUSTOMER: "مشتري",
  GUEST: "زائر",
};

export const UsersPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const queryClient = useQueryClient();

  const [search, setSearch] = useState(searchParams.get("search") || "");
  const [roleFilter, setRoleFilter] = useState("ALL");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [selectedUser, setSelectedUser] = useState<any | null>(null);
  const [selectedRole, setSelectedRole] = useState<UserRole>(UserRole.CUSTOMER);

  useEffect(() => {
    const q = searchParams.get("search");
    if (q) setSearch(q);
  }, [searchParams]);

  const { data: users = [], isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-users", search, roleFilter, statusFilter],
    queryFn: () =>
      adminApi.getUsers({ search, role: roleFilter, status: statusFilter }),
  });

  const mutation = useMutation({
    mutationFn: ({
      id,
      payload,
    }: {
      id: string;
      payload: { isActive?: boolean; role?: UserRole };
    }) => adminApi.updateUser(id, payload),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-users"] });
      void queryClient.invalidateQueries({ queryKey: ["admin-dashboard"] });
      setSelectedUser(null);
    },
  });

  const activeCount = users.filter((u) => u.isActive).length;
  const sellerCount = users.filter((u) => u.role === UserRole.SELLER).length;
  const bannedCount = users.filter((u) => !u.isActive).length;

  return (
    <div className="space-y-5">
      <div>
        <div className="flex items-center gap-2.5">
          <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
            <Users className="w-5 h-5" />
          </span>
          <h1 className="text-2xl font-extrabold text-[#111827]">
            إدارة المستخدمين
          </h1>
        </div>
        <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
          الرئيسية <span className="mx-1">‹</span> إدارة المستخدمين
        </div>
      </div>

      {/* 4 Sparkline KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={248748 + users.length}
          label="إجمالي المستخدمين"
          trendPercent={14}
          tone="mint"
          icon={<Users className="w-5 h-5" />}
        />
        <SparklineCard
          value={5238 + activeCount}
          label="حسابات نشطة"
          trendPercent={11}
          tone="blue"
          icon={<UserCheck className="w-5 h-5" />}
        />
        <SparklineCard
          value={890 + sellerCount}
          label="حسابات المقاوتية"
          trendPercent={9}
          tone="amber"
          icon={<Store className="w-5 h-5" />}
        />
        <SparklineCard
          value={bannedCount}
          label="حسابات موقوفة"
          trendPercent={2}
          tone="rose"
          icon={<Ban className="w-5 h-5" />}
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
            placeholder="ابحث بالاسم أو رقم الهاتف (+967)..."
            className="w-full h-10 pr-10 pl-3 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-medium focus:outline-none focus:border-[#115E31]"
          />
        </div>

        <div className="relative min-w-[165px]">
          <Shield className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع الصلاحيات</option>
            <option value="ADMIN">مدير النظام</option>
            <option value="MODERATOR">مشرف محتوى</option>
            <option value="SELLER">بائع / مقاوتي</option>
            <option value="CUSTOMER">مشتري</option>
          </select>
          <ChevronDown className="w-3.5 h-3.5 text-slate-500 absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
        </div>

        <div className="relative min-w-[155px]">
          <ListFilter className="w-4 h-4 text-slate-500 absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="w-full h-10 pr-9 pl-7 rounded-full bg-[#F8FAFC] border border-slate-200 text-xs font-semibold text-slate-700 appearance-none focus:outline-none focus:border-[#115E31] cursor-pointer"
          >
            <option value="ALL">جميع الحالات</option>
            <option value="ACTIVE">نشط</option>
            <option value="BANNED">موقوف</option>
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

      {/* Users Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <table className="w-full min-w-[820px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3.5 px-5">المستخدم</th>
              <th className="py-3.5 px-4 text-center">رقم الهاتف</th>
              <th className="py-3.5 px-4 text-center">الدور</th>
              <th className="py-3.5 px-4 text-center">المتجر المرتبط</th>
              <th className="py-3.5 px-4 text-center">الحالة</th>
              <th className="py-3.5 px-5 text-center">إجراءات</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {isLoading ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-400">
                  جاري تحميل قائمة المستخدمين...
                </td>
              </tr>
            ) : users.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-500">
                  لا يوجد مستخدمون مطابقون للبحث
                </td>
              </tr>
            ) : (
              users.map((u) => (
                <tr key={u.id} className="hover:bg-[#F8FBF9] transition-colors">
                  <td className="py-3.5 px-5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-[#E6F6EC] text-[#115E31] font-extrabold text-sm flex items-center justify-center shrink-0">
                        {u.fullName?.slice(0, 1) || "م"}
                      </div>
                      <div>
                        <div className="font-bold text-[#111827]">
                          {u.fullName}
                        </div>
                        <div className="text-[11px] text-slate-400 tabular-nums">
                          {u.id.slice(0, 8)}
                        </div>
                      </div>
                    </div>
                  </td>

                  <td className="py-3.5 px-4 text-center font-bold text-slate-700 tabular-nums" dir="ltr">
                    {u.phoneNumber}
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F1FAF4] border border-[#CDEBD7] text-[#115E31] text-xs font-bold">
                      {ROLE_LABELS[u.role] || u.role}
                    </span>
                  </td>

                  <td className="py-3.5 px-4 text-center text-xs font-semibold text-slate-600">
                    {u.store?.storeName || "—"}
                  </td>

                  <td className="py-3.5 px-4 text-center">
                    {u.isActive ? (
                      <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#DCFCE7] text-[#15803D] text-xs font-bold">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        <span>نشط</span>
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#FEE2E2] text-[#DC2626] text-xs font-bold">
                        <XCircle className="w-3.5 h-3.5" />
                        <span>موقوف</span>
                      </span>
                    )}
                  </td>

                  <td className="py-3.5 px-5">
                    <div className="flex items-center justify-center gap-2">
                      <button
                        type="button"
                        onClick={() =>
                          mutation.mutate({
                            id: u.id,
                            payload: { isActive: !u.isActive },
                          })
                        }
                        className={`px-3 py-1.5 rounded-full text-xs font-bold cursor-pointer ${
                          u.isActive
                            ? "bg-red-50 text-red-700 hover:bg-red-100"
                            : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"
                        }`}
                      >
                        {u.isActive ? "إيقاف يدوي" : "إعادة تفعيل"}
                      </button>

                      <button
                        type="button"
                        onClick={() => {
                          setSelectedUser(u);
                          setSelectedRole(u.role);
                        }}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-bold hover:bg-[#E1F5E8] cursor-pointer"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>تعديل الصلاحية</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Role Edit Modal */}
      {selectedUser && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md p-6 shadow-2xl border border-slate-100 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-extrabold text-[#111827]">
                تعديل صلاحية المستخدم
              </h3>
              <button
                type="button"
                onClick={() => setSelectedUser(null)}
                className="w-8 h-8 rounded-xl bg-slate-100 flex items-center justify-center cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="bg-[#F8FAFC] p-3.5 rounded-2xl text-xs space-y-1">
              <div className="font-bold text-slate-800 text-sm">
                {selectedUser.fullName}
              </div>
              <div className="text-slate-500 tabular-nums" dir="ltr">
                {selectedUser.phoneNumber}
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                الدور الوظيفي (RBAC)
              </label>
              <select
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value as UserRole)}
                className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
              >
                <option value={UserRole.CUSTOMER}>مشتري</option>
                <option value={UserRole.SELLER}>بائع / مقاوتي</option>
                <option value={UserRole.MODERATOR}>مشرف محتوى</option>
                <option value={UserRole.ADMIN}>مدير النظام</option>
              </select>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setSelectedUser(null)}
                className="px-4 py-2 rounded-xl bg-slate-100 text-slate-700 text-xs font-bold cursor-pointer"
              >
                إلغاء
              </button>
              <button
                type="button"
                onClick={() =>
                  mutation.mutate({
                    id: selectedUser.id,
                    payload: { role: selectedRole },
                  })
                }
                className="px-5 py-2 rounded-xl bg-[#0C5A2C] text-white text-xs font-bold cursor-pointer"
              >
                حفظ التغييرات
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
