import { Controller, Get, Patch, Body, UseGuards } from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";
import { UsersService } from "./users.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { User } from "../../database/entities/user.entity";

@Controller("users")
@UseGuards(AuthGuard("jwt"))
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get("me")
  async getProfile(@CurrentUser() user: User) {
    return this.usersService.findById(user.id);
  }

  @Patch("me")
  async updateProfile(@CurrentUser() user: User, @Body() body: any) {
    const allowed = {
      fullName: body.fullName,
      avatarUrl: body.avatarUrl,
      governorateId: body.governorateId,
      fcmToken: body.fcmToken,
    };
    return this.usersService.updateProfile(user.id, allowed);
  }
}
