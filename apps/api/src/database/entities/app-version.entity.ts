import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  UpdateDateColumn,
} from "typeorm";
import { AppUpdateType } from "@qatfa/shared-types";

@Entity("app_versions")
export class AppVersion {
  @PrimaryGeneratedColumn("increment")
  id: number;

  @Column({ type: "varchar", length: 20, default: "android" })
  platform: string;

  @Column({ name: "latest_version", type: "varchar", length: 20 })
  latestVersion: string;

  @Column({ name: "latest_build_number", type: "int" })
  latestBuildNumber: number;

  @Column({ name: "min_supported_version", type: "varchar", length: 20 })
  minSupportedVersion: string;

  @Column({ name: "min_supported_build_number", type: "int" })
  minSupportedBuildNumber: number;

  @Column({
    name: "update_type",
    type: "varchar",
    length: 20,
    default: AppUpdateType.OPTIONAL,
  })
  updateType: AppUpdateType;

  @Column({ type: "varchar", length: 200 })
  title: string;

  @Column({ name: "release_notes", type: "text" })
  releaseNotes: string;

  @Column({ name: "download_url", type: "varchar", length: 500 })
  downloadUrl: string;

  @Column({ name: "apk_size_in_bytes", type: "bigint", default: 15000000 })
  apkSizeInBytes: number;

  @Column({ type: "varchar", length: 64, nullable: true })
  sha256: string;

  @Column({
    name: "telegram_channel_url",
    type: "varchar",
    length: 500,
    nullable: true,
  })
  telegramChannelUrl: string;

  @Column({
    name: "telegram_post_url",
    type: "varchar",
    length: 500,
    nullable: true,
  })
  telegramPostUrl: string;

  @Column({
    name: "play_store_url",
    type: "varchar",
    length: 500,
    nullable: true,
  })
  playStoreUrl: string;

  @Column({ name: "is_active", type: "boolean", default: true })
  isActive: boolean;

  @UpdateDateColumn({ name: "updated_at", type: "timestamptz" })
  updatedAt: Date;
}
