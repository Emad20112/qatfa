import { Controller, Get, Query } from "@nestjs/common";
import { SystemService } from "./system.service";
import { Public } from "../../common/decorators/roles.decorator";

@Controller("system")
export class SystemController {
  constructor(private readonly systemService: SystemService) {}

  @Public()
  @Get("app-version")
  async checkAppVersion(
    @Query("platform") platform?: string,
    @Query("currentVersion") currentVersion?: string,
    @Query("buildNumber") buildNumber?: string,
    @Query("installerStore") installerStore?: string,
  ) {
    return this.systemService.checkVersion({
      platform,
      currentVersion,
      buildNumber,
      installerStore,
    });
  }

  @Public()
  @Get("health")
  async healthCheck() {
    return {
      status: "UP",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      service: "Qatfa Fastify API",
    };
  }
}
