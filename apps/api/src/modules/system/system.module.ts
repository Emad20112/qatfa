import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { SystemService } from "./system.service";
import { SystemController } from "./system.controller";
import { AppVersion } from "../../database/entities/app-version.entity";

@Module({
  imports: [TypeOrmModule.forFeature([AppVersion])],
  controllers: [SystemController],
  providers: [SystemService],
  exports: [SystemService],
})
export class SystemModule {}
