import { Module } from "@nestjs/common";
import { GeoService } from "./geo.service";
import { GeoController } from "./geo.controller";
import { Governorate } from "../../database/entities/governorate.entity";
import { District } from "../../database/entities/district.entity";
import { Market } from "../../database/entities/market.entity";
import { DatabaseModule } from "../../database/database.module";

@Module({
  imports: [DatabaseModule.forFeature([Governorate, District, Market])],
  controllers: [GeoController],
  providers: [GeoService],
  exports: [GeoService],
})
export class GeoModule {}
