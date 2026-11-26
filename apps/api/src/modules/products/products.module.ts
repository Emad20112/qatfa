import { Module } from "@nestjs/common";
import { ProductsService } from "./products.service";
import { ProductsController } from "./products.controller";
import { Product } from "../../database/entities/product.entity";
import { Store } from "../../database/entities/store.entity";
import { DatabaseModule } from "../../database/database.module";

@Module({
  imports: [DatabaseModule.forFeature([Product, Store])],
  controllers: [ProductsController],
  providers: [ProductsService],
  exports: [ProductsService],
})
export class ProductsModule {}
