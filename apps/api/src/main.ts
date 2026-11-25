import { NestFactory } from "@nestjs/core";
import {
  FastifyAdapter,
  NestFastifyApplication,
} from "@nestjs/platform-fastify";
import { ValidationPipe, Logger, RequestMethod } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import helmet from "@fastify/helmet";
import fastifyStatic from "@fastify/static";
import { AppModule } from "./app.module";
import { TransformInterceptor } from "./common/interceptors/transform.interceptor";
import { AllExceptionsFilter } from "./common/filters/http-exception.filter";
import { VersionCheckGuard } from "./common/guards/version-check.guard";
import { resolveAdminDistPath } from "./common/spa.controller";

async function bootstrap() {
  const logger = new Logger("QatfaBootstrap");

  const fastifyAdapter = new FastifyAdapter({
    logger: false,
  });

  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    fastifyAdapter,
  );

  const configService = app.get(ConfigService);
  const port = parseInt(String(configService.get("PORT", 3000)), 10) || 3000;
  const host = configService.get<string>("HOST", "0.0.0.0");
  const apiPrefix = configService.get<string>("API_PREFIX", "api/v1");

  // أمان الترويسات عبر Helmet
  await app.register(helmet, {
    contentSecurityPolicy: false,
  });

  // خدمة ملفات لوحة التحكم الإدارية الثابتة عند توفر البناء
  const adminDistPath = resolveAdminDistPath();
  if (adminDistPath) {
    await app.register(fastifyStatic, {
      root: adminDistPath,
      prefix: "/",
      wildcard: false,
      index: false,
    });
  }

  // تفعيل الـ CORS لتطبيقات الويب والموبايل
  app.enableCors({
    origin: true,
    methods: "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS",
    credentials: true,
  });

  // بادئة المسار الموحدة للمنصة مع استثناء مسارات لوحة التحكم
  app.setGlobalPrefix(apiPrefix, {
    exclude: [
      { path: "/", method: RequestMethod.GET },
      { path: "/users", method: RequestMethod.GET },
      { path: "/sellers", method: RequestMethod.GET },
      { path: "/verifications", method: RequestMethod.GET },
      { path: "/markets", method: RequestMethod.GET },
      { path: "/bookings", method: RequestMethod.GET },
      { path: "/reports", method: RequestMethod.GET },
      { path: "/analytics", method: RequestMethod.GET },
      { path: "/settings", method: RequestMethod.GET },
      { path: "/audit-logs", method: RequestMethod.GET },
      { path: "/support", method: RequestMethod.GET },
    ],
  });

  // الفلاتر والحراس والتحويلات المعتمدة
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );
  app.useGlobalInterceptors(new TransformInterceptor());
  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalGuards(new VersionCheckGuard(configService));

  // إعداد توثيق Swagger للـ APIs
  const swaggerConfig = new DocumentBuilder()
    .setTitle("قطفة API - Qatfa RESTful Engine")
    .setDescription(
      "واجهات البرمجة لمنصة قطفة لتجارة واستكشاف القات في الجمهورية اليمنية",
    )
    .setVersion("1.0.0")
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app as any, swaggerConfig);
  SwaggerModule.setup("docs", app as any, document);

  await app.listen(port, host);
  logger.log(
    `🌿 منصة قطفة - لوحة التحكم والخادم يعملان على: http://${host}:${port}/`,
  );
  logger.log(`📑 توثيق الـ Swagger متاح على: http://${host}:${port}/docs`);
}

bootstrap();
