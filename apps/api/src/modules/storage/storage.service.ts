import { Injectable, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "crypto";

export interface PresignedUploadResponse {
  uploadUrl: string;
  publicUrl: string;
  key: string;
  expiresInSeconds: number;
}

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);
  private s3Client: S3Client | null = null;
  private readonly bucketName: string;
  private readonly publicBaseUrl: string;
  private readonly isConfigured: boolean;

  constructor(private readonly configService: ConfigService) {
    const accountId = this.configService.get<string>("R2_ACCOUNT_ID");
    const accessKeyId = this.configService.get<string>("R2_ACCESS_KEY_ID");
    const secretAccessKey = this.configService.get<string>(
      "R2_SECRET_ACCESS_KEY",
    );
    this.bucketName = this.configService.get<string>(
      "R2_BUCKET_NAME",
      "qatfa-media",
    );
    this.publicBaseUrl = this.configService
      .get<string>("R2_PUBLIC_URL", "https://cdn.qatfa.ye")
      .replace(/\/$/, "");

    if (accountId && accessKeyId && secretAccessKey) {
      try {
        const endpoint = `https://${accountId}.r2.cloudflarestorage.com`;
        this.s3Client = new S3Client({
          region: "auto",
          endpoint,
          credentials: {
            accessKeyId,
            secretAccessKey,
          },
        });
        this.isConfigured = true;
        this.logger.log(
          `☁️ Cloudflare R2 Storage Service initialized for bucket: ${this.bucketName}`,
        );
      } catch (err: any) {
        this.logger.warn(
          `⚠️ Failed to initialize Cloudflare R2 S3Client: ${err.message}`,
        );
        this.isConfigured = false;
      }
    } else {
      this.isConfigured = false;
      this.logger.warn(
        "⚠️ Cloudflare R2 credentials not fully set — storage running in mock fallback mode",
      );
    }
  }

  /**
   * توليد رابط رفع موقع (Presigned PUT URL)
   * يتيح للموبايل أو لوحة التحكم رفع الصورة مباشرة إلى R2 دون استهلاك موارد الخادم
   */
  async createPresignedUploadUrl(
    filename: string,
    contentType: string = "image/webp",
    folder: "products" | "stores" | "avatars" | "documents" = "products",
    expiresInSeconds: number = 300,
  ): Promise<PresignedUploadResponse> {
    const cleanExt = filename.includes(".")
      ? filename.split(".").pop()?.toLowerCase() || "webp"
      : "webp";
    const fileId = randomUUID();
    const key = `${folder}/${fileId}.${cleanExt}`;
    const publicUrl = `${this.publicBaseUrl}/${key}`;

    if (!this.isConfigured || !this.s3Client) {
      this.logger.log(`[Storage Mock] Generated presigned URL for key: ${key}`);
      return {
        uploadUrl: `${this.publicBaseUrl}/mock-upload/${key}`,
        publicUrl,
        key,
        expiresInSeconds,
      };
    }

    try {
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: key,
        ContentType: contentType,
      });

      const uploadUrl = await getSignedUrl(this.s3Client, command, {
        expiresIn: expiresInSeconds,
      });

      return {
        uploadUrl,
        publicUrl,
        key,
        expiresInSeconds,
      };
    } catch (err: any) {
      this.logger.error(`Failed to generate presigned URL: ${err.message}`);
      return {
        uploadUrl: `${this.publicBaseUrl}/mock-upload/${key}`,
        publicUrl,
        key,
        expiresInSeconds,
      };
    }
  }

  getStorageStatus() {
    return {
      provider: "Cloudflare R2",
      isConfigured: this.isConfigured,
      bucket: this.bucketName,
      publicBaseUrl: this.publicBaseUrl,
    };
  }
}
