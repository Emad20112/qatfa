import { Controller, Get, Post, Body, Query, UseGuards } from "@nestjs/common";
import { StorageService } from "./storage.service";
import { Public } from "../../common/decorators/roles.decorator";
import { AuthGuard } from "@nestjs/passport";
import { ApiTags, ApiOperation, ApiBearerAuth } from "@nestjs/swagger";

export class PresignUploadDto {
  filename: string;
  contentType?: string;
  folder?: "products" | "stores" | "avatars" | "documents";
}

@ApiTags("Storage (Cloudflare R2)")
@Controller("storage")
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Public()
  @Get("status")
  @ApiOperation({
    summary: "التحقق من حالة اتصال التخزين السحابي Cloudflare R2",
  })
  getStatus() {
    return this.storageService.getStorageStatus();
  }

  @Post("presign-upload")
  @UseGuards(AuthGuard("jwt"))
  @ApiBearerAuth()
  @ApiOperation({
    summary: "توليد رابط رفع مباشر موقع لـ Cloudflare R2 بدون وسيط",
  })
  async presignUpload(@Body() body: PresignUploadDto) {
    return this.storageService.createPresignedUploadUrl(
      body.filename || "image.webp",
      body.contentType || "image/webp",
      body.folder || "products",
    );
  }
}
