import { Controller, Post, Body, HttpCode, HttpStatus } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { RequestOtpDto, VerifyOtpDto } from "./dto/auth.dto";
import { Public } from "../../common/decorators/roles.decorator";

@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post("request-otp")
  @HttpCode(HttpStatus.OK)
  async requestOtp(@Body() dto: RequestOtpDto) {
    const result = await this.authService.requestOtp(dto.phoneNumber);
    return {
      message: "تم إرسال رمز التحقق بنجاح",
      data: result,
    };
  }

  @Public()
  @Post("verify-otp")
  @HttpCode(HttpStatus.OK)
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    const result = await this.authService.verifyOtp(dto.phoneNumber, dto.code);
    return {
      message: "تم التحقق وتسجيل الدخول بنجاح",
      data: result,
    };
  }
}
