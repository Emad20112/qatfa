import React, { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  BellRing,
  CheckCircle2,
  DownloadCloud,
  Megaphone,
  Save,
  Send,
  Settings,
  Smartphone,
} from "lucide-react";
import { AppUpdateType } from "@qatfa/shared-types";
import { adminApi } from "../../services/api";

export const SettingsPage: React.FC = () => {
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ["admin-settings"],
    queryFn: () => adminApi.getSettings(),
  });

  const [latestVersion, setLatestVersion] = useState("1.0.0");
  const [latestBuildNumber, setLatestBuildNumber] = useState(1);
  const [minSupportedVersion, setMinSupportedVersion] = useState("1.0.0");
  const [minSupportedBuildNumber, setMinSupportedBuildNumber] = useState(1);
  const [updateType, setUpdateType] = useState<AppUpdateType>(
    AppUpdateType.OPTIONAL,
  );
  const [downloadUrl, setDownloadUrl] = useState("");
  const [telegramChannelUrl, setTelegramChannelUrl] = useState("");
  const [releaseNotes, setReleaseNotes] = useState("");
  const [settingsSavedMsg, setSettingsSavedMsg] = useState("");

  const [broadcastTitle, setBroadcastTitle] = useState("");
  const [broadcastBody, setBroadcastBody] = useState("");
  const [broadcastAudience, setBroadcastAudience] = useState<
    "ALL" | "CUSTOMERS" | "SELLERS" | "GOVERNORATE"
  >("ALL");
  const [broadcastDeepLink, setBroadcastDeepLink] = useState("qatfa://feed");
  const [broadcastSentMsg, setBroadcastSentMsg] = useState("");

  useEffect(() => {
    if (data?.appVersion) {
      setLatestVersion(data.appVersion.latestVersion || "1.0.0");
      setLatestBuildNumber(data.appVersion.latestBuildNumber || 1);
      setMinSupportedVersion(data.appVersion.minSupportedVersion || "1.0.0");
      setMinSupportedBuildNumber(data.appVersion.minSupportedBuildNumber || 1);
      setUpdateType(data.appVersion.updateType || AppUpdateType.OPTIONAL);
      setDownloadUrl(data.appVersion.downloadUrl || "");
      setTelegramChannelUrl(data.appVersion.telegramChannelUrl || "");
      setReleaseNotes(data.appVersion.releaseNotes || "");
    }
  }, [data]);

  const updateSettingsMutation = useMutation({
    mutationFn: () =>
      adminApi.updateSettings({
        latestVersion,
        latestBuildNumber: Number(latestBuildNumber),
        minSupportedVersion,
        minSupportedBuildNumber: Number(minSupportedBuildNumber),
        updateType,
        downloadUrl,
        telegramChannelUrl,
        releaseNotes,
      }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-settings"] });
      setSettingsSavedMsg("تم حفظ إعدادات الإصدار والتحديث بنجاح");
      setTimeout(() => setSettingsSavedMsg(""), 3500);
    },
  });

  const broadcastMutation = useMutation({
    mutationFn: () =>
      adminApi.sendBroadcast({
        title: broadcastTitle,
        body: broadcastBody,
        audience: broadcastAudience,
        deepLink: broadcastDeepLink,
      }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-settings"] });
      setBroadcastTitle("");
      setBroadcastBody("");
      setBroadcastSentMsg("تم إرسال الإشعار الجماعي وتسجيله في سجل العمليات");
      setTimeout(() => setBroadcastSentMsg(""), 3500);
    },
  });

  const broadcasts: any[] = data?.broadcasts || [];

  return (
    <div className="space-y-5">
      <div>
        <div className="flex items-center gap-2.5">
          <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
            <Settings className="w-5 h-5" />
          </span>
          <h1 className="text-2xl font-extrabold text-[#111827]">
            إعدادات النظام
          </h1>
        </div>
        <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
          الرئيسية <span className="mx-1">‹</span> إعدادات النظام
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
        {/* App Version & Distribution Control (Direct APK + Telegram) */}
        <form
          onSubmit={(e) => {
            e.preventDefault();
            updateSettingsMutation.mutate();
          }}
          className="lg:col-span-7 bg-white rounded-2xl p-6 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] space-y-4"
        >
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center gap-2.5">
              <div className="w-9 h-9 rounded-xl bg-[#EFFAF3] text-[#115E31] flex items-center justify-center">
                <Smartphone className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-base font-bold text-[#111827]">
                  إدارة إصدارات التطبيق والتوزيع (APK / Telegram)
                </h3>
                <p className="text-xs text-slate-400">
                  التحكم بحد التحديث الإجباري وروابط تحميل النسخ مباشرة
                </p>
              </div>
            </div>
            <span className="px-3 py-1 rounded-full bg-[#E6F6EC] text-[#15803D] text-xs font-bold">
              Android
            </span>
          </div>

          {isLoading ? (
            <div className="py-8 text-center text-xs text-slate-400">
              جاري تحميل الإعدادات...
            </div>
          ) : (
            <>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">
                    أحدث إصدار متاح (Version)
                  </label>
                  <input
                    type="text"
                    value={latestVersion}
                    onChange={(e) => setLatestVersion(e.target.value)}
                    dir="ltr"
                    className="w-full h-10 px-3.5 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">
                    رقم البناء الأحدث (Build Number)
                  </label>
                  <input
                    type="number"
                    value={latestBuildNumber}
                    onChange={(e) =>
                      setLatestBuildNumber(parseInt(e.target.value, 10) || 1)
                    }
                    dir="ltr"
                    className="w-full h-10 px-3.5 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">
                    أدنى إصدار مدعوم (Min Version)
                  </label>
                  <input
                    type="text"
                    value={minSupportedVersion}
                    onChange={(e) => setMinSupportedVersion(e.target.value)}
                    dir="ltr"
                    className="w-full h-10 px-3.5 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">
                    أدنى رقم بناء مدعوم (Min Build)
                  </label>
                  <input
                    type="number"
                    value={minSupportedBuildNumber}
                    onChange={(e) =>
                      setMinSupportedBuildNumber(
                        parseInt(e.target.value, 10) || 1,
                      )
                    }
                    dir="ltr"
                    className="w-full h-10 px-3.5 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  سياسة التحديث عند فتح التطبيق
                </label>
                <select
                  value={updateType}
                  onChange={(e) =>
                    setUpdateType(e.target.value as AppUpdateType)
                  }
                  className="w-full h-10 px-3.5 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
                >
                  <option value={AppUpdateType.OPTIONAL}>
                    تحديث مرن (OPTIONAL - قابل للتخطي)
                  </option>
                  <option value={AppUpdateType.FORCE}>
                    تحديث إجباري (FORCE - يمنع الدخول حتى التحديث)
                  </option>
                  <option value={AppUpdateType.PATCH}>
                    رقعة برمجية هوائية (PATCH)
                  </option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  رابط تحميل حزمة APK المباشر (Cloudflare R2)
                </label>
                <div className="relative">
                  <DownloadCloud className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="url"
                    value={downloadUrl}
                    onChange={(e) => setDownloadUrl(e.target.value)}
                    dir="ltr"
                    className="w-full h-10 pr-3.5 pl-10 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  رابط قناة تيليجرام الاحتياطية
                </label>
                <input
                  type="url"
                  value={telegramChannelUrl}
                  onChange={(e) => setTelegramChannelUrl(e.target.value)}
                  dir="ltr"
                  className="w-full h-10 px-3.5 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  ملاحظات الإصدار (Release Notes)
                </label>
                <textarea
                  rows={2}
                  value={releaseNotes}
                  onChange={(e) => setReleaseNotes(e.target.value)}
                  className="w-full p-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
                />
              </div>

              {settingsSavedMsg && (
                <div className="p-3 rounded-xl bg-[#E6F6EC] text-[#15803D] text-xs font-bold flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4" />
                  <span>{settingsSavedMsg}</span>
                </div>
              )}

              <div className="flex justify-end pt-2">
                <button
                  type="submit"
                  disabled={updateSettingsMutation.isPending}
                  className="h-10 px-6 rounded-full bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center gap-2 cursor-pointer"
                >
                  <Save className="w-4 h-4" />
                  <span>حفظ إعدادات التوزيع</span>
                </button>
              </div>
            </>
          )}
        </form>

        {/* Push Notifications Broadcast Manager */}
        <div className="lg:col-span-5 space-y-5">
          <form
            onSubmit={(e) => {
              e.preventDefault();
              if (!broadcastTitle.trim() || !broadcastBody.trim()) return;
              broadcastMutation.mutate();
            }}
            className="bg-white rounded-2xl p-6 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] space-y-4"
          >
            <div className="flex items-center gap-2.5 pb-3 border-b border-slate-100">
              <div className="w-9 h-9 rounded-xl bg-[#FFF6EB] text-[#D97706] flex items-center justify-center">
                <Megaphone className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-base font-bold text-[#111827]">
                  إرسال إشعار جماعي (Push Broadcast)
                </h3>
                <p className="text-xs text-slate-400">
                  إرسال تنبيهات قطفة الصباح أو العروض عبر FCM
                </p>
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                عنوان الإشعار
              </label>
              <input
                type="text"
                required
                value={broadcastTitle}
                onChange={(e) => setBroadcastTitle(e.target.value)}
                placeholder="مثال: وصول قطفة الهمداني الطازجة اليوم"
                className="w-full h-10 px-3.5 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                نص الرسالة
              </label>
              <textarea
                rows={3}
                required
                value={broadcastBody}
                onChange={(e) => setBroadcastBody(e.target.value)}
                placeholder="اكتب محتوى الإشعار الموجز للمستخدمين..."
                className="w-full p-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  الفئة المستهدفة
                </label>
                <select
                  value={broadcastAudience}
                  onChange={(e) =>
                    setBroadcastAudience(e.target.value as any)
                  }
                  className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
                >
                  <option value="ALL">جميع المستخدمين</option>
                  <option value="CUSTOMERS">المشترين فقط</option>
                  <option value="SELLERS">البائعين (المقاوتية)</option>
                  <option value="GOVERNORATE">محافظة محددة</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  الرابط العميق (Deep Link)
                </label>
                <input
                  type="text"
                  value={broadcastDeepLink}
                  onChange={(e) => setBroadcastDeepLink(e.target.value)}
                  dir="ltr"
                  className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
                />
              </div>
            </div>

            {broadcastSentMsg && (
              <div className="p-3 rounded-xl bg-[#E6F6EC] text-[#15803D] text-xs font-bold flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4" />
                <span>{broadcastSentMsg}</span>
              </div>
            )}

            <button
              type="submit"
              disabled={broadcastMutation.isPending}
              className="w-full h-10 rounded-full bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center justify-center gap-2 cursor-pointer"
            >
              <Send className="w-3.5 h-3.5" />
              <span>إرسال الإشعار الآن</span>
            </button>
          </form>

          {/* Recent Broadcasts History */}
          <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] space-y-3">
            <div className="flex items-center gap-2">
              <BellRing className="w-4 h-4 text-[#115E31]" />
              <h4 className="text-sm font-bold text-[#111827]">
                سجل الإشعارات المرسلة
              </h4>
            </div>
            <div className="space-y-2.5 max-h-56 overflow-y-auto">
              {broadcasts.map((b) => (
                <div
                  key={b.id}
                  className="p-3 rounded-xl bg-[#F8FAFC] border border-slate-100 space-y-1"
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-xs font-extrabold text-[#111827]">
                      {b.title}
                    </span>
                    <span className="px-2 py-0.5 rounded-full bg-[#E6F6EC] text-[#15803D] text-[10px] font-bold">
                      {b.audience}
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-600">{b.body}</p>
                  <div className="text-[10px] text-slate-400">
                    بواسطة {b.sentBy} · {b.sentAt}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
