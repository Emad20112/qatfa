import {
  Injectable,
  NotFoundException,
  ConflictException,
  Logger,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Store } from "../../database/entities/store.entity";
import { User } from "../../database/entities/user.entity";
import { Product } from "../../database/entities/product.entity";
import { UserRole, StockStatus } from "@qatfa/shared-types";
import { RedisService } from "../../common/redis/redis.service";
import { decodeCursor, encodeCursor } from "../../common/utils/cursor.util";

@Injectable()
export class StoresService {
  private readonly logger = new Logger(StoresService.name);

  constructor(
    @InjectRepository(Store)
    private readonly storeRepository: Repository<Store>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    private readonly redisService: RedisService,
  ) {}

  /**
   * استعراض قائمة المتاجر النشطة مع تجنب الروابط غير المقيدة (Unbounded Joins)
   */
  async findAll(query: { marketId?: number; cursor?: string; limit?: number }) {
    const limit = Math.min(Math.max(Number(query.limit) || 20, 1), 50);
    const marketId = query.marketId ? Number(query.marketId) : undefined;
    const cacheKey = `stores:${marketId || "all"}:${query.cursor || "start"}:${limit}`;

    const cached = await this.redisService.get(cacheKey);
    if (cached) {
      return cached;
    }

    const qb = this.storeRepository
      .createQueryBuilder("store")
      .leftJoinAndSelect("store.market", "market")
      .select([
        "store.id",
        "store.storeName",
        "store.slug",
        "store.bio",
        "store.logoUrl",
        "store.coverUrl",
        "store.marketId",
        "store.stallNumber",
        "store.stallLandmark",
        "store.latitude",
        "store.longitude",
        "store.isVerifiedPhone",
        "store.isVerifiedBadge",
        "store.isOpenNow",
        "store.averageRating",
        "store.ratingsCount",
        "store.followersCount",
        "store.createdAt",
        "market.nameAr",
        "market.centerLatitude",
        "market.centerLongitude",
      ])
      .where("store.isOpenNow = :isOpen", { isOpen: true });

    if (marketId) {
      qb.andWhere("store.marketId = :marketId", { marketId });
    }

    const decoded = decodeCursor(query.cursor);
    if (decoded && decoded.sortValue) {
      qb.andWhere("(store.createdAt, store.id) < (:cursorDate, :cursorId)", {
        cursorDate: new Date(decoded.sortValue),
        cursorId: decoded.id,
      });
    }

    qb.orderBy("store.createdAt", "DESC").addOrderBy("store.id", "DESC");
    qb.take(limit + 1);

    const rawItems = await qb.getMany();
    const hasMore = rawItems.length > limit;
    const items = hasMore ? rawItems.slice(0, limit) : rawItems;

    let nextCursor: string | null = null;
    if (hasMore && items.length > 0) {
      const lastItem = items[items.length - 1];
      nextCursor = encodeCursor(lastItem.createdAt.toISOString(), lastItem.id);
    }

    const response = {
      data: items,
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

    await this.redisService.set(cacheKey, response, 60);
    return response;
  }

  /**
   * جلب تفاصيل متجر محدد وعروضه النشطة المتوفرة اليوم فقط
   */
  async findBySlugOrId(identifier: string): Promise<any> {
    const cacheKey = `store:detail:${identifier}`;
    const cached = await this.redisService.get(cacheKey);
    if (cached) {
      return cached;
    }

    const store = await this.storeRepository.findOne({
      where: [{ id: identifier }, { slug: identifier }],
      relations: ["market"],
    });

    if (!store) {
      throw new NotFoundException("المتجر غير موجود");
    }

    // جلب عروض اليوم النشطة المتوفرة فقط لهذا المتجر
    const activeProducts = await this.productRepository.find({
      where: {
        storeId: store.id,
        isActive: true,
        stockStatus: StockStatus.AVAILABLE,
      },
      order: { createdAt: "DESC" },
      take: 20,
    });

    const result = {
      ...store,
      products: activeProducts,
    };

    await this.redisService.set(cacheKey, result, 60);
    return result;
  }

  /**
   * إنشاء متجر جديد للمقاوتي وترقية صلاحيته
   */
  async createStore(userId: string, data: any): Promise<Store> {
    const existing = await this.storeRepository.findOne({ where: { userId } });
    if (existing) {
      throw new ConflictException("المستخدم يمتلك متجراً بالفعل");
    }

    const slug =
      data.storeName.trim().toLowerCase().replace(/\s+/g, "-") +
      "-" +
      Math.floor(1000 + Math.random() * 9000);

    const store = this.storeRepository.create({
      userId,
      storeName: data.storeName.trim(),
      slug,
      bio: data.bio,
      marketId: data.marketId,
      stallNumber: data.stallNumber,
      stallLandmark: data.stallLandmark,
      latitude: data.latitude,
      longitude: data.longitude,
      phoneCall: data.phoneCall,
      phoneWhatsapp: data.phoneWhatsapp,
      isOpenNow: true,
      isVerifiedPhone: true,
    });

    const saved = await this.storeRepository.save(store);
    await this.userRepository.update(userId, { role: UserRole.SELLER });

    if (saved.marketId) {
      await this.redisService.invalidateMarket(saved.marketId);
    }

    return saved;
  }

  /**
   * تعديل بيانات المتجر أو تبديل حالة الفتح والإغلاق الرئيسية (Master Store Toggle)
   */
  async updateMyStore(userId: string, data: any): Promise<Store> {
    const store = await this.storeRepository.findOne({ where: { userId } });
    if (!store) {
      throw new NotFoundException("المتجر غير موجود");
    }

    Object.assign(store, data);
    const updated = await this.storeRepository.save(store);

    if (updated.marketId) {
      await this.redisService.invalidateMarket(updated.marketId);
    }
    await this.redisService.invalidateStore(updated.id);

    return updated;
  }

  /**
   * تبديل حالة المتجر اليوم (مفتوح / مغلق بضاعة اليوم نفدت)
   */
  async toggleOpenStatus(userId: string, isOpen: boolean): Promise<Store> {
    const store = await this.storeRepository.findOne({ where: { userId } });
    if (!store) {
      throw new NotFoundException("المتجر غير موجود");
    }

    store.isOpenNow = isOpen;
    const updated = await this.storeRepository.save(store);

    if (updated.marketId) {
      await this.redisService.invalidateMarket(updated.marketId);
    }
    await this.redisService.invalidateStore(updated.id);

    return updated;
  }
}
