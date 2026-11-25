import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  OneToMany,
} from "typeorm";
import { UserRole } from "@qatfa/shared-types";
import { Store } from "./store.entity";
import { Review } from "./review.entity";
import { Report } from "./report.entity";
import { LeadClick } from "./lead-click.entity";

@Entity("users")
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "phone_number", type: "varchar", length: 20, unique: true })
  phoneNumber: string;

  @Column({ name: "full_name", type: "varchar", length: 100 })
  fullName: string;

  @Column({
    type: "varchar",
    length: 20,
    default: UserRole.CUSTOMER,
  })
  role: UserRole;

  @Column({ name: "avatar_url", type: "varchar", length: 500, nullable: true })
  avatarUrl: string;

  @Column({ name: "governorate_id", type: "int", nullable: true })
  governorateId: number;

  @Column({ name: "is_active", type: "boolean", default: true })
  isActive: boolean;

  @Column({ name: "fcm_token", type: "varchar", length: 300, nullable: true })
  fcmToken: string;

  @CreateDateColumn({ name: "created_at", type: "timestamptz" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at", type: "timestamptz" })
  updatedAt: Date;

  @OneToOne(() => Store, (store) => store.user)
  store: Store;

  @OneToMany(() => Review, (review) => review.user)
  reviews: Review[];

  @OneToMany(() => Report, (report) => report.user)
  reports: Report[];

  @OneToMany(() => LeadClick, (click) => click.user)
  leadClicks: LeadClick[];
}
