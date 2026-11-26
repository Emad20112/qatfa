import { DynamicModule, Global, Logger, Module, Provider } from "@nestjs/common";
import { getRepositoryToken } from "@nestjs/typeorm";
import { randomUUID } from "crypto";
import {
  AppUpdateType,
  Currency,
  PriceUnit,
  QualityGrade,
  StockStatus,
  UserRole,
} from "@qatfa/shared-types";
import { AllEntities } from "./index";
import { User } from "./entities/user.entity";
import { Store } from "./entities/store.entity";
import { Product } from "./entities/product.entity";
import { Governorate } from "./entities/governorate.entity";
import { District } from "./entities/district.entity";
import { Market } from "./entities/market.entity";
import { AppVersion } from "./entities/app-version.entity";
import { Review } from "./entities/review.entity";
import { Report } from "./entities/report.entity";
import { LeadClick } from "./entities/lead-click.entity";

// MOCKED — in-memory TypeORM repository store (no PostgreSQL required; data resets on restart)
class InMemoryStore {
  readonly tables = new Map<Function, any[]>();
  private readonly counters = new Map<Function, number>();
  private seeded = false;

  getTable<T>(entity: Function): T[] {
    if (!this.tables.has(entity)) {
      this.tables.set(entity, []);
    }
    return this.tables.get(entity) as T[];
  }

  nextIntId(entity: Function): number {
    const current = this.counters.get(entity) || 0;
    const next = current + 1;
    this.counters.set(entity, next);
    return next;
  }

