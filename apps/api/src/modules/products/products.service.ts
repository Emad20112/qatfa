import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Product } from "../../database/entities/product.entity";
import { Store } from "../../database/entities/store.entity";
import { StockStatus } from "@qatfa/shared-types";

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(Store)
    private readonly storeRepository: Repository<Store>,
  ) {}

  async getFeed(query: any) {
    const qb = this.productRepository
      .createQueryBuilder("product")
      .leftJoinAndSelect("product.store", "store")
      .leftJoinAndSelect("store.market", "market")
      .where("product.isActive = :isActive", { isActive: true })
      .andWhere("product.stockStatus = :status", {
        status: StockStatus.AVAILABLE,
      });

    if (query.marketId) {
      qb.andWhere("store.marketId = :marketId", { marketId: query.marketId });
    }

    if (query.targetBudget) {
      const budget = parseFloat(query.targetBudget);
      const min = budget * 0.9;
      const max = budget * 1.1;
      qb.andWhere("product.price BETWEEN :min AND :max", { min, max });
    }

    if (query.qatType) {
      qb.andWhere("product.qatType LIKE :qatType", {
        qatType: `%${query.qatType}%`,
      });
    }

    qb.orderBy("product.createdAt", "DESC");

    const [items, total] = await qb.take(20).getManyAndCount();
    return {
      data: items,
      meta: {
        page: 1,
        limit: 20,
        totalItems: total,
      },
    };
  }

  async findById(id: string): Promise<Product> {
    const product = await this.productRepository.findOne({
      where: { id },
      relations: ["store", "store.market"],
    });
    if (!product) {
      throw new NotFoundException("القطفة غير موجودة");
    }
    return product;
  }

  async createProduct(userId: string, data: any): Promise<Product> {
    const store = await this.storeRepository.findOne({ where: { userId } });
    if (!store) {
      throw new UnauthorizedException("يجب امتلاك متجر لنشر قطفة");
    }

    const product = this.productRepository.create({
      storeId: store.id,
      title: data.title,
      qatType: data.qatType,
      qualityGrade: data.qualityGrade,
      price: data.price,
      currency: data.currency,
      priceUnit: data.priceUnit,
      stockQuantity: data.stockQuantity || 1,
      stockStatus: StockStatus.AVAILABLE,
      harvestRegion: data.harvestRegion,
      harvestTime: data.harvestTime,
      images: data.images || [],
      isActive: true,
    });

    return this.productRepository.save(product);
  }

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
      product.isActive = false; // إخفاء آلي عند النفاذ وفق وثيقة 04 و 12
    }

    return this.productRepository.save(product);
  }
}
