import { randomBytes } from "crypto";
import { ConfigService } from "@nestjs/config";

// Runtime-generated fallback secret for local preview when JWT_SECRET is not set
const runtimeFallbackSecret = randomBytes(32).toString("hex");

export function resolveJwtSecret(configService?: ConfigService): string {
  const configured =
    configService?.get<string>("JWT_SECRET") || process.env.JWT_SECRET;
  if (configured && configured.trim().length > 0) {
    return configured.trim();
  }
  return runtimeFallbackSecret;
}
