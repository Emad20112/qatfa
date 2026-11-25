import { Controller, Get, Res } from "@nestjs/common";
import { FastifyReply } from "fastify";
import * as fs from "fs";
import * as path from "path";
import { Public } from "./decorators/roles.decorator";

export function resolveAdminDistPath(): string | null {
  const candidates = [
    path.resolve(process.cwd(), "apps/admin/dist"),
    path.resolve(process.cwd(), "../admin/dist"),
    path.resolve(__dirname, "../../../../apps/admin/dist"),
    path.resolve(__dirname, "../../../admin/dist"),
  ];
  return candidates.find((p) => fs.existsSync(path.join(p, "index.html"))) || null;
}

@Public()
@Controller()
export class SpaController {
  @Get([
    "/",
    "users",
    "sellers",
    "verifications",
    "markets",
    "bookings",
    "reports",
    "analytics",
    "settings",
    "audit-logs",
    "support",
  ])
  serveSpa(@Res() reply: FastifyReply) {
    const distPath = resolveAdminDistPath();
    if (!distPath) {
      return reply.redirect("/docs");
    }
    const indexHtml = fs.readFileSync(path.join(distPath, "index.html"), "utf-8");
    return reply.type("text/html; charset=utf-8").send(indexHtml);
  }
}
