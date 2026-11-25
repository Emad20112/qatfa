import { Injectable, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { AppVersion } from "../../database/entities/app-version.entity";
import { AppUpdateType, AppVersionCheckResult } from "@qatfa/shared-types";

@Injectable()
export class SystemService {
  private readonly logger = new Logger(SystemService.name);

  constructor(
    private readonly configService: ConfigService,
    @InjectRepository(AppVersion)
    private readonly versionRepository: Repository<AppVersion>,
  ) {}

  async checkVersion(query: {
    platform?: string;
    currentVersion?: string;
    buildNumber?: string;
    installerStore?: string;
  }): Promise<AppVersionCheckResult> {
    const platform = query.platform || "android";
    const clientBuild = parseInt(query.buildNumber || "1", 10);

    let versionRecord = await this.versionRepository.findOne({
      where: { platform, isActive: true },
      order: { latestBuildNumber: "DESC" },
    });

    // في حال عدم وجود سجل بالقاعدة يتم الاعتماد على متغيرات البيئة الآمنة
    const latestVersion =
      versionRecord?.latestVersion ||
      this.configService.get("CURRENT_LATEST_VERSION", "1.0.0");
    const latestBuildNumber =
      versionRecord?.latestBuildNumber ||
      parseInt(this.configService.get("CURRENT_LATEST_BUILD", "1"), 10);
    const minSupportedVersion =
      versionRecord?.minSupportedVersion ||
      this.configService.get("MIN_SUPPORTED_VERSION", "1.0.0");
    const minSupportedBuildNumber =
      versionRecord?.minSupportedBuildNumber ||
      parseInt(this.configService.get("MIN_SUPPORTED_BUILD", "1"), 10);

    let updateType = AppUpdateType.OPTIONAL;
    if (clientBuild < minSupportedBuildNumber) {
      updateType = AppUpdateType.FORCE; // إلزامي فوري
    }

    return {
      latestVersion,
      latestBuildNumber,
      minSupportedVersion,
      minSupportedBuildNumber,
      updateType,
      title: versionRecord?.title || "تحديث جديد متوفر لمنصة قطفة 🌿",
      releaseNotes:
        versionRecord?.releaseNotes ||
        "تحسينات في الأداء وعرض خريطة الأسواق الشعبية",
      downloadUrl:
        versionRecord?.downloadUrl ||
        this.configService.get(
          "APK_DOWNLOAD_URL",
          "https://cdn.qatfa.ye/releases/qatfa-v1.0.0.apk",
        ),
      apkSizeInBytes: Number(versionRecord?.apkSizeInBytes || 15200000),
      sha256:
        versionRecord?.sha256 ||
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      telegramChannelUrl:
        versionRecord?.telegramChannelUrl ||
        this.configService.get(
          "TELEGRAM_CHANNEL_URL",
          "https://t.me/qatfa_app",
        ),
      telegramPostUrl:
        versionRecord?.telegramPostUrl || "https://t.me/qatfa_app/1",
      playStoreUrl:
        versionRecord?.playStoreUrl ||
        "https://play.google.com/store/apps/details?id=ye.qatfa.app",
      showTelegramOption: true,
    };
  }
}
