import React, { useState } from "react";
import { MapPin, Maximize2, X } from "lucide-react";

export interface MarketMapPin {
  id: number;
  name: string;
  x: number;
  y: number;
  storesCount: number;
}

interface YemenMarketsMapProps {
  pins: MarketMapPin[];
  activeMarketsCount: number;
  compact?: boolean;
}

export const YemenMarketsMap: React.FC<YemenMarketsMapProps> = ({
  pins,
  activeMarketsCount,
  compact = true,
}) => {
  const [selectedPin, setSelectedPin] = useState<MarketMapPin | null>(null);
  const [expanded, setExpanded] = useState(false);

  const renderSvg = (heightClass: string) => (
    <div className={`relative w-full ${heightClass} flex items-center justify-center`}>
      <svg
        viewBox="0 0 220 140"
        className="w-full h-full drop-shadow-xs"
        role="img"
        aria-label="خريطة أسواق اليمن"
      >
        {/* Stylized outline of Yemen governorates matching reference */}
        <path
          d="M36 42 L58 26 L94 22 L145 14 L196 18 L206 36 L192 58 L160 69 L126 84 L95 102 L68 114 L46 118 L34 102 L26 76 Z"
          fill="#EAEFF3"
          stroke="#FFFFFF"
          strokeWidth="2"
          strokeLinejoin="round"
        />
        {/* Internal governorate lines */}
        <path
          d="M58 26 L72 64 L46 118 M94 22 L95 102 M145 14 L126 84 M32 76 L95 66 L160 69"
          fill="none"
          stroke="#FFFFFF"
          strokeWidth="1.2"
          strokeOpacity="0.9"
        />
        {/* Socotra */}
        <ellipse cx="195" cy="112" rx="8" ry="3.5" fill="#EAEFF3" stroke="#FFFFFF" strokeWidth="1.2" />

        {pins.slice(0, compact ? 5 : pins.length).map((pin) => {
          const cx = (pin.x / 100) * 180 + 20;
          const cy = (pin.y / 100) * 105 + 12;
          const isSelected = selectedPin?.id === pin.id;
          return (
            <g
              key={pin.id}
              transform={`translate(${cx}, ${cy})`}
              className="cursor-pointer"
              onClick={() => setSelectedPin(pin)}
              onMouseEnter={() => setSelectedPin(pin)}
            >
              <circle
                r={isSelected ? 10 : 7}
                fill="#166534"
                fillOpacity="0.16"
              />
              <path
                d="M0 -11 C-4.2 -11 -7.5 -7.7 -7.5 -3.6 C-7.5 1.8 0 8 0 8 C0 8 7.5 1.8 7.5 -3.6 C7.5 -7.7 4.2 -11 0 -11 Z"
                fill={isSelected ? "#15803D" : "#115E31"}
                stroke="#FFFFFF"
                strokeWidth="1.2"
              />
              <circle cx="0" cy="-3.8" r="2.3" fill="#FFFFFF" />
            </g>
          );
        })}
      </svg>

      {selectedPin && (
        <div className="absolute top-2 right-2 bg-white/95 backdrop-blur-xs border border-emerald-100 shadow-md rounded-xl px-3 py-1.5 text-xs">
          <div className="font-bold text-[#0F4C2A]">{selectedPin.name}</div>
          <div className="text-slate-500 tabular-nums">
            {selectedPin.storesCount} متجر ومفرش نشط
          </div>
        </div>
      )}
    </div>
  );

  return (
    <>
      <div className="relative flex flex-col justify-between h-full">
        <div className="flex items-center justify-between mb-1">
          <h3 className="text-base font-bold text-[#111827]">خريطة الأسواق</h3>
          {compact && (
            <button
              type="button"
              onClick={() => setExpanded(true)}
              className="w-8 h-8 rounded-lg border border-slate-200 text-slate-500 hover:text-[#115E31] hover:border-emerald-200 flex items-center justify-center transition-colors cursor-pointer"
              title="تكبير الخريطة"
            >
              <Maximize2 className="w-4 h-4" />
            </button>
          )}
        </div>

        {renderSvg(compact ? "h-[168px]" : "h-[280px]")}

        <div className="flex justify-end pt-2">
          <button
            type="button"
            onClick={() => setExpanded(true)}
            className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-[#EAF7EF] text-[#115E31] text-xs font-bold hover:bg-[#DCF2E4] transition-colors cursor-pointer tabular-nums"
          >
            <MapPin className="w-3.5 h-3.5" />
            <span>{activeMarketsCount} أسواق نشطة</span>
          </button>
        </div>
      </div>

      {expanded && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-2xl p-6 shadow-2xl border border-slate-100">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-lg font-extrabold text-[#111827]">
                  توزيع أسواق قطفة النشطة في الجمهورية اليمنية
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  انقر على أي دبوس لاستعراض تفاصيل السوق وعدد المفارش النشطة
                </p>
              </div>
              <button
                type="button"
                onClick={() => setExpanded(false)}
                className="w-9 h-9 rounded-xl bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-600 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {renderSvg("h-[320px]")}

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 mt-4">
              {pins.map((pin) => (
                <button
                  key={pin.id}
                  type="button"
                  onClick={() => setSelectedPin(pin)}
                  className={`text-right p-2.5 rounded-xl border transition-colors cursor-pointer ${
                    selectedPin?.id === pin.id
                      ? "border-[#15803D] bg-[#EAF7EF]"
                      : "border-slate-100 bg-slate-50 hover:bg-slate-100"
                  }`}
                >
                  <div className="text-xs font-bold text-[#111827] truncate">
                    {pin.name}
                  </div>
                  <div className="text-[11px] text-[#15803D] font-semibold mt-0.5 tabular-nums">
                    {pin.storesCount} مفرش نشط
                  </div>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </>
  );
};
