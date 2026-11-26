import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from "typeorm";
import { District } from "./district.entity";
import { Store } from "./store.entity";

@Entity("markets")
@Index(["districtId", "isActive"])
export class Market {
  @PrimaryGeneratedColumn("increment")
  id: number;

  @Column({ name: "district_id", type: "int" })
  districtId: number;

  @ManyToOne(() => District, (district) => district.markets, {
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "district_id" })
  district: District;

  @Column({ name: "name_ar", type: "varchar", length: 150 })
  nameAr: string;

  @Column({ name: "name_en", type: "varchar", length: 150, nullable: true })
  nameEn: string;

  @Column({ type: "decimal", precision: 10, scale: 7, nullable: true })
  centerLatitude: number;

  @Column({ type: "decimal", precision: 10, scale: 7, nullable: true })
  centerLongitude: number;

  @Column({ name: "boundary_polygon", type: "text", nullable: true })
  boundaryPolygon: string;

  @Column({ name: "is_active", type: "boolean", default: true })
  isActive: boolean;

  @OneToMany(() => Store, (store) => store.market)
  stores: Store[];
}
