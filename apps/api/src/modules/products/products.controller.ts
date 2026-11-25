import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";
import { ProductsService } from "./products.service";
import { Public } from "../../common/decorators/roles.decorator";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { User } from "../../database/entities/user.entity";

@Controller("products")
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Public()
  @Get("feed")
  async getFeed(@Query() query: any) {
    return this.productsService.getFeed(query);
  }

  @Public()
  @Get(":id")
  async getDetail(@Param("id") id: string) {
    return this.productsService.findById(id);
  }

  @UseGuards(AuthGuard("jwt"))
  @Post()
  async createProduct(@CurrentUser() user: User, @Body() body: any) {
    return this.productsService.createProduct(user.id, body);
  }

  @UseGuards(AuthGuard("jwt"))
  @Patch(":id/stock")
  async updateStock(
    @Param("id") id: string,
    @CurrentUser() user: User,
    @Body("stockStatus") stockStatus: any,
  ) {
    return this.productsService.updateStock(id, user.id, stockStatus);
  }
}
