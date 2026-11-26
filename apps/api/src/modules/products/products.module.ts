import { Module } from "@nestjs/common";
import { ProductsService } from "./products.service";
import { ProductsController } from "./products.controller";
import { Product } from "../../database/entities/product.entity";
import { Store } from "../../database/entities/store.entity";
import { InMemoryDatabaseModule } from "../../database/in-memory-database.module";

@Module({
  imports: [InMemoryDatabaseModule.forFeature([Product, Store])],
  controllers: [ProductsController],
  providers: [ProductsService],
  exports: [ProductsService],
})
export class ProductsModule {}
