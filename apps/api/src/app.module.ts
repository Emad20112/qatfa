import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { InMemoryDatabaseModule } from "./database/in-memory-database.module";
import { RedisModule } from "./common/redis/redis.module";
import { AuthModule } from "./modules/auth/auth.module";
import { UsersModule } from "./modules/users/users.module";
import { StoresModule } from "./modules/stores/stores.module";
import { ProductsModule } from "./modules/products/products.module";
import { GeoModule } from "./modules/geo/geo.module";
import { SystemModule } from "./modules/system/system.module";
import { AdminModule } from "./modules/admin/admin.module";
import { SpaController } from "./common/spa.controller";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [".env", "apps/api/.env"],
    }),
    InMemoryDatabaseModule.forRoot(),
    RedisModule,
    AuthModule,
    UsersModule,
    StoresModule,
    ProductsModule,
    GeoModule,
    SystemModule,
    AdminModule,
  ],
  controllers: [SpaController],
})
export class AppModule {}
