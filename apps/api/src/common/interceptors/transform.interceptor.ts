import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from "@nestjs/common";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";
import { ApiResponse } from "@qatfa/shared-types";
import * as crypto from "crypto";

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
    const request = ctx.getRequest();
    const response = ctx.getResponse();
    const statusCode = response.statusCode || 200;

    return next.handle().pipe(
      map((result) => {
        let finalResponse: ApiResponse<T>;

        // إذا كانت الاستجابة مسبقة التشكيل
        if (result && typeof result === "object" && "success" in result) {
          finalResponse = result;
        } else if (
          result &&
          typeof result === "object" &&
          "data" in result
        ) {
          finalResponse = {
            success: true,
            statusCode,
            message: result.message || "تمت العملية بنجاح",
            data: result.data,
            meta: result.meta,
            pagination: result.pagination,
            error: null,
          };
        } else {
          finalResponse = {
            success: true,
            statusCode,
            message: "تمت العملية بنجاح",
            data: result ?? null,
            error: null,
          };
        }

        // توليد ETag للطلبات المشروطة لتمكين كاش فلاتر وتوفير 100% من حجم النقل عند عدم التغير
        if (
          request.method === "GET" &&
          statusCode === 200 &&
          finalResponse.data !== undefined &&
          finalResponse.data !== null
        ) {
          try {
            const serialized = JSON.stringify(finalResponse.data);
            const etag = crypto
              .createHash("md5")
              .update(serialized)
              .digest("hex");
            const clientEtag = request.headers["if-none-match"];

            response.header("ETag", `"${etag}"`);
            response.header(
              "Cache-Control",
              "public, max-age=30, stale-while-revalidate=60",
            );

            if (
              clientEtag &&
              (clientEtag === `"${etag}"` ||
                clientEtag === etag ||
                clientEtag === `W/"${etag}"`)
            ) {
              response.status(304);
              return null as any;
            }
          } catch {
            // الاستمرار في حال فشل التجزئة
          }
        }

        return finalResponse;
      }),
    );
  }
}
