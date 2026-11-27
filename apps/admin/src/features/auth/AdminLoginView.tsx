import React, { useState } from "react";
import { KeyRound, Lock, ShieldCheck } from "lucide-react";
import { useAuth } from "../../context/AuthContext";

export const AdminLoginView: React.FC = () => {
  const { authStatus, isLoadingStatus, login, claim } = useAuth();
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const isFirstRunSetup =
    !isLoadingStatus &&
    authStatus &&
    !authStatus.isClaimed &&
    !authStatus.hasEnvPasscode;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (isFirstRunSetup && password !== confirmPassword) {
      setError("كلمتا المرور غير متطابقتين");
      return;
    }

    if (password.trim().length < 6) {
      setError("يرجى إدخال كلمة مرور لا تقل عن 6 أحرف");
      return;
    }

    setSubmitting(true);
    try {
      if (isFirstRunSetup) {
        await claim(password);
      } else {
        await login(password);
      }
    } catch (err: any) {
      setError(err?.message || "تعذر التحقق من بيانات الدخول");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-[#F6F8FA]">
      {/* Right Decorative Emerald Panel */}
      <div className="hidden lg:flex w-[42%] bg-gradient-to-b from-[#073619] via-[#09401E] to-[#052310] text-white p-12 flex-col justify-between relative overflow-hidden">
        <div className="relative z-10">
          <div className="flex items-center gap-3">
            <img
              src="/qatfa_logo.svg"
              alt="شعار منصة قطفة"
              className="h-14 w-auto object-contain rounded-lg shadow-md"
            />
            <div>
              <div className="text-3xl font-extrabold leading-none">قطفة</div>
              <div className="text-[11px] tracking-[0.24em] text-emerald-200/80 font-bold mt-1">
                QATFA ADMIN
              </div>
            </div>
          </div>

          <h1 className="text-3xl font-extrabold leading-snug mt-14 max-w-md">
            مركز إدارة ومراقبة أسواق القات في الجمهورية اليمنية
          </h1>
          <p className="text-emerald-100/80 text-sm leading-relaxed mt-4 max-w-md">
            إدارة موحدة لطلبات توثيق المقاوتية والأسواق، الرقابة اليدوية على
            البلاغات، متابعة الحجوزات اليومية، وتحديث خرائط الأسواق النشطة.
          </p>
        </div>

        <div className="relative z-10 rounded-2xl overflow-hidden border border-white/15 h-48">
          <img
            src="/images/sidebar-hills.jpg"
            alt="مزارع اليمن"
            referrerPolicy="no-referrer"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#052310]/90 via-[#052310]/30 to-transparent flex items-end p-5">
            <span className="text-base font-extrabold text-white">
              معاً .. لننمو أكثر
            </span>
          </div>
        </div>
      </div>

      {/* Left Login / Setup Card */}
      <div className="flex-1 flex items-center justify-center p-6">
        <div className="w-full max-w-md bg-white rounded-3xl shadow-[0_8px_30px_rgba(15,23,42,0.06)] border border-slate-100 p-8">
          <div className="flex items-center gap-3 mb-6">
            <img
              src={
                authStatus?.adminProfile.avatarUrl || "/images/avatar-ahmed.jpg"
              }
              alt="أحمد محمد"
              referrerPolicy="no-referrer"
              className="w-14 h-14 rounded-full object-cover border-2 border-[#E6F6EC]"
            />
            <div>
              <div className="flex items-center gap-1.5">
                <span className="text-base font-extrabold text-[#111827]">
                  {authStatus?.adminProfile.fullName || "أحمد محمد"}
                </span>
                <ShieldCheck className="w-4 h-4 text-[#15803D]" />
              </div>
              <div className="text-xs text-slate-500 font-semibold">
                {authStatus?.adminProfile.roleLabel || "مدير النظام"}
              </div>
            </div>
          </div>

          <h2 className="text-xl font-extrabold text-[#111827]">
            {isFirstRunSetup
              ? "الإعداد الأولي لحساب مدير النظام"
              : "تسجيل الدخول للوحة التحكم"}
          </h2>
          <p className="text-xs text-slate-500 mt-1.5 leading-relaxed">
            {isFirstRunSetup
              ? "قم بتعيين كلمة مرور خاصة لحماية لوحة الإدارة في هذه الجلسة."
              : "أدخل كلمة مرور مدير النظام للوصول إلى كافة صفحات الإدارة."}
          </p>

          <form onSubmit={handleSubmit} className="mt-6 space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                كلمة مرور الإدارة
              </label>
              <div className="relative">
                <Lock className="w-4 h-4 text-slate-400 absolute right-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  className="w-full h-11 pr-10 pl-4 rounded-xl bg-[#F4F6F8] border border-slate-200 focus:border-[#15803D] focus:bg-white focus:outline-none text-sm"
                />
              </div>
            </div>

            {isFirstRunSetup && (
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  تأكيد كلمة المرور
                </label>
                <div className="relative">
                  <KeyRound className="w-4 h-4 text-slate-400 absolute right-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                    className="w-full h-11 pr-10 pl-4 rounded-xl bg-[#F4F6F8] border border-slate-200 focus:border-[#15803D] focus:bg-white focus:outline-none text-sm"
                  />
                </div>
              </div>
            )}

            {error && (
              <div className="p-3 rounded-xl bg-red-50 border border-red-100 text-xs font-semibold text-red-700">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={submitting || isLoadingStatus}
              className="w-full h-11 rounded-xl bg-gradient-to-l from-[#1D7E36] to-[#0E4F27] hover:opacity-95 text-white font-bold text-sm shadow-sm transition-opacity cursor-pointer disabled:opacity-60"
            >
              {submitting
                ? "جاري التحقق..."
                : isFirstRunSetup
                  ? "تعيين كلمة المرور والدخول"
                  : "دخول إلى لوحة التحكم"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};
