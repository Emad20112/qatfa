import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from "typeorm";
import {
  Currency,
  PriceUnit,
  QualityGrade,
  StockStatus,
} from "@qatfa/shared-types";
import { Store } from "./store.entity";

@Entity("products")
export class Product {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "store_id", type: "uuid" })
  storeId: string;

  @ManyToOne(() => Store, (store) => store.products, { onDelete: "CASCADE" })
  @JoinColumn({ name: "store_id" })
  store: Store;

  @Column({ type: "varchar", length: 150 })
  title: string;

  @Column({ name: "qat_type", type: "varchar", length: 100 })
  qatType: string;

  @Column({
    name: "quality_grade",
    type: "varchar",
    length: 50,
    default: QualityGrade.RUOOS,
  })
  qualityGrade: QualityGrade;

  @Column({ type: "decimal", precision: 12, scale: 2 })
  price: number;

  @Column({
    type: "varchar",
    length: 20,
    default: Currency.YER_OLD,
  })
  currency: Currency;

  @Column({
    name: "price_unit",
    type: "varchar",
    length: 50,
    default: PriceUnit.HABBAH,
  })
  priceUnit: PriceUnit;

  @Column({
    name: "stock_status",
    type: "varchar",
    length: 30,
    default: StockStatus.AVAILABLE,
  })
  stockStatus: StockStatus;

  @Column({ name: "stock_quantity", type: "int", default: 1 })
  stockQuantity: number;

  @Column({
    name: "harvest_region",
    type: "varchar",
    length: 150,
    nullable: true,
  })
  harvestRegion: string;

  @Column({
    name: "harvest_time",
    type: "varchar",
    length: 100,
    nullable: true,
  })
  harvestTime: string;

  @Column({ type: "simple-array", nullable: true })
  images: string[];

  @Column({ name: "is_active", type: "boolean", default: true })
  isActive: boolean;

  @CreateDateColumn({ name: "created_at", type: "timestamptz" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at", type: "timestamptz" })
  updatedAt: Date;
}
