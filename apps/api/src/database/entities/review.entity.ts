import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from "typeorm";
import { User } from "./user.entity";
import { Store } from "./store.entity";

@Entity("reviews")
@Unique(["userId", "storeId"])
export class Review {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "store_id", type: "uuid" })
  storeId: string;

  @ManyToOne(() => Store, (store) => store.reviews, { onDelete: "CASCADE" })
  @JoinColumn({ name: "store_id" })
  store: Store;

  @Column({ name: "user_id", type: "uuid" })
  userId: string;

  @ManyToOne(() => User, (user) => user.reviews, { onDelete: "CASCADE" })
  @JoinColumn({ name: "user_id" })
  user: User;

  @Column({ type: "int" })
  rating: number;

  @Column({ type: "text", nullable: true })
  comment: string;

  @Column({ name: "seller_reply", type: "text", nullable: true })
  sellerReply: string;

  @Column({ name: "seller_replied_at", type: "timestamptz", nullable: true })
  sellerRepliedAt: Date;

  @Column({ name: "is_visible", type: "boolean", default: true })
  isVisible: boolean;

  @CreateDateColumn({ name: "created_at", type: "timestamptz" })
  createdAt: Date;
}
