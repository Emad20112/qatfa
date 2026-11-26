import {
  DynamicModule,
  Global,
  Logger,
  Module,
  Provider,
} from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AllEntities } from "./index";
import { InMemoryDatabaseModule } from "./in-memory-database.module";

function isSupabaseConfigured(): boolean {
  const url = process.env.DATABASE_URL;
  if (url && !url.includes("[YOUR") && url.startsWith("postgres")) {
    return true;
  }
  const host = process.env.DB_HOST;
  const pass = process.env.DB_PASSWORD;
  return Boolean(
    host &&
      host !== "localhost" &&
      host !== "127.0.0.1" &&
      pass &&
      !pass.includes("[YOUR")
  );
}

@Global()
@Module({})
export class DatabaseModule {
  private static readonly logger = new Logger(DatabaseModule.name);

  static forRoot(): DynamicModule {
    if (isSupabaseConfigured()) {
      this.logger.log(
        "🐘 Connecting to Supabase / PostgreSQL Managed Database with SSL...",
      );

      return {
        module: DatabaseModule,
        imports: [
          TypeOrmModule.forRootAsync({
            imports: [ConfigModule],
            inject: [ConfigService],
            useFactory: (config: ConfigService) => {
              const directUrl = config.get<string>("DATABASE_URL");
              if (directUrl) {
                return {
                  type: "postgres",
                  url: directUrl,
                  entities: AllEntities,
                  synchronize: config.get<string>("DB_SYNC", "true") === "true",
                  ssl: { rejectUnauthorized: false },
                  logging: config.get<string>("DB_LOGGING") === "true",
                };
              }

              return {
                type: "postgres",
                host: config.get<string>("DB_HOST"),
                port: Number(config.get("DB_PORT", 5432)),
                username: config.get<string>("DB_USER", "postgres"),
                password: config.get<string>("DB_PASSWORD"),
                database: config.get<string>("DB_NAME", "postgres"),
                entities: AllEntities,
                synchronize: config.get<string>("DB_SYNC", "true") === "true",
                ssl: { rejectUnauthorized: false },
                logging: config.get<string>("DB_LOGGING") === "true",
              };
            },
          }),
        ],
        exports: [TypeOrmModule],
      };
    }

    // وضع التراجع الذكي لـ In-Memory عند عدم وجود اتصال مباشر بـ Supabase
    this.logger.warn(
      "🌱 Supabase Direct DB URL not fully configured — running in seamless In-Memory Mock Mode",
    );
    return InMemoryDatabaseModule.forRoot();
  }

  static forFeature(entities: Function[]): DynamicModule {
    if (isSupabaseConfigured()) {
      return TypeOrmModule.forFeature(entities);
    }
    return InMemoryDatabaseModule.forFeature(entities);
  }
}