  seedInitialData() {
    if (this.seeded) return;
    this.seeded = true;

    const now = new Date();

    const govs: Partial<Governorate>[] = [
      {
        id: 1,
        nameAr: "صنعاء (الأمانة)",
        nameEn: "Sanaa",
        defaultCurrency: Currency.YER_OLD,
        isActive: true,
      },
      {
        id: 2,
        nameAr: "عدن",
        nameEn: "Aden",
        defaultCurrency: Currency.YER_NEW,
        isActive: true,
      },
    ];
    this.tables.set(Governorate, govs);
    this.counters.set(Governorate, 2);

    const districts: Partial<District>[] = [
      {
        id: 1,
        governorateId: 1,
        nameAr: "مديرية السبعين",
        nameEn: "Al-Sabain",
        isActive: true,
      },
      {
        id: 2,
        governorateId: 1,
        nameAr: "مديرية معين",
        nameEn: "Moeen",
        isActive: true,
      },
      {
        id: 3,
        governorateId: 2,
        nameAr: "الشيخ عثمان",
        nameEn: "Sheikh Othman",
        isActive: true,
      },
    ];
    this.tables.set(District, districts);
    this.counters.set(District, 3);

    const markets: Partial<Market>[] = [
      {
        id: 1,
        districtId: 1,
        nameAr: "سوق شميلة الشعبي",
        nameEn: "Shumaila Market",
        centerLatitude: 15.3182,
        centerLongitude: 44.2254,
        isActive: true,
      },
      {
        id: 2,
        districtId: 2,
        nameAr: "سوق مذبح وعلي محسن",
        nameEn: "Ali Mohsen Market",
        centerLatitude: 15.3694,
        centerLongitude: 44.1782,
        isActive: true,
      },
      {
        id: 3,
        districtId: 3,
        nameAr: "سوق قات الشيخ عثمان المركزي",
        nameEn: "Sheikh Othman Central Market",
        centerLatitude: 12.8687,
        centerLongitude: 44.9961,
        isActive: true,
      },
    ];
    this.tables.set(Market, markets);
    this.counters.set(Market, 3);

    const versions: Partial<AppVersion>[] = [
      {
        id: 1,
        platform: "android",
        latestVersion: "1.0.0",
        latestBuildNumber: 1,
        minSupportedVersion: "1.0.0",
        minSupportedBuildNumber: 1,
        updateType: AppUpdateType.OPTIONAL,
        title: "مرحباً بك في منصة قطفة 🌿",
        releaseNotes:
          "الإصدار الأول الرسمي - استكشف أسواق القات في صنعاء وعدن وتواصل مع المقاوتية مباشرة.",
        downloadUrl: "https://cdn.qatfa.ye/releases/qatfa-v1.0.0.apk",
        apkSizeInBytes: 15200000,
        sha256:
          "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        telegramChannelUrl: "https://t.me/qatfa_app",
        telegramPostUrl: "https://t.me/qatfa_app/1",
        playStoreUrl:
          "https://play.google.com/store/apps/details?id=ye.qatfa.app",
        isActive: true,
        updatedAt: now,
      },
    ];
    this.tables.set(AppVersion, versions);
    this.counters.set(AppVersion, 1);

    const seller1Id = "11111111-1111-4111-8111-111111111111";
    const seller2Id = "22222222-2222-4222-8222-222222222222";
    const users: Partial<User>[] = [
      {
        id: seller1Id,
        phoneNumber: "+967777111222",
        fullName: "أبو هيثم الهمداني",
        role: UserRole.SELLER,
        governorateId: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: seller2Id,
        phoneNumber: "+967733444555",
        fullName: "مفرش الضالعي للقات",
        role: UserRole.SELLER,
        governorateId: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
    ];
    this.tables.set(User, users);

    const store1Id = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa";
    const store2Id = "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb";
    const stores: Partial<Store>[] = [
      {
        id: store1Id,
        userId: seller1Id,
        storeName: "مفرش الأمانة للقات الهمداني",
        slug: "al-amana-hamdani-1001",
        bio: "أجود أنواع القات الهمداني والشامي يومياً من المزرعة إلى السوق",
        marketId: 1,
        stallNumber: "A-14",
        stallLandmark: "بجانب البوابة الشرقية لسوق شميلة",
        latitude: 15.3185,
        longitude: 44.2258,
        isVerifiedPhone: true,
        isVerifiedBadge: true,
        isOpenNow: true,
        averageRating: 4.8,
        ratingsCount: 34,
        followersCount: 120,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: store2Id,
        userId: seller2Id,
        storeName: "ركن يافع والضالع المركزي",
        slug: "yafea-dhalea-central-1002",
        bio: "قطفة طازجة يومياً من مزارع يافع والضالع - توصيل سريع داخل عدن",
        marketId: 3,
        stallNumber: "C-07",
        stallLandmark: "وسط سوق الشيخ عثمان مقابل المسجد",
        latitude: 12.8691,
        longitude: 44.9964,
        isVerifiedPhone: true,
        isVerifiedBadge: true,
        isOpenNow: true,
        averageRating: 4.7,
        ratingsCount: 21,
        followersCount: 85,
        createdAt: now,
        updatedAt: now,
      },
    ];
    this.tables.set(Store, stores);

    const products: Partial<Product>[] = [
      {
        id: "10000000-0000-4000-8000-000000000001",
        storeId: store1Id,
        title: "قطفة همداني رووس درجة أولى",
        qatType: "همداني",
        qualityGrade: QualityGrade.RUOOS,
        price: 5000,
        currency: Currency.YER_OLD,
        priceUnit: PriceUnit.HABBAH,
        stockStatus: StockStatus.AVAILABLE,
        stockQuantity: 15,
        harvestRegion: "همدان - صنعاء",
        harvestTime: "قطفة الفجر",
        images: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: "10000000-0000-4000-8000-000000000002",
        storeId: store1Id,
        title: "شامي صعدي طازج - قلايد",
        qatType: "شامي",
        qualityGrade: QualityGrade.QATAF,
        price: 8500,
        currency: Currency.YER_OLD,
        priceUnit: PriceUnit.QILADAH,
        stockStatus: StockStatus.AVAILABLE,
        stockQuantity: 8,
        harvestRegion: "صعدة",
        harvestTime: "وصل قبل ساعة",
        images: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: "10000000-0000-4000-8000-000000000003",
        storeId: store2Id,
        title: "قعطبي فاخر - قبضة يومية",
        qatType: "قعطبي",
        qualityGrade: QualityGrade.RUOOS,
        price: 12000,
        currency: Currency.YER_NEW,
        priceUnit: PriceUnit.QABDAH,
        stockStatus: StockStatus.AVAILABLE,
        stockQuantity: 12,
        harvestRegion: "الضالع",
        harvestTime: "قطفة الصباح",
        images: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
    ];
    this.tables.set(Product, products);

    this.tables.set(Review, []);
    this.tables.set(Report, []);
    this.tables.set(LeadClick, []);
  }
}

class InMemoryQueryBuilder<T extends Record<string, any>> {
  private readonly joins: Array<{ path: string; alias: string }> = [];
  private readonly predicates: Array<(item: T) => boolean> = [];
  private orderField: string | null = null;
  private orderDir: "ASC" | "DESC" = "ASC";
  private takeLimit: number | null = null;
  private skipOffset = 0;

  constructor(
    private readonly repo: InMemoryRepository<T>,
    private readonly alias: string,
  ) {}

  innerJoin(path: string, alias: string): this {
    this.joins.push({ path, alias });
    return this;
  }

  leftJoin(path: string, alias: string): this {
    this.joins.push({ path, alias });
    return this;
  }

  innerJoinAndSelect(path: string, alias: string): this {
    this.joins.push({ path, alias });
    return this;
  }

  leftJoinAndSelect(path: string, alias: string): this {
    this.joins.push({ path, alias });
    return this;
  }

  select(fields?: string | string[]): this {
    return this;
  }

  addSelect(fields?: string | string[]): this {
    return this;
  }

  limit(limit: number): this {
    this.takeLimit = limit;
    return this;
  }

  offset(offset: number): this {
    this.skipOffset = offset;
    return this;
  }

  where(condition: string | Record<string, any>, params?: Record<string, any>): this {
    this.predicates.length = 0;
    return this.andWhere(condition, params);
  }

  andWhere(
    condition: string | Record<string, any>,
    params: Record<string, any> = {},
  ): this {
    if (typeof condition !== "string") {
      this.predicates.push((item) =>
        Object.entries(condition).every(([k, v]) => item[k] === v),
      );
      return this;
    }

    const trimmed = condition.trim();

    // Handle Keyset pagination cursor tuple: (createdAt, id) < (:cursorDate, :cursorId)
    const cursorMatch = trimmed.match(
      /\((?:[a-zA-Z0-9_.]+\.)?createdAt,\s*(?:[a-zA-Z0-9_.]+\.)?id\)\s*<\s*\(:cursorDate,\s*:cursorId\)/i,
    );
    if (cursorMatch) {
      const cursorDate = new Date(params.cursorDate).getTime();
      const cursorId = Number(params.cursorId);
      this.predicates.push((item: any) => {
        const itemDate = new Date(item.createdAt).getTime();
        const itemId = Number(item.id);
        if (itemDate < cursorDate) return true;
        if (itemDate === cursorDate && itemId < cursorId) return true;
        return false;
      });
      return this;
    }

    // Handle BETWEEN: "product.price BETWEEN :min AND :max"
    const betweenMatch = trimmed.match(
      /^([a-zA-Z0-9_.]+)\s+BETWEEN\s+:([a-zA-Z0-9_]+)\s+AND\s+:([a-zA-Z0-9_]+)$/i,
    );
    if (betweenMatch) {
      const [, fieldPath, minKey, maxKey] = betweenMatch;
      const min = Number(params[minKey]);
      const max = Number(params[maxKey]);
      this.predicates.push((item) => {
        const val = Number(this.resolvePath(item, fieldPath));
        return !Number.isNaN(val) && val >= min && val <= max;
      });
      return this;
    }

    // Handle comparison operators: <=, >=, <, >
    const compMatch = trimmed.match(/^([a-zA-Z0-9_.]+)\s*(<=|>=|<|>)\s*:([a-zA-Z0-9_]+)$/);
    if (compMatch) {
      const [, fieldPath, op, paramKey] = compMatch;
      const target = Number(params[paramKey]);
      this.predicates.push((item) => {
        const val = Number(this.resolvePath(item, fieldPath));
        if (Number.isNaN(val)) return false;
        if (op === "<=") return val <= target;
        if (op === ">=") return val >= target;
        if (op === "<") return val < target;
        if (op === ">") return val > target;
        return false;
      });
      return this;
    }

    // Handle LIKE / ILIKE: "product.qatType LIKE :qatType"
    const likeMatch = trimmed.match(
      /^([a-zA-Z0-9_.]+)\s+I?LIKE\s+:([a-zA-Z0-9_]+)$/i,
    );
    if (likeMatch) {
      const [, fieldPath, paramKey] = likeMatch;
      const pattern = String(params[paramKey] ?? "")
        .replace(/^%|%$/g, "")
        .toLowerCase();
      this.predicates.push((item) => {
        const val = String(this.resolvePath(item, fieldPath) ?? "").toLowerCase();
        return val.includes(pattern);
      });
      return this;
    }

    // Handle equality: "store.marketId = :marketId"
    const eqMatch = trimmed.match(/^([a-zA-Z0-9_.]+)\s*=\s*:([a-zA-Z0-9_]+)$/);
    if (eqMatch) {
      const [, fieldPath, paramKey] = eqMatch;
      const expected = params[paramKey];
      this.predicates.push((item) => {
        const val = this.resolvePath(item, fieldPath);
        return String(val) === String(expected) || val === expected;
      });
      return this;
    }

    return this;
  }

  orderBy(field: string, dir: "ASC" | "DESC" = "ASC"): this {
    this.orderField = field;
    this.orderDir = dir;
    return this;
  }

  take(limit: number): this {
    this.takeLimit = limit;
    return this;
  }

  skip(offset: number): this {
    this.skipOffset = offset;
    return this;
  }

  async getManyAndCount(): Promise<[T[], number]> {
    const relationPaths = this.joins.map((j) => {
      const parts = j.path.split(".");
      if (parts[0] === this.alias) {
        return parts.slice(1).join(".");
      }
      return j.path;
    });

    const hydrated = this.repo
      .getAllRaw()
      .map((item) => this.repo.hydrate(item, relationPaths));

    const filtered = hydrated.filter((item) =>
      this.predicates.every((fn) => fn(item)),
    );

    if (this.orderField) {
      const fieldPath = this.orderField;
      const dir = this.orderDir === "DESC" ? -1 : 1;
      filtered.sort((a, b) => {
        const va = this.resolvePath(a, fieldPath);
        const vb = this.resolvePath(b, fieldPath);
        if (va instanceof Date && vb instanceof Date) {
          return (va.getTime() - vb.getTime()) * dir;
        }
        if (va === vb) return 0;
        return va > vb ? dir : -dir;
      });
    }

    const total = filtered.length;
    const sliced =
      this.takeLimit !== null
        ? filtered.slice(this.skipOffset, this.skipOffset + this.takeLimit)
        : filtered.slice(this.skipOffset);

    return [sliced, total];
  }

  async getMany(): Promise<T[]> {
    const [items] = await this.getManyAndCount();
    return items;
  }

  async getOne(): Promise<T | null> {
    const [items] = await this.take(1).getManyAndCount();
    return items[0] ?? null;
  }

  async getRawMany(): Promise<any[]> {
    return this.getMany();
  }

  async getRawOne(): Promise<any | null> {
    return this.getOne();
  }

  private resolvePath(obj: any, path: string): any {
    const parts = path.split(".");
    const cleanParts = parts[0] === this.alias ? parts.slice(1) : parts;
    let current = obj;
    for (const part of cleanParts) {
      if (current == null) return undefined;
      current = current[part];
    }
    return current;
  }
}

export class InMemoryRepository<T extends Record<string, any>> {
  private readonly uuidEntities = new Set<Function>([
    User,
    Store,
    Product,
    Review,
    Report,
    LeadClick,
  ]);

  constructor(
    private readonly entity: Function,
    private readonly store: InMemoryStore,
  ) {}

  getAllRaw(): T[] {
    return this.store.getTable<T>(this.entity);
  }

  createQueryBuilder(alias: string): InMemoryQueryBuilder<T> {
    return new InMemoryQueryBuilder<T>(this, alias);
  }

  async count(): Promise<number> {
    return this.getAllRaw().length;
  }

  async find(options?: {
    where?: Record<string, any> | Array<Record<string, any>>;
    relations?: string[];
    order?: Record<string, "ASC" | "DESC">;
  }): Promise<T[]> {
    let items = this.getAllRaw().map((item) =>
      this.hydrate(item, options?.relations || []),
    );

    if (options?.where) {
      const clauses = Array.isArray(options.where)
        ? options.where
        : [options.where];
      items = items.filter((item) =>
        clauses.some((clause) =>
          Object.entries(clause).every(([k, v]) => item[k] === v),
        ),
      );
    }

    if (options?.order) {
      const entries = Object.entries(options.order);
      if (entries.length > 0) {
        const [field, direction] = entries[0];
        const dir = direction === "DESC" ? -1 : 1;
        items.sort((a, b) => {
          if (a[field] === b[field]) return 0;
          return a[field] > b[field] ? dir : -dir;
        });
      }
    }

    return items;
  }

  async findOne(options: {
    where: Record<string, any> | Array<Record<string, any>>;
    relations?: string[];
    order?: Record<string, "ASC" | "DESC">;
  }): Promise<T | null> {
    const results = await this.find(options);
    return results[0] ?? null;
  }

  create(data: Partial<T>): T {
    return { ...data } as T;
  }

  async save(entityOrEntities: Partial<T>): Promise<T>;
  async save(entityOrEntities: Array<Partial<T>>): Promise<T[]>;
  async save(
    entityOrEntities: Partial<T> | Array<Partial<T>>,
  ): Promise<T | T[]> {
    if (Array.isArray(entityOrEntities)) {
      const saved: T[] = [];
      for (const item of entityOrEntities) {
        saved.push(await this.saveOne(item));
      }
      return saved;
    }
    return this.saveOne(entityOrEntities);
  }

  private async saveOne(data: Partial<T>): Promise<T> {
    const table = this.getAllRaw();
    const now = new Date();
    const record: any = { ...data };

    if (!record.id) {
      record.id = this.uuidEntities.has(this.entity)
        ? randomUUID()
        : this.store.nextIntId(this.entity);
    }

    const idx = table.findIndex((item) => item.id === record.id);
    if (idx >= 0) {
      const updated = {
        ...table[idx],
        ...record,
        updatedAt: now,
      };
      table[idx] = updated;
      return { ...updated };
    }

    if (!record.createdAt) record.createdAt = now;
    if (!record.updatedAt) record.updatedAt = now;
    table.push(record);
    return { ...record };
  }

  async update(id: string | number, partialData: Partial<T>): Promise<void> {
    const table = this.getAllRaw();
    const idx = table.findIndex((item) => item.id === id);
    if (idx >= 0) {
      const cleanUpdate = Object.fromEntries(
        Object.entries(partialData).filter(([, v]) => v !== undefined),
      );
      table[idx] = {
        ...table[idx],
        ...cleanUpdate,
        updatedAt: new Date(),
      };
    }
  }

  hydrate(raw: T, relations: string[] = []): T {
    const copy: any = { ...raw };

    const need = (prefix: string) =>
      relations.some((r) => r === prefix || r.startsWith(`${prefix}.`));

    if (this.entity === User && need("store")) {
      const stores = this.store.getTable<Store>(Store);
      const found = stores.find((s) => s.userId === copy.id) || null;
      copy.store = found ? { ...found } : null;
    }

    if (this.entity === Store) {
      if (need("market")) {
        const markets = this.store.getTable<Market>(Market);
        const found = markets.find((m) => m.id === copy.marketId) || null;
        copy.market = found ? { ...found } : null;
      }
      if (need("products")) {
        const products = this.store.getTable<Product>(Product);
        copy.products = products
          .filter((p) => p.storeId === copy.id)
          .map((p) => ({ ...p }));
      }
    }

    if (this.entity === Product && need("store")) {
      const stores = this.store.getTable<Store>(Store);
      const found = stores.find((s) => s.id === copy.storeId) || null;
      if (found) {
        const storeCopy: any = { ...found };
        if (relations.includes("store.market")) {
          const markets = this.store.getTable<Market>(Market);
          const market = markets.find((m) => m.id === storeCopy.marketId) || null;
          storeCopy.market = market ? { ...market } : null;
        }
        copy.store = storeCopy;
      } else {
        copy.store = null;
      }
    }

    if (this.entity === Governorate && need("districts")) {
      const districts = this.store.getTable<District>(District);
      const markets = this.store.getTable<Market>(Market);
      copy.districts = districts
        .filter((d) => d.governorateId === copy.id && d.isActive)
        .map((d) => {
          const dCopy: any = { ...d };
          if (relations.includes("districts.markets")) {
            dCopy.markets = markets
              .filter((m) => m.districtId === d.id && m.isActive)
              .map((m) => ({ ...m }));
          }
          return dCopy;
        });
    }

    if (this.entity === Market && need("stores")) {
      const stores = this.store.getTable<Store>(Store);
      const products = this.store.getTable<Product>(Product);
      copy.stores = stores
        .filter((s) => s.marketId === copy.id)
        .map((s) => {
          const sCopy: any = { ...s };
          if (relations.includes("stores.products")) {
            sCopy.products = products
              .filter((p) => p.storeId === s.id)
              .map((p) => ({ ...p }));
          }
          return sCopy;
        });
    }

    return copy;
  }
}

const sharedStore = new InMemoryStore();

@Global()
@Module({})
export class InMemoryDatabaseModule {
  private static readonly logger = new Logger(InMemoryDatabaseModule.name);

  static forRoot(): DynamicModule {
    sharedStore.seedInitialData();
    this.logger.warn(
      "[AI Studio] PostgreSQL offline — using seeded in-memory TypeORM repository layer",
    );

    const providers: Provider[] = AllEntities.map((entity) => ({
      provide: getRepositoryToken(entity),
      useValue: new InMemoryRepository(entity, sharedStore),
    }));

    return {
      module: InMemoryDatabaseModule,
      providers,
      exports: providers,
    };
  }

  static forFeature(entities: Function[]): DynamicModule {
    sharedStore.seedInitialData();
    const providers: Provider[] = entities.map((entity) => ({
      provide: getRepositoryToken(entity),
      useValue: new InMemoryRepository(entity, sharedStore),
    }));

    return {
      module: InMemoryDatabaseModule,
      providers,
      exports: providers,
    };
  }
}
