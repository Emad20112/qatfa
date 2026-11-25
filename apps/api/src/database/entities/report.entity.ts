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

@Entity("reports")
@Unique(["userId", "targetType", "targetId"])
export class Report {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "user_id", type: "uuid" })
  userId: string;

  @ManyToOne(() => User, (user) => user.reports, { onDelete: "CASCADE" })
  @JoinColumn({ name: "user_id" })
  user: User;

  @Column({ name: "target_type", type: "varchar", length: 50 })
  targetType: string; // 'PRODUCT' | 'STORE' | 'REVIEW'

  @Column({ name: "target_id", type: "varchar", length: 64 })
  targetId: string;

  @Column({ type: "varchar", length: 100 })
  reason: string;

  @Column({ type: "text", nullable: true })
  comment: string;

  @Column({
    name: "contact_phone",
    type: "varchar",
    length: 20,
    nullable: true,
  })
  contactPhone: string;

  @Column({ type: "varchar", length: 50, default: "PENDING" })
  status: string; // 'PENDING' | 'INVESTIGATING' | 'RESOLVED' | 'DISMISSED'

  @CreateDateColumn({ name: "created_at", type: "timestamptz" })
  createdAt: Date;
}
