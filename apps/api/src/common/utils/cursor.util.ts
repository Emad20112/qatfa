export interface DecodedCursor {
  sortValue: string | number;
  id: string;
}

/**
 * تشفير مؤشر التصفح بصيغة Base64url Opaque Cursor
 */
export function encodeCursor(sortValue: string | number, id: string): string {
  const payload = JSON.stringify({ s: sortValue, id });
  return Buffer.from(payload, "utf-8").toString("base64url");
}

/**
 * فك تشفير مؤشر التصفح واستخراج القيمة المفتاحية والمعرف
 */
export function decodeCursor(cursor?: string): DecodedCursor | null {
  if (!cursor || typeof cursor !== "string") {
    return null;
  }

  try {
    const raw = Buffer.from(cursor, "base64url").toString("utf-8");
    const parsed = JSON.parse(raw);
    if (!parsed || parsed.s === undefined || !parsed.id) {
      return null;
    }
    return {
      sortValue: parsed.s,
      id: parsed.id,
    };
  } catch {
    return null;
  }
}
