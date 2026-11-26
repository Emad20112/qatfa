import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AllEntities } from "./database";
import { RedisModule } from "./common/redis/redis.module";
import { AuthModule } from "./modules/auth/auth.module";
import { UsersModule } from "./modules/users/users.module";
import { StoresModule } from "./modules/stores/stores.module";
import { ProductsModule } from "./modules/products/products.module";
import { GeoModule } from "./modules/geo/geo.module";
import { SystemModule } from "./modules/system/system.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [".env", "apps/api/.env"],
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        type: "postgres",
        host: config.get<string>("DB_HOST", "localhost"),
        port: parseInt(config.get<string>("DB_PORT", "5432"), 10),
        username: config.get<string>("DB_USER", "qatfa_user"),
        password: config.get<string>("DB_PASSWORD", "qatfa_secure_pass_2026"),
        database: config.get<string>("DB_NAME", "qatfa_db"),
        entities: AllEntities,
        synchronize: config.get<string>("DB_SYNC", "true") === "true",
        logging: config.get<string>("DB_LOGGING", "false") === "true",
        extra: {
          max: 30,
          min: 5,
          idleTimeoutMillis: 10000,
          connectionTimeoutMillis: 3000,
        },
      }),
      inject: [ConfigService],
    }),
    RedisModule,
    AuthModule,
    UsersModule,
    StoresModule,
    ProductsModule,
    GeoModule,
    SystemModule,
  ],
})
export class AppModule {}
