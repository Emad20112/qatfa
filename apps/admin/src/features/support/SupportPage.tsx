import React, { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  CheckCircle2,
  ChevronDown,
  Clock,
  Headphones,
  ListFilter,
  MessageSquare,
  Phone,
  RefreshCw,
  Search,
  Send,
  X,
} from "lucide-react";
import { adminApi } from "../../services/api";
import { SparklineCard } from "../../components/ui/SparklineCard";

export const SupportPage: React.FC = () => {
  const queryClient = useQueryClient();

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [selectedTicket, setSelectedTicket] = useState<any | null>(null);
  const [replyText, setReplyText] = useState("");
  const [nextStatus, setNextStatus] = useState<
    "OPEN" | "IN_PROGRESS" | "RESOLVED"
  >("IN_PROGRESS");

  const { data: tickets = [], isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-support", search, statusFilter],
    queryFn: () =>
      adminApi.getSupportTickets({ search, status: statusFilter }),
  });

  const mutation = useMutation({
    mutationFn: ({
      id,
      status,
      reply,
    }: {
      id: string;
      status: "OPEN" | "IN_PROGRESS" | "RESOLVED";
      reply: string;
    }) => adminApi.updateSupportTicket(id, { status, reply }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["admin-support"] });
      setSelectedTicket(null);
      setReplyText("");
    },
  });

  const openCount = tickets.filter((t) => t.status === "OPEN").length;
  const inProgressCount = tickets.filter(
    (t) => t.status === "IN_PROGRESS",
  ).length;
  const resolvedCount = tickets.filter((t) => t.status === "RESOLVED").length;

  const renderStatusPill = (status: string) => {
    if (status === "OPEN") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#FEE2E2] text-[#DC2626] text-xs font-bold">
          <MessageSquare className="w-3.5 h-3.5" />
          <span>تذكرة مفتوحة</span>
        </span>
      );
    }
    if (status === "IN_PROGRESS") {
      return (
        <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#FEF3C7] text-[#D97706] text-xs font-bold">
          <Clock className="w-3.5 h-3.5" />
          <span>جاري المتابعة</span>
        </span>
      );
    }
    return (
      <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#DCFCE7] text-[#15803D] text-xs font-bold">
        <CheckCircle2 className="w-3.5 h-3.5" />
        <span>تم الحل</span>
      </span>
    );
  };

  return (
    <div className="space-y-5">
      <div>
        <div className="flex items-center gap-2.5">
          <span className="w-9 h-9 rounded-xl bg-[#E6F6EC] text-[#115E31] flex items-center justify-center">
            <Headphones className="w-5 h-5" />
          </span>
          <h1 className="text-2xl font-extrabold text-[#111827]">
            الدعم الفني
          </h1>
        </div>
        <div className="text-xs font-semibold text-slate-500 mt-1 mr-11">
          الرئيسية <span className="mx-1">‹</span> الدعم الفني
        </div>
      </div>

      {/* 4 Sparkline KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <SparklineCard
          value={tickets.length}
          label="إجمالي التذاكر الواردة"
          trendPercent={9}
          tone="mint"
          icon={<Headphones className="w-5 h-5" />}
        />
        <SparklineCard
          value={openCount}
          label="تذاكر جديدة بانتظار الرد"
          trendPercent={12}
          tone="rose"
          icon={<MessageSquare className="w-5 h-5" />}
        />
        <SparklineCard
          value={inProgressCount}
          label="قيد المتابعة"
          trendPercent={6}
          tone="amber"
          icon={<Clock className="w-5 h-5" />}
        />
        <SparklineCard
          value={resolvedCount}
          label="تذاكر مغلقة"
          trendPercent={19}
          tone="blue"
          icon={<CheckCircle2 className="w-5 h-5" />}
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
            placeholder="ابحث برقم التذكرة أو الموضوع أو اسم المرسل..."
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
            <option value="OPEN">مفتوحة</option>
            <option value="IN_PROGRESS">جاري المتابعة</option>
            <option value="RESOLVED">تم الحل</option>
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

      {/* Tickets Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-[0_2px_12px_rgba(15,23,42,0.03)] overflow-x-auto">
        <table className="w-full min-w-[840px] text-right">
          <thead>
            <tr className="bg-[#F8FAFC] border-b border-slate-100 text-xs font-extrabold text-slate-600">
              <th className="py-3.5 px-5">#</th>
              <th className="py-3.5 px-4">الموضوع والرسالة</th>
              <th className="py-3.5 px-4 text-center">المرسل</th>
              <th className="py-3.5 px-4 text-center">الأولوية</th>
              <th className="py-3.5 px-4 text-center">الحالة</th>
              <th className="py-3.5 px-5 text-center">إجراءات</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {isLoading ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-400">
                  جاري تحميل تذاكر الدعم الفني...
                </td>
              </tr>
            ) : tickets.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-slate-500">
                  لا توجد تذاكر دعم مطابقة
                </td>
              </tr>
            ) : (
              tickets.map((ticket) => (
                <tr
                  key={ticket.id}
                  className="hover:bg-[#F8FBF9] transition-colors"
                >
                  <td className="py-3.5 px-5 font-bold text-slate-700 tabular-nums whitespace-nowrap">
                    {ticket.ticketCode}
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="font-bold text-[#111827]">
                      {ticket.subject}
                    </div>
                    <div className="text-xs text-slate-500 mt-0.5 line-clamp-1">
                      {ticket.message}
                    </div>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    <div className="text-xs font-bold text-slate-800">
                      {ticket.senderName}
                    </div>
                    <div className="text-[11px] text-slate-400">
                      {ticket.senderRole} · {ticket.createdAtLabel}
                    </div>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    <span
                      className={`px-3 py-1 rounded-full text-xs font-bold ${
                        ticket.priority === "عاجل"
                          ? "bg-red-50 text-red-700"
                          : ticket.priority === "متوسط"
                            ? "bg-amber-50 text-amber-700"
                            : "bg-slate-100 text-slate-600"
                      }`}
                    >
                      {ticket.priority}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-center">
                    {renderStatusPill(ticket.status)}
                  </td>
                  <td className="py-3.5 px-5 text-center">
                    <button
                      type="button"
                      onClick={() => {
                        setSelectedTicket(ticket);
                        setReplyText(ticket.reply || "");
                        setNextStatus(
                          ticket.status === "OPEN"
                            ? "IN_PROGRESS"
                            : ticket.status,
                        );
                      }}
                      className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#EFFAF3] border border-[#CBEBD6] text-[#115E31] text-xs font-bold hover:bg-[#E1F5E8] cursor-pointer whitespace-nowrap"
                    >
                      <MessageSquare className="w-3.5 h-3.5" />
                      <span>الرد والمتابعة</span>
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Ticket Reply Modal */}
      {selectedTicket && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <form
            onSubmit={(e) => {
              e.preventDefault();
              mutation.mutate({
                id: selectedTicket.id,
                status: nextStatus,
                reply: replyText,
              });
            }}
            className="bg-white rounded-3xl w-full max-w-lg p-6 shadow-2xl border border-slate-100 space-y-4"
          >
            <div className="flex items-start justify-between gap-3">
              <div>
                <div className="text-xs font-bold text-[#15803D] tabular-nums">
                  {selectedTicket.ticketCode} · {selectedTicket.senderRole}
                </div>
                <h3 className="text-base font-extrabold text-[#111827] mt-0.5">
                  {selectedTicket.subject}
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setSelectedTicket(null)}
                className="w-8 h-8 rounded-xl bg-slate-100 flex items-center justify-center cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="bg-[#F8FAFC] p-4 rounded-2xl border border-slate-100 text-xs space-y-2">
              <div className="flex items-center justify-between">
                <span className="font-bold text-slate-800">
                  {selectedTicket.senderName}
                </span>
                <span
                  className="inline-flex items-center gap-1 text-slate-600 font-bold tabular-nums"
                  dir="ltr"
                >
                  <Phone className="w-3.5 h-3.5 text-[#115E31]" />
                  {selectedTicket.phoneNumber}
                </span>
              </div>
              <p className="text-slate-600 leading-relaxed">
                {selectedTicket.message}
              </p>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                حالة التذكرة
              </label>
              <select
                value={nextStatus}
                onChange={(e) => setNextStatus(e.target.value as any)}
                className="w-full h-10 px-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs font-bold"
              >
                <option value="OPEN">مفتوحة</option>
                <option value="IN_PROGRESS">جاري المتابعة</option>
                <option value="RESOLVED">تم الحل وإغلاق التذكرة</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                رد فريق الدعم الفني
              </label>
              <textarea
                rows={3}
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                placeholder="اكتب الرد أو التوجيه الميداني للعميل أو التاجر..."
                className="w-full p-3 rounded-xl bg-[#F8FAFC] border border-slate-200 text-xs"
              />
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setSelectedTicket(null)}
                className="px-4 py-2 rounded-xl bg-slate-100 text-slate-700 text-xs font-bold cursor-pointer"
              >
                إلغاء
              </button>
              <button
                type="submit"
                disabled={mutation.isPending}
                className="px-5 py-2 rounded-xl bg-[#0C5A2C] hover:bg-[#094722] text-white text-xs font-bold inline-flex items-center gap-1.5 cursor-pointer"
              >
                <Send className="w-3.5 h-3.5" />
                <span>حفظ وإرسال الرد</span>
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
