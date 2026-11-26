import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsArray,
  Min,
} from "class-validator";
import { Currency, PriceUnit, QualityGrade } from "@qatfa/shared-types";

export class CreateProductDto {
  @IsNotEmpty({ message: "عنوان القطفة مطلوب" })
  @IsString()
  title: string;

  @IsNotEmpty({ message: "نوع القات مطلوب" })
  @IsString()
  qatType: string;

  @IsOptional()
  @IsEnum(QualityGrade)
  qualityGrade?: QualityGrade = QualityGrade.RUOOS;

  @IsNotEmpty({ message: "السعر مطلوب" })
  @IsNumber({}, { message: "السعر يجب أن يكون رقماً" })
  @Min(100, { message: "السعر يجب ألا يقل عن 100 ريال" })
  price: number;

  @IsOptional()
  @IsEnum(Currency)
  currency?: Currency = Currency.YER_OLD;

  @IsOptional()
  @IsEnum(PriceUnit)
  priceUnit?: PriceUnit = PriceUnit.HABBAH;

  @IsOptional()
  @IsNumber()
  stockQuantity?: number = 1;

  @IsOptional()
  @IsString()
  harvestRegion?: string;

  @IsOptional()
  @IsString()
  harvestTime?: string;

  @IsOptional()
  @IsArray()
  images?: string[];

  @IsOptional()
  @IsString()
  blurHash?: string;
}
