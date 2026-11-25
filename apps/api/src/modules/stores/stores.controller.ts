import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";
import { StoresService } from "./stores.service";
import { Public } from "../../common/decorators/roles.decorator";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { User } from "../../database/entities/user.entity";

@Controller("stores")
export class StoresController {
  constructor(private readonly storesService: StoresService) {}

  @Public()
  @Get()
  async getStores(@Query() query: any) {
    return this.storesService.findAll(query);
  }

  @Public()
  @Get(":idOrSlug")
  async getStoreDetail(@Param("idOrSlug") idOrSlug: string) {
    return this.storesService.findBySlugOrId(idOrSlug);
  }

  @UseGuards(AuthGuard("jwt"))
  @Post()
  async createStore(@CurrentUser() user: User, @Body() body: any) {
    return this.storesService.createStore(user.id, body);
  }

  @UseGuards(AuthGuard("jwt"))
  @Patch("my-store")
  async updateMyStore(@CurrentUser() user: User, @Body() body: any) {
    return this.storesService.updateMyStore(user.id, body);
  }
}
