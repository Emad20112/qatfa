import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from "typeorm";
import { User } from "./user.entity";

@Entity("lead_clicks")
export class LeadClick {
  @PrimaryGeneratedColumn("increment", { type: "bigint" })
  id: string;

  @Column({ name: "store_id", type: "uuid" })
  storeId: string;

  @Column({ name: "product_id", type: "uuid", nullable: true })
  productId: string;

  @Column({ name: "user_id", type: "uuid", nullable: true })
  userId: string;

  @ManyToOne(() => User, (user) => user.leadClicks, {
    onDelete: "SET NULL",
    nullable: true,
  })
  @JoinColumn({ name: "user_id" })
  user: User;

  @Column({ name: "click_type", type: "varchar", length: 20 }) // 'CALL' | 'WHATSAPP'
  clickType: string;

  @Column({ name: "ip_hash", type: "varchar", length: 64, nullable: true })
  ipHash: string;

  @CreateDateColumn({ name: "created_at", type: "timestamptz" })
  createdAt: Date;
}
