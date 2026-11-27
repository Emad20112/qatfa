import {
  Controller,
  Post,
  Get,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
} from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";
import { AuthService } from "./auth.service";
import { RequestOtpDto, VerifyOtpDto } from "./dto/auth.dto";
import { Public } from "../../common/decorators/roles.decorator";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { User } from "../../database/entities/user.entity";

@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post("request-otp")
  @HttpCode(HttpStatus.OK)
  async requestOtp(@Body() dto: RequestOtpDto) {
    const result = await this.authService.requestOtp(dto.phoneNumber, dto.fullName);
    return {
      message: "تم إرسال رمز التحقق بنجاح",
      data: result,
    };
  }

  // دعم مسار بديل متوافق مع api_endpoints في تطبيقات الجوال
  @Public()
  @Post("otp/request")
  @HttpCode(HttpStatus.OK)
  async requestOtpAlias(@Body() dto: RequestOtpDto) {
    return this.requestOtp(dto);
  }

  @Public()
  @Post("verify-otp")
  @HttpCode(HttpStatus.OK)
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    const result = await this.authService.verifyOtp(
      dto.phoneNumber,
      dto.code,
      dto.fullName,
    );
    return {
      message: "تم التحقق وتسجيل الدخول بنجاح",
      data: result,
    };
  }

  // دعم مسار بديل متوافق مع api_endpoints في تطبيقات الجوال
  @Public()
  @Post("otp/verify")
  @HttpCode(HttpStatus.OK)
  async verifyOtpAlias(@Body() dto: VerifyOtpDto) {
    return this.verifyOtp(dto);
  }

  @Public()
  @Get("otp-logs")
  getOtpLogs() {
    return {
      message: "سجل رموز التحقق اللحظي",
      data: this.authService.getOtpLogs(),
    };
  }

  @UseGuards(AuthGuard("jwt"))
  @Get("me")
  async getMe(@CurrentUser() user: User) {
    const fullUser = await this.authService.getMe(user.id);
    return {
      message: "بيانات المستخدم الحالي",
      data: fullUser,
    };
  }
}
