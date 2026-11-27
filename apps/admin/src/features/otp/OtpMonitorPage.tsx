import React, { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import {
  CheckCircle2,
  Clock,
  Copy,
  KeyRound,
  RefreshCw,
  Search,
  ShieldAlert,
  Smartphone,
  User,
  Zap,
} from "lucide-react";
import { adminApi, OtpLogRecord } from "../../services/api";

export const OtpMonitorPage: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<"ALL" | "ACTIVE" | "USED" | "EXPIRED">("ALL");
  const [copiedId, setCopiedId] = useState<string | null>(null);

  // تحديث تلقائي كل 3 ثوانٍ لالتقاط الرموز الجديدة لحظياً
  const { data: otpLogs = [], isLoading, isFetching, refetch } = useQuery<OtpLogRecord[]>({
    queryKey: ["admin", "otp-logs"],
    queryFn: () => adminApi.getOtpLogs(),
    refetchInterval: 3000,
  });

  const handleCopy = (id: string, code: string) => {
    navigator.clipboard.writeText(code);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const filteredLogs = otpLogs.filter((log) => {
    const matchesSearch =
      log.phoneNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (log.fullName && log.fullName.toLowerCase().includes(searchTerm.toLowerCase())) ||
      log.code.includes(searchTerm);

    const matchesStatus =
      statusFilter === "ALL" || log.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  const activeCount = otpLogs.filter((l) => l.status === "ACTIVE").length;
  const usedCount = otpLogs.filter((l) => l.status === "USED").length;
  const expiredCount = otpLogs.filter((l) => l.status === "EXPIRED").length;

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6 select-none" dir="rtl">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-l from-emerald-900 to-emerald-800 text-white p-6 rounded-2xl shadow-lg border border-emerald-700/50">
        <div className="space-y-1">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-emerald-500/20 rounded-xl border border-emerald-400/30">
              <KeyRound className="w-6 h-6 text-emerald-300" />
            </div>
            <div>
              <h1 className="text-2xl font-black">مراقبة رموز التحقق اللحظية (OTP Live Monitor)</h1>
              <div className="flex items-center gap-2 text-xs font-semibold text-emerald-200/90 mt-1">
                <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse" />
                <span>متصل بالخادم وتصل الرموز فور طلبها من التطبيق للاختبار الميداني</span>
              </div>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => refetch()}
            disabled={isFetching}
            className="flex items-center gap-2 px-4 py-2.5 bg-white/10 hover:bg-white/20 active:bg-white/30 text-white rounded-xl text-sm font-bold border border-white/20 transition-all shadow-sm"
          >
            <RefreshCw className={`w-4 h-4 ${isFetching ? "animate-spin text-emerald-300" : ""}`} />
            <span>تحديث الآن</span>
          </button>
        </div>
      </div>

      {/* Stats Quick Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-gray-200/80 shadow-sm flex items-center justify-between">
          <div>
            <div className="text-xs font-bold text-gray-400 mb-1">إجمالي الرموز المطلوبة</div>
            <div className="text-2xl font-black text-gray-800">{otpLogs.length}</div>
          </div>
          <div className="p-3 bg-gray-100 rounded-xl text-gray-600">
            <Zap className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-emerald-200/80 shadow-sm flex items-center justify-between">
          <div>
            <div className="text-xs font-bold text-emerald-600 mb-1">رموز صالحة حالياً</div>
            <div className="text-2xl font-black text-emerald-700">{activeCount}</div>
          </div>
          <div className="p-3 bg-emerald-50 rounded-xl text-emerald-600">
            <Clock className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-blue-200/80 shadow-sm flex items-center justify-between">
          <div>
            <div className="text-xs font-bold text-blue-600 mb-1">تم التحقق منها بنجاح</div>
            <div className="text-2xl font-black text-blue-700">{usedCount}</div>
          </div>
          <div className="p-3 bg-blue-50 rounded-xl text-blue-600">
            <CheckCircle2 className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-red-200/80 shadow-sm flex items-center justify-between">
          <div>
            <div className="text-xs font-bold text-red-500 mb-1">منتهية الصلاحية</div>
            <div className="text-2xl font-black text-red-600">{expiredCount}</div>
          </div>
          <div className="p-3 bg-red-50 rounded-xl text-red-500">
            <ShieldAlert className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="bg-white p-4 rounded-2xl border border-gray-200/80 shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
        <div className="relative w-full md:w-96">
          <Search className="w-4 h-4 text-gray-400 absolute right-3.5 top-3.5" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="بحث برقم الهاتف، الاسم، أو الرمز..."
            className="w-full pr-10 pl-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
          />
        </div>

        <div className="flex items-center gap-1.5 self-stretch md:self-auto overflow-x-auto">
          {[
            { id: "ALL", label: "الكل" },
            { id: "ACTIVE", label: "صالحة الآن" },
            { id: "USED", label: "مستخدمة" },
            { id: "EXPIRED", label: "منتهية" },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setStatusFilter(tab.id as any)}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                statusFilter === tab.id
                  ? "bg-emerald-700 text-white shadow-sm"
                  : "bg-gray-100 text-gray-600 hover:bg-gray-200"
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Table of OTP Logs */}
      <div className="bg-white rounded-2xl border border-gray-200/80 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right border-collapse">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-200 text-xs font-black text-gray-500 uppercase tracking-wider">
                <th className="py-4 px-5">المستخدم</th>
                <th className="py-4 px-5">رقم الهاتف</th>
                <th className="py-4 px-5">رمز التحقق (OTP)</th>
                <th className="py-4 px-5">الحالة</th>
                <th className="py-4 px-5">تاريخ ووقت الطلب</th>
                <th className="py-4 px-5 text-center">إجراء سريع</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 text-sm">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-gray-400">
                    <div className="flex items-center justify-center gap-2">
                      <RefreshCw className="w-5 h-5 animate-spin text-emerald-600" />
                      <span>جاري تحميل سجل رموز التحقق...</span>
                    </div>
                  </td>
                </tr>
              ) : filteredLogs.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-gray-400">
                    <div className="flex flex-col items-center justify-center gap-2">
                      <KeyRound className="w-8 h-8 text-gray-300" />
                      <span>لا توجد رموز تحقق مطابقة حالياً. قم بطلب رمز جديد من تطبيق الجوال.</span>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredLogs.map((log) => {
                  const isCopied = copiedId === log.id;
                  const createdAtDate = new Date(log.createdAt);

                  return (
                    <tr
                      key={log.id}
                      className={`hover:bg-gray-50/80 transition-colors ${
                        log.status === "ACTIVE" ? "bg-emerald-50/30 font-medium" : ""
                      }`}
                    >
                      {/* Name */}
                      <td className="py-4 px-5">
                        <div className="flex items-center gap-2.5">
                          <div className="w-8 h-8 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-black">
                            <User className="w-4 h-4" />
                          </div>
                          <div>
                            <div className="font-bold text-gray-900">
                              {log.fullName || "مستخدم جديد"}
                            </div>
                            <div className="text-[11px] text-gray-400">طلب تسجيل دخول</div>
                          </div>
                        </div>
                      </td>

                      {/* Phone */}
                      <td className="py-4 px-5 font-mono text-gray-700" dir="ltr">
                        <div className="flex items-center justify-end gap-1.5">
                          <span>{log.phoneNumber}</span>
                          <Smartphone className="w-3.5 h-3.5 text-gray-400" />
                        </div>
                      </td>

                      {/* Code */}
                      <td className="py-4 px-5">
                        <div className="inline-flex items-center gap-2 bg-emerald-50 border border-emerald-200 px-3 py-1.5 rounded-xl font-mono text-base font-black tracking-widest text-emerald-800">
                          <span>{log.code}</span>
                        </div>
                      </td>

                      {/* Status */}
                      <td className="py-4 px-5">
                        {log.status === "ACTIVE" && (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-200">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-ping" />
                            صالح للاستخدام
                          </span>
                        )}
                        {log.status === "USED" && (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-gray-100 text-gray-600 border border-gray-200">
                            <CheckCircle2 className="w-3 h-3 text-gray-500" />
                            تم التحقق
                          </span>
                        )}
                        {log.status === "EXPIRED" && (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-red-50 text-red-600 border border-red-200">
                            <Clock className="w-3 h-3 text-red-500" />
                            منتهي
                          </span>
                        )}
                      </td>

                      {/* Timestamp */}
                      <td className="py-4 px-5 text-xs text-gray-500">
                        <div>{createdAtDate.toLocaleTimeString("ar-YE", { hour: "2-digit", minute: "2-digit", second: "2-digit" })}</div>
                        <div className="text-[10px] text-gray-400">{createdAtDate.toLocaleDateString("ar-YE")}</div>
                      </td>

                      {/* Copy Action */}
                      <td className="py-4 px-5 text-center">
                        <button
                          onClick={() => handleCopy(log.id, log.code)}
                          className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                            isCopied
                              ? "bg-emerald-600 text-white"
                              : "bg-emerald-50 text-emerald-800 hover:bg-emerald-100 active:scale-95 border border-emerald-200"
                          }`}
                        >
                          {isCopied ? (
                            <>
                              <CheckCircle2 className="w-3.5 h-3.5" />
                              <span>تم النسخ!</span>
                            </>
                          ) : (
                            <>
                              <Copy className="w-3.5 h-3.5" />
                              <span>نسخ الرمز</span>
                            </>
                          )}
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
