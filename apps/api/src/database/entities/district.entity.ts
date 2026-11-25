import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from "typeorm";
import { Governorate } from "./governorate.entity";
import { Market } from "./market.entity";

@Entity("districts")
export class District {
  @PrimaryGeneratedColumn("increment")
  id: number;

  @Column({ name: "governorate_id", type: "int" })
  governorateId: number;

  @ManyToOne(() => Governorate, (gov) => gov.districts, { onDelete: "CASCADE" })
  @JoinColumn({ name: "governorate_id" })
  governorate: Governorate;

  @Column({ name: "name_ar", type: "varchar", length: 100 })
  nameAr: string;

  @Column({ name: "name_en", type: "varchar", length: 100, nullable: true })
  nameEn: string;

  @Column({ name: "is_active", type: "boolean", default: true })
  isActive: boolean;

  @OneToMany(() => Market, (market) => market.district)
  markets: Market[];
}
