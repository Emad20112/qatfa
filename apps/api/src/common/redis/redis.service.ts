import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import Redis, { RedisOptions } from "ioredis";

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client: Redis | null = null;
  private isConnected = false;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    const host = this.configService.get<string>("REDIS_HOST", "localhost");
    const port = parseInt(
      this.configService.get<string>("REDIS_PORT", "6379"),
      10,
    );
    const password = this.configService.get<string>("REDIS_PASSWORD", undefined);

    const options: RedisOptions = {
      host,
      port,
      password: password && password.length > 0 ? password : undefined,
      lazyConnect: true,
      maxRetriesPerRequest: 1,
      connectTimeout: 2000,
      retryStrategy: (times) => {
        if (times > 3) {
          // التراجع وعدم محاولة الاتصال المتكرر لعدم استنزاف الموارد
          return null;
        }
        return Math.min(times * 500, 2000);
      },
    };

    try {
      this.client = new Redis(options);

      this.client.on("connect", () => {
        this.isConnected = true;
        this.logger.log(`⚡ متصل بنجاح بخادم Redis على: ${host}:${port}`);
      });

      this.client.on("error", (err) => {
        this.isConnected = false;
        this.logger.warn(`⚠️ تعذر الاتصال بـ Redis (${err.message}) - سيتم التراجع لقاعدة البيانات المباشرة`);
      });

      this.client.on("close", () => {
        this.isConnected = false;
      });

      this.client.connect().catch((err) => {
        this.logger.warn(`⚠️ فشل الاتصال الأولي بـ Redis (${err.message})`);
      });
    } catch (err: any) {
      this.logger.warn(`⚠️ استثناء عند تهيئة عميل Redis: ${err.message}`);
    }
  }

  async onModuleDestroy() {
    if (this.client) {
      try {
        await this.client.quit();
      } catch {
        // تجاهل أخطاء الإغلاق
      }
    }
  }

  get isReady(): boolean {
    return this.isConnected && this.client !== null && this.client.status === "ready";
  }

  async get<T = any>(key: string): Promise<T | null> {
    if (!this.isReady || !this.client) return null;
    try {
      const data = await this.client.get(key);
      if (!data) return null;
      return JSON.parse(data) as T;
    } catch (err: any) {
      this.logger.debug(`فشل قراءة الكاش للمفتاح ${key}: ${err.message}`);
      return null;
    }
  }

  async set(key: string, value: any, ttlSeconds?: number): Promise<void> {
    if (!this.isReady || !this.client) return;
    try {
      const payload = JSON.stringify(value);
      if (ttlSeconds && ttlSeconds > 0) {
        await this.client.set(key, payload, "EX", ttlSeconds);
      } else {
        await this.client.set(key, payload);
      }
    } catch (err: any) {
      this.logger.debug(`فشل كتابة الكاش للمفتاح ${key}: ${err.message}`);
    }
  }

  async del(key: string): Promise<void> {
    if (!this.isReady || !this.client) return;
    try {
      await this.client.del(key);
    } catch (err: any) {
      this.logger.debug(`فشل حذف الكاش للمفتاح ${key}: ${err.message}`);
    }
  }

  async delByPattern(pattern: string): Promise<void> {
    if (!this.isReady || !this.client) return;
    try {
      const stream = this.client.scanStream({
        match: pattern,
        count: 100,
      });

      stream.on("data", async (keys: string[]) => {
        if (keys.length > 0 && this.client) {
          const pipeline = this.client.pipeline();
          keys.forEach((key) => pipeline.del(key));
          await pipeline.exec();
        }
      });
    } catch (err: any) {
      this.logger.debug(`فشل حذف الكاش بالنمط ${pattern}: ${err.message}`);
    }
  }

  async invalidateMarket(marketId: number): Promise<void> {
    await this.delByPattern(`feed:*:${marketId}:*`);
    await this.delByPattern(`search:*:${marketId}:*`);
    await this.delByPattern(`market:${marketId}:*`);
    this.logger.debug(`تم إبطال كاش السوق [${marketId}] بنجاح`);
  }

  async invalidateStore(storeId: string): Promise<void> {
    await this.del(`store:${storeId}`);
    await this.delByPattern(`store:${storeId}:*`);
  }
}
