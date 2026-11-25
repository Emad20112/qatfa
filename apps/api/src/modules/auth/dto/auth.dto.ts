import { IsNotEmpty, IsString, Matches } from "class-validator";

export class RequestOtpDto {
  @IsNotEmpty({ message: "رقم الهاتف مطلوب" })
  @IsString()
  @Matches(/^(\+967)?(77|78|73|71|70)[0-9]{7}$/, {
    message: "يرجى إدخال رقم هاتف يمني صحيح (مثال: +967771234567 أو 771234567)",
  })
  phoneNumber: string;
}

export class VerifyOtpDto {
  @IsNotEmpty({ message: "رقم الهاتف مطلوب" })
  @IsString()
  phoneNumber: string;

  @IsNotEmpty({ message: "رمز التحقق مطلوب" })
  @IsString()
  code: string;
}
