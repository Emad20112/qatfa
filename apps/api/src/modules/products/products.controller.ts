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
import { SearchProductsDto } from "./dto/search-products.dto";
import { CreateProductDto } from "./dto/create-product.dto";

@Controller("products")
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  /**
   * استعراض موجز قطفات اليوم النشطة بالترقيم المؤشري (Keyset Cursor)
   */
  @Public()
  @Get("feed")
  async getFeed(
    @Query("marketId") marketId?: number,
    @Query("cursor") cursor?: string,
    @Query("limit") limit?: number,
  ) {
    return this.productsService.getFeed({ marketId, cursor, limit });
  }

  /**
   * محرك البحث الموحد والبحث العكسي بالميزانية والفلترة متعددة المستويات
   */
  @Public()
  @Get("search")
  async search(@Query() dto: SearchProductsDto) {
    return this.productsService.searchProducts(dto);
  }

  /**
   * جلب تفاصيل قطفة محددة بالمعرف
   */
  @Public()
  @Get(":id")
  async getDetail(@Param("id") id: string) {
    return this.productsService.findById(id);
  }

  /**
   * نشر قطفة جديدة (يتطلب حساب مقاوتي مسجل)
   */
  @UseGuards(AuthGuard("jwt"))
  @Post()
  async createProduct(
    @CurrentUser() user: User,
    @Body() body: CreateProductDto,
  ) {
    return this.productsService.createProduct(user.id, body);
  }

  /**
   * تحديث حالة توفر المنتج والمخزون
   */
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
