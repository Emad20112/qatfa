import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Governorate } from "../../database/entities/governorate.entity";
import { Market } from "../../database/entities/market.entity";

@Injectable()
export class GeoService {
  constructor(
    @InjectRepository(Governorate)
    private readonly govRepository: Repository<Governorate>,
    @InjectRepository(Market)
    private readonly marketRepository: Repository<Market>,
  ) {}

  async getTree() {
    return this.govRepository.find({
      where: { isActive: true },
      relations: ["districts", "districts.markets"],
    });
  }

  async getMarketMap(marketId: number) {
    const market = await this.marketRepository.findOne({
      where: { id: marketId },
      relations: ["stores", "stores.products"],
    });
    return market;
  }
}
