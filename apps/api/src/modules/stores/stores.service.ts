import {
  Injectable,
  NotFoundException,
  ConflictException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Store } from "../../database/entities/store.entity";
import { User } from "../../database/entities/user.entity";
import { UserRole } from "@qatfa/shared-types";

@Injectable()
export class StoresService {
  constructor(
    @InjectRepository(Store)
    private readonly storeRepository: Repository<Store>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async findAll(query: any) {
    const qb = this.storeRepository
      .createQueryBuilder("store")
      .leftJoinAndSelect("store.market", "market")
      .leftJoinAndSelect("store.products", "product")
      .where("store.isOpenNow = :isOpen", { isOpen: true });

    if (query.marketId) {
      qb.andWhere("store.marketId = :marketId", { marketId: query.marketId });
    }

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

  async findBySlugOrId(identifier: string): Promise<Store> {
    const store = await this.storeRepository.findOne({
      where: [{ id: identifier }, { slug: identifier }],
      relations: ["market", "products"],
    });
    if (!store) {
      throw new NotFoundException("المتجر غير موجود");
    }
    return store;
  }

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
      storeName: data.storeName,
      slug,
      bio: data.bio,
      marketId: data.marketId,
      stallNumber: data.stallNumber,
      stallLandmark: data.stallLandmark,
      latitude: data.latitude,
      longitude: data.longitude,
      isOpenNow: true,
      isVerifiedPhone: true,
    });

    const saved = await this.storeRepository.save(store);
    await this.userRepository.update(userId, { role: UserRole.SELLER });

    return saved;
  }

  async updateMyStore(userId: string, data: any): Promise<Store> {
    const store = await this.storeRepository.findOne({ where: { userId } });
    if (!store) {
      throw new NotFoundException("المتجر غير موجود");
    }

    Object.assign(store, data);
    return this.storeRepository.save(store);
  }
}
