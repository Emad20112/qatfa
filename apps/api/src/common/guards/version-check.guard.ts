import {
  Injectable,
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Logger,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";

/**
 * حارس التحقق من إصدار التطبيق (وفق ميثاق docs/24 و docs/27)
 * يفحص ترويسة X-App-Build، وإذا كان الإصدار قديماً وغير مدعوم، يرجع 426 Upgrade Required
 */
@Injectable()
export class VersionCheckGuard implements CanActivate {
  private readonly logger = new Logger(VersionCheckGuard.name);

  constructor(private readonly configService: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const appBuildHeader = request.headers["x-app-build"];
    const appPlatform = request.headers["x-app-platform"] || "android";

    // مسارات مستثناة من الفحص الإلزامي (مثل الاستعلام عن الإصدار نفسه وفحص الصحة)
    const url = request.url;
    if (url.includes("/system/app-version") || url.includes("/health")) {
      return true;
    }

    if (appBuildHeader) {
      const clientBuildNumber = parseInt(appBuildHeader, 10);
      const minSupportedBuild = parseInt(
        this.configService.get<string>("MIN_SUPPORTED_BUILD", "1"),
        10,
      );

      if (!isNaN(clientBuildNumber) && clientBuildNumber < minSupportedBuild) {
        this.logger.warn(
          `رفض طلب من تطبيق قديم: Build=${clientBuildNumber}، الحد الأدنى المطلوب=${minSupportedBuild}`,
        );

        throw new HttpException(
          {
            success: false,
            statusCode: 426, // 426 Upgrade Required
            message:
              "يتطلب التطبيق تحديثاً فورياً لمتابعة الاستخدام وحماية أمان حسابك",
            data: {
              isForceUpdate: true,
              downloadUrl: this.configService.get<string>("APK_DOWNLOAD_URL"),
              telegramUrl: this.configService.get<string>(
                "TELEGRAM_CHANNEL_URL",
              ),
            },
            error: "UPGRADE_REQUIRED",
          },
          426,
        );
      }
    }

    return true;
  }
}
