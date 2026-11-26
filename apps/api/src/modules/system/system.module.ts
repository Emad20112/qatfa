import { Module } from "@nestjs/common";
import { SystemService } from "./system.service";
import { SystemController } from "./system.controller";
import { AppVersion } from "../../database/entities/app-version.entity";
import { InMemoryDatabaseModule } from "../../database/in-memory-database.module";

@Module({
  imports: [InMemoryDatabaseModule.forFeature([AppVersion])],
  controllers: [SystemController],
  providers: [SystemService],
  exports: [SystemService],
})
export class SystemModule {}
