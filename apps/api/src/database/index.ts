import { User } from "./entities/user.entity";
import { Store } from "./entities/store.entity";
import { Product } from "./entities/product.entity";
import { Governorate } from "./entities/governorate.entity";
import { District } from "./entities/district.entity";
import { Market } from "./entities/market.entity";
import { Review } from "./entities/review.entity";
import { Report } from "./entities/report.entity";
import { LeadClick } from "./entities/lead-click.entity";
import { AppVersion } from "./entities/app-version.entity";

export const AllEntities = [
  User,
  Store,
  Product,
  Governorate,
  District,
  Market,
  Review,
  Report,
  LeadClick,
  AppVersion,
];

export * from "./entities/user.entity";
export * from "./entities/store.entity";
export * from "./entities/product.entity";
export * from "./entities/governorate.entity";
export * from "./entities/district.entity";
export * from "./entities/market.entity";
export * from "./entities/review.entity";
export * from "./entities/report.entity";
export * from "./entities/lead-click.entity";
export * from "./entities/app-version.entity";
