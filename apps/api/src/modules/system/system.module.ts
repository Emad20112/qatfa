import { Module } from "@nestjs/common";
import { SystemService } from "./system.service";
import { SystemController } from "./system.controller";
import { AppVersion } from "../../database/entities/app-version.entity";
import { DatabaseModule } from "../../database/database.module";

@Module({
  imports: [DatabaseModule.forFeature([AppVersion])],
  controllers: [SystemController],
  providers: [SystemService],
  exports: [SystemService],
})
export class SystemModule {}
