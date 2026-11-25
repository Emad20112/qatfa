import { Module } from "@nestjs/common";
import { StoresService } from "./stores.service";
import { StoresController } from "./stores.controller";
import { Store } from "../../database/entities/store.entity";
import { User } from "../../database/entities/user.entity";
import { InMemoryDatabaseModule } from "../../database/in-memory-database.module";

@Module({
  imports: [InMemoryDatabaseModule.forFeature([Store, User])],
  controllers: [StoresController],
  providers: [StoresService],
  exports: [StoresService],
})
export class StoresModule {}
