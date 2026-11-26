import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
  Logger,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Product } from "../../database/entities/product.entity";
import { Store } from "../../database/entities/store.entity";
import {
  StockStatus,
  ProductCardSlim,
  BudgetMatchType,
  PriceUnit,
} from "@qatfa/shared-types";
import { RedisService } from "../../common/redis/redis.service";
import { decodeCursor, encodeCursor } from "../../common/utils/cursor.util";
import {
  formatArabicTimeAgo,
  normalizeArabic,
} from "../../common/utils/arabic-normalizer.util";
import { SearchProductsDto } from "./dto/search-products.dto";
import { CreateProductDto } from "./dto/create-product.dto";

@Injectable()
export class ProductsService {
  private readonly logger = new Logger(ProductsService.name);

  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(Store)
    private readonly storeRepository: Repository<Store>,
    private readonly redisService: RedisService,
  ) {}

  /**
   * جلب موجز عروض اليوم النشطة بالترقيم المؤشري عالي الأداء O(1)
   */
  async getFeed(query: { marketId?: number; cursor?: string; limit?: number }) {
    const limit = Math.min(Math.max(Number(query.limit) || 20, 1), 50);
    const marketId = query.marketId ? Number(query.marketId) : undefined;
    const cacheKey = `feed:drops:${marketId || "all"}:${query.cursor || "start"}:${limit}`;

    // 1. فحص كاش Redis أولاً
    const cached = await this.redisService.get(cacheKey);
    if (cached) {
      return cached;
    }

    // 2. بناء استعلام Keyset Cursor عالي الكفاءة
    const qb = this.productRepository
      .createQueryBuilder("product")
      .innerJoin("product.store", "store")
      .leftJoin("store.market", "market")
      .select([
        "product.id",
        "product.storeId",
        "product.title",
        "product.qatType",
        "product.qualityGrade",
        "product.price",
        "product.currency",
        "product.priceUnit",
        "product.stockStatus",
        "product.stockQuantity",
        "product.harvestRegion",
        "product.harvestTime",
        "product.images",
        "product.blurHash",
        "product.dropDate",
        "product.createdAt",
        "store.id",
        "store.storeName",
        "store.slug",
        "store.stallNumber",
        "store.stallLandmark",
        "store.isVerifiedPhone",
        "store.isVerifiedBadge",
        "store.isOpenNow",
        "store.phoneCall",
        "store.phoneWhatsapp",
        "store.averageRating",
        "market.nameAr",
      ])
      .where("product.isActive = :isActive", { isActive: true })
      .andWhere("product.stockStatus = :status", {
        status: StockStatus.AVAILABLE,
      })
      .andWhere("store.isOpenNow = :isOpen", { isOpen: true });

    if (marketId) {
      qb.andWhere("store.marketId = :marketId", { marketId });
    }

    // فك تشفير المؤشر وتطبيق شرط المقارنة المركبة
    const decoded = decodeCursor(query.cursor);
    if (decoded && decoded.sortValue) {
      qb.andWhere(
        "(product.createdAt, product.id) < (:cursorDate, :cursorId)",
        {
          cursorDate: new Date(decoded.sortValue),
          cursorId: decoded.id,
        },
      );
    }

    // الترتيب الحتمي بالأحدث
    qb.orderBy("product.createdAt", "DESC").addOrderBy("product.id", "DESC");

    // جلب limit + 1 لمعرفة هل توجد صفحة تالية بصفر استعلامات عدّ COUNT(*)
    qb.take(limit + 1);

    const rawItems = await qb.getMany();
    const hasMore = rawItems.length > limit;
    const items = hasMore ? rawItems.slice(0, limit) : rawItems;

    // توليد المؤشر القادم من العنصر الأخير
    let nextCursor: string | null = null;
    if (hasMore && items.length > 0) {
      const lastItem = items[items.length - 1];
      nextCursor = encodeCursor(lastItem.createdAt.toISOString(), lastItem.id);
    }

    // تحويل البيانات لهيكل بطاقة العرض الرشيقة لفلاتر
    const slimCards: ProductCardSlim[] = items.map((p) => this.mapToSlimCard(p));

    const response = {
      data: slimCards,
      pagination: {
        nextCursor,
        hasMore,
        limit,
      },
      meta: {
        limit,
        hasMore,
        nextCursor,
      },
    };

    // حفظ في كاش Redis بـ TTL 45 ثانية
    await this.redisService.set(cacheKey, response, 45);

    return response;
  }

  /**
   * محرك البحث الموحد والبحث العكسي بالميزانية والفلترة متعددة المستويات
   */
  async searchProducts(dto: SearchProductsDto) {
    const limit = Math.min(Math.max(Number(dto.limit) || 20, 1), 50);
    const targetBudget = dto.targetBudget ? Number(dto.targetBudget) : undefined;
    const tolerance = dto.budgetTolerance ? Number(dto.budgetTolerance) : 0.1;
    const priceUnit = dto.priceUnit || (targetBudget ? PriceUnit.HABBAH : undefined);

    const cacheKey = `search:${dto.marketId || "all"}:${targetBudget || "no-b"}:${priceUnit || "all"}:${dto.qatType || "all"}:${dto.cursor || "start"}:${limit}`;
    const cached = await this.redisService.get(cacheKey);
    if (cached) {
      return cached;
    }

    const qb = this.productRepository
      .createQueryBuilder("product")
      .innerJoin("product.store", "store")
      .leftJoin("store.market", "market")
      .select([
        "product.id",
        "product.storeId",
        "product.title",
        "product.qatType",
        "product.qualityGrade",
        "product.price",
        "product.currency",
        "product.priceUnit",
        "product.stockStatus",
        "product.stockQuantity",
        "product.harvestRegion",
        "product.harvestTime",
        "product.images",
        "product.blurHash",
        "product.dropDate",
        "product.createdAt",
        "store.id",
        "store.storeName",
        "store.slug",
        "store.stallNumber",
        "store.stallLandmark",
        "store.isVerifiedPhone",
        "store.isVerifiedBadge",
        "store.isOpenNow",
        "store.phoneCall",
        "store.phoneWhatsapp",
        "store.averageRating",
        "market.nameAr",
      ])
      .where("product.isActive = :isActive", { isActive: true })
      .andWhere("product.stockStatus = :status", {
        status: StockStatus.AVAILABLE,
      })
      .andWhere("store.isOpenNow = :isOpen", { isOpen: true });

    // الفلترة الجغرافية
    if (dto.marketId) {
      qb.andWhere("store.marketId = :marketId", { marketId: dto.marketId });
    } else if (dto.districtId) {
      qb.andWhere("market.districtId = :districtId", {
        districtId: dto.districtId,
      });
    }

    // الفلترة بالنوع مع التطبيع العربي
    if (dto.qatType) {
      const cleanType = normalizeArabic(dto.qatType);
      qb.andWhere("product.qatType ILIKE :cleanType", {
        cleanType: `%${cleanType}%`,
      });
    }

    // الفلترة بالجودة والوحدة
    if (dto.qualityGrade) {
      qb.andWhere("product.qualityGrade = :qualityGrade", {
        qualityGrade: dto.qualityGrade,
      });
    }
    if (priceUnit) {
      qb.andWhere("product.priceUnit = :priceUnit", { priceUnit });
    }

    // منطق البحث العكسي حسب الميزانية
    if (targetBudget !== undefined && targetBudget > 0) {
      const min = Math.round(targetBudget * (1.0 - tolerance));
      const max = Math.round(targetBudget * (1.0 + tolerance));
      qb.andWhere("product.price BETWEEN :min AND :max", { min, max });

      // الترتيب بالأقرب للميزانية رياضياً
      qb.orderBy(`ABS(product.price - ${targetBudget})`, "ASC")
        .addOrderBy("product.createdAt", "DESC")
        .addOrderBy("product.id", "DESC");
    } else {
      if (dto.minPrice) {
        qb.andWhere("product.price >= :minPrice", { minPrice: dto.minPrice });
      }
      if (dto.maxPrice) {
        qb.andWhere("product.price <= :maxPrice", { maxPrice: dto.maxPrice });
      }

      qb.orderBy("product.createdAt", "DESC").addOrderBy("product.id", "DESC");
    }

    // تطبيق المؤشر للترقيم المفتاحي
    const decoded = decodeCursor(dto.cursor);
    if (decoded && decoded.sortValue) {
      if (targetBudget !== undefined) {
        // مؤشر البحث بالميزانية
        qb.andWhere(
          `ABS(product.price - ${targetBudget}) > :cursorDelta OR (ABS(product.price - ${targetBudget}) = :cursorDelta AND product.id < :cursorId)`,
          {
            cursorDelta: Number(decoded.sortValue),
            cursorId: decoded.id,
          },
        );
      } else {
        // مؤشر التصفح الزمني
        qb.andWhere(
          "(product.createdAt, product.id) < (:cursorDate, :cursorId)",
          {
            cursorDate: new Date(decoded.sortValue),
            cursorId: decoded.id,
          },
        );
      }
    }

    qb.take(limit + 1);

    const rawItems = await qb.getMany();
    const hasMore = rawItems.length > limit;
    const items = hasMore ? rawItems.slice(0, limit) : rawItems;

    let nextCursor: string | null = null;
    if (hasMore && items.length > 0) {
      const lastItem = items[items.length - 1];
      const sortValue =
        targetBudget !== undefined
          ? Math.abs(Number(lastItem.price) - targetBudget)
          : lastItem.createdAt.toISOString();
      nextCursor = encodeCursor(sortValue, lastItem.id);
    }

    const slimCards: ProductCardSlim[] = items.map((p) =>
      this.mapToSlimCard(p, targetBudget),
    );

    const response = {
      data: slimCards,
      pagination: {
        nextCursor,
        hasMore,
        limit,
      },
      meta: {
        limit,
        hasMore,
        nextCursor,
      },
    };

    await this.redisService.set(cacheKey, response, 45);
    return response;
  }

  /**
   * جلب تفاصيل قطفة محددة بالمعرف
   */
  async findById(id: string): Promise<Product> {
    const cacheKey = `product:${id}`;
    const cached = await this.redisService.get(cacheKey);
    if (cached) {
      return cached;
    }

    const product = await this.productRepository.findOne({
      where: { id },
      relations: ["store", "store.market"],
    });

    if (!product) {
      throw new NotFoundException("القطفة غير موجودة");
    }

    await this.redisService.set(cacheKey, product, 120);
    return product;
  }

  /**
   * نشر قطفة جديدة مع إبطال الكاش فورياً لضمان ظهورها اللحظي
   */
  async createProduct(
    userId: string,
    data: CreateProductDto,
  ): Promise<Product> {
    const store = await this.storeRepository.findOne({ where: { userId } });
    if (!store) {
      throw new UnauthorizedException("يجب امتلاك متجر لنشر قطفة");
    }

    const product = this.productRepository.create({
      storeId: store.id,
      title: data.title.trim(),
      qatType: data.qatType.trim(),
      qualityGrade: data.qualityGrade,
      price: data.price,
      currency: data.currency,
      priceUnit: data.priceUnit,
      stockQuantity: data.stockQuantity || 1,
      stockStatus: StockStatus.AVAILABLE,
      harvestRegion: data.harvestRegion,
      harvestTime: data.harvestTime,
      images: data.images || [],
      blurHash: data.blurHash,
      isActive: true,
    });

    const saved = await this.productRepository.save(product);

    // إبطال كاش السوق والمتجر فورياً
    if (store.marketId) {
      await this.redisService.invalidateMarket(store.marketId);
    }
    await this.redisService.invalidateStore(store.id);

    return saved;
  }

  /**
   * تحديث حالة المخزون مع إخفاء المنتج آلياً عند النفاذ وإبطال الكاش
   */
  async updateStock(
    id: string,
    userId: string,
    stockStatus: StockStatus,
  ): Promise<Product> {
    const product = await this.findById(id);
    const store = await this.storeRepository.findOne({ where: { userId } });

    if (!store || product.storeId !== store.id) {
      throw new UnauthorizedException("غير مصرح لك بتعديل هذا المنتج");
    }

    product.stockStatus = stockStatus;
    if (stockStatus === StockStatus.SOLD_OUT) {
      product.isActive = false; // الإخفاء الآلي للعروض المباعة
    } else {
      product.isActive = true;
    }

    const updated = await this.productRepository.save(product);

    // إبطال كاش السوق والمتجر فورياً
    if (store.marketId) {
      await this.redisService.invalidateMarket(store.marketId);
    }
    await this.redisService.del(`product:${id}`);
    await this.redisService.invalidateStore(store.id);

    return updated;
  }

  /**
   * تحويل الكيان إلى بطاقة عرض رشيقة مخصصة لتطبيق فلاتر
   */
  private mapToSlimCard(
    p: Product,
    targetBudget?: number,
  ): ProductCardSlim {
    const price = Number(p.price);
    const images = Array.isArray(p.images) ? p.images : [];
    const primaryImage = images.length > 0 ? images[0] : undefined;

    let budgetMatch: ProductCardSlim["budgetMatch"] = undefined;

    if (targetBudget !== undefined && targetBudget > 0) {
      const priceDelta = Math.abs(price - targetBudget);
      const signedDelta = price - targetBudget;

      let matchType = BudgetMatchType.EXACT_MATCH;
      let deltaText = "مطابق تماماً لميزانيتك";
      let badgeColor = "#2E7D32"; // أخضر داكن

      if (signedDelta < 0) {
        matchType = BudgetMatchType.NEAR_MATCH_CHEAPER;
        deltaText = `وفرت ${priceDelta.toLocaleString("ar-YE")} ريال`;
        badgeColor = "#1B5E20"; // زمردي
      } else if (signedDelta > 0) {
        matchType = BudgetMatchType.NEAR_MATCH_STRETCHED;
        deltaText = `زيادة ${priceDelta.toLocaleString("ar-YE")} ريال`;
        badgeColor = "#E65100"; // برتقالي
      }

      budgetMatch = {
        targetBudget,
        priceDelta,
        signedDelta,
        deltaText,
        matchType,
        badgeColor,
      };
    }

    return {
      id: p.id,
      storeId: p.storeId,
      title: p.title,
      qatType: p.qatType,
      qualityGrade: p.qualityGrade,
      price,
      currency: p.currency,
      priceUnit: p.priceUnit,
      stockStatus: p.stockStatus,
      stockQuantity: p.stockQuantity,
      harvestRegion: p.harvestRegion,
      harvestTime: p.harvestTime,
      primaryImage,
      images,
      blurHash: p.blurHash,
      dropDate: p.dropDate || new Date().toISOString().split("T")[0],
      createdAt: p.createdAt.toISOString(),
      publishedTimeAgo: formatArabicTimeAgo(p.createdAt),
      store: {
        id: p.store ? p.store.id : p.storeId,
        storeName: p.store ? p.store.storeName : "مفرش معتمد",
        slug: p.store?.slug,
        stallNumber: p.store?.stallNumber,
        stallLandmark: p.store?.stallLandmark,
        isVerifiedPhone: p.store ? p.store.isVerifiedPhone : false,
        isVerifiedBadge: p.store ? p.store.isVerifiedBadge : false,
        isOpenNow: p.store ? p.store.isOpenNow : true,
        phoneCall: p.store?.phoneCall,
        phoneWhatsapp: p.store?.phoneWhatsapp,
        averageRating: p.store ? Number(p.store.averageRating) : 0,
        marketName: p.store?.market?.nameAr,
      },
      budgetMatch,
    };
  }
}
