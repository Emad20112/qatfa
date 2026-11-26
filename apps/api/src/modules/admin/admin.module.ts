import { Module } from "@nestjs/common";
import { AuthModule } from "../auth/auth.module";
import { DatabaseModule } from "../../database/database.module";
import { User } from "../../database/entities/user.entity";
import { Store } from "../../database/entities/store.entity";
import { Product } from "../../database/entities/product.entity";
import { Governorate } from "../../database/entities/governorate.entity";
import { District } from "../../database/entities/district.entity";
import { Market } from "../../database/entities/market.entity";
import { AppVersion } from "../../database/entities/app-version.entity";
import { AdminController } from "./admin.controller";
import { AdminService } from "./admin.service";

@Module({
  imports: [
    AuthModule,
    DatabaseModule.forFeature([
      User,
      Store,
      Product,
      Governorate,
      District,
      Market,
      AppVersion,
    ]),
  ],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
