import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from "@nestjs/common";
import { ApiResponse } from "@qatfa/shared-types";

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = "حدث خطأ داخلي في الخادم، يرجى المحاولة لاحقاً";
    let errorDetail: any = null;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const res = exception.getResponse();
      if (typeof res === "string") {
        message = res;
      } else if (typeof res === "object" && res !== null) {
        message = (res as any).message || message;
        errorDetail = (res as any).error || null;
      }
    } else if (exception instanceof Error) {
      this.logger.error(
        `Unhandled Exception at ${request.url}: ${exception.message}`,
        exception.stack,
      );
    }

    const payload: ApiResponse<null> = {
      success: false,
      statusCode: status,
      message: Array.isArray(message) ? message.join("، ") : message,
      data: null,
      error:
        errorDetail ||
        (exception instanceof Error ? exception.name : "INTERNAL_SERVER_ERROR"),
    };

    response.status(status).send(payload);
  }
}
