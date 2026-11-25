import React from "react";
import { ArrowUp } from "lucide-react";

export type SparklineTone = "mint" | "amber" | "blue" | "rose";

interface SparklineCardProps {
  value: string | number;
  label: string;
  trendPercent: number;
  tone: SparklineTone;
  icon: React.ReactNode;
  points?: number[];
}

const TONE_MAP: Record<
  SparklineTone,
  {
    bg: string;
    iconBg: string;
    iconColor: string;
    stroke: string;
    trendColor: string;
  }
> = {
  mint: {
    bg: "bg-gradient-to-br from-[#E4F7EC] to-[#F3FCF6]",
    iconBg: "bg-[#C7EBD6]",
    iconColor: "text-[#147A3B]",
    stroke: "#16A34A",
    trendColor: "text-[#15803D]",
  },
  amber: {
    bg: "bg-gradient-to-br from-[#FEF3E1] to-[#FFFBF3]",
    iconBg: "bg-[#F59E0B]",
    iconColor: "text-white",
    stroke: "#F59E0B",
    trendColor: "text-[#15803D]",
  },
  blue: {
    bg: "bg-gradient-to-br from-[#E7F1FE] to-[#F4F8FF]",
    iconBg: "bg-[#1D6FE2]",
    iconColor: "text-white",
    stroke: "#2563EB",
    trendColor: "text-[#15803D]",
  },
  rose: {
    bg: "bg-gradient-to-br from-[#FDECEC] to-[#FFF5F5]",
    iconBg: "bg-[#E53935]",
    iconColor: "text-white",
    stroke: "#EF4444",
    trendColor: "text-[#DC2626]",
  },
};

export const SparklineCard: React.FC<SparklineCardProps> = ({
  value,
  label,
  trendPercent,
  tone,
  icon,
  points = [18, 28, 22, 36, 30, 44, 48],
}) => {
  const palette = TONE_MAP[tone];
  const width = 128;
  const height = 28;
  const max = Math.max(...points);
  const min = Math.min(...points);
  const span = max - min || 1;

  const coords = points.map((p, idx) => {
    const x = (idx / Math.max(1, points.length - 1)) * (width - 8) + 4;
    const y = height - 4 - ((p - min) / span) * (height - 10);
    return { x, y };
  });

  const pathD = coords.reduce((acc, pt, idx) => {
    if (idx === 0) return `M ${pt.x} ${pt.y}`;
    const prev = coords[idx - 1];
    const cx = (prev.x + pt.x) / 2;
    return `${acc} C ${cx} ${prev.y}, ${cx} ${pt.y}, ${pt.x} ${pt.y}`;
  }, "");

  const lastPoint = coords[coords.length - 1];

  return (
    <div
      className={`${palette.bg} rounded-2xl px-5 py-4 border border-black/[0.03] shadow-[0_2px_10px_rgba(15,23,42,0.03)] flex flex-col justify-between gap-2 transition-transform duration-150 hover:-translate-y-0.5`}
    >
      <div className="flex items-start justify-between gap-3">
        <div
          className={`w-11 h-11 rounded-full ${palette.iconBg} ${palette.iconColor} flex items-center justify-center shrink-0 shadow-xs`}
        >
          {icon}
        </div>
        <div className="text-left">
          <div className="text-[26px] leading-tight font-extrabold text-[#111827] tabular-nums">
            {typeof value === "number" ? value.toLocaleString("en-US") : value}
          </div>
          <div className="text-[13px] font-semibold text-[#374151] mt-0.5">
            {label}
          </div>
        </div>
      </div>

      <div className="flex items-center justify-between gap-2 pt-1">
        <svg
          width={width}
          height={height}
          viewBox={`0 0 ${width} ${height}`}
          className="overflow-visible shrink-0"
          aria-hidden="true"
        >
          <path
            d={pathD}
            fill="none"
            stroke={palette.stroke}
            strokeWidth="2"
            strokeLinecap="round"
          />
          {lastPoint && (
            <circle
              cx={lastPoint.x}
              cy={lastPoint.y}
              r="3"
              fill={palette.stroke}
            />
          )}
        </svg>

        <span
          className={`inline-flex items-center gap-0.5 text-xs font-bold tabular-nums ${palette.trendColor}`}
        >
          {trendPercent}%
          <ArrowUp className="w-3.5 h-3.5" />
        </span>
      </div>
    </div>
  );
};
