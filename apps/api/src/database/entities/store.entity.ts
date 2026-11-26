import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
  ManyToOne,
  OneToMany,
  Index,
} from "typeorm";
import { User } from "./user.entity";
import { Market } from "./market.entity";
import { Product } from "./product.entity";
import { Review } from "./review.entity";

@Entity("stores")
@Index(["marketId", "isOpenNow"])
@Index(["storeName"])
@Index(["latitude", "longitude"])
export class Store {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "user_id", type: "uuid", unique: true })
  userId: string;

  @OneToOne(() => User, (user) => user.store, { onDelete: "CASCADE" })
  @JoinColumn({ name: "user_id" })
  user: User;

  @Column({ name: "store_name", type: "varchar", length: 150 })
  storeName: string;

  @Column({ type: "varchar", length: 160, unique: true })
  slug: string;

  @Column({ type: "text", nullable: true })
  bio: string;

  @Column({ name: "logo_url", type: "varchar", length: 500, nullable: true })
  logoUrl: string;

  @Column({ name: "cover_url", type: "varchar", length: 500, nullable: true })
  coverUrl: string;

  @Column({ name: "market_id", type: "int", nullable: true })
  marketId: number;

  @ManyToOne(() => Market, (market) => market.stores, { nullable: true })
  @JoinColumn({ name: "market_id" })
  market: Market;

  @Column({ name: "stall_number", type: "varchar", length: 50, nullable: true })
  stallNumber: string;

  @Column({
    name: "stall_landmark",
    type: "varchar",
    length: 255,
    nullable: true,
  })
  stallLandmark: string;

  @Column({ type: "decimal", precision: 10, scale: 7, nullable: true })
  latitude: number;

  @Column({ type: "decimal", precision: 10, scale: 7, nullable: true })
  longitude: number;

  @Column({ name: "is_verified_phone", type: "boolean", default: false })
  isVerifiedPhone: boolean;

  @Column({ name: "is_verified_badge", type: "boolean", default: false })
  isVerifiedBadge: boolean;

  @Column({ name: "is_open_now", type: "boolean", default: true })
  isOpenNow: boolean;

  @Column({ name: "phone_call", type: "varchar", length: 20, nullable: true })
  phoneCall: string;

  @Column({
    name: "phone_whatsapp",
    type: "varchar",
    length: 20,
    nullable: true,
  })
  phoneWhatsapp: string;

  @Column({
    name: "average_rating",
    type: "decimal",
    precision: 3,
    scale: 2,
    default: 0.0,
  })
  averageRating: number;

  @Column({ name: "ratings_count", type: "int", default: 0 })
  ratingsCount: number;

  @Column({ name: "followers_count", type: "int", default: 0 })
  followersCount: number;

  @CreateDateColumn({ name: "created_at", type: "timestamptz" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at", type: "timestamptz" })
  updatedAt: Date;

  @OneToMany(() => Product, (product) => product.store)
  products: Product[];

  @OneToMany(() => Review, (review) => review.store)
  reviews: Review[];
}
