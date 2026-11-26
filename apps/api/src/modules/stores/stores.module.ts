import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { StoresService } from "./stores.service";
import { StoresController } from "./stores.controller";
import { Store } from "../../database/entities/store.entity";
import { User } from "../../database/entities/user.entity";
import { Product } from "../../database/entities/product.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Store, User, Product])],
  controllers: [StoresController],
  providers: [StoresService],
  exports: [StoresService],
})
export class StoresModule {}
