import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";
import { District } from "./district.entity";
import { Currency } from "@qatfa/shared-types";

@Entity("governorates")
export class Governorate {
  @PrimaryGeneratedColumn("increment")
  id: number;

  @Column({ name: "name_ar", type: "varchar", length: 100, unique: true })
  nameAr: string;

  @Column({ name: "name_en", type: "varchar", length: 100, nullable: true })
  nameEn: string;

  @Column({
    name: "default_currency",
    type: "varchar",
    length: 20,
    default: Currency.YER_OLD,
  })
  defaultCurrency: Currency;

  @Column({ name: "is_active", type: "boolean", default: true })
  isActive: boolean;

  @OneToMany(() => District, (district) => district.governorate)
  districts: District[];
}
