import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from "@nestjs/common";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";
import { ApiResponse } from "@qatfa/shared-types";

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<
  T,
  ApiResponse<T>
> {
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<ApiResponse<T>> {
    const ctx = context.switchToHttp();
    const response = ctx.getResponse();
    const statusCode = response.statusCode || 200;

    return next.handle().pipe(
      map((result) => {
        // إذا كانت الاستجابة مسبقة التشكيل
        if (result && typeof result === "object" && "success" in result) {
          return result;
        }

        // إذا كانت النتيجة تحتوي على بيانات وتقسيم صفحات meta
        if (
          result &&
          typeof result === "object" &&
          "data" in result &&
          "meta" in result
        ) {
          return {
            success: true,
            statusCode,
            message: result.message || "تمت العملية بنجاح",
            data: result.data,
            meta: result.meta,
            error: null,
          };
        }

        return {
          success: true,
          statusCode,
          message: "تمت العملية بنجاح",
          data: result ?? null,
          error: null,
        };
      }),
    );
  }
}
