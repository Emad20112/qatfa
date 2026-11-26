import { NestFactory, Reflector } from "@nestjs/core";
import {
  FastifyAdapter,
  NestFastifyApplication,
} from "@nestjs/platform-fastify";
import { ValidationPipe, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import helmet from "@fastify/helmet";
import compress from "@fastify/compress";
import { AppModule } from "./app.module";
import { TransformInterceptor } from "./common/interceptors/transform.interceptor";
import { AllExceptionsFilter } from "./common/filters/http-exception.filter";
import { VersionCheckGuard } from "./common/guards/version-check.guard";
import { RolesGuard } from "./common/guards/roles.guard";

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
  const port = configService.get<number>("PORT", 3000);
  const host = configService.get<string>("HOST", "0.0.0.0");
  const apiPrefix = configService.get<string>("API_PREFIX", "api/v1");

  // أمان الترويسات عبر Helmet
  await app.register(helmet, {
    contentSecurityPolicy: false,
  });

  // تفعيل ضغط الاستجابات الفائق عبر Brotli و Gzip لتوفير 96% من باقات البيانات
  await app.register(compress as any, {
    encodings: ["br", "gzip", "deflate"],
    threshold: 1024,
  });

  // إضافة مقياس زمن المعالجة الداخلي Server-Timing
  const httpAdapter = app.getHttpAdapter();
  const fastifyInstance = httpAdapter.getInstance();
  fastifyInstance.addHook("onRequest", (req: any, reply: any, done: () => void) => {
    req.startTime = process.hrtime.bigint();
    done();
  });
  fastifyInstance.addHook(
    "onSend",
    (req: any, reply: any, payload: any, done: () => void) => {
      if (req.startTime) {
        const elapsedMs =
          Number(process.hrtime.bigint() - req.startTime) / 1e6;
        reply.header("Server-Timing", `total;dur=${elapsedMs.toFixed(2)}`);
      }
      done();
    },
  );

  // تفعيل الـ CORS لتطبيقات الويب والموبايل
  app.enableCors({
    origin: true,
    methods: "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS",
    credentials: true,
  });

  // بادئة المسار الموحدة للمنصة
  app.setGlobalPrefix(apiPrefix);

  // الفلاتر والحراس والتحويلات المعتمدة
  const reflector = app.get(Reflector);
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );
  app.useGlobalInterceptors(new TransformInterceptor());
  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalGuards(
    new VersionCheckGuard(configService),
    new RolesGuard(reflector),
  );

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
    `🌿 منصة قطفة - خادم الواجهات يعمل بنجاح على: http://${host}:${port}/${apiPrefix}`,
  );
  logger.log(`📑 توثيق الـ Swagger متاح على: http://${host}:${port}/docs`);
}

bootstrap();
